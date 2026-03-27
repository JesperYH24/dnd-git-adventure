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
    $attackTotal = $heroRoll + $weapon.AttackBonus

    Write-Action "$($Hero.Name) attacks with $($weapon.Name): roll $heroRoll, total $attackTotal vs AC $targetArmorClass" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $weapon.DamageMin -Maximum $weapon.DamageMax
        $heroDamage = $weapon.DamageMax + $extraDamage
        $MonsterHP.Value -= $heroDamage

        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($($weapon.DamageMax) + $extraDamage)" "Yellow"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumbles, drops the weapon, and must pick it up next turn!"
    }
    elseif ($attackTotal -ge $targetArmorClass) {
        $heroDamage = Roll-Damage -Minimum $weapon.DamageMin -Maximum $weapon.DamageMax
        $MonsterHP.Value -= $heroDamage

        Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage!" "Yellow"
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
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage

        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage! ($($Monster.damageMax) + $extraDamage)" "Yellow"
    }
    elseif ($attackRoll -eq 1) {
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Action "$($Monster.definite) stumbles and loses its balance!" "DarkYellow"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackTotal -ge $heroArmorClass) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
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

function Format-InventoryItemLine {
    param($Item)

    $tags = @()

    if ($Item.Type -eq "Weapon") {
        $tags += "hit $($Item.AttackBonus)"
        $tags += "dmg $($Item.DamageMin)-$($Item.DamageMax)"
    }
    elseif ($Item.Type -eq "Armor") {
        $tags += "AC +$($Item.ArmorBonus)"
    }
    elseif ($Item.Type -eq "Consumable" -and $null -ne $Item.HealAmount) {
        $tags += "+$($Item.HealAmount) HP"
    }

    $slotCost = Get-ItemSlotCost -Item $Item
    $slotLabel = if ($slotCost -eq 1) { "slot" } else { "slots" }

    $tags += "$slotCost $slotLabel"

    if ($Item.Equipped -and $Item.Type -in @("Weapon", "Armor")) {
        $tags += "equipped"
    }

    return "$($Item.Name) [$($Item.Type)] - $($tags -join ', ')"
}

function Show-Inventory {
    param($Hero)

    Write-ColorLine ""
    Write-ColorLine "===== INVENTORY =====" "Cyan"
    Write-ColorLine "Slots: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero)" "DarkCyan"

    if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
        Write-ColorLine "Inventory is empty." "DarkGray"
        Write-ColorLine ""
        return
    }

    for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
        $item = $Hero.Inventory[$i]
        Write-ColorLine "$($i + 1). $(Format-InventoryItemLine -Item $item)" "White"
    }

    Write-ColorLine ""
}

function Resolve-LootDrop {
    param(
        $Hero,
        $Monster,
        $Room
    )

    $loot = Get-MonsterLoot -Monster $Monster

    if (-not $loot -or $loot.Count -eq 0) {
        Write-Scene "$($Monster.definite) carried no loot."
        return
    }

    Write-ColorLine ""
    Write-ColorLine "===== LOOT =====" "Yellow"

    foreach ($item in $loot) {
        Write-ColorLine "- $(Format-InventoryItemLine -Item $item)" "White"
    }

    Write-ColorLine ""

    foreach ($item in $loot) {
        $choice = (Read-Host "Pick up '$($item.Name)'? (Y/N)").ToUpper()

        if ($choice -eq "Y") {
            if (Can-HeroCarryItem -Hero $Hero -Item $item) {
                $Hero.Inventory += $item
                Write-Scene "$($Hero.Name) picks up $($item.Name)."
            }
            else {
                $Room.Loot += $item
                Write-Scene "$($Hero.Name) has no room for $($item.Name), so it stays in the room."
            }
        }
        else {
            $Room.Loot += $item
            Write-Scene "$($Hero.Name) leaves $($item.Name) behind."
        }

        Write-ColorLine ""
    }

    Show-Inventory -Hero $Hero
}

function Use-InventoryItem {
    param(
        $Hero,
        [ref]$HeroHP,
        $Item
    )

    if ($Item.Type -eq "Consumable" -and $null -ne $Item.HealAmount) {
        if ($HeroHP.Value -ge $Hero.HP) {
            Write-Scene "$($Hero.Name) is already at full HP and cannot use $($Item.Name)."
            return $false
        }

        $oldHP = $HeroHP.Value
        $HeroHP.Value = [Math]::Min($HeroHP.Value + $Item.HealAmount, $Hero.HP)
        $healed = $HeroHP.Value - $oldHP

        Write-Scene "$($Hero.Name) drinks $($Item.Name) and recovers $healed HP!"
        Write-Scene "$($Hero.Name) now has $($HeroHP.Value)/$($Hero.HP) HP."

        return $true
    }

    Write-Scene "$($Item.Name) cannot be used right now."
    return $false
}

function Drop-InventoryItem {
    param(
        $Hero,
        [int]$Index,
        $Room
    )

    if (-not $Room) {
        Write-Scene "There is nowhere safe to drop that right now."
        return $false
    }

    $item = $Hero.Inventory[$Index]

    if (-not (Can-DropItem -Hero $Hero -Item $item)) {
        Write-Scene "You cannot drop $($item.Name); it would leave the rest of your gear without enough carrying space."
        return $false
    }

    if ($null -ne $item.PSObject.Properties["Equipped"]) {
        $item.Equipped = $false
    }

    $Room.Loot += $item
    Remove-InventoryItemAt -Hero $Hero -Index $Index
    Write-Scene "$($Hero.Name) leaves $($item.Name) in $($Room.Name)."
    return $true
}

function Open-InventoryMenu {
    param(
        $Hero,
        [ref]$HeroHP,
        $Room = $null
    )

    while ($true) {
        Show-Inventory -Hero $Hero

        if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
            Read-Host "Press Enter to go back"
            return $false
        }

        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose item number"

        if ($choice -eq "0") {
            return $false
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Enter a valid number." "DarkYellow"
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $Hero.Inventory.Count) {
            Write-ColorLine "That item does not exist." "DarkYellow"
            continue
        }

        $selectedItem = $Hero.Inventory[$index]

        Write-ColorLine ""
        Write-ColorLine "Selected: $(Format-InventoryItemLine -Item $selectedItem)" "Cyan"

        if ($selectedItem.Type -eq "Consumable") {
            Write-ColorLine "U. Use" "White"
        }

        if ($selectedItem.Type -eq "Weapon" -or $selectedItem.Type -eq "Armor") {
            Write-ColorLine "E. Equip" "White"
        }

        Write-ColorLine "D. Drop" "White"
        Write-ColorLine "B. Back" "DarkGray"
        Write-ColorLine ""

        $action = (Read-Host "Choose action").ToUpper()

        switch ($action) {
            "U" {
                $used = Use-InventoryItem -Hero $Hero -HeroHP $HeroHP -Item $selectedItem

                if ($used) {
                    Remove-InventoryItemAt -Hero $Hero -Index $index
                    return $true
                }
            }
            "E" {
                if ($selectedItem.Type -in @("Weapon", "Armor")) {
                    Set-EquippedItem -Hero $Hero -Item $selectedItem
                    Write-Scene "$($Hero.Name) equips $($selectedItem.Name)."
                }
                else {
                    Write-Scene "$($selectedItem.Name) cannot be equipped."
                }
            }
            "D" {
                if (Drop-InventoryItem -Hero $Hero -Index $index -Room $Room) {
                    return $false
                }
            }
            "B" {
            }
            default {
                Write-ColorLine "Choose one of the available actions." "DarkYellow"
            }
        }
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
            Write-Scene "$($Hero.Name) picks up the weapon and loses the turn!"
            $HeroDroppedWeapon.Value = $false
            Write-ColorLine ""

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
