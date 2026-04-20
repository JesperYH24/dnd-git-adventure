function Start-ClassSelection {
    while ($true) {
        Clear-Host
        Write-SectionTitle -Text "A Call To Adventure" -Color "Magenta"
        Write-Scene "Beyond the last warm hearth and the final lantern on the road, the world yawns wide with ruined keeps, buried vaults, oathbound steel, and songs older than any kingdom now standing."
        Write-Scene "This is an age of road dust, dragonfire, sacred relics, and whispered bargains made beneath taverns, towers, and tomb doors sealed by forgotten hands."
        Write-Scene "Tonight, one soul steps from the edge of ordinary life and into that wider legend, where hunger, glory, terror, and triumph all wait beneath the same dark sky."
        Write-Scene "Choose the shape your story takes, and let the realm remember the class that first answered the call."
        Write-ColorLine ""
        Write-ColorLine "1. Barbarian" "White"
        Write-ColorLine "2. Bard" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" { return "Barbarian" }
            "2" { return "Bard" }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}

function Start-Intro {
    param(
        $Hero,
        [ref]$HeroHP
    )

    Write-SectionTitle -Text "The First Night" -Color "Yellow"
    Write-Scene "Night hangs heavy over the forest, and the wild dark presses close around the little circle of firelight."
    Write-Scene "$($Hero.Name) sits beside the campfire outside a black-mouthed cave, with steel, breath, and fate gathering in the hush before danger."
    Write-Scene "Old roads, hungry ruins, and the promise of hard-won glory all seem to narrow toward this one moment."
    Write-Scene "$($Hero.Name) stands at level $($Hero.Level) as a $($Hero.Class), carrying $($HeroHP.Value)/$($Hero.HP) HP into whatever waits below."
    Write-Scene "Somewhere in the depths, the first true trial of the adventure stirs."
    Write-ColorLine ""
}

function Ensure-TutorialArrivalStarterFunds {
    param($Game)

    $cheapestInn = Get-CheapestTownInn

    if ($null -eq $cheapestInn) {
        return $null
    }

    $missingCopper = [Math]::Max(0, [int]$cheapestInn.PriceCopper - [int]$Game.Hero.CurrencyCopper)

    if ($missingCopper -le 0) {
        return $null
    }

    Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $missingCopper | Out-Null

    return [PSCustomObject]@{
        CopperGranted = $missingCopper
        Inn = $cheapestInn
    }
}

function Show-BardTutorialCampfireHint {
    param($Game)

    if ($Game.Hero.Class -ne "Bard" -or $Game.Quest.Completed) {
        return
    }

    if ($null -eq $Game.Hero.PSObject.Properties["TutorialCampfireHintShown"]) {
        $Game.Hero | Add-Member -NotePropertyName TutorialCampfireHintShown -NotePropertyValue $false
    }

    if ($Game.Hero.TutorialCampfireHintShown) {
        return
    }

    Write-Scene "$($Game.Hero.Name) carries a musician's edge into the cave. At the campfire, the instrument can be used to prepare bardic inspiration before danger begins."
    Write-Scene "Prepared inspiration can boost attack, block, or focus, and it also fuels Cutting Words. It comes back on a short rest, so it is worth readying before the first descent."
    Write-ColorLine ""
    $Game.Hero.TutorialCampfireHintShown = $true
}

function Confirm-BardTutorialPreparation {
    param($Game)

    if ($Game.Hero.Class -ne "Bard" -or $Game.Quest.Completed) {
        return
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero

    if ($null -eq $bardicStatus -or $null -eq $bardicStatus.Instrument -or $bardicStatus.CurrentDice -gt 0) {
        return
    }

    Write-Scene "$($Game.Hero.Name) can take one last breath by the fire and ready bardic inspiration on the $($bardicStatus.Instrument.Name.ToLower()) before entering the cave."
    Write-ColorLine "1. Prepare bardic inspiration now" "White"
    Write-ColorLine "2. Enter the cave without preparing" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $preparation = Prepare-HeroBardicInspiration -Hero $Game.Hero
                Write-Scene $preparation.Message
                Write-ColorLine ""
                return
            }
            "2" {
                Write-Scene "$($Game.Hero.Name) lets the last note fade and steps into danger without a prepared refrain."
                Write-ColorLine ""
                return
            }
            default {
                Write-ColorLine "Choose 1 or 2." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Reset-TutorialAfterDefeat {
    param(
        $Game,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon
    )

    $freshGame = Initialize-Game -Class $Game.Hero.Class

    foreach ($key in @($Game.Keys)) {
        $Game.Remove($key)
    }

    foreach ($entry in $freshGame.GetEnumerator()) {
        $Game[$entry.Key] = $entry.Value
    }

    Set-UiHeroName -Name $Game.Hero.Name
    $HeroHP.Value = [int]$Game.HeroHP
    $HeroDroppedWeapon.Value = [bool]$Game.HeroDroppedWeapon

    Write-SectionTitle -Text "Defeat" -Color "Red"
    Write-Scene "$($Game.Hero.Name) wakes again by the campfire with the whole failed descent still hanging in the nerves like a bad dream."
    Write-Scene "The cave must be faced again from the beginning."
    Write-ColorLine ""
}

function Complete-TutorialAndEnterTown {
    param(
        $Game,
        [ref]$HeroHP,
        [bool]$DebugSkip = $false
    )

    if ($DebugSkip) {
        Write-SectionTitle -Text "Tutorial Skip" -Color "Yellow"
        Write-Scene "A hidden shortcut pulls $($Game.Hero.Name) past the early trial and straight toward the city's next chapter."
        Write-Scene "The cave's warning is treated as known, and the road to town opens for testing."
        Write-ColorLine ""
        $Game.Quest.SeenDragon = $true

        if (-not $Game.ShadowSanctumRewardTaken) {
            $currencyResult = Add-HeroCurrency -Hero $Game.Hero -Denomination "GP" -Amount (Get-ShadowSanctumGoldRewardGP)

            if ($currencyResult.LeftoverCopper -gt 0 -and $null -ne $currencyResult.LeftoverItem) {
                $ashenThreshold = $Game.Rooms["ashen_threshold"]
                $ashenThreshold.Loot += $currencyResult.LeftoverItem
            }

            Clear-HeroBuff -Hero $Game.Hero
            $Game.ShadowSanctumRewardTaken = $true
        }
    }

    Write-Scene "'Report first,' one of them says. 'Tell the captain what you saw in that cave.'"
    Write-Scene "The guards exchange uneasy looks, then hurry $($Game.Hero.Name) through the gates."
    Write-Scene "They lead him straight to the quest giver so the warning can be heard at once."
    Write-Scene "$($Game.Hero.Name) delivers the warning about the dragon, and the city finally listens."
    $Game.Hero.LevelCap = 3
    $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Game.Hero
    $remainingTutorialXP = [Math]::Max(0, $nextLevelXP - $Game.Hero.XP)

    if ($remainingTutorialXP -gt 0) {
        Grant-HeroXP -Hero $Game.Hero -XP $remainingTutorialXP
        Write-Scene "$($Game.Hero.Name) gains the final $remainingTutorialXP XP from completing the tutorial."
    }

    $starterFunds = Ensure-TutorialArrivalStarterFunds -Game $Game

    if ($null -ne $starterFunds) {
        Write-Scene "Seeing $($Game.Hero.Name) nearly coinless, the quest giver presses just enough travel silver into his hand to cover the cheapest bed in town."
        Write-Scene "$($Game.Hero.Name) gains $(Convert-CopperToCurrencyText -Copper $starterFunds.CopperGranted), enough for a room at $($starterFunds.Inn.Name)."
    }

    Write-Scene "At last, $($Game.Hero.Name) is given food, warmth, and a real night's sleep behind the city walls."
    $levelUpMode = ""

    if ($DebugSkip) {
        $levelUpMode = "F"
    }

    $levelUpResult = Resolve-HeroLongRestLevelUp -Hero $Game.Hero -HeroHP $HeroHP -HPMode $levelUpMode
    $Game.Quest.Completed = $true
    $Game.Town.MustChooseFirstInn = $true

    if ($levelUpResult.LeveledUp) {
        $latestLevelUp = $levelUpResult.Results | Select-Object -Last 1
        Write-SectionTitle -Text "Level Up" -Color "Yellow"
        Write-EmphasisLine -Text "$($Game.Hero.Name) reaches level $($Game.Hero.Level)!" -Color "Yellow"
        Write-Scene "The tutorial has hardened him. His strength steadies, and his endurance grows."
        if ($latestLevelUp.Mode -eq "R") {
            Write-Scene "He gambles on the hit die and rolls a $($latestLevelUp.Roll), gaining $($latestLevelUp.Gain) HP."
        }
        else {
            Write-Scene "He takes the steady path and gains the fixed $($latestLevelUp.Gain) HP."
        }
        Write-Scene "Max HP rises to $($Game.Hero.HP), and he feels ready for the road ahead."
        Write-ColorLine ""
    }

    Write-SectionTitle -Text "Tutorial Complete" -Color "Green"
    Write-EmphasisLine -Text "$($Game.Hero.Name) survives the cave, delivers the warning, and completes the tutorial adventure." -Color "Green"
    Write-Scene "Now the city opens around him, with shops, rumors, and new roads waiting beyond the tutorial."
    Write-ColorLine ""
    return "EnterTown"
}

function Start-CampfireMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== CAMPFIRE =====" "Yellow"
        Show-BardTutorialCampfireHint -Game $Game
        Write-Scene "The campfire is a rare moment of safety. $($Game.Hero.Name) can gather his thoughts here."
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Check inventory" "White"
        Write-ColorLine "2. Enter the cave" "White"
        Write-ColorLine "3. Head to town" "White"
        Write-ColorLine "4. Check quest log" "White"
        if ($Game.Hero.Class -eq "Bard") {
            $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero
            $instrumentName = if ($null -ne $bardicStatus.Instrument) { $bardicStatus.Instrument.Name } else { "your instrument" }
            Write-ColorLine "5. Prepare bardic inspiration with $instrumentName ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) ready)" "White"
        }
        Write-ColorLine "G. Save adventure" "White"
        Write-TextSpeedOption
        Write-ColorLine ""

        $choice = Read-Host "Choose"
        $hiddenChoice = $choice.ToUpper()

        if ($hiddenChoice -eq "SKIP" -or $hiddenChoice -eq "SKIPTUTORIAL") {
            return (Complete-TutorialAndEnterTown -Game $Game -HeroHP $HeroHP -DebugSkip $true)
        }

        switch ($choice) {
            "1" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }

            "2" {
                Confirm-BardTutorialPreparation -Game $Game
                Write-Scene "$($Game.Hero.Name) rises, grips the weapon, and walks toward the cave entrance..."
                Write-Scene "Darkness closes in around him."
                Write-ColorLine ""
                return "EnterCave"
            }

            "3" {
                Write-Scene "$($Game.Hero.Name) follows the old road back toward the town gates."

                if (-not $Game.Quest.Completed) {
                    Write-Scene "The guards lower their spears and block the road."
                    if ($Game.Quest.SeenDragon) {
                        return (Complete-TutorialAndEnterTown -Game $Game -HeroHP $HeroHP)
                    }
                    Write-Scene "'No entry,' one of them says. 'Not until you report what is inside that cave.'"
                    Write-Scene "$($Game.Hero.Name) has no choice but to return to the campfire and face the cave."
                    Write-ColorLine ""
                    continue
                }

                    Write-Scene "The guards recognize the urgency in $($Game.Hero.Name)'s face and let him through."
                Write-Scene "$($Game.Hero.Name) returns to town with hard-earned knowledge from the cave."
                Write-ColorLine ""
                return "EnterTown"
            }

            "4" {
                Show-QuestLog -Game $Game -Hero $Game.Hero
            }
            "5" {
                if ($Game.Hero.Class -eq "Bard") {
                    $preparation = Prepare-HeroBardicInspiration -Hero $Game.Hero
                    Write-Scene $preparation.Message
                    Write-ColorLine ""
                }
                else {
                    Write-ColorLine "Invalid choice. Try again." "Red"
                    Write-ColorLine ""
                }
            }
            "G" {
                Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null
            }
            "T" {
                Toggle-TextSpeed | Out-Null
            }

            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }

    Write-Scene "$($Game.Hero.Name) steps into the dark cave..."
    Write-Scene "Something is waiting in here..."
    Write-ColorLine ""
}

function Start-DetectionPhase {
    param(
        $Hero,
        $Monster,
        [ref]$HeroStarts,
        [ref]$MonsterStarts
    )

    $heroDexModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"
    $monsterInitiativeBonus = 0

    if ($null -ne $Monster.initiativeBonus) {
        $monsterInitiativeBonus = [int]$Monster.initiativeBonus
    }

    $heroHasAdvantage = Get-HeroHasInitiativeAdvantage -Hero $Hero
    $heroFirstRoll = Roll-Dice -Sides 20
    $heroRoll = $heroFirstRoll
    $heroSecondRoll = $null

    if ($heroHasAdvantage) {
        $heroSecondRoll = Roll-Dice -Sides 20
        $heroRoll = [Math]::Max($heroFirstRoll, $heroSecondRoll)
    }

    $monsterRoll = Roll-Dice -Sides 20
    $heroTotal = $heroRoll + $heroDexModifier
    $monsterTotal = $monsterRoll + $monsterInitiativeBonus

    if ($heroHasAdvantage) {
        Write-Scene "$($Hero.Name) rolls initiative with d20 advantage: $heroFirstRoll and $heroSecondRoll, taking $heroRoll $(Format-AbilityModifier -Modifier $heroDexModifier) = $heroTotal"
    }
    else {
        Write-Scene "$($Hero.Name) rolls initiative on d20: $heroRoll $(Format-AbilityModifier -Modifier $heroDexModifier) = $heroTotal"
    }
    Write-Scene "$($Monster.definite) rolls initiative on d20: $monsterRoll $(Format-AbilityModifier -Modifier $monsterInitiativeBonus) = $monsterTotal"
    Write-ColorLine ""

    if ($heroRoll -eq 20) {
        Write-Scene "$($Hero.Name) seizes the moment with a perfect initiative roll!"
        $HeroStarts.Value = $true
    }
    elseif ($heroTotal -ge $monsterTotal) {
        Write-Scene "$($Hero.Name) moves first and catches $($Monster.definite) off guard."
        $HeroStarts.Value = $true
    }
    else {
        Write-Scene "$($Monster.definite) is quicker on the draw and strikes first!"
        $MonsterStarts.Value = $true
    }
}
