# Outer-wall wilderness exploration. This is intentionally lighter than dungeon rooms:
# hidden positions, persistent landmarks, camp safety, and awareness before combat.

function Get-MonsterZoneDefaultState {
    return @{
        CurrentX = 0
        CurrentY = 0
        Visits = 0
        DiscoveredLandmarks = @{}
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

    return [PSCustomObject]@{
        Discovered = (-not $alreadyDiscovered)
        Landmark = $Landmark
        Text = if ($alreadyDiscovered) { $Landmark.RepeatVisitText } else { $Landmark.FirstVisitText }
    }
}

function Get-HeroWildernessSkillModifier {
    param(
        $Hero,
        [string]$Skill
    )

    switch ($Skill) {
        "Perception" { return Get-HeroAbilityCheckModifier -Hero $Hero -Ability "WIS" -CheckTag "Perception" }
        "Stealth" { return Get-HeroAbilityCheckModifier -Hero $Hero -Ability "DEX" -CheckTag "Stealth" }
        default { return Get-HeroAbilityCheckModifier -Hero $Hero -Ability "WIS" -CheckTag $Skill }
    }
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
        (New-MonsterZoneCreature -Id "wall_wolf" -Name "wall-prowling wolf" -Article "A" -Definite "The Wall-Prowling Wolf" -HP 18 -XP 90 -ArmorClass 13 -AttackBonus 3 -InitiativeBonus 2 -DamageDiceSides 6 -DamageBonus 1 -PerceptionBonus 3 -StealthBonus 3 -OddityName "Smoke-Tainted Pelt" -OddityValue 45 -IntroText "A lean wolf moves low through the grass, its coat darkened by old smoke and its attention fixed too close to the city wall." -SenseTraits @("Keen Hearing and Smell") -SenseBonus 2)
        (New-MonsterZoneCreature -Id "razor_boar" -Name "razor-tusk boar" -Article "A" -Definite "The Razor-Tusk Boar" -HP 22 -XP 100 -ArmorClass 12 -AttackBonus 3 -InitiativeBonus 0 -DamageDiceSides 8 -DamageBonus 1 -PerceptionBonus 1 -StealthBonus 0 -OddityName "Razor Boar Tusk" -OddityValue 55 -IntroText "A boar shoulders through the brush, tusks chipped against stone and wet earth flying from its hooves." -SenseTraits @("Keen Smell") -SenseBonus 1)
        (New-MonsterZoneCreature -Id "grave_hungry_thing" -Name "grave-hungry thing" -Article "A" -Definite "The Grave-Hungry Thing" -HP 20 -XP 120 -ArmorClass 11 -AttackBonus 2 -InitiativeBonus 1 -DamageDiceSides 6 -DamageBonus 2 -PerceptionBonus 2 -StealthBonus 2 -OddityName "Pale Grave Claw" -OddityValue 70 -IntroText "Something pale and joint-wrong crawls from behind a stone, smelling of old graves and fresh appetite." -SenseTraits @("Blindsight") -SenseBonus 3 -CountersInvisibility $true)
        (New-MonsterZoneCreature -Id "kobold_wall_scout" -Name "kobold wall scout" -Article "A" -Definite "The Kobold Wall Scout" -HP 14 -XP 110 -ArmorClass 13 -AttackBonus 3 -InitiativeBonus 3 -DamageDiceSides 6 -DamageBonus 0 -PerceptionBonus 2 -StealthBonus 4 -OddityName "Black-Wax Scout Token" -OddityValue 65 -IntroText "A small scaled scout freezes near a patrol marker, one claw wrapped around a black-waxed token.")
        (New-MonsterZoneCreature -Id "scale_touched_mastiff" -Name "scale-touched mastiff" -Article "A" -Definite "The Scale-Touched Mastiff" -HP 24 -XP 140 -ArmorClass 13 -AttackBonus 4 -InitiativeBonus 2 -DamageDiceSides 8 -DamageBonus 2 -PerceptionBonus 4 -StealthBonus 1 -OddityName "Black Scale Shard" -OddityValue 90 -IntroText "A mastiff built like a guard dog stalks into view, black scale plates showing through its hide where fur should be." -SenseTraits @("Keen Smell") -SenseBonus 2)
    )
}

function Get-RandomMonsterZoneCreature {
    return (Get-MonsterZoneCreatures | Get-Random)
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

    if (-not $Game.Town.MonsterZone.DefeatedCreatures.ContainsKey($creatureId) -or $null -eq $Game.Town.MonsterZone.DefeatedCreatures[$creatureId]) {
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

    $creature = Get-RandomMonsterZoneCreature
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
        Add-MonsterZoneCreatureDefeat -Game $Game -Creature $creature | Out-Null
        $oddityResult = Add-MonsterZoneOddity -Game $Game -Creature $creature
        Write-Scene $oddityResult.Message
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

    while ($true) {
        Write-SectionTitle -Text "Beyond the Wall" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Monster Zone" -HeroHP $HeroHP.Value
        Write-Scene "Past the outer gate, the road loosens into scrubland, old markers, ruined work sites, and too much quiet. The city is still visible, but it no longer feels close."
        Write-EmphasisLine -Text "Location: $(Get-MonsterZoneLocationText -Game $Game) | Camp: $(Get-MonsterZoneCampLevelName -Level (Get-MonsterZoneCurrentCampLevel -Game $Game)) | Oddities: $(@($Game.Town.MonsterZone.Oddities).Count)/$(Get-MonsterZoneOddityCapacity -Game $Game)" -Color "Yellow"
        Write-ColorLine ""
        Write-ColorLine "1. Travel north" "White"
        Write-ColorLine "2. Travel east" "White"
        Write-ColorLine "3. Travel south" "White"
        Write-ColorLine "4. Travel west" "White"
        Write-ColorLine "5. Search the area" "White"
        Write-ColorLine "6. Make or improve camp" "White"
        Write-ColorLine "7. Sleep under the open sky" "White"
        Write-ColorLine "8. Return to the city gate" "White"
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

                    $encounterRoll = Roll-Dice -Sides 100
                    $danger = if ($null -ne $move.Landmark) { [int]$move.Landmark.DangerLevel } else { 1 }
                    $encounterChance = 20 + ($danger * 10)

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
                Write-ColorLine ""
            }
            "6" {
                $campAction = if ((Get-MonsterZoneCurrentCampLevel -Game $Game) -le 0) { "Build" } else { "Improve" }
                $camp = Resolve-MonsterZoneCampAction -Game $Game -HeroHP $HeroHP -Action $campAction
                Write-Scene "$($Game.Hero.Name) works the site into a $($camp.CampName)."
                Write-Scene $camp.Message
                Write-ColorLine ""
            }
            "7" {
                $camp = Resolve-MonsterZoneCampAction -Game $Game -HeroHP $HeroHP -Action "OpenSky"
                Write-Scene "$($Game.Hero.Name) sleeps under the open sky with the wall fires dim behind the grass."
                Write-Scene $camp.Message
                Write-ColorLine ""
            }
            "8" {
                $Game.Town.MonsterZone.CurrentX = 0
                $Game.Town.MonsterZone.CurrentY = 0
                Write-Scene "$($Game.Hero.Name) follows the road markers back until the outer gate has shape again."
                Write-ColorLine ""
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
