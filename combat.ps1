. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\ui.ps1"

function Get-BarbarianCriticalKillText {
    param(
        $Hero,
        $Monster,
        $Weapon
    )

    $weaponName = "weapon"

    if ($null -ne $Weapon -and -not [string]::IsNullOrWhiteSpace($Weapon.Name)) {
        $weaponName = $Weapon.Name.ToLower()
    }

    return "$($Hero.Name) tears through $($Monster.definite) in a savage finishing blow, driving the $weaponName clean through the kill!"
}

function Get-MonsterCriticalDamage {
    param($Monster)

    $profile = Get-MonsterDamageProfile -Monster $Monster
    $extraDamageRoll = Roll-Dice -Sides $profile.DiceSides

    return [PSCustomObject]@{
        Damage = [Math]::Max(1, $profile.DamageMax + $extraDamageRoll)
        DamageMax = $profile.DamageMax
        ExtraDamageRoll = $extraDamageRoll
    }
}

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [int]$AttackBonusModifier = 0
    )

    $weapon = Get-HeroWeaponProfile -Hero $Hero
    $targetArmorClass = [int]$Monster.armorClass
    $heroRoll = Roll-Dice -Sides 20
    $attackTotal = $heroRoll + $weapon.TotalAttackBonus + $AttackBonusModifier

    $bonusText = ""

    if ($AttackBonusModifier -gt 0) {
        $bonusText = " (+$AttackBonusModifier focus)"
    }

    Write-Action "$($Hero.Name) attacks with $($weapon.Name): d20 roll $heroRoll, total $attackTotal$bonusText vs AC $targetArmorClass" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $bonusDamageRoll = Roll-WeaponBonusDamage -WeaponProfile $weapon
        $heroDamage = [Math]::Max(1, $weapon.DamageMax + $extraDamageRoll + $weapon.DamageBonus + $bonusDamageRoll)
        $MonsterHP.Value -= $heroDamage

        Write-Action "CRITICAL HIT!" "Red"
        if ($bonusDamageRoll -gt 0 -and -not [string]::IsNullOrWhiteSpace($weapon.BonusDamageType)) {
            Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($($weapon.DamageMax) + $extraDamageRoll + $($weapon.DamageBonus) + $bonusDamageRoll $($weapon.BonusDamageType.ToLower()))" "Yellow"
        }
        else {
            Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($($weapon.DamageMax) + $extraDamageRoll + $($weapon.DamageBonus))" "Yellow"
        }

        if ($MonsterHP.Value -le 0 -and $Hero.Class -eq "Barbarian") {
            Write-Scene (Get-BarbarianCriticalKillText -Hero $Hero -Monster $Monster -Weapon $weapon)
        }
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumbles, drops the weapon, and must pick it up next turn!"
    }
    elseif ($attackTotal -ge $targetArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $bonusDamageRoll = Roll-WeaponBonusDamage -WeaponProfile $weapon
        $heroDamage = [Math]::Max(1, $damageRoll + $weapon.DamageBonus + $bonusDamageRoll)
        $MonsterHP.Value -= $heroDamage

        if ($bonusDamageRoll -gt 0 -and -not [string]::IsNullOrWhiteSpace($weapon.BonusDamageType)) {
            Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage! ($damageRoll + $($weapon.DamageBonus) + $bonusDamageRoll $($weapon.BonusDamageType.ToLower()))" "Yellow"
        }
        else {
            Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage! ($damageRoll + $($weapon.DamageBonus))" "Yellow"
        }
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
        [ref]$MonsterOffBalance,
        [int]$BlockArmorBonus = 0,
        [int]$AttackPenaltyModifier = 0
    )

    $heroArmorClass = (Get-HeroArmorClass -Hero $Hero) + $BlockArmorBonus
    $attackRoll = Roll-Dice -Sides 20
    $attackTotal = $attackRoll + [int]$Monster.attackBonus - $AttackPenaltyModifier
    $blockText = ""
    $penaltyText = ""

    if ($BlockArmorBonus -gt 0) {
        $blockText = " (including +$BlockArmorBonus block)"
    }

    if ($AttackPenaltyModifier -gt 0) {
        $penaltyText = " (-$AttackPenaltyModifier distract)"
    }

    Write-Action "$($Monster.definite) attacks: d20 roll $attackRoll, total $attackTotal$penaltyText vs AC $heroArmorClass$blockText" "DarkCyan"

    if ($attackRoll -eq 20) {
        Write-Action "CRITICAL HIT!" "Red"
        $criticalDamage = Get-MonsterCriticalDamage -Monster $Monster
        $monsterDamage = $criticalDamage.Damage

        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage! ($($criticalDamage.DamageMax) + $($criticalDamage.ExtraDamageRoll))" "Yellow"
    }
    elseif ($attackRoll -eq 1) {
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Action "$($Monster.definite) stumbles and loses its balance!" "DarkYellow"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackTotal -ge $heroArmorClass) {
        $cuttingWordsResult = Try-Resolve-BardCuttingWords `
            -Hero $Hero `
            -Monster $Monster `
            -AttackTotal ([ref]$attackTotal) `
            -TargetArmorClass $heroArmorClass

        if ($cuttingWordsResult.PreventedHit) {
            Write-Action "$($Monster.definite) misses after the bard's cutting words throw off the strike!" "DarkGray"
            Write-ColorLine ""
            return
        }

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

function Resolve-HeroInspirationBoost {
    param(
        $Hero,
        [string]$PrimaryAction,
        [ref]$HeroAttackBonus,
        [ref]$HeroBlockArmorBonus,
        [ref]$HeroFocusAttackBonus
    )

    if ($Hero.Class -ne "Bard") {
        return
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return
    }

    if ($PrimaryAction -eq "A") {
        $boostLabel = "boost this attack"
    }
    elseif ($PrimaryAction -eq "B") {
        $boostLabel = "strengthen this block"
    }
    elseif ($PrimaryAction -eq "F") {
        $boostLabel = "sharpen this focus"
    }
    else {
        return
    }

    Write-ColorLine "Spend bardic inspiration to ${boostLabel}?" "Cyan"
    Write-ColorLine "1. Yes ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
    Write-ColorLine "2. No" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        if ($choice -eq "2") {
            Write-ColorLine ""
            return
        }

        if ($choice -eq "1") {
            $inspiration = Use-HeroBardicInspirationDie -Hero $Hero

            if (-not $inspiration.Success) {
                Write-ColorLine "No prepared bardic inspiration remains." "DarkYellow"
                Write-ColorLine ""
                return
            }

            if ($PrimaryAction -eq "A") {
                $HeroAttackBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) snaps into tempo on the $($inspiration.InstrumentName.ToLower()), drawing a sharper opening out of the moment."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) + $($inspiration.InstrumentBonus) instrument = +$($inspiration.TotalBonus) to hit." "Yellow"
            }
            elseif ($PrimaryAction -eq "B") {
                $HeroBlockArmorBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) lifts the rhythm at just the right instant and turns defense into a tighter guard."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) + $($inspiration.InstrumentBonus) instrument = +$($inspiration.TotalBonus) AC on this block." "Yellow"
            }
            else {
                $HeroFocusAttackBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) lets the $($inspiration.InstrumentName.ToLower()) carry a quick refrain that hangs in the air for the next clean opening."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) + $($inspiration.InstrumentBonus) instrument = +$($inspiration.TotalBonus) to the next attack." "Yellow"
            }

            Write-ColorLine ""
            return
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-HeroBonusAction {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP
    )

    if ($Hero.Class -ne "Bard" -or $MonsterHP.Value -le 0) {
        return
    }

    Write-ColorLine "Bonus action?" "Cyan"
    Write-ColorLine "M. Vicious Mockery" "White"
    Write-ColorLine "N. No bonus action" "DarkGray"
    Write-ColorLine ""

    while ($true) {
        $choice = (Read-Host "Choose bonus action").ToUpper()

        if ($choice -eq "N") {
            Write-ColorLine ""
            return
        }

        if ($choice -eq "M") {
            $spellSaveDC = Get-HeroSpellSaveDC -Hero $Hero
            $wisdomSaveBonus = 0

            if ($null -ne $Monster.PSObject.Properties["wisdomSaveBonus"]) {
                $wisdomSaveBonus = [int]$Monster.wisdomSaveBonus
            }

            $saveRoll = Roll-Dice -Sides 20
            $saveTotal = $saveRoll + $wisdomSaveBonus

            Write-Scene "$($Hero.Name) spits a vicious line that lands like a blade between the ribs of the mind."
            Write-Action "$($Monster.definite) makes a Wisdom save: d20 roll $saveRoll $(Format-AbilityModifier -Modifier $wisdomSaveBonus) = $saveTotal vs DC $spellSaveDC." "DarkCyan"

            if ($saveTotal -lt $spellSaveDC) {
                $damage = Roll-Dice -Sides 4
                $MonsterHP.Value = [Math]::Max(0, $MonsterHP.Value - $damage)
                Write-Action "Vicious Mockery deals $damage psychic damage." "Yellow"
            }
            else {
                Write-Action "$($Monster.definite) shakes off the mockery and takes no damage." "DarkGray"
            }

            Write-ColorLine ""
            return
        }

        Write-ColorLine "Choose M or N." "DarkYellow"
        Write-ColorLine ""
    }
}

function Try-Resolve-BardCuttingWords {
    param(
        $Hero,
        $Monster,
        [ref]$AttackTotal,
        [int]$TargetArmorClass
    )

    $result = [PSCustomObject]@{
        Used = $false
        PreventedHit = $false
    }

    if ($Hero.Class -ne "Bard") {
        return $result
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return $result
    }

    Write-ColorLine "Reaction? The attack would hit." "Cyan"
    Write-ColorLine "1. Use Cutting Words ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
    Write-ColorLine "2. Let the hit land" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        if ($choice -eq "2") {
            Write-ColorLine ""
            return $result
        }

        if ($choice -eq "1") {
            $inspiration = Use-HeroBardicInspirationDie -Hero $Hero

            if (-not $inspiration.Success) {
                Write-ColorLine "No prepared bardic inspiration remains." "DarkYellow"
                Write-ColorLine ""
                return $result
            }

            $AttackTotal.Value -= $inspiration.TotalBonus
            $result.Used = $true
            Write-Scene "$($Hero.Name) lashes out with cutting words, breaking the enemy's rhythm mid-swing."
            Write-Action "Cutting Words: d$($bardicStatus.DieSides) roll $($inspiration.Roll) + $($inspiration.InstrumentBonus) instrument = -$($inspiration.TotalBonus) to hit." "Yellow"

            if ($AttackTotal.Value -lt $TargetArmorClass) {
                $result.PreventedHit = $true
            }

            Write-ColorLine ""
            return $result
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }
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

        Write-Action "$($Hero.Name) lunges for a grapple: d20 roll $heroRoll, total $heroTotal" "Cyan"
        Write-Action "$($Monster.definite) resists: d20 roll $monsterRoll, total $monsterTotal" "DarkCyan"

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

function Show-BardTutorialCombatHint {
    param($Hero)

    if ($Hero.Class -ne "Bard" -or [int]$Hero.Level -ne 1) {
        return
    }

    if ($null -eq $Hero.PSObject.Properties["TutorialCombatHintShown"]) {
        $Hero | Add-Member -NotePropertyName TutorialCombatHintShown -NotePropertyValue $false
    }

    if ($Hero.TutorialCombatHintShown) {
        return
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return
    }

    Write-Scene "Prepared bardic inspiration can strengthen Attack, Block, or Focus after you choose the action. Vicious Mockery is your bonus action, and Cutting Words can interrupt a hit as a reaction."
    Write-ColorLine ""
    $Hero.TutorialCombatHintShown = $true
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
    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0

    while ($HeroHP.Value -gt 0 -and $MonsterHP.Value -gt 0) {
        if ($showStatus) {
            Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value
        }

        $showStatus = $true
        Show-BardTutorialCombatHint -Hero $Hero

        if ($HeroDroppedWeapon.Value) {
            Resolve-DroppedWeaponTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon -MonsterOffBalance $MonsterOffBalance

            if ($HeroHP.Value -le 0) {
                Write-Scene "$($Hero.Name) falls in battle..."
                break
            }

            continue
        }

        $choice = (Read-Host "What do you want to do? (A/B/F/I/R/T) - Attack, Block, Focus, Inventory, Run or Toggle text speed").ToUpper()
        $turnHeroAttackBonus = 0

        if ($choice -eq "I") {
            Write-ColorLine ""
            $usedItem = Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP -InCombat

            if ($usedItem) {
                if (-not $MonsterOffBalance.Value) {
                    Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -BlockArmorBonus $heroBlockArmorBonus
                    $heroBlockArmorBonus = 0

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
        elseif ($choice -eq "T") {
            Toggle-TextSpeed | Out-Null
            continue
        }

        if ($choice -in @("A", "B", "F")) {
            Resolve-HeroInspirationBoost `
                -Hero $Hero `
                -PrimaryAction $choice `
                -HeroAttackBonus ([ref]$turnHeroAttackBonus) `
                -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) `
                -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus)
        }

        if ($choice -eq "B") {
            Write-Scene "$($Hero.Name) braces for impact and raises a tight defense."
            $heroBlockArmorBonus += 2
            Write-Action "$($Hero.Name) gains +2 AC against the next attack." "Yellow"
            Write-ColorLine ""

            Resolve-HeroBonusAction -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP

            if ($MonsterHP.Value -le 0) {
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -BlockArmorBonus $heroBlockArmorBonus
                $heroBlockArmorBonus = 0

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
        elseif ($choice -eq "F") {
            Write-Scene "$($Hero.Name) slows the breath, studies the opening, and waits for the right strike."
            $heroFocusAttackBonus += 2
            Write-Action "$($Hero.Name) gains +2 to hit on the next attack." "Yellow"
            Write-ColorLine ""

            Resolve-HeroBonusAction -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP

            if ($MonsterHP.Value -le 0) {
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -BlockArmorBonus $heroBlockArmorBonus
                $heroBlockArmorBonus = 0

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
        elseif ($choice -eq "A") {
            Write-ColorLine ""
            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon -AttackBonusModifier ($heroFocusAttackBonus + $turnHeroAttackBonus)
            $heroFocusAttackBonus = 0

            if ($MonsterHP.Value -le 0) {
                break
            }

            Resolve-HeroBonusAction -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP

            if ($MonsterHP.Value -le 0) {
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -BlockArmorBonus $heroBlockArmorBonus
                $heroBlockArmorBonus = 0

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
            Write-ColorLine "Type A, B, F, I or R" "DarkYellow"
            Write-ColorLine ""
        }
    }
}
