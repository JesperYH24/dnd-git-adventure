. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\ui.ps1"

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon
    )

    $weapon = Get-HeroWeaponProfile -Hero $Hero
    $targetArmorClass = [int]$Monster.armorClass
    $heroRoll = Roll-Dice -Sides 20
    $attackTotal = $heroRoll + $weapon.TotalAttackBonus

    Write-Action "$($Hero.Name) attacks with $($weapon.Name): roll $heroRoll, total $attackTotal vs AC $targetArmorClass" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $heroDamage = [Math]::Max(1, $weapon.DamageMax + $extraDamageRoll + $weapon.DamageBonus)
        $MonsterHP.Value -= $heroDamage

        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($($weapon.DamageMax) + $extraDamageRoll + $($weapon.DamageBonus))" "Yellow"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumbles, drops the weapon, and must pick it up next turn!"
    }
    elseif ($attackTotal -ge $targetArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $heroDamage = [Math]::Max(1, $damageRoll + $weapon.DamageBonus)
        $MonsterHP.Value -= $heroDamage

        Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage! ($damageRoll + $($weapon.DamageBonus))" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) misses the attack!" "DarkGray"
    }

    if ($MonsterHP.Value -lt 0) {
        $MonsterHP.Value = 0
    }

    Write-ColorLine ""
}

function Invoke-MonsterAttack {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance
    )

    $heroArmorClass = Get-HeroArmorClass -Hero $Hero
    $attackRoll = Roll-Dice -Sides 20
    $attackTotal = $attackRoll + [int]$Monster.attackBonus
    Write-Action "$($Monster.definite) attacks: roll $attackRoll, total $attackTotal vs AC $heroArmorClass" "DarkCyan"

    if ($attackRoll -eq 20) {
        Write-Action "CRITICAL HIT!" "Red"
        $firstDamageRoll = Roll-MonsterDamage -Monster $Monster
        $secondDamageRoll = Roll-MonsterDamage -Monster $Monster
        $monsterDamage = $firstDamageRoll + $secondDamageRoll

        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage! ($firstDamageRoll + $secondDamageRoll)" "Yellow"
    }
    elseif ($attackRoll -eq 1) {
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Action "$($Monster.definite) stumbles and loses its balance!" "DarkYellow"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackTotal -ge $heroArmorClass) {
        $monsterDamage = Roll-MonsterDamage -Monster $Monster
        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) hits for $monsterDamage damage!" "Yellow"
    }
    else {
        Write-Action "$($Monster.definite) misses!" "DarkGray"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
    }

    Write-ColorLine ""
}

function Resolve-DroppedWeaponTurn {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance
    )

    $choice = "P"

    if ($Hero.Class -eq "Barbarian") {
        Write-ColorLine "What do you do?" "Cyan"
        Write-ColorLine "P. Pick up the weapon and lose the turn" "White"
        Write-ColorLine "G. Grapple with raw strength" "White"
        Write-ColorLine ""

        while ($true) {
            $choice = (Read-Host "Choose (P/G)").ToUpper()

            if ($choice -in @("P", "G")) {
                break
            }

            Write-ColorLine "Choose P or G." "DarkYellow"
            Write-ColorLine ""
        }
    }

    if ($choice -eq "G") {
        $heroStrengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
        $monsterStrengthBonus = 0

        if ($null -ne $Monster.strengthCheckBonus) {
            $monsterStrengthBonus = [int]$Monster.strengthCheckBonus
        }
        elseif ($null -ne $Monster.attackBonus) {
            $monsterStrengthBonus = [int]$Monster.attackBonus
        }

        $heroRoll = Roll-Dice -Sides 20
        $monsterRoll = Roll-Dice -Sides 20
        $heroTotal = $heroRoll + $heroStrengthModifier
        $monsterTotal = $monsterRoll + $monsterStrengthBonus

        Write-Action "$($Hero.Name) lunges for a grapple: roll $heroRoll, total $heroTotal" "Cyan"
        Write-Action "$($Monster.definite) resists: roll $monsterRoll, total $monsterTotal" "DarkCyan"

        if ($heroRoll -eq 20 -or ($monsterRoll -ne 20 -and $heroTotal -ge $monsterTotal)) {
            Write-Action "$($Hero.Name) slams into $($Monster.definite), forces it off balance, and snatches the weapon back!" "Yellow"
            $HeroDroppedWeapon.Value = $false
            $MonsterOffBalance.Value = $true
            Write-ColorLine ""
            return
        }

        Write-Scene "$($Hero.Name) fails to overpower $($Monster.definite) and is left exposed!"
        Write-ColorLine ""
    }
    else {
        Write-Scene "$($Hero.Name) picks up the weapon and loses the turn!"
        $HeroDroppedWeapon.Value = $false
        Write-ColorLine ""
    }

    if (-not $MonsterOffBalance.Value) {
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance
    }
    else {
        Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
        $MonsterOffBalance.Value = $false
        Write-ColorLine ""
    }
}

function Start-CombatLoop {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance,
        [ref]$EncounterFled,
        [bool]$SkipInitialStatus = $false
    )

    $showStatus = -not $SkipInitialStatus

    while ($HeroHP.Value -gt 0 -and $MonsterHP.Value -gt 0) {
        if ($showStatus) {
            Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value
        }

        $showStatus = $true

        if ($HeroDroppedWeapon.Value) {
            Resolve-DroppedWeaponTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon -MonsterOffBalance $MonsterOffBalance

            if ($HeroHP.Value -le 0) {
                Write-Scene "$($Hero.Name) falls in battle..."
                break
            }

            continue
        }

        $choice = (Read-Host "What do you want to do? (A/I/R) - Attack, Inventory or Run").ToUpper()

        if ($choice -eq "I") {
            Write-ColorLine ""
            $usedItem = Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP

            if ($usedItem) {
                if (-not $MonsterOffBalance.Value) {
                    Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                    if ($HeroHP.Value -le 0) {
                        Write-Scene "$($Hero.Name) falls in battle..."
                        break
                    }
                }
                else {
                    Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
                    $MonsterOffBalance.Value = $false
                    Write-ColorLine ""
                }
            }

            continue
        }
        elseif ($choice -eq "R") {
            Write-Scene "$($Hero.Name) flees from $($Monster.definite)!"
            $EncounterFled.Value = $true
            break
        }
        elseif ($choice -eq "A") {
            Write-ColorLine ""
            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                if ($HeroHP.Value -le 0) {
                    Write-Scene "$($Hero.Name) falls in battle..."
                    break
                }
            }
            else {
                Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
                $MonsterOffBalance.Value = $false
                Write-ColorLine ""
            }
        }
        else {
            Write-ColorLine ""
            Write-ColorLine "Type A, I or R" "DarkYellow"
            Write-ColorLine ""
        }
    }
}
