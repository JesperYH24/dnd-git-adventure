# Outer-wall wilderness exploration. This is intentionally lighter than dungeon rooms:
# hidden positions, persistent landmarks, camp safety, and awareness before combat.

function Get-MonsterZoneDefaultState {
    return @{
        CurrentX = 0
        CurrentY = 0
        Visits = 0
        DiscoveredLandmarks = @{}
        LandmarkMemory = @{}
        MilestoneXP = @{}
        Camps = @{}
        Oddities = @()
        DefeatedCreatures = @{}
        ReportedCreaturesToDorr = @{}
        PendingRingMonsterContracts = @{}
        CompletedRingMonsterContracts = @{}
        LastTravelText = ""
    }
}

function Initialize-MonsterZoneState {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    if ($null -eq $Game.Town.MonsterZone) {
        $Game.Town.MonsterZone = Get-MonsterZoneDefaultState
    }

    foreach ($entry in @(
        @{ Key = "CurrentX"; Value = 0 },
        @{ Key = "CurrentY"; Value = 0 },
        @{ Key = "Visits"; Value = 0 },
        @{ Key = "DiscoveredLandmarks"; Value = @{} },
        @{ Key = "LandmarkMemory"; Value = @{} },
        @{ Key = "MilestoneXP"; Value = @{} },
        @{ Key = "Camps"; Value = @{} },
        @{ Key = "Oddities"; Value = @() },
        @{ Key = "DefeatedCreatures"; Value = @{} },
        @{ Key = "ReportedCreaturesToDorr"; Value = @{} },
        @{ Key = "PendingRingMonsterContracts"; Value = @{} },
        @{ Key = "CompletedRingMonsterContracts"; Value = @{} },
        @{ Key = "LastTravelText"; Value = "" }
    )) {
        if (-not $Game.Town.MonsterZone.ContainsKey($entry.Key) -or $null -eq $Game.Town.MonsterZone[$entry.Key]) {
            $Game.Town.MonsterZone[$entry.Key] = $entry.Value
        }
    }
}

function Test-MonsterZoneUnlocked {
    param($Game)

    return ($null -ne $Game -and
        $null -ne $Game.Town -and
        $null -ne $Game.Town.StoryFlags -and
        [bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"])
}

function Grant-MonsterZoneMilestoneXP {
    param(
        $Game,
        [string]$Key,
        [int]$XP,
        [string]$Reason
    )

    Initialize-MonsterZoneState -Game $Game

    if ($null -eq $Game -or $null -eq $Game.Hero -or [string]::IsNullOrWhiteSpace($Key) -or $XP -le 0) {
        return [PSCustomObject]@{
            Awarded = $false
            XP = 0
            Message = ""
        }
    }

    if ([bool]$Game.Town.MonsterZone.MilestoneXP[$Key]) {
        return [PSCustomObject]@{
            Awarded = $false
            XP = 0
            Message = ""
        }
    }

    $Game.Town.MonsterZone.MilestoneXP[$Key] = $true
    Grant-HeroXP -Hero $Game.Hero -XP $XP

    $message = if ([string]::IsNullOrWhiteSpace($Reason)) {
        "$($Game.Hero.Name) gains $XP XP from monster-zone progress."
    }
    else {
        "$($Game.Hero.Name) gains $XP XP: $Reason."
    }

    return [PSCustomObject]@{
        Awarded = $true
        XP = $XP
        Message = $message
    }
}

function Get-MonsterZoneProgressionState {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    $defeatedTypes = @($Game.Town.MonsterZone.DefeatedCreatures.Keys).Count
    $reportedTypes = @($Game.Town.MonsterZone.ReportedCreaturesToDorr.Keys).Count
    $discoveredLandmarks = @($Game.Town.MonsterZone.DiscoveredLandmarks.Keys).Count
    $directRoutes = @(Get-MonsterZoneDirectTravelLandmarks -Game $Game).Count
    $completedContracts = @($Game.Town.MonsterZone.CompletedRingMonsterContracts.Keys).Count

    return [PSCustomObject]@{
        DefeatedTypes = $defeatedTypes
        ReportedTypes = $reportedTypes
        DiscoveredLandmarks = $discoveredLandmarks
        DirectRoutes = $directRoutes
        CompletedContracts = $completedContracts
        LevelFiveCapUnlocked = ([int]$Game.Hero.LevelCap -ge 5)
        LevelSixCapUnlocked = ([int]$Game.Hero.LevelCap -ge 6)
        LevelSixReady = ($defeatedTypes -ge 3 -and $reportedTypes -ge 2 -and $discoveredLandmarks -ge 4 -and ($directRoutes -ge 1 -or $completedContracts -ge 1))
    }
}

function Get-MonsterZoneProgressionSummaryText {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    if (-not [bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"]) {
        return "Monster-zone progression: locked until the outer-wall rumors begin."
    }

    $state = Get-MonsterZoneProgressionState -Game $Game

    if ([int]$Game.Hero.LevelCap -lt 6) {
        $routeProgress = if ([int]$state.DirectRoutes -gt 0 -or [int]$state.CompletedContracts -gt 0) { "1/1" } else { "0/1" }
        return "Level 6 proof: landmarks $([Math]::Min([int]$state.DiscoveredLandmarks, 4))/4 | defeated types $([Math]::Min([int]$state.DefeatedTypes, 3))/3 | Dorr reports $([Math]::Min([int]$state.ReportedTypes, 2))/2 | route/contract $routeProgress."
    }

    if ([int]$Game.Hero.Level -lt 6) {
        $nextXP = Get-XPThresholdForLevel -Level 6
        return "Level 6 cap open: reach $nextXP XP and take a long rest. Current XP: $($Game.Hero.XP)/$nextXP."
    }

    if (-not [bool]$Game.Town.StoryFlags["LevelSixGateDefenseCompleted"]) {
        return "Level 6 reached: long rest will draw the first organized gate-defense assault."
    }

    return "Level 6 gate defense complete: the wall held, and the city knows who stood there."
}

function Write-MonsterZoneProgressionStatus {
    param($Game)

    Write-EmphasisLine -Text (Get-MonsterZoneProgressionSummaryText -Game $Game) -Color "DarkCyan"
}

function Update-MonsterZoneLevelProgression {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    $messages = @()
    $state = Get-MonsterZoneProgressionState -Game $Game

    if ([bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"]) {
        if ([int]$Game.Hero.LevelCap -lt 5) {
            $Game.Hero.LevelCap = 5
            $messages += "Monster-zone progression: level cap raised to 5."
        }
        $Game.Town.StoryFlags["MonsterZoneLevelFiveCapUnlocked"] = $true
    }

    if ($state.LevelSixReady) {
        if ([int]$Game.Hero.LevelCap -lt 6) {
            $Game.Hero.LevelCap = 6
            $xp = Grant-MonsterZoneMilestoneXP -Game $Game -Key "level_cap_6_wall_pattern" -XP 600 -Reason "the Wall Watch has enough landmarks, monster trails, and routes to treat the attacks as a campaign"
            $messages += "Monster-zone progression: level cap raised to 6."
            if ($xp.Awarded) {
                $messages += $xp.Message
            }
        }
        $Game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] = $true
    }

    return [PSCustomObject]@{
        Changed = ($messages.Count -gt 0)
        Messages = $messages
        State = (Get-MonsterZoneProgressionState -Game $Game)
    }
}

function Write-MonsterZoneProgressionMessages {
    param($Game)

    $progression = Update-MonsterZoneLevelProgression -Game $Game

    foreach ($message in @($progression.Messages)) {
        Write-EmphasisLine -Text $message -Color "Green"
    }

    return $progression
}

function Get-MonsterZonePositionKey {
    param(
        [int]$X,
        [int]$Y
    )

    return "$X,$Y"
}

function Get-MonsterZoneLandmarks {
    return @(
        [PSCustomObject]@{
            Id = "old_mile_shrine"
            Name = "Old Mile Shrine"
            X = 0
            Y = 1
            FirstVisitText = "A waist-high shrine leans beside the old road, its saint's face scraped nearly smooth by weather. Someone has tied fresh blue thread around the base since the wall rumors began."
            RepeatVisitText = "The Old Mile Shrine still leans into the wind. The blue thread has picked up road dust, but no one has dared remove it."
            DangerLevel = 1
        }
        [PSCustomObject]@{
            Id = "collapsed_watchtower"
            Name = "Collapsed Watchtower"
            X = 1
            Y = 1
            FirstVisitText = "A watchtower lies folded into its own foundation. Claw marks scar stones that should have been too high for any ordinary beast."
            RepeatVisitText = "The Collapsed Watchtower gives a clean view back to the city wall and an uglier view of how far the patrol lights do not reach."
            DangerLevel = 2
        }
        [PSCustomObject]@{
            Id = "burned_orchard"
            Name = "Burned Orchard"
            X = -1
            Y = 0
            FirstVisitText = "Black fruit trees stand in stiff rows, burned without spreading flame to the grass between them. The pattern feels chosen."
            RepeatVisitText = "The Burned Orchard remains too orderly, its rows of dead trees pointing toward the city like accusing fingers."
            DangerLevel = 2
        }
        [PSCustomObject]@{
            Id = "dry_creek_bed"
            Name = "Dry Creek Bed"
            X = 0
            Y = 2
            FirstVisitText = "A dry creek bed cuts pale stone through the grass. Tracks collect here: paws, boots, split hooves, and one dragging line too wide to name yet."
            RepeatVisitText = "The Dry Creek Bed still gathers tracks like a ledger gathers debts. New marks cross old ones every time the wind drops."
            DangerLevel = 2
        }
        [PSCustomObject]@{
            Id = "hunters_cairn"
            Name = "Hunter's Cairn"
            X = -2
            Y = 1
            FirstVisitText = "A cairn of flat stones marks where hunters used to leave thanks before entering the scrubland. Several stones are overturned, but not scattered."
            RepeatVisitText = "The Hunter's Cairn waits in the scrub. The overturned stones have not moved, which somehow makes them worse."
            DangerLevel = 2
        }
        [PSCustomObject]@{
            Id = "blackened_scale_hollow"
            Name = "Blackened Scale Hollow"
            X = 2
            Y = 1
            FirstVisitText = "A shallow hollow smells of iron, ash, and wet hide. Black flakes cling to the soil like shed scale."
            RepeatVisitText = "The Blackened Scale Hollow has not lost its smell. The soil still looks touched by something hot from beneath the skin."
            DangerLevel = 3
        }
        [PSCustomObject]@{
            Id = "survey_camp"
            Name = "Abandoned Survey Camp"
            X = 1
            Y = 2
            FirstVisitText = "Survey stakes and a torn canvas lean around a cold fire pit. The map board is gone, but the pins were pulled in a hurry."
            RepeatVisitText = "The Abandoned Survey Camp flaps quietly in the wind. It still feels like someone meant to come back and then learned better."
            DangerLevel = 2
        }
        [PSCustomObject]@{
            Id = "boundary_stones"
            Name = "Ancient Boundary Stones"
            X = -1
            Y = 2
            FirstVisitText = "Old boundary stones rise from the grass in a broken line. Their runes are older than the city charter, and several have been freshly cracked."
            RepeatVisitText = "The Ancient Boundary Stones keep their broken line. Whatever cracked them did not bother finishing the work."
            DangerLevel = 3
        }
    )
}

function Get-MonsterZoneLandmarkAtPosition {
    param(
        [int]$X,
        [int]$Y
    )

    return (Get-MonsterZoneLandmarks | Where-Object { [int]$_.X -eq $X -and [int]$_.Y -eq $Y } | Select-Object -First 1)
}

function Get-MonsterZoneDirectTravelThreshold {
    return 3
}

function Get-MonsterZoneLandmarkMemoryRecord {
    param(
        $Game,
        [string]$LandmarkId
    )

    Initialize-MonsterZoneState -Game $Game

    if ([string]::IsNullOrWhiteSpace($LandmarkId)) {
        return $null
    }

    if (-not $Game.Town.MonsterZone.LandmarkMemory.ContainsKey($LandmarkId) -or $null -eq $Game.Town.MonsterZone.LandmarkMemory[$LandmarkId]) {
        $Game.Town.MonsterZone.LandmarkMemory[$LandmarkId] = @{
            VisitDays = @()
            Familiarity = 0
            FirstVisitDay = 0
            LastVisitDay = 0
            DirectTravelUnlocked = $false
        }
    }

    $record = $Game.Town.MonsterZone.LandmarkMemory[$LandmarkId]

    if (-not $record.ContainsKey("VisitDays") -or $null -eq $record["VisitDays"]) {
        $record["VisitDays"] = @()
    }
    if (-not $record.ContainsKey("Familiarity") -or $null -eq $record["Familiarity"]) {
        $record["Familiarity"] = @($record["VisitDays"]).Count
    }
    if (-not $record.ContainsKey("DirectTravelUnlocked") -or $null -eq $record["DirectTravelUnlocked"]) {
        $record["DirectTravelUnlocked"] = $false
    }
    if (-not $record.ContainsKey("FirstVisitDay") -or $null -eq $record["FirstVisitDay"]) {
        $record["FirstVisitDay"] = 0
    }
    if (-not $record.ContainsKey("LastVisitDay") -or $null -eq $record["LastVisitDay"]) {
        $record["LastVisitDay"] = 0
    }

    return $record
}

function Get-MonsterZoneLandmarkFamiliarity {
    param(
        $Game,
        [string]$LandmarkId
    )

    $record = Get-MonsterZoneLandmarkMemoryRecord -Game $Game -LandmarkId $LandmarkId

    if ($null -eq $record) {
        return 0
    }

    return [int]$record["Familiarity"]
}

function Update-MonsterZoneLandmarkMemory {
    param(
        $Game,
        $Landmark
    )

    Initialize-MonsterZoneState -Game $Game

    if ($null -eq $Landmark) {
        return [PSCustomObject]@{
            Familiarity = 0
            FamiliarityGained = $false
            DirectTravelUnlocked = $false
            DirectTravelJustUnlocked = $false
            Text = ""
        }
    }

    $day = if ($null -ne $Game.Town.DayNumber) { [int]$Game.Town.DayNumber } else { 1 }
    $record = Get-MonsterZoneLandmarkMemoryRecord -Game $Game -LandmarkId ([string]$Landmark.Id)
    $visitDays = @($record["VisitDays"] | ForEach-Object { [int]$_ })
    $hadDay = $visitDays -contains $day
    $wasDirect = [bool]$record["DirectTravelUnlocked"]

    if (-not $hadDay) {
        $visitDays += $day
        $record["VisitDays"] = @($visitDays | Sort-Object -Unique)
        if ([int]$record["FirstVisitDay"] -le 0) {
            $record["FirstVisitDay"] = $day
        }
        $record["LastVisitDay"] = $day
    }

    $record["Familiarity"] = @($record["VisitDays"]).Count
    $record["DirectTravelUnlocked"] = ([int]$record["Familiarity"] -ge (Get-MonsterZoneDirectTravelThreshold))

    $text = ""

    if (-not $hadDay) {
        if ([bool]$record["DirectTravelUnlocked"] -and -not $wasDirect) {
            $text = "$($Game.Hero.Name) knows the route to $($Landmark.Name) well enough now to travel there directly from the outer gate."
        }
        elseif ([int]$record["Familiarity"] -gt 1) {
            $text = "$($Game.Hero.Name) recognizes more of the route to $($Landmark.Name). Next time, the place will be easier to find."
        }
    }

    return [PSCustomObject]@{
        Familiarity = [int]$record["Familiarity"]
        FamiliarityGained = (-not $hadDay)
        DirectTravelUnlocked = [bool]$record["DirectTravelUnlocked"]
        DirectTravelJustUnlocked = ([bool]$record["DirectTravelUnlocked"] -and -not $wasDirect)
        Text = $text
    }
}

function Test-MonsterZoneLandmarkDirectTravelUnlocked {
    param(
        $Game,
        $Landmark
    )

    if ($null -eq $Landmark) {
        return $false
    }

    $record = Get-MonsterZoneLandmarkMemoryRecord -Game $Game -LandmarkId ([string]$Landmark.Id)
    return ($null -ne $record -and [bool]$record["DirectTravelUnlocked"])
}

function Get-MonsterZoneDirectTravelLandmarks {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    return @(Get-MonsterZoneLandmarks | Where-Object { Test-MonsterZoneLandmarkDirectTravelUnlocked -Game $Game -Landmark $_ })
}

function Move-MonsterZoneToLandmark {
    param(
        $Game,
        $Landmark
    )

    Initialize-MonsterZoneState -Game $Game

    if ($null -eq $Landmark) {
        return [PSCustomObject]@{
            Success = $false
            Message = "Choose a known landmark."
        }
    }

    if (-not (Test-MonsterZoneLandmarkDirectTravelUnlocked -Game $Game -Landmark $Landmark)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Game.Hero.Name) does not know the route to $($Landmark.Name) well enough to travel there directly yet."
            Landmark = $Landmark
        }
    }

    $Game.Town.MonsterZone.CurrentX = [int]$Landmark.X
    $Game.Town.MonsterZone.CurrentY = [int]$Landmark.Y
    $Game.Town.MonsterZone.Visits = [int]$Game.Town.MonsterZone.Visits + 1

    return [PSCustomObject]@{
        Success = $true
        Message = "$($Game.Hero.Name) leaves the outer gate by a route now familiar enough to trust, reaching $($Landmark.Name) without wandering the scrub first."
        X = [int]$Landmark.X
        Y = [int]$Landmark.Y
        Landmark = $Landmark
    }
}

function Get-MonsterZoneLocationText {
    param($Game)

    Initialize-MonsterZoneState -Game $Game
    $x = [int]$Game.Town.MonsterZone.CurrentX
    $y = [int]$Game.Town.MonsterZone.CurrentY

    if ($x -eq 0 -and $y -eq 0) {
        return "Outer Gate Approach"
    }

    $landmark = Get-MonsterZoneLandmarkAtPosition -X $x -Y $y

    if ($null -ne $landmark) {
        return $landmark.Name
    }

    return "Open Scrubland ($x,$y)"
}

function Move-MonsterZonePosition {
    param(
        $Game,
        [string]$Direction
    )

    Initialize-MonsterZoneState -Game $Game

    $dx = 0
    $dy = 0

    switch ($Direction.ToLower()) {
        "north" { $dy = 1 }
        "south" { $dy = -1 }
        "east" { $dx = 1 }
        "west" { $dx = -1 }
        default {
            return [PSCustomObject]@{
                Success = $false
                Edge = $false
                Message = "Choose north, east, south, or west."
            }
        }
    }

    $newX = [int]$Game.Town.MonsterZone.CurrentX + $dx
    $newY = [int]$Game.Town.MonsterZone.CurrentY + $dy

    if ([Math]::Abs($newX) -gt 2 -or $newY -lt 0 -or $newY -gt 2) {
        return [PSCustomObject]@{
            Success = $false
            Edge = $true
            Message = "The patrol markers thin out until even the road sounds vanish. Going farther would mean leaving the city's reach entirely, and this first push beyond the wall is not ready for that risk."
            X = [int]$Game.Town.MonsterZone.CurrentX
            Y = [int]$Game.Town.MonsterZone.CurrentY
        }
    }

    $Game.Town.MonsterZone.CurrentX = $newX
    $Game.Town.MonsterZone.CurrentY = $newY
    $Game.Town.MonsterZone.Visits = [int]$Game.Town.MonsterZone.Visits + 1

    return [PSCustomObject]@{
        Success = $true
        Edge = $false
        Message = "The city wall falls farther behind as $($Game.Hero.Name) travels $Direction."
        X = $newX
        Y = $newY
        Landmark = Get-MonsterZoneLandmarkAtPosition -X $newX -Y $newY
    }
}

function Discover-MonsterZoneLandmark {
    param(
        $Game,
        $Landmark
    )

    Initialize-MonsterZoneState -Game $Game

    if ($null -eq $Landmark) {
        return [PSCustomObject]@{
            Discovered = $false
            Text = "Low scrub, old grass, and broken road-stone stretch around $($Game.Hero.Name). Nothing here has a name yet."
        }
    }

    $alreadyDiscovered = [bool]$Game.Town.MonsterZone.DiscoveredLandmarks[$Landmark.Id]
    $Game.Town.MonsterZone.DiscoveredLandmarks[$Landmark.Id] = $true
    $memory = Update-MonsterZoneLandmarkMemory -Game $Game -Landmark $Landmark
    $text = if ($alreadyDiscovered) { $Landmark.RepeatVisitText } else { $Landmark.FirstVisitText }

    if (-not [string]::IsNullOrWhiteSpace($memory.Text)) {
        $text = "$text $($memory.Text)"
    }

    if (-not $alreadyDiscovered) {
        $xp = Grant-MonsterZoneMilestoneXP -Game $Game -Key "landmark_discovered_$($Landmark.Id)" -XP 120 -Reason "$($Landmark.Name) recorded for the outer-wall map"
        if ($xp.Awarded) {
            $text = "$text $($xp.Message)"
        }
    }

    if ($memory.DirectTravelJustUnlocked) {
        $xp = Grant-MonsterZoneMilestoneXP -Game $Game -Key "landmark_route_$($Landmark.Id)" -XP 180 -Reason "a reliable route to $($Landmark.Name) is now known"
        if ($xp.Awarded) {
            $text = "$text $($xp.Message)"
        }
    }

    $progression = Update-MonsterZoneLevelProgression -Game $Game
    foreach ($message in @($progression.Messages)) {
        $text = "$text $message"
    }

    return [PSCustomObject]@{
        Discovered = (-not $alreadyDiscovered)
        Landmark = $Landmark
        Familiarity = $memory.Familiarity
        FamiliarityGained = $memory.FamiliarityGained
        DirectTravelUnlocked = $memory.DirectTravelUnlocked
        DirectTravelJustUnlocked = $memory.DirectTravelJustUnlocked
        Text = $text
    }
}

function Get-MonsterZoneClassReadLines {
    param(
        $Hero,
        $Landmark = $null,
        $Creature = $null,
        [string]$Context = "Search"
    )

    if ($null -eq $Hero) {
        return @()
    }

    $class = [string]$Hero.Class
    $placeName = if ($null -ne $Landmark) { [string]$Landmark.Name } else { "the scrubland" }
    $creatureName = if ($null -ne $Creature) { [string]$Creature.definite } else { "the threat" }

    switch ($class) {
        "Barbarian" {
            if ($Context -eq "Observation") {
                return @("$($Hero.Name) reads $creatureName in the body first: weight in the shoulders, hunger in the breath, and the ugly promise of where the charge will land.")
            }

            return @("$($Hero.Name) reads $placeName through boot pressure, broken stems, and the old animal warning that lives below thought.")
        }
        "Bard" {
            if ($Context -eq "Observation") {
                return @("$($Hero.Name) listens for the rhythm around ${creatureName}: pauses too regular to be chance, breath too sharp for calm, and a story in the sounds it refuses to make.")
            }

            return @("$($Hero.Name) reads $placeName like a half-remembered verse: odd silences, local superstition, and the places where a frightened witness would leave something unsaid.")
        }
        "Fighter" {
            if ($Context -eq "Observation") {
                return @("$($Hero.Name) studies $creatureName like an opponent at the lists: first step, recovery angle, attack line, and how quickly it could threaten the wall road.")
            }

            return @("$($Hero.Name) reads $placeName in patrol terms: sightlines, retreat lanes, broken markers, and where a disciplined watch would have made its stand.")
        }
        default {
            if ($Context -eq "Observation") {
                return @("$($Hero.Name) keeps still and studies $creatureName for the first clear sign of how it means to attack.")
            }

            return @("$($Hero.Name) studies $placeName for tracks, shelter, and the safest way back to the city road.")
        }
    }
}

function Write-MonsterZoneClassRead {
    param(
        $Hero,
        $Landmark = $null,
        $Creature = $null,
        [string]$Context = "Search"
    )

    foreach ($line in (Get-MonsterZoneClassReadLines -Hero $Hero -Landmark $Landmark -Creature $Creature -Context $Context)) {
        Write-Scene $line
    }
}

function Get-HeroWildernessSkillModifier {
    param(
        $Hero,
        [string]$Skill
    )

    $skillProfile = Get-HeroSkillCheckModifier -Hero $Hero -Skill $Skill

    if ($null -ne $skillProfile) {
        return $skillProfile
    }

    return Get-HeroAbilityCheckModifier -Hero $Hero -Ability "WIS" -CheckTag $Skill
}

function New-MonsterZoneCreature {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Article,
        [string]$Definite,
        [int]$HP,
        [int]$XP,
        [int]$ArmorClass,
        [int]$AttackBonus,
        [int]$InitiativeBonus,
        [int]$DamageDiceSides,
        [int]$DamageBonus,
        [int]$PerceptionBonus,
        [int]$StealthBonus,
        [string]$OddityName,
        [int]$OddityValue,
        [string]$IntroText,
        [int]$MinLevelCap = 5,
        [string]$ThreatTier = "Outer Wall",
        [string[]]$SenseTraits = @(),
        [int]$SenseBonus = 0,
        [bool]$CountersInvisibility = $false
    )

    return @{
        id = $Id
        name = $Name
        article = $Article
        definite = $Definite
        hp = $HP
        xp = $XP
        armorClass = $ArmorClass
        attackBonus = $AttackBonus
        wisdomSaveBonus = 0
        initiativeBonus = $InitiativeBonus
        damageDiceCount = 1
        damageDiceSides = $DamageDiceSides
        damageBonus = $DamageBonus
        damageMin = [Math]::Max(1, 1 + $DamageBonus)
        damageMax = [Math]::Max(1, $DamageDiceSides + $DamageBonus)
        encounterChance = 100
        isBoss = $false
        perceptionBonus = $PerceptionBonus
        stealthBonus = $StealthBonus
        minLevelCap = $MinLevelCap
        threatTier = $ThreatTier
        senseTraits = @($SenseTraits)
        senseBonus = $SenseBonus
        countersInvisibility = $CountersInvisibility
        oddityName = $OddityName
        oddityValue = $OddityValue
        introText = $IntroText
    }
}

function Get-MonsterZoneCreatures {
    return @(
        (New-MonsterZoneCreature -Id "wall_wolf" -Name "wall-prowling wolf" -Article "A" -Definite "The Wall-Prowling Wolf" -HP 18 -XP 90 -ArmorClass 13 -AttackBonus 3 -InitiativeBonus 2 -DamageDiceSides 6 -DamageBonus 1 -PerceptionBonus 3 -StealthBonus 3 -OddityName "Smoke-Tainted Pelt" -OddityValue 45 -IntroText "A lean wolf moves low through the grass, its coat darkened by old smoke and its attention fixed too close to the city wall." -MinLevelCap 5 -ThreatTier "Level 4-5 wall pressure" -SenseTraits @("Keen Hearing and Smell") -SenseBonus 2)
        (New-MonsterZoneCreature -Id "razor_boar" -Name "razor-tusk boar" -Article "A" -Definite "The Razor-Tusk Boar" -HP 22 -XP 100 -ArmorClass 12 -AttackBonus 3 -InitiativeBonus 0 -DamageDiceSides 8 -DamageBonus 1 -PerceptionBonus 1 -StealthBonus 0 -OddityName "Razor Boar Tusk" -OddityValue 55 -IntroText "A boar shoulders through the brush, tusks chipped against stone and wet earth flying from its hooves." -MinLevelCap 5 -ThreatTier "Level 4-5 wall pressure" -SenseTraits @("Keen Smell") -SenseBonus 1)
        (New-MonsterZoneCreature -Id "grave_hungry_thing" -Name "grave-hungry thing" -Article "A" -Definite "The Grave-Hungry Thing" -HP 20 -XP 120 -ArmorClass 11 -AttackBonus 2 -InitiativeBonus 1 -DamageDiceSides 6 -DamageBonus 2 -PerceptionBonus 2 -StealthBonus 2 -OddityName "Pale Grave Claw" -OddityValue 70 -IntroText "Something pale and joint-wrong crawls from behind a stone, smelling of old graves and fresh appetite." -MinLevelCap 5 -ThreatTier "Level 4-5 wall pressure" -SenseTraits @("Blindsight") -SenseBonus 3 -CountersInvisibility $true)
        (New-MonsterZoneCreature -Id "kobold_wall_scout" -Name "kobold wall scout" -Article "A" -Definite "The Kobold Wall Scout" -HP 14 -XP 110 -ArmorClass 13 -AttackBonus 3 -InitiativeBonus 3 -DamageDiceSides 6 -DamageBonus 0 -PerceptionBonus 2 -StealthBonus 4 -OddityName "Black-Wax Scout Token" -OddityValue 65 -IntroText "A small scaled scout freezes near a patrol marker, one claw wrapped around a black-waxed token." -MinLevelCap 5 -ThreatTier "Level 4-5 wall pressure")
        (New-MonsterZoneCreature -Id "scale_touched_mastiff" -Name "scale-touched mastiff" -Article "A" -Definite "The Scale-Touched Mastiff" -HP 24 -XP 140 -ArmorClass 13 -AttackBonus 4 -InitiativeBonus 2 -DamageDiceSides 8 -DamageBonus 2 -PerceptionBonus 4 -StealthBonus 1 -OddityName "Black Scale Shard" -OddityValue 90 -IntroText "A mastiff built like a guard dog stalks into view, black scale plates showing through its hide where fur should be." -MinLevelCap 5 -ThreatTier "Level 4-5 wall pressure" -SenseTraits @("Keen Smell") -SenseBonus 2)
        (New-MonsterZoneCreature -Id "ash_horn_drakelet" -Name "ash-horn drakelet" -Article "An" -Definite "The Ash-Horn Drakelet" -HP 32 -XP 240 -ArmorClass 14 -AttackBonus 5 -InitiativeBonus 2 -DamageDiceSides 8 -DamageBonus 3 -PerceptionBonus 3 -StealthBonus 1 -OddityName "Ash-Horn Spur" -OddityValue 145 -IntroText "A low drake-shape drags itself over broken ground, horn nubs smoking as if the skull beneath them remembers fire." -MinLevelCap 5 -ThreatTier "Level 5 draconic pressure" -SenseTraits @("Heat Scent") -SenseBonus 2)
        (New-MonsterZoneCreature -Id "gate_sunder_brute" -Name "gate-sunder brute" -Article "A" -Definite "The Gate-Sunder Brute" -HP 46 -XP 390 -ArmorClass 13 -AttackBonus 6 -InitiativeBonus -1 -DamageDiceSides 10 -DamageBonus 4 -PerceptionBonus 2 -StealthBonus -1 -OddityName "Cracked Gate-Bone" -OddityValue 210 -IntroText "A huge crooked figure lumbers through the dust carrying a gate hinge like a club, its arms marked by black scale scars that have split and healed badly." -MinLevelCap 6 -ThreatTier "Level 6 gate-breaker threat" -SenseTraits @("Blood Scent") -SenseBonus 1)
    )
}

function Get-MonsterZoneAvailableCreatures {
    param($Game)

    $levelCap = if ($null -ne $Game -and $null -ne $Game.Hero -and $null -ne $Game.Hero.LevelCap) { [int]$Game.Hero.LevelCap } else { 5 }
    return @(Get-MonsterZoneCreatures | Where-Object {
        $minLevelCap = if ($null -ne $_.minLevelCap) { [int]$_.minLevelCap } else { 5 }
        $minLevelCap -le $levelCap
    })
}

function Get-RandomMonsterZoneCreature {
    param($Game)

    $available = @(Get-MonsterZoneAvailableCreatures -Game $Game)
    if ($available.Count -le 0) {
        $available = @(Get-MonsterZoneCreatures | Where-Object { [int]$_.minLevelCap -le 5 })
    }

    return ($available | Get-Random)
}

function New-GateDefenseWaveMonster {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Definite,
        [int]$HP,
        [int]$XP,
        [int]$ArmorClass,
        [int]$AttackBonus,
        [int]$InitiativeBonus,
        [int]$DamageDiceSides,
        [int]$DamageBonus,
        [int]$WisdomSaveBonus = 0,
        [int]$DexteritySaveBonus = 0,
        [string]$Intro = ""
    )

    return @{
        id = $Id
        name = $Name
        definite = $Definite
        hp = $HP
        xp = $XP
        armorClass = $ArmorClass
        attackBonus = $AttackBonus
        wisdomSaveBonus = $WisdomSaveBonus
        dexteritySaveBonus = $DexteritySaveBonus
        initiativeBonus = $InitiativeBonus
        damageDiceCount = 1
        damageDiceSides = $DamageDiceSides
        damageBonus = $DamageBonus
        damageMin = [Math]::Max(1, 1 + $DamageBonus)
        damageMax = [Math]::Max(1, $DamageDiceSides + $DamageBonus)
        encounterChance = 100
        isBoss = $false
        intro = $Intro
    }
}

function Get-LevelSixGateDefenseWaves {
    return @(
        [PSCustomObject]@{
            Id = "gate_yard_breach"
            Title = "Wave 1: Gate Yard Breach"
            AllyLine = "Belor and the Guard Station form a shield line under the gate arch. Crossbow crews keep the smaller shapes off the hero while runners drag barricades into place."
            SupportLine = "Temple healers wait behind a cart of clean linen and silver-thread charms, calling out when the wounded can still stand."
            Monster = (New-GateDefenseWaveMonster -Id "scaled_breach_hound" -Name "scaled breach hound" -Definite "The Scaled Breach Hound" -HP 30 -XP 260 -ArmorClass 14 -AttackBonus 5 -InitiativeBonus 2 -DamageDiceSides 8 -DamageBonus 3 -WisdomSaveBonus 1 -DexteritySaveBonus 2 -Intro "A hound-shaped thing hits the barricade low, black scale plates scraping sparks from the cobbles.")
            AllyOpeningDamage = 8
            HealerRestore = 8
            VictoryLine = "The first push breaks against the guard line. Belor shouts for the wall horns to answer in pairs: one breach held, more coming."
        }
        [PSCustomObject]@{
            Id = "champion_countercharge"
            Title = "Wave 2: Champion Countercharge"
            AllyLine = "Two city champions arrive from the tourney ground in dented bright armor, not waiting for heralds. A High Ledger mage burns sigils across the cobbles to split the next charge."
            SupportLine = "The temple circle raises a ward over the wounded. It does not stop fear, but it gives shaking hands enough steadiness to reload."
            Monster = (New-GateDefenseWaveMonster -Id "ash_horn_drakelet" -Name "ash-horn drakelet" -Definite "The Ash-Horn Drakelet" -HP 38 -XP 360 -ArmorClass 14 -AttackBonus 5 -InitiativeBonus 2 -DamageDiceSides 8 -DamageBonus 3 -WisdomSaveBonus 1 -DexteritySaveBonus 2 -Intro "The Ash-Horn Drakelet scrambles over broken stone with smoke threading from its horn nubs, snapping at every spell-light that touches it.")
            AllyOpeningDamage = 10
            HealerRestore = 10
            VictoryLine = "The champions force the drakelet's head down long enough for the line to close. The mage's last sigil cracks, but the street behind it is still standing."
        }
        [PSCustomObject]@{
            Id = "gate_sunder_final"
            Title = "Wave 3: Gate-Sunder Push"
            AllyLine = "The outer gate groans as the largest shape reaches it. Guards, champions, temple healers, and every runner still breathing move as one ugly machine around the hero."
            SupportLine = "A temple mage brands the broken gate with white fire. The ward will not win the fight, but it keeps the stones from giving up first."
            Monster = (New-GateDefenseWaveMonster -Id "gate_sunder_brute" -Name "gate-sunder brute" -Definite "The Gate-Sunder Brute" -HP 52 -XP 520 -ArmorClass 13 -AttackBonus 6 -InitiativeBonus -1 -DamageDiceSides 10 -DamageBonus 4 -WisdomSaveBonus 0 -DexteritySaveBonus -1 -Intro "The Gate-Sunder Brute comes in with a hinge still bolted around one fist, dragging part of the outside world behind it.")
            AllyOpeningDamage = 12
            HealerRestore = 14
            VictoryLine = "When the brute falls, the wall does not cheer. It exhales. Then the horns change from alarm to answer, carrying the news across the city."
        }
    )
}

function Test-LevelSixGateDefenseReady {
    param($Game)

    return ($null -ne $Game -and
        $null -ne $Game.Hero -and
        $null -ne $Game.Town -and
        $null -ne $Game.Town.StoryFlags -and
        [int]$Game.Hero.Level -ge 6 -and
        [bool]$Game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] -and
        -not [bool]$Game.Town.StoryFlags["LevelSixGateDefenseCompleted"])
}

function Start-LevelSixGateDefenseEvent {
    param(
        $Game,
        [ref]$HeroHP,
        [bool]$ForceWin = $false
    )

    if (-not (Test-LevelSixGateDefenseReady -Game $Game)) {
        return [PSCustomObject]@{
            Started = $false
            Completed = $false
            WavesCompleted = 0
            XP = 0
            Message = "Level 6 gate defense is not ready."
        }
    }

    $Game.Town.StoryFlags["LevelSixGateDefenseStarted"] = $true
    $wavesCompleted = 0
    $totalXP = 0

    Write-SectionTitle -Text "The Wall Answers" -Color "Red"
    Write-Scene "The morning after $($Game.Hero.Name)'s level 6 strength settles in, the city horns do not sound like ceremony. They sound like stone remembering it can break."
    Write-Scene "The Guard Station is already moving. Belor's wall-watch runners point toward the outer gate, where the monster-zone trails have become a living attack."
    Write-ColorLine ""

    foreach ($wave in @(Get-LevelSixGateDefenseWaves)) {
        $monster = $wave.Monster
        $monsterHP = [Math]::Max(1, [int]$monster.hp - [int]$wave.AllyOpeningDamage)
        $monsterOffBalance = $false
        $encounterFled = $false
        $heroDroppedWeapon = if ($null -ne $Game.PSObject.Properties["HeroDroppedWeapon"]) { [bool]$Game.HeroDroppedWeapon } else { $false }
        $distanceState = New-EncounterDistanceState -DistanceFeet 30 -HeroSpeedFeet 30 -MonsterSpeedFeet 30 -MeleeRangeFeet 5 -MaxDistanceFeet 90

        Write-SectionTitle -Text $wave.Title -Color "DarkRed"
        Write-Scene $wave.AllyLine
        Write-Scene $wave.SupportLine
        Write-Scene $monster.intro
        Write-Scene "Allied pressure deals $($wave.AllyOpeningDamage) opening damage before $($Game.Hero.Name) takes the center of the clash."

        if ($ForceWin) {
            $monsterHP = 0
        }
        else {
            Start-CombatLoop `
                -Hero $Game.Hero `
                -Monster $monster `
                -HeroHP $HeroHP `
                -MonsterHP ([ref]$monsterHP) `
                -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
                -MonsterOffBalance ([ref]$monsterOffBalance) `
                -EncounterFled ([ref]$encounterFled) `
                -HeroStarts $true `
                -DistanceState $distanceState
        }

        $Game.HeroDroppedWeapon = $heroDroppedWeapon

        if ($HeroHP.Value -le 0 -or $monsterHP -gt 0) {
            $HeroHP.Value = [Math]::Max(1, [Math]::Min([int]$Game.Hero.HP, [int]$HeroHP.Value + [int]$wave.HealerRestore))
            $wavesCompleted += 1
            Write-Scene "Temple hands drag $($Game.Hero.Name) behind the ward line before the street can take him. Belor's guards and the city champions finish the wave in a crush of shields, spell-light, and shouted names."
            Write-ColorLine ""
            continue
        }

        $wavesCompleted += 1
        Write-Scene $wave.VictoryLine
        Grant-HeroXP -Hero $Game.Hero -XP ([int]$monster.xp)
        $totalXP += [int]$monster.xp
        Write-Scene "$($Game.Hero.Name) gains $($monster.xp) XP from the wave."

        if ([int]$wave.HealerRestore -gt 0) {
            $beforeHeal = [int]$HeroHP.Value
            $HeroHP.Value = [Math]::Min([int]$Game.Hero.HP, $beforeHeal + [int]$wave.HealerRestore)
            $healed = [Math]::Max(0, [int]$HeroHP.Value - $beforeHeal)
            if ($healed -gt 0) {
                Write-Scene "Temple healers restore $healed HP before the next alarm reaches the gate."
            }
        }

        Write-ColorLine ""
    }

    $milestone = Grant-MonsterZoneMilestoneXP -Game $Game -Key "level_6_gate_defense" -XP 900 -Reason "the city gate held through the first organized monster assault"
    if ($milestone.Awarded) {
        $totalXP += [int]$milestone.XP
        Write-Scene $milestone.Message
    }

    $Game.Town.StoryFlags["LevelSixGateDefenseCompleted"] = $true
    Write-EmphasisLine -Text "Gate defense complete: the city has seen $($Game.Hero.Name) stand with its watch, champions, healers, and mages." -Color "Green"
    Write-ColorLine ""

    return [PSCustomObject]@{
        Started = $true
        Completed = $true
        WavesCompleted = $wavesCompleted
        XP = $totalXP
        Message = "The level 6 gate defense is complete."
    }
}

function Invoke-LevelSixGateDefenseAfterLevelUp {
    param(
        $Game,
        [ref]$HeroHP,
        $LevelUpResult,
        [bool]$ForceWin = $false
    )

    $reachedLevelSix = $false
    if ($null -ne $LevelUpResult -and $null -ne $LevelUpResult.Results) {
        foreach ($result in @($LevelUpResult.Results)) {
            if ([int]$result.Level -ge 6) {
                $reachedLevelSix = $true
            }
        }
    }

    if (-not $reachedLevelSix) {
        return [PSCustomObject]@{ Started = $false; Completed = $false; WavesCompleted = 0; XP = 0; Message = "Level 6 was not reached." }
    }

    return Start-LevelSixGateDefenseEvent -Game $Game -HeroHP $HeroHP -ForceWin:$ForceWin
}

function Get-MonsterZoneCreatureObservationLines {
    param($Creature)

    if ($null -eq $Creature) {
        return @()
    }

    switch ([string]$Creature.id) {
        "wall_wolf" {
            return @(
                "$($Creature.definite) keeps its belly close to the grass, circling for scent before it commits. It looks more like a hunter testing a weak flank than a starving animal.",
                "Its shoulders bunch before every short rush. If it attacks, it will likely come fast and low, trying to drag the fight sideways rather than crash straight in.",
                "The smoke-dark pelt is not just dirt. Something has marked or changed the creature, but it still thinks like a beast."
            )
        }
        "razor_boar" {
            return @(
                "$($Creature.definite) tears up root and stone as it moves, less stalking than daring the world to stand in front of it.",
                "Its tusks scrape bark clean from a trunk in one impatient jerk. This thing is dangerous in a charge, but it does not look subtle or especially careful.",
                "No venom shows, no strange spell-sense, just muscle, rage, and tusks sharp enough to make armor feel like a suggestion."
            )
        }
        "grave_hungry_thing" {
            return @(
                "$($Creature.definite) moves wrong: too many pauses, then too much speed, as if every joint remembers a different body.",
                "It does not sniff the air or watch the road like a normal predator. Its head tilts toward warmth, breath, and the tiny sounds skin makes when fear starts.",
                "This is no ordinary beast. It looks like an abomination from grave soil and appetite, and hiding by sight alone may not fool it."
            )
        }
        "kobold_wall_scout" {
            return @(
                "$($Creature.definite) counts patrol markers with quick glances and keeps one claw near the black-waxed token, as if the token matters more than its own comfort.",
                "It moves in bursts: freeze, listen, signal-check, then another skitter of ground. A fight with it may start with tricks, retreat, or a sudden jab rather than brute force.",
                "It is dangerous because it is organized. Alone it looks fragile; as a scout, it may be the first visible piece of something larger."
            )
        }
        "scale_touched_mastiff" {
            return @(
                "$($Creature.definite) samples the wind with a guard dog's patience, then plants its paws as if holding a gate no one else can see.",
                "The black scale plates shift under its hide when it breathes. It looks built to close hard, bite deep, and keep pressure once it has found a target.",
                "This is not a peaceful stray. It has a trained shape to its aggression, and the scale growth makes it feel touched by the same wrongness spreading beyond the wall."
            )
        }
        "ash_horn_drakelet" {
            return @(
                "$($Creature.definite) keeps its head low and sideways, protecting the smoking horn nubs while it tests the air for heat and movement.",
                "It does not rush like a simple beast. It waits for a line, then coils its whole body into a short violent lunge that could punish anyone standing too close.",
                "This feels closer to Halewick's shadow than the wall beasts do: draconic, young or stunted, and dangerous because it is learning the ground."
            )
        }
        "gate_sunder_brute" {
            return @(
                "$($Creature.definite) walks as if distance is only a delay before impact, dragging the stolen hinge until sparks jump from stone.",
                "It is slow to turn but brutal once committed. The safest read is that it breaks obstacles first and asks whether they were people afterward.",
                "The black scale scars along its arms are old wounds, not armor. Something draconic has survived inside the damage and left the creature stronger for it."
            )
        }
        default {
            return @(
                "$($Creature.definite) can be watched from a safer distance, but its habits are hard to name from here.",
                "The safest read is simple: it has not noticed the hero yet, and that advantage may matter more than certainty."
            )
        }
    }
}

function Write-MonsterZoneCreatureObservation {
    param($Creature)

    foreach ($line in (Get-MonsterZoneCreatureObservationLines -Creature $Creature)) {
        Write-Scene $line
    }
}

function Get-MonsterZoneCreatureSenseBonus {
    param($Creature)

    if ($null -eq $Creature -or $null -eq $Creature.senseBonus) {
        return 0
    }

    return [int]$Creature.senseBonus
}

function Test-MonsterZoneCreatureCountersInvisibility {
    param($Creature)

    return ($null -ne $Creature -and $null -ne $Creature.countersInvisibility -and [bool]$Creature.countersInvisibility)
}

function Resolve-WildernessAwareness {
    param(
        $Hero,
        $Creature,
        [int]$HeroPerceptionRoll = 0,
        [int]$HeroStealthRoll = 0,
        [int]$CreaturePerceptionRoll = 0,
        [int]$CreatureStealthRoll = 0
    )

    if ($HeroPerceptionRoll -le 0) { $HeroPerceptionRoll = Roll-Dice -Sides 20 }
    if ($HeroStealthRoll -le 0) { $HeroStealthRoll = Roll-Dice -Sides 20 }
    if ($CreaturePerceptionRoll -le 0) { $CreaturePerceptionRoll = Roll-Dice -Sides 20 }
    if ($CreatureStealthRoll -le 0) { $CreatureStealthRoll = Roll-Dice -Sides 20 }

    $heroPerception = Get-HeroWildernessSkillModifier -Hero $Hero -Skill "Perception"
    $heroStealth = Get-HeroWildernessSkillModifier -Hero $Hero -Skill "Stealth"
    $creaturePerceptionBonus = if ($null -ne $Creature.perceptionBonus) { [int]$Creature.perceptionBonus } else { 0 }
    $creatureStealthBonus = if ($null -ne $Creature.stealthBonus) { [int]$Creature.stealthBonus } else { 0 }
    $creatureSenseBonus = Get-MonsterZoneCreatureSenseBonus -Creature $Creature
    $invisibilityCountered = ((Get-HeroInvisibilityStealthBonus -Hero $Hero) -gt 0 -and (Test-MonsterZoneCreatureCountersInvisibility -Creature $Creature))
    $counteredInvisibilityBonus = if ($invisibilityCountered) { Get-HeroInvisibilityStealthBonus -Hero $Hero } else { 0 }
    $dangerSenseBonus = if (Test-HeroFeatureUnlocked -Hero $Hero -Feature "DangerSense") { 2 } else { 0 }
    $heroPerceptionTotal = $HeroPerceptionRoll + [int]$heroPerception.TotalModifier + $dangerSenseBonus
    $heroStealthTotal = $HeroStealthRoll + [int]$heroStealth.TotalModifier - $counteredInvisibilityBonus
    $creaturePerceptionTotal = $CreaturePerceptionRoll + $creaturePerceptionBonus + $creatureSenseBonus
    $creatureStealthTotal = $CreatureStealthRoll + $creatureStealthBonus
    $heroDetects = $heroPerceptionTotal -ge $creatureStealthTotal
    $creatureDetects = $creaturePerceptionTotal -ge $heroStealthTotal

    $outcome = "Mutual"

    if ($heroDetects -and -not $creatureDetects) {
        $outcome = "HeroAdvantage"
    }
    elseif ($creatureDetects -and -not $heroDetects) {
        $outcome = "CreatureAdvantage"
    }
    elseif (-not $heroDetects -and -not $creatureDetects) {
        $outcome = "Unclear"
    }

    return [PSCustomObject]@{
        Outcome = $outcome
        HeroDetects = $heroDetects
        CreatureDetects = $creatureDetects
        HeroPerceptionTotal = $heroPerceptionTotal
        HeroStealthTotal = $heroStealthTotal
        CreaturePerceptionTotal = $creaturePerceptionTotal
        CreatureStealthTotal = $creatureStealthTotal
        HeroPerceptionRoll = $HeroPerceptionRoll
        HeroStealthRoll = $HeroStealthRoll
        CreaturePerceptionRoll = $CreaturePerceptionRoll
        CreatureStealthRoll = $CreatureStealthRoll
        DangerSenseBonus = $dangerSenseBonus
        CreatureSenseBonus = $creatureSenseBonus
        InvisibilityCountered = $invisibilityCountered
    }
}

function Get-MonsterZoneOddityCapacity {
    param($Game)

    if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.Mounts -and [int]$Game.Town.Mounts.MonsterOddityCapacity -gt 0) {
        return [int]$Game.Town.Mounts.MonsterOddityCapacity
    }

    return 1
}

function Add-MonsterZoneCreatureDefeat {
    param(
        $Game,
        $Creature
    )

    Initialize-MonsterZoneState -Game $Game

    if ($null -eq $Creature) {
        return $null
    }

    $creatureId = if (-not [string]::IsNullOrWhiteSpace([string]$Creature.id)) { [string]$Creature.id } else { [string]$Creature.name }

    if ([string]::IsNullOrWhiteSpace($creatureId)) {
        return $null
    }

    $isFirstDefeatType = (-not $Game.Town.MonsterZone.DefeatedCreatures.ContainsKey($creatureId) -or $null -eq $Game.Town.MonsterZone.DefeatedCreatures[$creatureId])

    if ($isFirstDefeatType) {
        $Game.Town.MonsterZone.DefeatedCreatures[$creatureId] = @{
            Id = $creatureId
            Name = [string]$Creature.name
            Definite = [string]$Creature.definite
            OddityName = [string]$Creature.oddityName
            Count = 0
        }
    }

    $record = $Game.Town.MonsterZone.DefeatedCreatures[$creatureId]
    $record["Count"] = [int]$record["Count"] + 1
    $record["LastDefeatedDay"] = if ($null -ne $Game.Town.DayNumber) { [int]$Game.Town.DayNumber } else { 1 }
    $recordName = [string]$record["Name"]
    $xp = if ($isFirstDefeatType) {
        Grant-MonsterZoneMilestoneXP -Game $Game -Key "creature_proof_$creatureId" -XP 240 -Reason "$recordName proof secured for the wall reports"
    }
    else {
        [PSCustomObject]@{ Awarded = $false; XP = 0; Message = "" }
    }
    $record["MilestoneXPMessage"] = if ($xp.Awarded) { $xp.Message } else { "" }
    Update-MonsterZoneLevelProgression -Game $Game | Out-Null

    return [PSCustomObject]$record
}

function Add-MonsterZoneOddity {
    param(
        $Game,
        $Creature
    )

    Initialize-MonsterZoneState -Game $Game

    $capacity = Get-MonsterZoneOddityCapacity -Game $Game
    $current = @($Game.Town.MonsterZone.Oddities).Count

    if ($current -ge $capacity) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Game.Hero.Name) has no more safe hauling room for monster oddities. A better pack animal would make the next trip more profitable."
        }
    }

    $oddity = [PSCustomObject]@{
        Name = if ($null -ne $Creature.oddityName) { [string]$Creature.oddityName } else { "Unsorted Monster Oddity" }
        Source = [string]$Creature.name
        Value = if ($null -ne $Creature.oddityValue) { [int]$Creature.oddityValue } else { 25 }
    }

    $Game.Town.MonsterZone.Oddities += $oddity

    return [PSCustomObject]@{
        Success = $true
        Oddity = $oddity
        Message = "$($Game.Hero.Name) secures $($oddity.Name) for the Docks buyers. Haul: $($current + 1)/$capacity."
    }
}

function Get-MonsterZoneUnreportedCreatureRecords {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    $records = @()

    foreach ($creatureId in @($Game.Town.MonsterZone.DefeatedCreatures.Keys)) {
        if (-not [bool]$Game.Town.MonsterZone.ReportedCreaturesToDorr[[string]$creatureId]) {
            $records += $Game.Town.MonsterZone.DefeatedCreatures[$creatureId]
        }
    }

    return $records
}

function Get-MonsterZoneObjectiveState {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    $oddityCount = @($Game.Town.MonsterZone.Oddities).Count
    $oddityCapacity = Get-MonsterZoneOddityCapacity -Game $Game
    $unreported = @(Get-MonsterZoneUnreportedCreatureRecords -Game $Game)
    $discoveredCount = @($Game.Town.MonsterZone.DiscoveredLandmarks.Keys).Count
    $currentLandmark = Get-MonsterZoneLandmarkAtPosition -X ([int]$Game.Town.MonsterZone.CurrentX) -Y ([int]$Game.Town.MonsterZone.CurrentY)

    if ($unreported.Count -gt 0) {
        $names = @($unreported | ForEach-Object { $_["Name"] }) -join ", "

        return [PSCustomObject]@{
            Type = "ReturnProofToDorr"
            Title = "Return proof to Dorr"
            Detail = "Report the defeated trail: $names."
            Hint = "Go back to town and visit the fighting ring so Dorr can turn proof into future monster contracts."
            NextStep = "Return to town, enter the fighting ring, and report the trail to Dorr."
            TownReminder = "Dorr can use unreported monster proof: $names."
        }
    }

    if ($oddityCount -ge $oddityCapacity -and $oddityCount -gt 0) {
        return [PSCustomObject]@{
            Type = "ReturnOddities"
            Title = "Return with monster oddities"
            Detail = "Haul is full: $oddityCount/$oddityCapacity oddities."
            Hint = "Head back before another kill wastes valuable parts."
            NextStep = "Return to the city gate before taking another fight."
            TownReminder = "Monster oddity haul is full: $oddityCount/$oddityCapacity. Bring the parts back before hunting again."
        }
    }

    if ($null -ne $currentLandmark -and -not [bool]$Game.Town.MonsterZone.DiscoveredLandmarks[$currentLandmark.Id]) {
        return [PSCustomObject]@{
            Type = "InvestigateLandmark"
            Title = "Investigate the landmark"
            Detail = "Record what is strange about $($currentLandmark.Name)."
            Hint = "Search the area before pushing deeper."
            NextStep = "Choose Search the area here before travelling on."
            TownReminder = "$($currentLandmark.Name) is still unrecorded beyond the wall."
        }
    }

    if ($discoveredCount -le 0) {
        return [PSCustomObject]@{
            Type = "FindLandmark"
            Title = "Find a landmark"
            Detail = "Leave the gate road and record the first reliable place beyond the wall."
            Hint = "Travel into the scrubland and search what you find."
            NextStep = "Travel away from the gate, then search any landmark you reach."
            TownReminder = "Outer-wall work needs its first reliable landmark."
        }
    }

    if ($oddityCount -gt 0) {
        return [PSCustomObject]@{
            Type = "KeepOrReturnOddities"
            Title = "Choose the next risk"
            Detail = "Haul: $oddityCount/$oddityCapacity oddities."
            Hint = "Return safely for value, or keep hunting while there is still hauling room."
            NextStep = "Return for safe value, or keep hunting only if HP and camp safety can carry the risk."
            TownReminder = "Carrying monster oddities: $oddityCount/$oddityCapacity."
        }
    }

    return [PSCustomObject]@{
        Type = "TrackCreature"
        Title = "Track a wall creature"
        Detail = "Find a beast or stranger threat, then bring back proof or an oddity."
        Hint = "Travel through landmarks, watch for tracks, and survive the first real trail."
        NextStep = "Travel between landmarks or search for tracks until a creature commits."
        TownReminder = "Outer-wall proof still needs a creature trail, more landmarks, or useful oddities."
    }
}

function Get-MonsterZoneObjectiveSummaryText {
    param($Game)

    $objective = Get-MonsterZoneObjectiveState -Game $Game

    if ($null -eq $objective) {
        return ""
    }

    return "$($objective.Title): $($objective.Detail) Next: $($objective.NextStep)"
}

function Get-MonsterZoneTownReminderText {
    param($Game)

    if (-not (Test-MonsterZoneUnlocked -Game $Game)) {
        return ""
    }

    $objective = Get-MonsterZoneObjectiveState -Game $Game

    if ($null -eq $objective -or [string]::IsNullOrWhiteSpace([string]$objective.TownReminder)) {
        return ""
    }

    return "Beyond the wall: $($objective.TownReminder)"
}

function Write-MonsterZoneObjectiveStatus {
    param($Game)

    $objective = Get-MonsterZoneObjectiveState -Game $Game
    Write-EmphasisLine -Text "Objective: $($objective.Title) | $($objective.Detail)" -Color "Cyan"
    Write-Scene $objective.Hint
    Write-Scene "Next step: $($objective.NextStep)"
}

function Write-MonsterZoneObjectiveProgress {
    param(
        $Game,
        [string]$Reason = ""
    )

    $objective = Get-MonsterZoneObjectiveState -Game $Game
    $prefix = if ([string]::IsNullOrWhiteSpace($Reason)) { "Objective updated" } else { "Objective updated: $Reason" }
    Write-Action "$prefix -> $($objective.Title). $($objective.Detail)" "Yellow"
}

function Start-MonsterZoneDirectTravelMenu {
    param($Game)

    $landmarks = @(Get-MonsterZoneDirectTravelLandmarks -Game $Game)

    if ($landmarks.Count -le 0) {
        Write-Scene "$($Game.Hero.Name) does not know any outer-wall landmark routes well enough for direct travel yet. Return to the same places on different days to build a reliable route."
        Write-ColorLine ""
        return $null
    }

    Write-SectionTitle -Text "Known Outer Routes" -Color "Yellow"
    Write-Scene "These routes have become familiar enough to follow from the outer gate without wandering the scrub first."
    Write-ColorLine ""

    for ($i = 0; $i -lt $landmarks.Count; $i++) {
        $familiarity = Get-MonsterZoneLandmarkFamiliarity -Game $Game -LandmarkId ([string]$landmarks[$i].Id)
        Write-ColorLine "$($i + 1). $($landmarks[$i].Name) - route familiarity $familiarity/$(Get-MonsterZoneDirectTravelThreshold)" "White"
    }

    Write-ColorLine "0. Back" "DarkGray"
    Write-ColorLine ""
    $choice = Read-Host "Choose landmark"

    if ($choice -eq "0") {
        return $null
    }

    $selectedIndex = 0

    if ([int]::TryParse($choice, [ref]$selectedIndex) -and $selectedIndex -ge 1 -and $selectedIndex -le $landmarks.Count) {
        return (Move-MonsterZoneToLandmark -Game $Game -Landmark $landmarks[$selectedIndex - 1])
    }

    Write-ColorLine "Choose a listed landmark." "DarkYellow"
    Write-ColorLine ""
    return $null
}

function Get-MonsterZoneCampLevelName {
    param([int]$Level)

    switch ($Level) {
        1 { return "Basic Camp" }
        2 { return "Hidden Camp" }
        3 { return "Fortified Camp" }
        default { return "Open Sky" }
    }
}

function Get-MonsterZoneCurrentCampLevel {
    param($Game)

    Initialize-MonsterZoneState -Game $Game
    $key = Get-MonsterZonePositionKey -X ([int]$Game.Town.MonsterZone.CurrentX) -Y ([int]$Game.Town.MonsterZone.CurrentY)

    if ($Game.Town.MonsterZone.Camps.ContainsKey($key)) {
        return [int]$Game.Town.MonsterZone.Camps[$key]
    }

    return 0
}

function Set-MonsterZoneCurrentCampLevel {
    param(
        $Game,
        [int]$Level
    )

    Initialize-MonsterZoneState -Game $Game
    $key = Get-MonsterZonePositionKey -X ([int]$Game.Town.MonsterZone.CurrentX) -Y ([int]$Game.Town.MonsterZone.CurrentY)
    $Game.Town.MonsterZone.Camps[$key] = [Math]::Max(0, [Math]::Min(3, $Level))
}

function Resolve-MonsterZoneCampAction {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$Action,
        [int]$NightRoll = 0,
        [string]$HPMode = "F"
    )

    Initialize-MonsterZoneState -Game $Game

    if ($NightRoll -le 0) {
        $NightRoll = Roll-Dice -Sides 100
    }

    $campLevel = Get-MonsterZoneCurrentCampLevel -Game $Game

    if ($Action -eq "Build") {
        $campLevel = [Math]::Max(1, $campLevel)
        Set-MonsterZoneCurrentCampLevel -Game $Game -Level $campLevel
    }
    elseif ($Action -eq "Improve") {
        $campLevel = [Math]::Min(3, $campLevel + 1)
        Set-MonsterZoneCurrentCampLevel -Game $Game -Level $campLevel
    }
    elseif ($Action -eq "OpenSky") {
        $campLevel = 0
    }

    $risk = [Math]::Max(10, 55 - ($campLevel * 15))
    $interrupted = $NightRoll -le $risk
    $restResult = Resolve-HeroLongRestLevelUp -Hero $Game.Hero -HeroHP $HeroHP -HPMode $HPMode

    return [PSCustomObject]@{
        CampLevel = $campLevel
        CampName = Get-MonsterZoneCampLevelName -Level $campLevel
        NightRoll = $NightRoll
        NightRisk = $risk
        Interrupted = $interrupted
        RestResult = $restResult
        Message = if ($interrupted) { "The long rest completes, but something moves close enough in the dark to prove the camp is not truly safe." } else { "The long rest holds. Morning finds the camp quiet and the city wall still visible in the distance." }
    }
}

function Start-MonsterZoneEncounter {
    param(
        $Game,
        [ref]$HeroHP,
        [bool]$ForceEncounter = $false
    )

    $creature = Get-RandomMonsterZoneCreature -Game $Game
    $monsterHP = [int]$creature.hp
    $monsterOffBalance = $false
    $encounterFled = $false
    $heroDroppedWeapon = if ($null -ne $Game.PSObject.Properties["HeroDroppedWeapon"]) { [bool]$Game.HeroDroppedWeapon } else { $false }
    $heroStarts = $false
    $monsterStarts = $false
    $distanceState = New-EncounterDistanceState -DistanceFeet 30 -HeroSpeedFeet 30 -MonsterSpeedFeet 30 -MeleeRangeFeet 5 -MaxDistanceFeet 120

    Write-SectionTitle -Text "Wilderness Encounter" -Color "Red"
    Write-Scene $creature.introText

    $awareness = Resolve-WildernessAwareness -Hero $Game.Hero -Creature $creature
    Write-Scene "$($Game.Hero.Name)'s Perception total $($awareness.HeroPerceptionTotal) contests $($creature.definite)'s Stealth total $($awareness.CreatureStealthTotal)."
    Write-Scene "$($creature.definite)'s Perception total $($awareness.CreaturePerceptionTotal) contests $($Game.Hero.Name)'s Stealth total $($awareness.HeroStealthTotal)."
    if ($awareness.CreatureSenseBonus -gt 0) {
        $senseText = if ($null -ne $creature.senseTraits -and @($creature.senseTraits).Count -gt 0) { @($creature.senseTraits) -join ", " } else { "heightened senses" }
        Write-Scene "$($creature.definite)'s $senseText helps it read the approach. (+$($awareness.CreatureSenseBonus) Perception)"
    }
    if ($awareness.InvisibilityCountered) {
        Write-Scene "$($creature.definite)'s senses do not rely on sight alone; Invisibility cannot carry the whole approach here."
    }
    Write-ColorLine ""

    switch ($awareness.Outcome) {
        "HeroAdvantage" {
            Write-Scene "$($Game.Hero.Name) spots the danger first and has a heartbeat to choose the shape of the encounter."
            Write-ColorLine "1. Avoid it and move on" "White"
            Write-ColorLine "2. Close into melee for a surprise attack" "White"
            Write-ColorLine "3. Shadow it from near range (30 ft)" "White"
            Write-ColorLine "4. Hold farther out and observe (60 ft)" "White"
            Write-ColorLine "5. Face it openly" "White"
            $choice = Read-Host "Choose"

            if ($choice -eq "1") {
                Write-Scene "$($Game.Hero.Name) lets the creature pass without giving the grass a reason to speak."
                return "Avoided"
            }

            $heroStarts = $true

            if ($choice -eq "2") {
                $monsterOffBalance = $true
                $distanceState.DistanceFeet = 5
                Write-Scene "$($Game.Hero.Name) closes the last distance quietly enough to begin with the creature off balance."
            }
            elseif ($choice -eq "3") {
                $distanceState.DistanceFeet = 30
                Write-Scene "$($Game.Hero.Name) shadows the creature from near range, close enough to act before it fully understands the danger."
            }
            elseif ($choice -eq "4") {
                $distanceState.DistanceFeet = 60
                Write-Scene "$($Game.Hero.Name) keeps a longer line of ground between them, buying space before the fight breaks open."
                Write-MonsterZoneCreatureObservation -Creature $creature
                Write-MonsterZoneClassRead -Hero $Game.Hero -Creature $creature -Context "Observation"
            }
            else {
                $distanceState.DistanceFeet = 30
                Write-Scene "$($Game.Hero.Name) steps into view and lets the encounter begin on open terms."
            }
        }
        "CreatureAdvantage" {
            $monsterStarts = $true
            Write-Scene "$($creature.definite) has the better angle. The fight starts with the wilds choosing the first beat."
        }
        "Unclear" {
            Write-Scene "Both sides catch fragments: bent grass, held breath, one wrong sound. The encounter starts tense rather than clean."
            Start-DetectionPhase -Hero $Game.Hero -Monster $creature -HeroStarts ([ref]$heroStarts) -MonsterStarts ([ref]$monsterStarts)
        }
        default {
            Write-Scene "Both sides see enough. There is no clean ambush now."
            Start-DetectionPhase -Hero $Game.Hero -Monster $creature -HeroStarts ([ref]$heroStarts) -MonsterStarts ([ref]$monsterStarts)
        }
    }

    Start-CombatLoop `
        -Hero $Game.Hero `
        -Monster $creature `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroStarts $heroStarts `
        -DistanceState $distanceState

    $Game.HeroDroppedWeapon = $heroDroppedWeapon

    if ($HeroHP.Value -le 0) {
        return "Defeated"
    }

    if ($monsterHP -le 0) {
        Write-Scene "$($creature.definite) falls, leaving the outer grass suddenly too quiet."
        Grant-HeroXP -Hero $Game.Hero -XP ([int]$creature.xp)
        Write-Scene "$($Game.Hero.Name) gains $($creature.xp) XP."
        $defeatRecord = Add-MonsterZoneCreatureDefeat -Game $Game -Creature $creature
        if ($null -ne $defeatRecord -and -not [string]::IsNullOrWhiteSpace([string]$defeatRecord.MilestoneXPMessage)) {
            Write-Scene ([string]$defeatRecord.MilestoneXPMessage)
        }
        $oddityResult = Add-MonsterZoneOddity -Game $Game -Creature $creature
        Write-Scene $oddityResult.Message
        Write-MonsterZoneObjectiveProgress -Game $Game -Reason "creature proof secured"
        Write-MonsterZoneProgressionMessages -Game $Game | Out-Null
        return "Won"
    }

    if ($encounterFled) {
        return "Fled"
    }

    return "None"
}

function Start-MonsterZoneMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    if (-not (Test-MonsterZoneUnlocked -Game $Game)) {
        Write-Scene "The outer gates are not open for monster-zone work yet. The city needs a reason to look beyond the wall."
        Write-ColorLine ""
        return
    }

    Initialize-MonsterZoneState -Game $Game
    Write-MonsterZoneProgressionMessages -Game $Game | Out-Null

    while ($true) {
        Write-SectionTitle -Text "Beyond the Wall" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Monster Zone" -HeroHP $HeroHP.Value
        Write-Scene "Past the outer gate, the road loosens into scrubland, old markers, ruined work sites, and too much quiet. The city is still visible, but it no longer feels close."
        Write-EmphasisLine -Text "Location: $(Get-MonsterZoneLocationText -Game $Game) | Camp: $(Get-MonsterZoneCampLevelName -Level (Get-MonsterZoneCurrentCampLevel -Game $Game)) | Oddities: $(@($Game.Town.MonsterZone.Oddities).Count)/$(Get-MonsterZoneOddityCapacity -Game $Game)" -Color "Yellow"
        Write-MonsterZoneProgressionStatus -Game $Game
        Write-MonsterZoneObjectiveStatus -Game $Game
        Write-ColorLine ""
        Write-ColorLine "1. Travel north" "White"
        Write-ColorLine "2. Travel east" "White"
        Write-ColorLine "3. Travel south" "White"
        Write-ColorLine "4. Travel west" "White"
        Write-ColorLine "5. Search the area" "White"
        Write-ColorLine "6. Make or improve camp" "White"
        Write-ColorLine "7. Sleep under the open sky" "White"
        Write-ColorLine "8. Return to the city gate" "White"
        Write-ColorLine "9. Travel to a known landmark" $(if (@(Get-MonsterZoneDirectTravelLandmarks -Game $Game).Count -gt 0) { "White" } else { "DarkGray" })
        Write-ColorLine "S. Status" "White"
        if (Test-HeroInvisibilityOutOfCombatOptionVisible -Hero $Game.Hero) {
            Write-ColorLine (Get-HeroInvisibilityOutOfCombatOptionText -Hero $Game.Hero) "White"
        }
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            { $_ -in @("1", "2", "3", "4") } {
                $direction = switch ($choice) {
                    "1" { "north" }
                    "2" { "east" }
                    "3" { "south" }
                    "4" { "west" }
                }

                $move = Move-MonsterZonePosition -Game $Game -Direction $direction
                Write-Scene $move.Message

                if ($move.Success) {
                    $discovery = Discover-MonsterZoneLandmark -Game $Game -Landmark $move.Landmark
                    Write-Scene $discovery.Text
                    if ($discovery.Discovered) {
                        Write-MonsterZoneObjectiveProgress -Game $Game -Reason "landmark recorded"
                    }

                    $encounterRoll = Roll-Dice -Sides 100
                    $danger = if ($null -ne $move.Landmark) { [int]$move.Landmark.DangerLevel } else { 1 }
                    $familiarity = if ($null -ne $move.Landmark) { Get-MonsterZoneLandmarkFamiliarity -Game $Game -LandmarkId ([string]$move.Landmark.Id) } else { 0 }
                    $encounterChance = [Math]::Max(10, (20 + ($danger * 10)) - ([Math]::Max(0, $familiarity - 1) * 5))

                    if ($encounterRoll -le $encounterChance) {
                        $encounterResult = Start-MonsterZoneEncounter -Game $Game -HeroHP $HeroHP

                        if ($encounterResult -eq "Defeated") {
                            return "Defeated"
                        }
                    }
                    else {
                        Write-Scene "Nothing commits to an attack, though the grass keeps moving after the wind stops."
                    }
                }

                Write-ColorLine ""
            }
            "5" {
                $landmark = Get-MonsterZoneLandmarkAtPosition -X ([int]$Game.Town.MonsterZone.CurrentX) -Y ([int]$Game.Town.MonsterZone.CurrentY)
                $discovery = Discover-MonsterZoneLandmark -Game $Game -Landmark $landmark
                Write-Scene $discovery.Text
                Write-MonsterZoneClassRead -Hero $Game.Hero -Landmark $landmark -Context "Search"
                if ($discovery.Discovered) {
                    Write-MonsterZoneObjectiveProgress -Game $Game -Reason "landmark recorded"
                }
                Write-ColorLine ""
            }
            "6" {
                $campAction = if ((Get-MonsterZoneCurrentCampLevel -Game $Game) -le 0) { "Build" } else { "Improve" }
                $camp = Resolve-MonsterZoneCampAction -Game $Game -HeroHP $HeroHP -Action $campAction
                Write-Scene "$($Game.Hero.Name) works the site into a $($camp.CampName)."
                Write-Scene $camp.Message
                Invoke-LevelSixGateDefenseAfterLevelUp -Game $Game -HeroHP $HeroHP -LevelUpResult $camp.RestResult -ForceWin:(Get-UiOutputSuppressed) | Out-Null
                Write-ColorLine ""
            }
            "7" {
                $camp = Resolve-MonsterZoneCampAction -Game $Game -HeroHP $HeroHP -Action "OpenSky"
                Write-Scene "$($Game.Hero.Name) sleeps under the open sky with the wall fires dim behind the grass."
                Write-Scene $camp.Message
                Invoke-LevelSixGateDefenseAfterLevelUp -Game $Game -HeroHP $HeroHP -LevelUpResult $camp.RestResult -ForceWin:(Get-UiOutputSuppressed) | Out-Null
                Write-ColorLine ""
            }
            "8" {
                $Game.Town.MonsterZone.CurrentX = 0
                $Game.Town.MonsterZone.CurrentY = 0
                Write-Scene "$($Game.Hero.Name) follows the road markers back until the outer gate has shape again."
                Write-ColorLine ""
            }
            "9" {
                $directTravel = Start-MonsterZoneDirectTravelMenu -Game $Game

                if ($null -ne $directTravel) {
                    Write-Scene $directTravel.Message

                    if ($directTravel.Success) {
                        $discovery = Discover-MonsterZoneLandmark -Game $Game -Landmark $directTravel.Landmark
                        Write-Scene $discovery.Text
                    }

                    Write-ColorLine ""
                }
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "V" {
                if (Test-HeroInvisibilityOutOfCombatOptionVisible -Hero $Game.Hero) {
                    Invoke-HeroOutOfCombatInvisibilityAction -Hero $Game.Hero | Out-Null
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                }
            }
            "0" {
                return
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}
