function Invoke-ExplorationCommonAction {
    param(
        [string]$Choice,
        $Game,
        [ref]$HeroHP,
        $Room
    )

    switch ($Choice) {
        "I" {
            Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP -Room $Room | Out-Null
            return "Handled"
        }
        "L" {
            Resolve-RoomLoot -Hero $Game.Hero -Room $Room
            return "Handled"
        }
        "S" {
            $statusSnapshot = Get-HeroStatusSnapshot -Hero $Game.Hero -HeroHP $HeroHP.Value -Game $Game

            Write-ColorLine ""
            Write-ColorLine "Status:" "Cyan"
            Write-HeroStatusDetails -Hero $Game.Hero -HeroHP $HeroHP.Value -Snapshot $statusSnapshot
            Write-ColorLine ""
            return "Handled"
        }
        "T" {
            Toggle-TextSpeed | Out-Null
            return "Handled"
        }
    }

    return "Unhandled"
}

function Start-RoomExploration {
    param(
        $Game,
        [ref]$HeroHP,
        [hashtable]$Rooms,
        [string]$StartRoomId,
        [scriptblock]$ShowCurrentRoom = { param($Game, $Room) Show-Room -Room $Room },
        [scriptblock]$ShowCurrentRoomActions = { param($Game, $Room, [int]$HeroHPValue) Show-RoomActions -Room $Room -Hero $Game.Hero -HeroHP $HeroHPValue },
        [scriptblock]$ResolveEncounter = { param($Game, $Room, [ref]$HeroHP, [ref]$CurrentRoomId) return $null },
        [scriptblock]$HandleEncounterResult = { param($Game, $Room, $EncounterResult, [ref]$HeroHP, [ref]$CurrentRoomId) return "Proceed" },
        [scriptblock]$HandleCustomAction = { param([string]$Choice, $Game, $Room, [ref]$HeroHP, [ref]$CurrentRoomId) return "Unhandled" },
        [scriptblock]$ShouldContinue = { param($Game, [int]$HeroHPValue) return ($HeroHPValue -gt 0) }
    )

    $currentRoomId = $StartRoomId

    while (& $ShouldContinue $Game $HeroHP.Value) {
        $room = $Rooms[$currentRoomId]

        if ($null -eq $room) {
            Write-Scene "The path ahead is unfinished."
            return "MissingRoom"
        }

        & $ShowCurrentRoom $Game $room

        $encounterResult = & $ResolveEncounter $Game $room $HeroHP ([ref]$currentRoomId)
        $Game.CurrentRoomId = $currentRoomId

        $encounterAction = & $HandleEncounterResult $Game $room $encounterResult $HeroHP ([ref]$currentRoomId)
        $Game.CurrentRoomId = $currentRoomId

        if ($encounterAction -eq "Return") {
            return $encounterResult
        }

        if ($encounterAction -eq "Continue") {
            continue
        }

        $room.Visited = $true

        while ($true) {
            $exitMap = & $ShowCurrentRoomActions $Game $room $HeroHP.Value

            if ($null -eq $exitMap) {
                $exitMap = @{}
            }

            $choice = (Read-Host "Choose").ToUpper()

            if ($exitMap.ContainsKey($choice)) {
                $Game.LastRoomId = $currentRoomId
                $currentRoomId = $exitMap[$choice]
                $Game.CurrentRoomId = $currentRoomId
                break
            }

            $commonActionResult = Invoke-ExplorationCommonAction -Choice $choice -Game $Game -HeroHP $HeroHP -Room $room

            if ($commonActionResult -eq "Handled") {
                continue
            }

            $customActionResult = & $HandleCustomAction $choice $Game $room $HeroHP ([ref]$currentRoomId)
            $Game.CurrentRoomId = $currentRoomId

            if ($customActionResult -eq "Return") {
                return $choice
            }

            if ($customActionResult -eq "Handled") {
                continue
            }

            Write-ColorLine "Choose one of the listed actions." "DarkYellow"
            Write-ColorLine ""
        }
    }
}

function Start-CaveExploration {
    param(
        $Game,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon
    )

    Start-RoomExploration `
        -Game $Game `
        -HeroHP $HeroHP `
        -Rooms $Game.Rooms `
        -StartRoomId $Game.CurrentRoomId `
        -ResolveEncounter {
            param($Game, $Room, [ref]$HeroHP, [ref]$CurrentRoomId)

            Resolve-RoomEncounter `
                -Game $Game `
                -Room $Room `
                -HeroHP $HeroHP `
                -HeroDroppedWeapon $HeroDroppedWeapon `
                -CurrentRoomId $CurrentRoomId
        } `
        -HandleEncounterResult {
            param($Game, $Room, $EncounterResult, [ref]$HeroHP, [ref]$CurrentRoomId)

            if ($EncounterResult -eq "Defeated") {
                Write-Scene "$($Game.Hero.Name) falls in the depths of the cave..."
                Reset-TutorialAfterDefeat -Game $Game -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon
                return "Return"
            }

            if ($EncounterResult -eq "Victory") {
                Write-Scene "The lair falls silent. The cave is yours."
                $Game.GameWon = $true
                return "Return"
            }

            if ($EncounterResult -eq "Fled") {
                Write-Scene "$($Game.Hero.Name) scrambles back through the tunnels to safety."
                return "Continue"
            }

            return "Proceed"
        } `
        -HandleCustomAction {
            param([string]$Choice, $Game, $Room, [ref]$HeroHP, [ref]$CurrentRoomId)

            if ($Choice -ne "Q") {
                return "Unhandled"
            }

            if ($Room.Id -eq "entrance") {
                Write-Scene "$($Game.Hero.Name) leaves the cave and returns to the campfire."
                return "Return"
            }

            Write-Scene "$($Game.Hero.Name) cannot leave the cave from here."
            Write-Scene "The safest path out leads back to the Cave Entrance."
            return "Handled"
        } `
        -ShouldContinue {
            param($Game, [int]$HeroHPValue)

            return ($HeroHPValue -gt 0 -and -not $Game.GameWon)
        } | Out-Null
}
