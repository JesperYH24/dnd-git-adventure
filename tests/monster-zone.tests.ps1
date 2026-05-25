. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-MonsterZoneUnlocksFromWallRumors {
    $game = Initialize-Game

    Assert-Equal -Actual (Test-MonsterZoneUnlocked -Game $game) -Expected $false -Message "Monster zone should stay locked before wall rumors start."

    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true

    Assert-Equal -Actual (Test-MonsterZoneUnlocked -Game $game) -Expected $true -Message "Monster zone should unlock when post-rest wall rumors start."
}

function Test-MonsterZoneTravelFindsPersistentLandmark {
    $game = Initialize-Game
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true

    $move = Move-MonsterZonePosition -Game $game -Direction "west"
    $discovery = Discover-MonsterZoneLandmark -Game $game -Landmark $move.Landmark
    $return = Move-MonsterZonePosition -Game $game -Direction "east"
    $secondMove = Move-MonsterZonePosition -Game $game -Direction "west"
    $secondDiscovery = Discover-MonsterZoneLandmark -Game $game -Landmark $secondMove.Landmark

    Assert-True -Condition $move.Success -Message "The hero should be able to travel west from the gate."
    Assert-Equal -Actual $move.Landmark.Id -Expected "burned_orchard" -Message "Travelling west from the gate should consistently find the Burned Orchard."
    Assert-Equal -Actual $discovery.Discovered -Expected $true -Message "The first landmark visit should count as a new discovery."
    Assert-True -Condition $return.Success -Message "The hero should be able to return east toward the gate."
    Assert-Equal -Actual $secondMove.Landmark.Id -Expected "burned_orchard" -Message "Returning west again should find the same landmark."
    Assert-Equal -Actual $secondDiscovery.Discovered -Expected $false -Message "The second visit should use repeat discovery state."
}

function Test-MonsterZoneLandmarkFamiliarityGrowsAcrossDays {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "burned_orchard" } | Select-Object -First 1

    $dayOne = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    $sameDay = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    Advance-TownToNextDay -Game $game | Out-Null
    $dayTwo = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark

    Assert-Equal -Actual $dayOne.Familiarity -Expected 1 -Message "First landmark visit should start route familiarity."
    Assert-Equal -Actual $sameDay.Familiarity -Expected 1 -Message "Repeating a landmark on the same day should not farm route familiarity."
    Assert-Equal -Actual $dayTwo.Familiarity -Expected 2 -Message "Returning on a different day should improve route familiarity."
    Assert-True -Condition ($dayTwo.Text -like "*easier to find*") -Message "A later-day repeat visit should tell the player the route is becoming easier to find."
}

function Test-MonsterZoneLandmarkDirectTravelUnlocksAfterRepeatDays {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "collapsed_watchtower" } | Select-Object -First 1

    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    Advance-TownToNextDay -Game $game | Out-Null
    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    Advance-TownToNextDay -Game $game | Out-Null
    $thirdVisit = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    $directLandmarks = @(Get-MonsterZoneDirectTravelLandmarks -Game $game)
    $directTravel = Move-MonsterZoneToLandmark -Game $game -Landmark $landmark

    Assert-Equal -Actual $thirdVisit.DirectTravelJustUnlocked -Expected $true -Message "A third different-day landmark visit should unlock direct travel."
    Assert-True -Condition ($thirdVisit.Text -like "*directly from the outer gate*") -Message "Unlock text should explain direct travel from the gate."
    Assert-Equal -Actual $directLandmarks[0].Id -Expected "collapsed_watchtower" -Message "Unlocked landmarks should appear in the direct-travel list."
    Assert-Equal -Actual $directTravel.Success -Expected $true -Message "Known landmark routes should support direct travel."
    Assert-Equal -Actual $game.Town.MonsterZone.CurrentX -Expected 1 -Message "Direct travel should move to the landmark X coordinate."
    Assert-Equal -Actual $game.Town.MonsterZone.CurrentY -Expected 1 -Message "Direct travel should move to the landmark Y coordinate."
}

function Test-MonsterZoneLandmarksAwardMilestoneXPOnce {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "burned_orchard" } | Select-Object -First 1

    $first = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    $sameDay = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    Advance-TownToNextDay -Game $game | Out-Null
    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    Advance-TownToNextDay -Game $game | Out-Null
    $route = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    $repeatRoute = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark

    Assert-True -Condition ($first.Text -like "*120 XP*") -Message "A first landmark discovery should award monster-zone milestone XP."
    Assert-True -Condition ($sameDay.Text -notlike "*120 XP*") -Message "The same landmark should not award discovery XP twice."
    Assert-True -Condition ($route.Text -like "*180 XP*") -Message "Unlocking a reliable route should award route milestone XP."
    Assert-True -Condition ($repeatRoute.Text -notlike "*180 XP*") -Message "Reliable route XP should only be awarded once."
    Assert-Equal -Actual $game.Hero.XP -Expected 300 -Message "One landmark discovery and one direct-route unlock should total 300 XP."
}

function Test-MonsterZoneSoftEdgeBlocksOvertravel {
    $game = Initialize-Game
    Move-MonsterZonePosition -Game $game -Direction "west" | Out-Null
    Move-MonsterZonePosition -Game $game -Direction "west" | Out-Null

    $edge = Move-MonsterZonePosition -Game $game -Direction "west"

    Assert-Equal -Actual $edge.Success -Expected $false -Message "The current monster zone should block travel beyond its soft edge."
    Assert-Equal -Actual $edge.Edge -Expected $true -Message "Overtravel should be marked as an edge result."
    Assert-True -Condition ($edge.Message -like "*city*reach*" -or $edge.Message -like "*patrol*") -Message "The soft edge should explain the city patrol boundary."
}

function Test-WildernessAwarenessCanGiveHeroAdvantage {
    $hero = Get-Hero -Class "Fighter"
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    $result = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 18 -CreaturePerceptionRoll 1 -CreatureStealthRoll 1

    Assert-Equal -Actual $result.Outcome -Expected "HeroAdvantage" -Message "Strong hero awareness should spot the creature before being detected."
    Assert-Equal -Actual $result.HeroDetects -Expected $true -Message "Hero should detect the creature."
    Assert-Equal -Actual $result.CreatureDetects -Expected $false -Message "Creature should not detect the hero in this controlled check."
}

function Test-BarbarianDangerSenseStartsAtLevelTwo {
    $hero = Get-Hero -Class "Barbarian"
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    $levelOne = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 10 -HeroStealthRoll 10 -CreaturePerceptionRoll 10 -CreatureStealthRoll 10
    $hero.Level = 2
    $levelTwo = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 10 -HeroStealthRoll 10 -CreaturePerceptionRoll 10 -CreatureStealthRoll 10

    Assert-Equal -Actual $levelOne.DangerSenseBonus -Expected 0 -Message "Danger Sense should not affect awareness at Barbarian level 1."
    Assert-Equal -Actual $levelTwo.DangerSenseBonus -Expected 2 -Message "Danger Sense should add its monster-zone awareness bonus at Barbarian level 2."
    Assert-Equal -Actual ($levelTwo.HeroPerceptionTotal - $levelOne.HeroPerceptionTotal) -Expected 2 -Message "Danger Sense should improve the hero's perception total by 2."
}

function Test-InvisibilityImprovesMonsterZoneStealth {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "scale_touched_mastiff" } | Select-Object -First 1

    $visible = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 5 -CreaturePerceptionRoll 10 -CreatureStealthRoll 1
    Invoke-HeroInvisibility -Hero $hero | Out-Null
    $invisible = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 5 -CreaturePerceptionRoll 10 -CreatureStealthRoll 1

    Assert-Equal -Actual $visible.CreatureDetects -Expected $true -Message "The creature should detect the visible bard in the controlled check."
    Assert-Equal -Actual $invisible.CreatureDetects -Expected $false -Message "Invisibility should help the bard avoid monster-zone detection."
    Assert-Equal -Actual $invisible.Outcome -Expected "HeroAdvantage" -Message "Invisibility should help the bard sneak up after spotting a creature."
}

function Test-MonsterZoneKeenSensesHelpAgainstStealth {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Invoke-HeroInvisibility -Hero $hero | Out-Null
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "scale_touched_mastiff" } | Select-Object -First 1

    $result = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 5 -CreaturePerceptionRoll 10 -CreatureStealthRoll 1

    Assert-Equal -Actual $result.CreatureSenseBonus -Expected 2 -Message "Keen-scent creatures should add their sense bonus to the perception side of the stealth contest."
    Assert-Equal -Actual $result.CreaturePerceptionTotal -Expected 16 -Message "Creature perception total should include base perception and keen senses."
    Assert-Equal -Actual $result.InvisibilityCountered -Expected $false -Message "Keen senses should help detection without fully countering Invisibility."
}

function Test-MonsterZoneBlindsightCountersInvisibilityBonus {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "grave_hungry_thing" } | Select-Object -First 1

    $visible = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 5 -CreaturePerceptionRoll 10 -CreatureStealthRoll 1
    Invoke-HeroInvisibility -Hero $hero | Out-Null
    $invisible = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 20 -HeroStealthRoll 5 -CreaturePerceptionRoll 10 -CreatureStealthRoll 1

    Assert-Equal -Actual $invisible.CreatureSenseBonus -Expected 3 -Message "Blindsight should still add its sense bonus to perception."
    Assert-Equal -Actual $invisible.InvisibilityCountered -Expected $true -Message "Blindsight should counter Invisibility's stealth bonus in monster-zone awareness."
    Assert-Equal -Actual $invisible.HeroStealthTotal -Expected $visible.HeroStealthTotal -Message "Blindsight should remove the extra Invisibility stealth bonus from the contest."
}

function Test-MonsterZoneCreaturesHaveObservationFlavor {
    $creatures = Get-MonsterZoneCreatures

    foreach ($creature in $creatures) {
        $lines = @(Get-MonsterZoneCreatureObservationLines -Creature $creature)

        Assert-True -Condition ($lines.Count -ge 2) -Message "$($creature.id) should have multiple observation lines for the 60 ft stalk choice."
        Assert-True -Condition (($lines -join " ").Length -gt 80) -Message "$($creature.id) observation text should give the player a real read, not a bare label."
    }

    $graveThing = $creatures | Where-Object { $_.id -eq "grave_hungry_thing" } | Select-Object -First 1
    $graveText = @(Get-MonsterZoneCreatureObservationLines -Creature $graveThing) -join " "

    Assert-True -Condition ($graveText -like "*abomination*") -Message "The grave-hungry thing observation should mark it as stranger than a normal beast."
    Assert-True -Condition ($graveText -like "*sight alone*") -Message "The grave-hungry thing observation should hint that sight-based stealth is unreliable."
}

function Test-MonsterZoneCreaturePoolScalesWithLevelCap {
    $game = Initialize-Game
    $game.Hero.LevelCap = 5

    $levelFive = @(Get-MonsterZoneAvailableCreatures -Game $game)
    $game.Hero.LevelCap = 6
    $levelSix = @(Get-MonsterZoneAvailableCreatures -Game $game)

    Assert-True -Condition ($levelFive.id -contains "ash_horn_drakelet") -Message "Level 5-cap monster-zone work should include the draconic pressure creature."
    Assert-True -Condition ($levelFive.id -notcontains "gate_sunder_brute") -Message "Level 6 gate-breaker threats should stay out of the level 5 pool."
    Assert-True -Condition ($levelSix.id -contains "gate_sunder_brute") -Message "Level 6-cap monster-zone work should unlock the stronger gate-breaker threat."
}

function Test-MonsterZoneWeatherPersistsForCurrentDay {
    $game = Initialize-Game

    $first = Get-MonsterZoneWeatherState -Game $game -WeatherRoll 96
    $sameDay = Get-MonsterZoneWeatherState -Game $game -WeatherRoll 1
    Advance-TownToNextDay -Game $game | Out-Null
    $nextDay = Get-MonsterZoneWeatherState -Game $game -WeatherRoll 1

    Assert-Equal -Actual $first.Id -Expected "ash_haze" -Message "High weather rolls should produce ash haze."
    Assert-Equal -Actual $sameDay.Id -Expected "ash_haze" -Message "Monster-zone weather should stay stable during the same town day."
    Assert-Equal -Actual $nextDay.Id -Expected "clear" -Message "A new town day should allow fresh monster-zone weather."
}

function Test-MonsterZoneWeatherModifiesAwareness {
    $hero = Get-Hero -Class "Fighter"
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1
    $weather = Get-MonsterZoneWeatherProfile -WeatherId "cold_fog"

    $clear = Resolve-WildernessAwareness -Hero $hero -Creature $creature -HeroPerceptionRoll 10 -HeroStealthRoll 10 -CreaturePerceptionRoll 10 -CreatureStealthRoll 10
    $fog = Resolve-WildernessAwareness -Hero $hero -Creature $creature -Weather $weather -HeroPerceptionRoll 10 -HeroStealthRoll 10 -CreaturePerceptionRoll 10 -CreatureStealthRoll 10

    Assert-Equal -Actual $fog.WeatherId -Expected "cold_fog" -Message "Awareness results should record the weather that modified the contest."
    Assert-Equal -Actual ($fog.HeroPerceptionTotal - $clear.HeroPerceptionTotal) -Expected -3 -Message "Cold fog should lower hero perception."
    Assert-Equal -Actual ($fog.HeroStealthTotal - $clear.HeroStealthTotal) -Expected 2 -Message "Cold fog should help hero stealth."
    Assert-Equal -Actual ($fog.CreaturePerceptionTotal - $clear.CreaturePerceptionTotal) -Expected -2 -Message "Cold fog should lower creature perception."
    Assert-Equal -Actual ($fog.CreatureStealthTotal - $clear.CreatureStealthTotal) -Expected 2 -Message "Cold fog should help creature stealth."
}

function Test-MonsterZoneWeatherChangesCampRisk {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-MonsterZoneWeather -Game $game -WeatherId "rain" | Out-Null

    $openSky = Resolve-MonsterZoneCampAction -Game $game -HeroHP ([ref]$heroHP) -Action "OpenSky" -NightRoll 100

    Assert-Equal -Actual $openSky.Weather.Id -Expected "rain" -Message "Camp risk should use the current monster-zone weather."
    Assert-Equal -Actual $openSky.WeatherCampRiskModifier -Expected 10 -Message "Cold rain should add its camp risk modifier."
    Assert-Equal -Actual $openSky.NightRisk -Expected 65 -Message "Cold rain should make open-sky rest riskier."
}

function Test-MonsterZoneAddsMoreCreatureTypes {
    $game = Initialize-Game
    $game.Hero.LevelCap = 5

    $levelFive = @(Get-MonsterZoneAvailableCreatures -Game $game)
    $game.Hero.LevelCap = 6
    $levelSix = @(Get-MonsterZoneAvailableCreatures -Game $game)

    foreach ($id in @("glass_carrion_crow", "marsh_venom_adder", "iron_root_stag")) {
        Assert-True -Condition ($levelFive.id -contains $id) -Message "$id should broaden the level 5 monster-zone creature pool."
    }

    Assert-True -Condition ($levelFive.id -notcontains "hollow_scale_wyrmling") -Message "The hollow-scale wyrmling should stay out of the level 5 pool."
    Assert-True -Condition ($levelSix.id -contains "hollow_scale_wyrmling") -Message "The hollow-scale wyrmling should unlock for level 6 monster-zone play."
}

function Test-MonsterZoneClassReadsAreDistinct {
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "dry_creek_bed" } | Select-Object -First 1
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1
    $barbarian = Get-Hero -Class "Barbarian"
    $bard = Get-Hero -Class "Bard"
    $fighter = Get-Hero -Class "Fighter"

    $barbarianSearch = @(Get-MonsterZoneClassReadLines -Hero $barbarian -Landmark $landmark -Context "Search") -join " "
    $bardSearch = @(Get-MonsterZoneClassReadLines -Hero $bard -Landmark $landmark -Context "Search") -join " "
    $fighterSearch = @(Get-MonsterZoneClassReadLines -Hero $fighter -Landmark $landmark -Context "Search") -join " "
    $bardObservation = @(Get-MonsterZoneClassReadLines -Hero $bard -Creature $creature -Context "Observation") -join " "

    Assert-True -Condition ($barbarianSearch -like "*boot pressure*") -Message "Barbarian wilderness reads should lean on body, tracks, and instinct."
    Assert-True -Condition ($bardSearch -like "*verse*") -Message "Bard wilderness reads should lean on rhythm, lore, and story."
    Assert-True -Condition ($fighterSearch -like "*patrol*") -Message "Fighter wilderness reads should lean on patrol logic and sightlines."
    Assert-True -Condition ($bardObservation -like "*rhythm*") -Message "Bard observation reads should add class flavor to monster watching."
}

function Test-BardCanCastInvisibilityFromMonsterZoneMenu {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.Level = 4
    Initialize-HeroSpellcasting -Hero $game.Hero | Out-Null
    Restore-HeroSpellSlots -Hero $game.Hero | Out-Null
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    $heroHP = $game.Hero.HP

    $script:MonsterZoneInput = [System.Collections.Queue]::new()
    foreach ($choice in @("V", "0")) {
        $script:MonsterZoneInput.Enqueue($choice)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:MonsterZoneInput.Count -eq 0) {
            throw "No monster-zone test input remains for prompt '$Prompt'."
        }

        return $script:MonsterZoneInput.Dequeue()
    }

    try {
        Start-MonsterZoneMenu -Game $game -HeroHP ([ref]$heroHP)
    }
    finally {
        Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
    }

    Assert-Equal -Actual $game.Hero.ActiveBuff.Type -Expected "Invisibility" -Message "The monster-zone menu should let a level 4 bard cast Invisibility out of combat."
    Assert-Equal -Actual $game.Hero.CurrentSpellSlots.Level2 -Expected 2 -Message "Monster-zone Invisibility should spend one level 2 spell slot."
}

function Test-PackAnimalControlsMonsterOddityCapacity {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Select-Object -First 1

    $first = Add-MonsterZoneOddity -Game $game -Creature $creature
    $blocked = Add-MonsterZoneOddity -Game $game -Creature $creature

    $gameWithMule = Initialize-Game
    $gameWithMule.Town.Mounts.MonsterOddityCapacity = 4
    $muleFirst = Add-MonsterZoneOddity -Game $gameWithMule -Creature $creature
    Add-MonsterZoneOddity -Game $gameWithMule -Creature $creature | Out-Null
    Add-MonsterZoneOddity -Game $gameWithMule -Creature $creature | Out-Null
    $muleFourth = Add-MonsterZoneOddity -Game $gameWithMule -Creature $creature

    Assert-True -Condition $first.Success -Message "A hero without pack animals should still haul one oddity."
    Assert-Equal -Actual $blocked.Success -Expected $false -Message "A hero without pack animals should be blocked after one oddity."
    Assert-True -Condition $muleFirst.Success -Message "A mule-backed hero should haul the first oddity."
    Assert-True -Condition $muleFourth.Success -Message "A mule-backed hero should haul up to four oddities."
    Assert-Equal -Actual @($gameWithMule.Town.MonsterZone.Oddities).Count -Expected 4 -Message "Mule capacity should allow four monster oddities."
}

function Test-MonsterZoneTracksDefeatedCreatureProof {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "wall_wolf" } | Select-Object -First 1

    $first = Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature
    $second = Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature

    Assert-Equal -Actual $first.Id -Expected "wall_wolf" -Message "Monster-zone defeat tracking should keep the creature id."
    Assert-Equal -Actual $second.Count -Expected 2 -Message "Repeated defeats should increment the creature proof counter."
    Assert-Equal -Actual $game.Town.MonsterZone.DefeatedCreatures["wall_wolf"]["OddityName"] -Expected "Smoke-Tainted Pelt" -Message "Defeat proof should keep the linked oddity name for Dorr and buyers."
    Assert-Equal -Actual $game.Hero.XP -Expected 240 -Message "The first defeated creature type should award proof milestone XP once."
    Assert-True -Condition ($first.MilestoneXPMessage -like "*240 XP*") -Message "The first defeat record should carry its XP message for combat output."
    Assert-Equal -Actual $second.MilestoneXPMessage -Expected "" -Message "Repeated defeats of the same creature type should not repeat proof XP."
}

function Test-MonsterZoneProgressionCanRaiseCapToSix {
    $game = Initialize-Game
    $game.Hero.LevelCap = 5
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true

    $landmarks = @(Get-MonsterZoneLandmarks | Select-Object -First 4)
    foreach ($landmark in $landmarks) {
        Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    }

    Advance-TownToNextDay -Game $game | Out-Null
    Discover-MonsterZoneLandmark -Game $game -Landmark $landmarks[0] | Out-Null
    Advance-TownToNextDay -Game $game | Out-Null
    Discover-MonsterZoneLandmark -Game $game -Landmark $landmarks[0] | Out-Null

    $creatures = @(Get-MonsterZoneCreatures | Select-Object -First 3)
    foreach ($creature in $creatures) {
        Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    }

    $report = Report-MonsterZoneDiscoveriesToDorr -Game $game
    $progression = Update-MonsterZoneLevelProgression -Game $game
    $xpAfterUnlock = [int]$game.Hero.XP
    $repeat = Update-MonsterZoneLevelProgression -Game $game

    Assert-Equal -Actual @($report.NewlyReported).Count -Expected 3 -Message "Reporting three defeated monster types should satisfy the Dorr proof side of level 6 progression."
    Assert-Equal -Actual $progression.State.LevelSixReady -Expected $true -Message "The monster zone should become level 6-ready after landmarks, routes, defeats, and reports line up."
    Assert-Equal -Actual $game.Hero.LevelCap -Expected 6 -Message "Monster-zone progression should raise the level cap to 6."
    Assert-Equal -Actual $game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] -Expected $true -Message "Level 6 monster-zone readiness should set a story flag."
    Assert-Equal -Actual $xpAfterUnlock -Expected 2460 -Message "The level 4-6 monster-zone proof package should award meaningful one-time XP."
    Assert-Equal -Actual $game.Hero.XP -Expected $xpAfterUnlock -Message "Rechecking level 6 progression should not duplicate cap XP."
    Assert-Equal -Actual $repeat.Changed -Expected $false -Message "A completed level 6 progression check should be quiet on repeat."
}

function Test-MonsterZoneProgressionSummaryShowsLevelSixRequirements {
    $game = Initialize-Game
    $game.Hero.LevelCap = 5
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    $game.Town.MonsterZone.DiscoveredLandmarks["old_mile_shrine"] = $true
    $game.Town.MonsterZone.DiscoveredLandmarks["burned_orchard"] = $true
    $game.Town.MonsterZone.DefeatedCreatures["wall_wolf"] = @{ Name = "wall-prowling wolf" }
    $game.Town.MonsterZone.ReportedCreaturesToDorr["wall_wolf"] = @{ Name = "wall-prowling wolf" }

    $summary = Get-MonsterZoneProgressionSummaryText -Game $game

    Assert-True -Condition ($summary -like "*landmarks 2/4*") -Message "Monster-zone progression summary should show landmark progress toward level 6."
    Assert-True -Condition ($summary -like "*defeated types 1/3*") -Message "Monster-zone progression summary should show defeated creature type progress."
    Assert-True -Condition ($summary -like "*Dorr reports 1/2*") -Message "Monster-zone progression summary should show Dorr report progress."
    Assert-True -Condition ($summary -like "*route/contract 0/1*") -Message "Monster-zone progression summary should show the route or contract requirement."
}

function Test-MonsterZoneProgressionSummaryChangesAfterCapUnlock {
    $game = Initialize-Game
    $game.Hero.Level = 5
    $game.Hero.LevelCap = 6
    $game.Hero.XP = 8200
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    $game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] = $true

    $summary = Get-MonsterZoneProgressionSummaryText -Game $game

    Assert-True -Condition ($summary -like "*Level 6 cap open*") -Message "After cap unlock, progression summary should tell the player to earn XP and rest."
    Assert-True -Condition ($summary -like "*8200/9500*") -Message "After cap unlock, progression summary should show XP progress to level 6."
}

function Test-LevelSixGateDefenseRunsScriptedWaves {
    $game = Initialize-Game
    $game.Hero.Level = 6
    $game.Hero.LevelCap = 6
    $game.Hero.XP = 9500
    $game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] = $true
    $heroHP = $game.Hero.HP

    $event = Start-LevelSixGateDefenseEvent -Game $game -HeroHP ([ref]$heroHP) -ForceWin $true
    $repeat = Start-LevelSixGateDefenseEvent -Game $game -HeroHP ([ref]$heroHP) -ForceWin $true

    Assert-Equal -Actual $event.Started -Expected $true -Message "The level 6 gate defense should start when the hero has reached level 6 and unlocked the cap."
    Assert-Equal -Actual $event.Completed -Expected $true -Message "The scripted gate defense should complete after its wave sequence."
    Assert-Equal -Actual $event.WavesCompleted -Expected 3 -Message "The gate defense should run three escalating waves."
    Assert-Equal -Actual $event.XP -Expected 2040 -Message "The gate defense should award wave XP plus the city-defense milestone."
    Assert-Equal -Actual $game.Hero.XP -Expected 11540 -Message "The hero should receive the scripted defense XP package once."
    Assert-Equal -Actual $game.Town.StoryFlags["LevelSixGateDefenseStarted"] -Expected $true -Message "The gate defense should mark its started flag."
    Assert-Equal -Actual $game.Town.StoryFlags["LevelSixGateDefenseCompleted"] -Expected $true -Message "The gate defense should mark its completion flag."
    Assert-Equal -Actual $repeat.Started -Expected $false -Message "The completed gate defense should not start twice."
}

function Test-LevelSixGateDefenseWaitsForActualLevelSix {
    $game = Initialize-Game
    $game.Hero.Level = 5
    $game.Hero.LevelCap = 6
    $game.Town.StoryFlags["MonsterZoneLevelSixCapUnlocked"] = $true
    $heroHP = $game.Hero.HP

    $event = Start-LevelSixGateDefenseEvent -Game $game -HeroHP ([ref]$heroHP) -ForceWin $true

    Assert-Equal -Actual $event.Started -Expected $false -Message "Opening the level 6 cap should not start the defense before the hero actually reaches level 6."
    Assert-Equal -Actual $game.Town.StoryFlags["LevelSixGateDefenseCompleted"] -Expected $null -Message "The gate defense should remain untouched before level 6."
}

function Test-MonsterZoneObjectiveStartsWithLandmarkSearch {
    $game = Initialize-Game

    $objective = Get-MonsterZoneObjectiveState -Game $game

    Assert-Equal -Actual $objective.Type -Expected "FindLandmark" -Message "A fresh monster-zone trip should first point the player toward a reliable landmark."
    Assert-True -Condition ($objective.Detail -like "*first reliable place*") -Message "The first objective should explain why the player is leaving the gate road."
    Assert-True -Condition ($objective.NextStep -like "*Travel*search*") -Message "The first objective should give a concrete next action."
}

function Test-MonsterZoneObjectivePrioritizesDorrProof {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    Add-MonsterZoneOddity -Game $game -Creature $creature | Out-Null
    $objective = Get-MonsterZoneObjectiveState -Game $game

    Assert-Equal -Actual $objective.Type -Expected "ReturnProofToDorr" -Message "Unreported defeated creatures should become the top monster-zone objective."
    Assert-True -Condition ($objective.Detail -like "*kobold wall scout*") -Message "The Dorr proof objective should name the defeated creature trail."
    Assert-True -Condition ($objective.NextStep -like "*fighting ring*Dorr*") -Message "The Dorr proof objective should tell the player where to report it."
}

function Test-MonsterZoneObjectiveWarnsWhenOddityHaulIsFull {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "razor_boar" } | Select-Object -First 1

    $game.Town.MonsterZone.DiscoveredLandmarks["burned_orchard"] = $true
    Add-MonsterZoneOddity -Game $game -Creature $creature | Out-Null
    $game.Town.MonsterZone.ReportedCreaturesToDorr["razor_boar"] = @{ Name = "razor-tusk boar" }
    $objective = Get-MonsterZoneObjectiveState -Game $game

    Assert-Equal -Actual $objective.Type -Expected "ReturnOddities" -Message "A full oddity haul should tell the player to return before wasting parts."
    Assert-True -Condition ($objective.Detail -like "*1/1*") -Message "The full-haul objective should show current oddity capacity."
    Assert-True -Condition ($objective.NextStep -like "*Return*city gate*") -Message "The full-haul objective should tell the player to head back."
}

function Test-MonsterZoneTownReminderOnlyAppearsWhenUnlocked {
    $game = Initialize-Game

    $locked = Get-MonsterZoneTownReminderText -Game $game
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    $unlocked = Get-MonsterZoneTownReminderText -Game $game

    Assert-Equal -Actual $locked -Expected "" -Message "Town should not show monster-zone reminders before the wall rumors unlock the area."
    Assert-True -Condition ($unlocked -like "*Beyond the wall*first reliable landmark*") -Message "Town should show a short actionable monster-zone reminder once the area is open."
}

function Test-MonsterZoneObjectiveSummaryIncludesNextStep {
    $game = Initialize-Game
    $summary = Get-MonsterZoneObjectiveSummaryText -Game $game

    Assert-True -Condition ($summary -like "*Find a landmark*") -Message "Objective summary should include the current objective title."
    Assert-True -Condition ($summary -like "*Next:*") -Message "Objective summary should include a next-step label."
}

function Test-MonsterZoneLandmarkDiscoveryCreatesFieldLead {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "dry_creek_bed" } | Select-Object -First 1

    $discovery = Discover-MonsterZoneLandmark -Game $game -Landmark $landmark
    $lead = Get-MonsterZoneLastFieldLead -Game $game

    Assert-Equal -Actual $lead["Type"] -Expected "Landmark" -Message "First landmark discovery should become the latest field lead."
    Assert-True -Condition ($discovery.Text -like "*Field lead:*") -Message "Landmark discovery text should include the concrete follow-up lead."
    Assert-True -Condition ($lead["NextStep"] -like "*creature trail*" -or $lead["NextStep"] -like "*tracking*") -Message "Dry Creek Bed should point the player toward tracking a creature trail."
}

function Test-MonsterZoneObjectiveFollowsLatestLandmarkLead {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "collapsed_watchtower" } | Select-Object -First 1

    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    $objective = Get-MonsterZoneObjectiveState -Game $game

    Assert-Equal -Actual $objective.Type -Expected "FollowFieldLead" -Message "After a landmark discovery, the monster-zone objective should follow the latest field lead."
    Assert-True -Condition ($objective.Detail -like "*watched the wall*") -Message "The landmark lead objective should carry the specific landmark payoff."
    Assert-True -Condition ($objective.NextStep -like "*Search*tracks*") -Message "The landmark lead objective should tell the player the next concrete action."
}

function Test-MonsterZoneCreatureProofUpdatesFieldLead {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "wall_wolf" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    $lead = Get-MonsterZoneLastFieldLead -Game $game

    Assert-Equal -Actual $lead["Type"] -Expected "CreatureProof" -Message "Creature proof should become the latest field lead."
    Assert-True -Condition ($lead["NextStep"] -like "*Return*report*") -Message "Creature proof lead should push the player back toward reporting."
}

function Test-MonsterZoneOddityUpdatesFieldLead {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "razor_boar" } | Select-Object -First 1

    Add-MonsterZoneOddity -Game $game -Creature $creature | Out-Null
    $lead = Get-MonsterZoneLastFieldLead -Game $game

    Assert-Equal -Actual $lead["Type"] -Expected "Oddity" -Message "Securing an oddity should become the latest field lead."
    Assert-True -Condition ($lead["TownLead"] -like "*Razor Boar Tusk*") -Message "Oddity field lead should remember the actual part secured."
}

function Test-MonsterZoneFieldLeadActionCreatesCreatureTrail {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "burned_orchard" } | Select-Object -First 1

    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    $result = Resolve-MonsterZoneFieldLeadAction -Game $game
    $objective = Get-MonsterZoneObjectiveState -Game $game

    Assert-Equal -Actual $result.Success -Expected $true -Message "A fresh landmark field lead should be followable."
    Assert-Equal -Actual $result.Repeated -Expected $false -Message "The first field lead action should not be marked as repeated."
    Assert-Equal -Actual $result.NewLead["Type"] -Expected "CreatureTrail" -Message "Following a landmark field lead should turn it into a creature-trail lead."
    Assert-True -Condition ($result.XPMessage -like "*80 XP*") -Message "Following a new field lead should award a small one-time XP payoff."
    Assert-Equal -Actual $objective.Type -Expected "FollowFieldLead" -Message "The current objective should continue following the new creature-trail lead."
    Assert-True -Condition ($objective.NextStep -like "*Travel*search*creature*") -Message "The creature-trail objective should point the player toward finding the encounter."
}

function Test-MonsterZoneFieldLeadActionDoesNotFarmXp {
    $game = Initialize-Game
    $landmark = Get-MonsterZoneLandmarks | Where-Object { $_.Id -eq "survey_camp" } | Select-Object -First 1

    Discover-MonsterZoneLandmark -Game $game -Landmark $landmark | Out-Null
    $firstXp = [int]$game.Hero.XP
    Resolve-MonsterZoneFieldLeadAction -Game $game | Out-Null
    $afterFirst = [int]$game.Hero.XP
    $repeat = Resolve-MonsterZoneFieldLeadAction -Game $game

    Assert-Equal -Actual ($afterFirst - $firstXp) -Expected 80 -Message "The first field lead follow-up should grant exactly its small XP payoff."
    Assert-Equal -Actual $repeat.XPMessage -Expected "" -Message "Repeating a field lead follow-up should not award XP again."
    Assert-Equal -Actual $game.Hero.XP -Expected $afterFirst -Message "Repeated field lead follow-up should not change hero XP."
}

function Test-MonsterZoneFieldLeadActionOnlyForLandmarks {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "wall_wolf" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    $available = Test-MonsterZoneFieldLeadActionAvailable -Game $game
    $result = Resolve-MonsterZoneFieldLeadAction -Game $game

    Assert-Equal -Actual $available -Expected $false -Message "Town-report leads should not show as field-followable."
    Assert-Equal -Actual $result.Success -Expected $false -Message "Creature proof leads should point back to town rather than resolving in the field."
    Assert-True -Condition ($result.Message -like "*back to town*") -Message "Non-field leads should explain that they point back to town."
}

function Test-CampImprovementLowersNightRisk {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-MonsterZoneWeather -Game $game -WeatherId "clear" | Out-Null

    $openSky = Resolve-MonsterZoneCampAction -Game $game -HeroHP ([ref]$heroHP) -Action "OpenSky" -NightRoll 100
    $basic = Resolve-MonsterZoneCampAction -Game $game -HeroHP ([ref]$heroHP) -Action "Build" -NightRoll 100
    $hidden = Resolve-MonsterZoneCampAction -Game $game -HeroHP ([ref]$heroHP) -Action "Improve" -NightRoll 100

    Assert-Equal -Actual $openSky.NightRisk -Expected 55 -Message "Open sky rest should have the highest starting night risk."
    Assert-Equal -Actual $basic.NightRisk -Expected 40 -Message "Basic camp should lower night risk."
    Assert-Equal -Actual $hidden.NightRisk -Expected 25 -Message "Improved hidden camp should lower night risk further."
    Assert-Equal -Actual (Get-MonsterZoneCurrentCampLevel -Game $game) -Expected 2 -Message "Build then improve should leave the current position with a level 2 camp."
}

Test-MonsterZoneUnlocksFromWallRumors
Test-MonsterZoneTravelFindsPersistentLandmark
Test-MonsterZoneLandmarkFamiliarityGrowsAcrossDays
Test-MonsterZoneLandmarkDirectTravelUnlocksAfterRepeatDays
Test-MonsterZoneLandmarksAwardMilestoneXPOnce
Test-MonsterZoneSoftEdgeBlocksOvertravel
Test-WildernessAwarenessCanGiveHeroAdvantage
Test-BarbarianDangerSenseStartsAtLevelTwo
Test-InvisibilityImprovesMonsterZoneStealth
Test-MonsterZoneKeenSensesHelpAgainstStealth
Test-MonsterZoneBlindsightCountersInvisibilityBonus
Test-MonsterZoneCreaturesHaveObservationFlavor
Test-MonsterZoneCreaturePoolScalesWithLevelCap
Test-MonsterZoneWeatherPersistsForCurrentDay
Test-MonsterZoneWeatherModifiesAwareness
Test-MonsterZoneWeatherChangesCampRisk
Test-MonsterZoneAddsMoreCreatureTypes
Test-MonsterZoneClassReadsAreDistinct
Test-BardCanCastInvisibilityFromMonsterZoneMenu
Test-PackAnimalControlsMonsterOddityCapacity
Test-MonsterZoneTracksDefeatedCreatureProof
Test-MonsterZoneProgressionCanRaiseCapToSix
Test-MonsterZoneProgressionSummaryShowsLevelSixRequirements
Test-MonsterZoneProgressionSummaryChangesAfterCapUnlock
Test-LevelSixGateDefenseRunsScriptedWaves
Test-LevelSixGateDefenseWaitsForActualLevelSix
Test-MonsterZoneObjectiveStartsWithLandmarkSearch
Test-MonsterZoneObjectivePrioritizesDorrProof
Test-MonsterZoneObjectiveWarnsWhenOddityHaulIsFull
Test-MonsterZoneTownReminderOnlyAppearsWhenUnlocked
Test-MonsterZoneObjectiveSummaryIncludesNextStep
Test-MonsterZoneLandmarkDiscoveryCreatesFieldLead
Test-MonsterZoneObjectiveFollowsLatestLandmarkLead
Test-MonsterZoneCreatureProofUpdatesFieldLead
Test-MonsterZoneOddityUpdatesFieldLead
Test-MonsterZoneFieldLeadActionCreatesCreatureTrail
Test-MonsterZoneFieldLeadActionDoesNotFarmXp
Test-MonsterZoneFieldLeadActionOnlyForLandmarks
Test-CampImprovementLowersNightRisk

Write-Host "Monster zone tests passed." -ForegroundColor Green
