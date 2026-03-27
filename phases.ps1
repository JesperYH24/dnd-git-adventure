function Start-Intro {
    param(
        $Hero,
        [ref]$HeroHP
    )

    Write-Scene "Night hangs heavy over the forest."
    Write-Scene "$($Hero.Name) sits by the campfire outside a dark cave."
    Write-Scene "The fire crackles softly while the wind slips through the trees."
    Write-Scene "$($Hero.Name) is a level $($Hero.Level) $($Hero.Class) with $($HeroHP.Value)/$($Hero.HP) HP."
    Write-Scene "Somewhere in the depths, danger waits..."
    Write-ColorLine ""
}

function Start-CampfireMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== CAMPFIRE =====" "Yellow"
        Write-Scene "The campfire is a rare moment of safety. Borzig can gather his thoughts here."
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Check inventory" "White"
        Write-ColorLine "2. Enter the cave" "White"
        Write-ColorLine "3. Head to town" "White"
        Write-ColorLine "4. Check quest log" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }

            "2" {
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
                        Write-Scene "'Report first,' one of them says. 'Tell the captain what you saw in that cave.'"
                        Write-Scene "The guards exchange uneasy looks, then hurry Borzig through the gates."
                        Write-Scene "They lead him straight to the quest giver so the warning can be heard at once."
                        Write-Scene "$($Game.Hero.Name) delivers the warning about the dragon, and the city finally listens."
                        $Game.Quest.Completed = $true
                        $Game.GameWon = $true
                        return "EnterTown"
                    }
                    Write-Scene "'No entry,' one of them says. 'Not until you report what is inside that cave.'"
                    Write-Scene "$($Game.Hero.Name) has no choice but to return to the campfire and face the cave."
                    Write-ColorLine ""
                    continue
                }

                Write-Scene "The guards recognize the urgency in Borzig's face and let him through."
                Write-Scene "$($Game.Hero.Name) returns to town with hard-earned knowledge from the cave."
                $Game.GameWon = $true
                return "EnterTown"
            }

            "4" {
                Show-QuestLog -Quest $Game.Quest
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
        [ref]$HeroBonusAttack,
        [ref]$MonsterStarts
    )

    $detectRoll = Roll-Dice -Sides 20
    Write-Scene "$($Hero.Name) rolls a d20 for initiative: $detectRoll"
    Write-ColorLine ""

    if ($detectRoll -ge 15) {
        Write-Scene "$($Hero.Name) seizes the initiative before $($Monster.definite) can react!"
        Write-Scene "$($Hero.Name) gains two immediate attacks."
        $HeroStarts.Value = $true
        $HeroBonusAttack.Value = $true
    }
    elseif ($detectRoll -ge 8) {
        Write-Scene "$($Hero.Name) and $($Monster.definite) clash at the same moment!"
        Write-Scene "$($Hero.Name) still manages to act first."
        $HeroStarts.Value = $true
    }
    else {
        Write-Scene "Too late! $($Monster.definite) lunges out of the shadows!"
        Write-Scene "$($Monster.definite) attacks first."
        $MonsterStarts.Value = $true
    }
}

function Start-OpeningPhase {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance,
        [bool]$HeroStarts,
        [bool]$HeroBonusAttack,
        [bool]$MonsterStarts
    )

    if ($HeroStarts) {
        $attacks = if ($HeroBonusAttack) { 2 } else { 1 }

        for ($i = 1; $i -le $attacks; $i++) {
            Write-ColorLine ""
            Write-Action "Opening attack $i of $attacks" "Cyan"

            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                return $false
            }

            if ($HeroDroppedWeapon.Value) {
                break
            }
        }

        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) falls in battle..."
            return $false
        }
    }
    elseif ($MonsterStarts) {
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) falls in battle..."
            return $false
        }
    }

    return $true
}
