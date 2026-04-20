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
            Reset-TutorialAfterDefeat -Game $Game -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon
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
        $statusSnapshot = Get-HeroStatusSnapshot -Hero $Game.Hero -HeroHP $HeroHP.Value -Game $Game

                    Write-ColorLine ""
                    Write-ColorLine "Status:" "Cyan"
                    Write-HeroStatusDetails -Hero $Game.Hero -HeroHP $HeroHP.Value -Snapshot $statusSnapshot
                    Write-ColorLine ""
                }
                "T" {
                    Toggle-TextSpeed | Out-Null
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
