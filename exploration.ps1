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
        Id               = $Id
        Name             = $Name
        Description      = $Description
        Exits            = $Exits
        EncounterChance  = $EncounterChance
        BossRoom         = $BossRoom
        Loot             = @()
        EncounterResolved = $false
        Visited          = $false
    }
}

function Get-CaveRooms {
    return @{
        entrance = (New-Room -Id "entrance" -Name "Cave Entrance" -Description "A cold draft spills through the cracked stone archway. Faint torchlight flickers deeper inside." -Exits @{ north = "echo_hall"; east = "fungal_nest" } -EncounterChance 20)
        echo_hall = (New-Room -Id "echo_hall" -Name "Echo Hall" -Description "Each footstep bounces back from the damp walls. Broken bones crunch beneath your boots." -Exits @{ south = "entrance"; east = "collapsed_crossing" } -EncounterChance 70)
        fungal_nest = (New-Room -Id "fungal_nest" -Name "Fungal Nest" -Description "Pale mushrooms pulse with a sickly glow, painting the chamber in ghostly green." -Exits @{ west = "entrance"; north = "underground_lake" } -EncounterChance 75)
        collapsed_crossing = (New-Room -Id "collapsed_crossing" -Name "Collapsed Crossing" -Description "A ruined bridge spans a black chasm. The old path continues through loose rubble." -Exits @{ west = "echo_hall"; north = "dragon_lair" } -EncounterChance 65)
        underground_lake = (New-Room -Id "underground_lake" -Name "Underground Lake" -Description "Black water laps against the stone. Something moves beneath the surface before falling still." -Exits @{ south = "fungal_nest"; east = "dragon_lair" } -EncounterChance 70)
        dragon_lair = (New-Room -Id "dragon_lair" -Name "Dragon Lair" -Description "Heat rolls through the cavern. Gold glints beneath ash, and a massive shadow shifts in the dark." -Exits @{ south = "collapsed_crossing"; west = "underground_lake" } -EncounterChance 100 -BossRoom $true)
    }
}

function Show-Room {
    param($Room)

    Write-ColorLine ""
    Write-ColorLine "===== $($Room.Name.ToUpper()) =====" "Cyan"
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
            if (Can-HeroCarryItem -Hero $Hero -Item $item) {
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

function Resolve-RoomEncounter {
    param(
        $Game,
        $Room,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon,
        [ref]$CurrentRoomId
    )

    if ($Room.BossRoom -and ($Room.EncounterResolved -or $Game.Quest.SeenDragon)) {
        return "None"
    }

    if ($Room.BossRoom) {
        Write-ColorLine ""
        Write-ColorLine "===== ENCOUNTER =====" "Red"
        Write-Scene "A vast silhouette rises above the treasure mound."
        Write-Scene "The Ancient Dragon opens one blazing eye and the whole cavern shakes."
        Write-Scene "One sweep of its claws tears the stone beside Borzig apart."
        Write-Scene "This is no fight for a level 1 hero."
        Write-Scene "Borzig must survive, escape, and warn the town."
        Write-ColorLine ""

        $Game.Quest.SeenDragon = $true

        if ($Game.LastRoomId) {
            $CurrentRoomId.Value = $Game.LastRoomId
        }

        Write-Scene "$($Game.Hero.Name) stumbles back through the tunnels as the dragon's roar follows close behind."
        return "Fled"
    }
    else {
        $spawnRoll = Roll-Dice -Sides 100

        if ($spawnRoll -gt $Room.EncounterChance) {
            Write-Scene "The room stays quiet. Nothing attacks."
            return "None"
        }

        $monster = Get-RandomMonster
    }

    $monsterHP = $monster.hp
    $monsterOffBalance = $false
    $heroStarts = $false
    $heroBonusAttack = $false
    $monsterStarts = $false

    Write-ColorLine ""
    Write-ColorLine "===== ENCOUNTER =====" "Red"
    Write-Scene "$($monster.article) $($monster.name) emerges from the darkness."
    Write-Scene "$($monster.definite) squares up against $($Game.Hero.Name)."
    Write-ColorLine ""

    Start-DetectionPhase `
        -Hero $Game.Hero `
        -Monster $monster `
        -HeroStarts ([ref]$heroStarts) `
        -HeroBonusAttack ([ref]$heroBonusAttack) `
        -MonsterStarts ([ref]$monsterStarts)

    $openingResult = Start-OpeningPhase `
        -Hero $Game.Hero `
        -Monster $monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon $HeroDroppedWeapon `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroStarts $heroStarts `
        -HeroBonusAttack $heroBonusAttack `
        -MonsterStarts $monsterStarts

    if (-not $openingResult) {
        if ($HeroHP.Value -le 0) {
            return "Defeated"
        }

        if ($monsterHP -le 0) {
            Write-Scene "$($monster.definite) collapses to the ground. You win!"
            Resolve-LootDrop -Hero $Game.Hero -Monster $monster -Room $Room
            $Room.EncounterResolved = $true

            if ($Room.BossRoom) {
                return "Victory"
            }

            return "Won"
        }
    }

    $encounterFled = $false

    Start-CombatLoop `
        -Hero $Game.Hero `
        -Monster $monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon $HeroDroppedWeapon `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -SkipInitialStatus $monsterStarts

    if ($HeroHP.Value -le 0) {
        return "Defeated"
    }

    if ($monsterHP -le 0) {
        Write-Scene "$($monster.definite) collapses to the ground. You win!"
        Resolve-LootDrop -Hero $Game.Hero -Monster $monster -Room $Room
        if ($Room.BossRoom) {
            $Room.EncounterResolved = $true
        }

        if ($Room.BossRoom) {
            return "Victory"
        }

        return "Won"
    }

    if ($encounterFled) {
        if ($Game.LastRoomId) {
            $CurrentRoomId.Value = $Game.LastRoomId
        }

        return "Fled"
    }

    return "None"
}

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
                    Write-ColorLine ""
                    Write-ColorLine "Status:" "Cyan"
                    Write-ColorLine "$($Game.Hero.Name): $($HeroHP.Value)/$($Game.Hero.HP) HP" "Green"
                    Write-ColorLine "Level: $($Game.Hero.Level)" "White"
                    Write-ColorLine "Armor Class: $(Get-HeroArmorClass -Hero $Game.Hero)" "White"
                    Write-ColorLine "Weapon: $($equippedWeapon.Name) (hit $($equippedWeapon.AttackBonus), damage $($equippedWeapon.DamageMin)-$($equippedWeapon.DamageMax))" "White"
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
