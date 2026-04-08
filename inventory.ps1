function Format-InventoryItemLine {
    param($Item)

    $tags = @()

    if ($Item.Type -eq "Weapon") {
        $tags += "hit $($Item.AttackBonus)"
        $tags += "dmg $($Item.DamageDiceCount)d$($Item.DamageDiceSides)"
        $tags += (Get-WeaponRequirementText -Weapon $Item)
    }
    elseif ($Item.Type -eq "Armor") {
        $tags += "AC +$($Item.ArmorBonus)"
    }
    elseif ($Item.Type -eq "Consumable" -and $null -ne $Item.HealAmount) {
        $tags += "+$($Item.HealAmount) HP"
    }
    elseif ($Item.Type -eq "Consumable" -and $Item.BuffType -eq "Haste") {
        $tags += "initiative advantage"
    }
    elseif ($Item.Type -eq "Currency") {
        $tags += "$($Item.Amount) $($Item.Denomination.ToUpper())"
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
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Hero) / $($Hero.GoldPouchCapacityGP) GP capacity" "DarkYellow"

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
            if ($item.Type -eq "Currency") {
                $currencyResult = Add-HeroCurrency -Hero $Hero -Denomination $item.Denomination -Amount $item.Amount

                if ($currencyResult.StoredCopper -gt 0) {
                    Write-Scene "$($Hero.Name) stores the coins in the gold pouch."
                }

                if ($currencyResult.LeftoverCopper -gt 0) {
                    $Room.Loot += $currencyResult.LeftoverItem
                    Write-Scene "The gold pouch is full, so some currency remains behind."
                }
            }
            elseif (Can-HeroCarryItem -Hero $Hero -Item $item) {
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

    if ($Item.Type -eq "Consumable" -and $Item.BuffType -eq "Haste") {
        Apply-HeroBuff -Hero $Hero -BuffType "Haste" -BuffName $Item.Name
        Write-Scene "$($Hero.Name) drinks $($Item.Name) and feels time sharpen around every movement."
        Write-Scene "$($Hero.Name) now has advantage on initiative for the rest of the dungeon."
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
        Write-TextSpeedOption
        Write-ColorLine ""

        $choice = (Read-Host "Choose item number").ToUpper()

        if ($choice -eq "0") {
            return $false
        }

        if ($choice -eq "T") {
            Toggle-TextSpeed | Out-Null
            continue
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
        Write-TextSpeedOption
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
                    $equipResult = Set-EquippedItem -Hero $Hero -Item $selectedItem

                    if ($equipResult.Success) {
                        Write-Scene "$($Hero.Name) equips $($selectedItem.Name)."
                    }
                    else {
                        Write-Scene $equipResult.Message
                    }
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
            "T" {
                Toggle-TextSpeed | Out-Null
            }
            default {
                Write-ColorLine "Choose one of the available actions." "DarkYellow"
            }
        }
    }
}
