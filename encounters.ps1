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

    $spawnRoll = Roll-Dice -Sides 100

    if ($spawnRoll -gt $Room.EncounterChance) {
        Write-Scene "The room stays quiet. Nothing attacks."
        return "None"
    }

    $monster = Get-RandomMonster
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

