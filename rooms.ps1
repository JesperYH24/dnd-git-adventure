function New-Room {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Description,
        [hashtable]$Exits,
        [int]$EncounterChance = 0,
        [bool]$BossRoom = $false
    )

    return [PSCustomObject]@{
        Id                = $Id
        Name              = $Name
        Description       = $Description
        Exits             = $Exits
        EncounterChance   = $EncounterChance
        BossRoom          = $BossRoom
        Loot              = @()
        EncounterResolved = $false
        Visited           = $false
    }
}

function Get-CaveRooms {
    return @{
        entrance = (New-Room -Id "entrance" -Name "Cave Entrance" -Description "A cold draft spills through the cracked stone archway. Faint torchlight flickers deeper inside." -Exits @{ north = "echo_hall"; east = "fungal_nest" } -EncounterChance 20)
        echo_hall = (New-Room -Id "echo_hall" -Name "Echo Hall" -Description "Each footstep bounces back from the damp walls. Broken bones crunch beneath your boots." -Exits @{ south = "entrance"; north = "collapsed_crossing" } -EncounterChance 70)
        fungal_nest = (New-Room -Id "fungal_nest" -Name "Fungal Nest" -Description "Pale mushrooms pulse with a sickly glow, painting the chamber in ghostly green." -Exits @{ west = "entrance"; north = "underground_lake" } -EncounterChance 75)
        collapsed_crossing = (New-Room -Id "collapsed_crossing" -Name "Collapsed Crossing" -Description "A ruined bridge spans a black chasm. The old path continues through loose rubble." -Exits @{ south = "echo_hall"; east = "ashen_threshold" } -EncounterChance 65)
        underground_lake = (New-Room -Id "underground_lake" -Name "Underground Lake" -Description "Black water laps against the stone. Something moves beneath the surface before falling still." -Exits @{ south = "fungal_nest"; north = "ashen_threshold" } -EncounterChance 70)
        ashen_threshold = (New-Room -Id "ashen_threshold" -Name "Ashen Threshold" -Description "Soot clings to the stone here, and the air tastes of smoke. Two tunnel paths converge before a final scorched passage ahead." -Exits @{ west = "collapsed_crossing"; south = "underground_lake"; east = "shadow_sanctum" } -EncounterChance 45)
        shadow_sanctum = (New-Room -Id "shadow_sanctum" -Name "Shadow Sanctum" -Description "Heat rolls through the cavern. Gold glints beneath ash, and a massive shadow shifts in the dark." -Exits @{ west = "ashen_threshold" } -EncounterChance 100 -BossRoom $true)
    }
}

function Show-Room {
    param($Room)

    Write-SectionTitle -Text $Room.Name -Color "Cyan"
    Write-Scene $Room.Description

    if ($Room.Loot.Count -gt 0) {
        Write-Scene "You notice abandoned loot in the room."
    }

    if (-not $Room.Visited) {
        Write-Scene "The cave feels tense, as if something could emerge at any moment."
    }

    Write-ColorLine ""
}

function Show-RoomActions {
    param(
        $Room,
        $Hero,
        [int]$HeroHP
    )

    $exitIndex = 1
    $exitMap = @{}

    Write-ColorLine "What do you want to do?" "Cyan"

    foreach ($exit in $Room.Exits.GetEnumerator() | Sort-Object Name) {
        $destinationLabel = $exit.Value -replace "_", " "
        Write-ColorLine "$exitIndex. Go $($exit.Name) to $destinationLabel" "White"
        $exitMap["$exitIndex"] = $exit.Value
        $exitIndex++
    }

    Write-ColorLine "I. Open inventory" "White"
    Write-ColorLine "L. Check room loot" "White"
    Write-ColorLine "S. View status" "White"
    if ($Room.Id -eq "entrance") {
        Write-ColorLine "Q. Leave the cave" "White"
    }
    Write-ColorLine ""

    return $exitMap
}

function Resolve-RoomLoot {
    param(
        $Hero,
        $Room
    )

    if (-not $Room -or $Room.Loot.Count -eq 0) {
        Write-Scene "There is no loot waiting here."
        return
    }

    Write-ColorLine ""
    Write-ColorLine "===== ROOM LOOT =====" "Yellow"

    $remainingLoot = @()

    foreach ($item in $Room.Loot) {
        $slots = Get-ItemSlotCost -Item $item
        $slotLabel = if ($slots -eq 1) { "slot" } else { "slots" }
        Write-ColorLine "- $($item.Name) [$($item.Type)] ($slots $slotLabel)" "White"

        $choice = (Read-Host "Pick up '$($item.Name)'? (Y/N)").ToUpper()

        if ($choice -eq "Y") {
            if ($item.Type -eq "Currency") {
                $currencyResult = Add-HeroCurrency -Hero $Hero -Denomination $item.Denomination -Amount $item.Amount

                if ($currencyResult.StoredCopper -gt 0) {
                    Write-Scene "$($Hero.Name) stores the coins in the gold pouch."
                }

                if ($currencyResult.LeftoverCopper -gt 0) {
                    Write-Scene "The gold pouch is full, so some currency remains behind."
                    $remainingLoot += $currencyResult.LeftoverItem
                }
            }
            elseif (Can-HeroCarryItem -Hero $Hero -Item $item) {
                $Hero.Inventory += $item
                Write-Scene "$($Hero.Name) picks up $($item.Name)."
            }
            else {
                Write-Scene "$($Hero.Name) has no room for $($item.Name)."
                $remainingLoot += $item
            }
        }
        else {
            $remainingLoot += $item
        }

        Write-ColorLine ""
    }

    $Room.Loot = $remainingLoot
}
