# Chapter quests live outside the generic town menu code so each quest can grow into its own small adventure.

function Get-NightWatchReliefEnemy {
    return [PSCustomObject]@{
        name = "tunnel runner"
        article = "A"
        definite = "The Tunnel Runner"
        hp = 12
        xp = 0
        armorClass = 11
        attackBonus = 2
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 6
        damageBonus = 1
        damageMin = 2
        damageMax = 7
        isBoss = $false
    }
}

function Invoke-StoryCombat {
    param(
        $Game,
        [ref]$HeroHP,
        $Monster,
        [string]$Title,
        [string]$IntroText
    )

    $monsterHP = $Monster.hp
    $monsterOffBalance = $false
    $heroStarts = $false
    $heroBonusAttack = $false
    $monsterStarts = $false
    $encounterFled = $false

    Write-SectionTitle -Text $Title -Color "Red"
    Write-Scene $IntroText
    Write-Scene "$($Monster.article) $($Monster.name) steps out to stop Borzig."
    Write-ColorLine ""

    Start-DetectionPhase `
        -Hero $Game.Hero `
        -Monster $Monster `
        -HeroStarts ([ref]$heroStarts) `
        -HeroBonusAttack ([ref]$heroBonusAttack) `
        -MonsterStarts ([ref]$monsterStarts)

    $openingResult = Start-OpeningPhase `
        -Hero $Game.Hero `
        -Monster $Monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$Game.HeroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -HeroStarts $heroStarts `
        -HeroBonusAttack $heroBonusAttack `
        -MonsterStarts $monsterStarts

    if (-not $openingResult) {
        return [PSCustomObject]@{
            Won = ($monsterHP -le 0)
            Defeated = ($HeroHP.Value -le 0)
            Fled = $false
        }
    }

    Start-CombatLoop `
        -Hero $Game.Hero `
        -Monster $Monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$Game.HeroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled)

    return [PSCustomObject]@{
        Won = ($monsterHP -le 0)
        Defeated = ($HeroHP.Value -le 0)
        Fled = $encounterFled
    }
}

function Start-NightWatchReliefQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_night_watch"

    if ($null -eq $quest) {
        Write-Scene "The watch cannot seem to find that assignment anymore."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The watch already counts Night Watch Relief as finished."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the assignment before the watch will brief him."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Started) {
        $quest.Started = $true
        $quest.Objective = "Patrol the outer district with the night watch and investigate the broken tunnel seal."
    }

    Write-SectionTitle -Text "Night Watch Relief" -Color "Yellow"
    Write-Scene "Captain Halden meets Borzig under a guttering lantern and speaks without wasting a word."
    Write-Scene "'Outer district. Broken seal. Strange movement near the old drains. Walk the line, see what scared my people, and come back with something better than rumors.'"
    Write-Scene "Borzig joins Watchwoman Lysa on a short patrol through shuttered alleys and damp stone lanes."
    Write-ColorLine ""
    Write-Scene "At the edge of the district they find a smashed city seal, muddy footprints, and drag marks leading to a storm grate half-pried from the street."
    Write-Scene "Lysa crouches by the ironwork and swears under her breath. 'Someone's using the tunnels.'"
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-NightWatchReliefEnemy) `
        -Title "Outer District Ambush" `
        -IntroText "A lean runner bursts up from the broken drain with a hooked blade and tries to silence the patrol before anyone can shout."

    if ($combatResult.Defeated) {
        Write-Scene "$($Game.Hero.Name) is forced back and the patrol collapses into chaos."
        Write-ColorLine ""
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The runner disappears into the drainage dark before Borzig can finish the chase."
        Write-Scene "Lysa spits into the gutter. 'We still know more than we did, but the captain won't call this settled yet.'"
        Write-ColorLine ""
        return
    }

    Write-Scene "The runner goes down hard. On the body Borzig finds a marked token, a scrap of delivery code, and a key stamped with an undercity sigil."
    Write-Scene "Lysa stares at the broken grate, then at the token in Borzig's hand. 'That is not random theft. That's an operation.'"
    Write-ColorLine ""

    $Game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $Game.Town.Relationships["NightCaptain"] = "Respectful"
    Grant-HeroXP -Hero $Game.Hero -XP 200
    Write-Scene "$($Game.Hero.Name) gains 200 XP."

    $completionResult = Complete-TownQuest -Game $Game -QuestId "guard_night_watch"

    if ($completionResult.Success) {
        Write-Scene "$($Game.Hero.Name) reports back to Captain Halden and turns over the token, code scrap, and key."
        Write-Scene "'Good,' Halden says. 'Now we know this city's rot goes below the streets.'"

        if ($completionResult.RewardCopper -gt 0) {
            Write-Scene "$($Game.Hero.Name) receives $(Convert-CopperToCurrencyText -Copper $completionResult.RewardCopper) for the completed patrol."
        }

        Write-EmphasisLine -Text "Story Progress: Borzig has confirmed a real tunnel route beneath the city." -Color "Yellow"
    }

    if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
        Write-EmphasisLine -Text "$($Game.Hero.Name) feels stronger. A level up awaits after a long rest." -Color "Yellow"
    }

    Write-ColorLine ""
}

function Start-TownQuest {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId
    )

    switch ($QuestId) {
        "guard_night_watch" {
            Start-NightWatchReliefQuest -Game $Game -HeroHP $HeroHP
        }
        default {
            Write-Scene "That quest is not playable yet."
            Write-ColorLine ""
        }
    }
}
