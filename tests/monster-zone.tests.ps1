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
}

function Test-CampImprovementLowersNightRisk {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

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
Test-MonsterZoneSoftEdgeBlocksOvertravel
Test-WildernessAwarenessCanGiveHeroAdvantage
Test-BarbarianDangerSenseStartsAtLevelTwo
Test-InvisibilityImprovesMonsterZoneStealth
Test-MonsterZoneKeenSensesHelpAgainstStealth
Test-MonsterZoneBlindsightCountersInvisibilityBonus
Test-MonsterZoneCreaturesHaveObservationFlavor
Test-BardCanCastInvisibilityFromMonsterZoneMenu
Test-PackAnimalControlsMonsterOddityCapacity
Test-MonsterZoneTracksDefeatedCreatureProof
Test-CampImprovementLowersNightRisk

Write-Host "Monster zone tests passed." -ForegroundColor Green
