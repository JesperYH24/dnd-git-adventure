function Start-CaveExploration {
    param(
        $Game,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon
    )

    $currentRoomId = $Game.CurrentRoomId

    while ($HeroHP.Value -gt 0 -and -not $Game.GameWon) {
        $room = $Game.Rooms[$currentRoomId]

        Show-Room -Room $room

        $encounterResult = Resolve-RoomEncounter `
            -Game $Game `
            -Room $room `
            -HeroHP $HeroHP `
            -HeroDroppedWeapon $HeroDroppedWeapon `
            -CurrentRoomId ([ref]$currentRoomId)

        $Game.CurrentRoomId = $currentRoomId

        if ($encounterResult -eq "Defeated") {
            Write-Scene "$($Game.Hero.Name) falls in the depths of the cave..."
            return
        }

        if ($encounterResult -eq "Victory") {
            Write-Scene "The lair falls silent. The cave is yours."
            $Game.GameWon = $true
            return
        }

        if ($encounterResult -eq "Fled") {
            Write-Scene "$($Game.Hero.Name) scrambles back through the tunnels to safety."
            continue
        }

        $room.Visited = $true

        while ($true) {
            $exitMap = Show-RoomActions -Room $room -Hero $Game.Hero -HeroHP $HeroHP.Value
            $choice = (Read-Host "Choose").ToUpper()

            if ($exitMap.ContainsKey($choice)) {
                $Game.LastRoomId = $currentRoomId
                $currentRoomId = $exitMap[$choice]
                $Game.CurrentRoomId = $currentRoomId
                break
            }

            switch ($choice) {
                "I" {
                    Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP -Room $room | Out-Null
                }
                "L" {
                    Resolve-RoomLoot -Hero $Game.Hero -Room $room
                }
                "S" {
                    $equippedWeapon = Get-HeroWeaponProfile -Hero $Game.Hero
                    $strengthModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "STR"
                    $dexterityModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "DEX"
                    $constitutionModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "CON"
                    $intelligenceModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "INT"
                    $wisdomModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "WIS"
                    $charismaModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "CHA"
                    Write-ColorLine ""
                    Write-ColorLine "Status:" "Cyan"
                    Write-ColorLine "$($Game.Hero.Name): $($HeroHP.Value)/$($Game.Hero.HP) HP" "Green"
                    Write-ColorLine "Level: $($Game.Hero.Level)" "White"
                    Write-ColorLine "Armor Class: $(Get-HeroArmorClass -Hero $Game.Hero)" "White"
                    Write-ColorLine "Weapon: $($equippedWeapon.Name) (to hit +$($equippedWeapon.TotalAttackBonus), damage $(Get-WeaponDamageRollText -WeaponProfile $equippedWeapon) + $($equippedWeapon.DamageBonus), total $($equippedWeapon.TotalDamageMin)-$($equippedWeapon.TotalDamageMax))" "White"
                    Write-ColorLine "STR $($Game.Hero.STR) $(Format-AbilityModifier -Modifier $strengthModifier) | DEX $($Game.Hero.DEX) $(Format-AbilityModifier -Modifier $dexterityModifier) | CON $($Game.Hero.CON) $(Format-AbilityModifier -Modifier $constitutionModifier)" "DarkGray"
                    Write-ColorLine "INT $($Game.Hero.INT) $(Format-AbilityModifier -Modifier $intelligenceModifier) | WIS $($Game.Hero.WIS) $(Format-AbilityModifier -Modifier $wisdomModifier) | CHA $($Game.Hero.CHA) $(Format-AbilityModifier -Modifier $charismaModifier)" "DarkGray"
                    Write-ColorLine "Inventory: $(Get-InventoryUsedSlots -Hero $Game.Hero)/$(Get-InventoryCapacity -Hero $Game.Hero) slots" "White"
                    Write-ColorLine ""
                }
                "Q" {
                    if ($room.Id -eq "entrance") {
                        Write-Scene "$($Game.Hero.Name) leaves the cave and returns to the campfire."
                        return
                    }

                    Write-Scene "$($Game.Hero.Name) cannot leave the cave from here."
                    Write-Scene "The safest path out leads back to the Cave Entrance."
                }
                default {
                    Write-ColorLine "Choose one of the listed actions." "DarkYellow"
                    Write-ColorLine ""
                }
            }
        }
    }
}
