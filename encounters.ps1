function Resolve-ShadowSanctumReward {
    param($Game)

    if ($Game.ShadowSanctumRewardTaken) {
        return
    }

    Write-SectionTitle -Text "Ancient Temptation" -Color "Yellow"
    Write-Scene "Gold glints near the edge of the hoard, but the true horror is already beginning to stir."
    Write-Scene "$($Game.Hero.Name) has only seconds to grab what can be reached before the shadow wakes."
    Write-ColorLine "Roll a d20 to see how much gold $($Game.Hero.Name) can snatch." "White"
    Write-ColorLine ""
    Read-Host "Press Enter to roll" | Out-Null

    $goldRoll = Roll-Dice -Sides 20
    $goldRewardGP = Get-ShadowSanctumGoldRewardGP -Roll $goldRoll
    Write-Action "Sanctum gold roll: d20 roll $goldRoll = $goldRewardGP GP." "Cyan"

    $currencyResult = Add-HeroCurrency -Hero $Game.Hero -Denomination "GP" -Amount $goldRewardGP

    if ($currencyResult.StoredCopper -gt 0) {
        Write-EmphasisLine -Text "$($Game.Hero.Name) stuffs as much of the $goldRewardGP GP as possible into the gold pouch." -Color "Yellow"
    }

    if ($currencyResult.LeftoverCopper -gt 0) {
        $leftoverItem = $currencyResult.LeftoverItem
        $ashenThreshold = $Game.Rooms["ashen_threshold"]
        $ashenThreshold.Loot += $leftoverItem
        Write-Scene "The gold pouch cannot hold the full reward, so the remaining coins are left behind near the sanctum approach."
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
        Write-Scene "Then one blazing eye opens, and the whole cavern seems to lean toward $($Game.Hero.Name)."
        Write-ColorLine ""
        Write-EmphasisLine -Text "Stone explodes beside him under a single lazy sweep of the beast's claws." -Color "Red"
        Write-ColorLine ""
        Write-Scene "This is not a battle for a level 1 hero."
        Write-Scene "$($Game.Hero.Name) has one chance: survive, escape, and carry this warning back to town."
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
    $monsterStarts = $false

    Write-SectionTitle -Text "Encounter" -Color "Red"
    Write-Scene "$($monster.article) $($monster.name) emerges from the darkness."
    Write-Scene "$($monster.definite) squares up against $($Game.Hero.Name)."
    Write-ColorLine ""

    Start-DetectionPhase `
        -Hero $Game.Hero `
        -Monster $monster `
        -HeroStarts ([ref]$heroStarts) `
        -MonsterStarts ([ref]$monsterStarts)

    $encounterFled = $false

    Start-CombatLoop `
        -Hero $Game.Hero `
        -Monster $monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon $HeroDroppedWeapon `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroStarts $heroStarts

    if ($HeroHP.Value -le 0) {
        return "Defeated"
    }

    if ($monsterHP -le 0) {
        Write-Scene "$($monster.definite) collapses to the ground. The path ahead is clear."
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
