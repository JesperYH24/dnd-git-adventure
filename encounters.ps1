function Resolve-ShadowSanctumReward {
    param($Game)

    if ($Game.ShadowSanctumRewardTaken) {
        return
    }

    Write-SectionTitle -Text "Ancient Temptation" -Color "Yellow"
    Write-Scene "Near the edge of the hoard, two prizes catch $($Game.Hero.Name)'s eye before the true horror fully stirs."
    Write-ColorLine "1. Take 100 GP" "White"
    Write-ColorLine "2. Drink a Potion of Haste" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose your prize"

        if ($choice -eq "1") {
            Add-HeroCurrency -Hero $Game.Hero -Denomination "GP" -Amount 100 | Out-Null
            Write-EmphasisLine -Text "$($Game.Hero.Name) stuffs 100 GP into the gold pouch." -Color "Yellow"
            break
        }

        if ($choice -eq "2") {
            Apply-HeroBuff -Hero $Game.Hero -BuffType "Haste" -BuffName "Potion of Haste"
            Write-EmphasisLine -Text "$($Game.Hero.Name) downs the Potion of Haste and feels the world sharpen around him." -Color "Yellow"
            break
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }

    $Game.ShadowSanctumRewardTaken = $true
    Write-ColorLine ""
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
        Resolve-ShadowSanctumReward -Game $Game
        Write-SectionTitle -Text "Boss Encounter" -Color "Red"
        Write-EmphasisLine -Text "A colossal shadow rises above the hoard." -Color "DarkRed"
        Write-ColorLine ""
        Write-Scene "The heat in the chamber surges all at once."
        Write-Scene "Gold shifts under something vast, ancient, and still half-hidden in smoke."
        Write-Scene "Then one blazing eye opens, and the whole cavern seems to lean toward Borzig."
        Write-ColorLine ""
        Write-EmphasisLine -Text "Stone explodes beside him under a single lazy sweep of the beast's claws." -Color "Red"
        Write-ColorLine ""
        Write-Scene "This is not a battle for a level 1 hero."
        Write-Scene "Borzig has one chance: survive, escape, and carry this warning back to town."
        Write-ColorLine ""

        $Game.Quest.SeenDragon = $true

        if ($Game.LastRoomId) {
            $CurrentRoomId.Value = $Game.LastRoomId
        }

        Write-EmphasisLine -Text "$($Game.Hero.Name) stumbles back through the tunnels as the dragon's roar chases him into the dark." -Color "Yellow"
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

    Write-SectionTitle -Text "Encounter" -Color "Red"
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
            Grant-HeroXP -Hero $Game.Hero -XP $monster.xp
            Write-Scene "$($Game.Hero.Name) gains $($monster.xp) XP."
            if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
                Write-EmphasisLine -Text "$($Game.Hero.Name) feels stronger. A level up awaits after a long rest." -Color "Yellow"
                Write-ColorLine ""
            }
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
        Grant-HeroXP -Hero $Game.Hero -XP $monster.xp
        Write-Scene "$($Game.Hero.Name) gains $($monster.xp) XP."
        if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
            Write-EmphasisLine -Text "$($Game.Hero.Name) feels stronger. A level up awaits after a long rest." -Color "Yellow"
            Write-ColorLine ""
        }
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
