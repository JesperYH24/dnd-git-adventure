# Chapter quests live outside the generic town menu code so each quest can grow into its own small adventure.

function Get-NightWatchReliefEnemy {
    return [PSCustomObject]@{
        name = "tunnel runner"
        article = "A"
        definite = "The Tunnel Runner"
        combatantType = "Opponent"
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

function Get-StorehouseTroubleEnemy {
    return [PSCustomObject]@{
        name = "storehouse cutthroat"
        article = "A"
        definite = "The Storehouse Cutthroat"
        combatantType = "Opponent"
        hp = 14
        xp = 0
        armorClass = 12
        attackBonus = 3
        initiativeBonus = 1
        damageDiceCount = 1
        damageDiceSides = 6
        damageBonus = 2
        damageMin = 3
        damageMax = 8
        isBoss = $false
    }
}

function Get-BrokenSealPatrolEnemy {
    return [PSCustomObject]@{
        name = "understreet enforcer"
        article = "An"
        definite = "The Understreet Enforcer"
        combatantType = "Opponent"
        hp = 16
        xp = 0
        armorClass = 13
        attackBonus = 4
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 2
        damageMin = 3
        damageMax = 10
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

function Start-NonCombatQuestCheck {
    param(
        $Hero,
        [string]$Ability,
        [int]$DC,
        [string]$ActionText
    )

    $modifier = Get-HeroAbilityModifier -Hero $Hero -Ability $Ability
    $roll = Roll-Dice -Sides 20
    $total = $roll + $modifier

    Write-Scene $ActionText
    Write-Action "$($Hero.Name) tests ${Ability}: roll $roll $(Format-AbilityModifier -Modifier $modifier) = $total vs DC $DC" "Cyan"
    Write-ColorLine ""

    return ($total -ge $DC)
}

function Complete-StoryQuestAndReport {
    param(
        $Game,
        [string]$QuestId,
        [string]$CompletionText,
        [string]$ProgressText = ""
    )

    $completionResult = Complete-TownQuest -Game $Game -QuestId $QuestId

    if (-not $completionResult.Success) {
        return
    }

    Write-Scene $CompletionText

    if ($completionResult.RewardXP -gt 0) {
        Write-Scene "$($Game.Hero.Name) gains $($completionResult.RewardXP) XP."
    }

    if ($completionResult.RewardCopper -gt 0) {
        Write-Scene "$($Game.Hero.Name) receives $(Convert-CopperToCurrencyText -Copper $completionResult.RewardCopper)."
    }

    if ($null -ne $completionResult.RewardItem) {
        Write-Scene "$($Game.Hero.Name) also receives $($completionResult.RewardItem.Name)."
    }

    if (-not [string]::IsNullOrWhiteSpace($ProgressText)) {
        Write-EmphasisLine -Text $ProgressText -Color "Yellow"
    }

    if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
        Write-EmphasisLine -Text "$($Game.Hero.Name) feels stronger. A level up awaits after a long rest." -Color "Yellow"
    }

    Write-ColorLine ""
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

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Patrol the outer district with the night watch and investigate the broken tunnel seal."

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
    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_night_watch" -CompletionText "'Good,' Halden says when Borzig reports back. 'Now we know this city's rot goes below the streets.'" -ProgressText "Story Progress: Borzig has confirmed a real tunnel route beneath the city."
}

function Start-StorehouseTroubleQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "patron_storehouse_rats"

    if ($null -eq $quest) {
        Write-Scene "The storehouse assignment has gone missing from the clerk's stack."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the storehouse job before the clerk hands over the key."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The riverside storehouse is already cleared and paid out."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Clear the riverside storehouse and learn why marked goods are vanishing from inside locked walls."

    Write-SectionTitle -Text "Storehouse Trouble" -Color "Yellow"
    Write-Scene "The patron's clerk presses a cold iron key into Borzig's hand and points him toward the river quarter."
    Write-Scene "Inside the locked storehouse he finds broken crate lids, muddy bootprints, and neat stacks of goods that have already been sorted for resale."
    Write-Scene "Someone has been using the place as a transfer point, not just a hiding place."
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-StorehouseTroubleEnemy) `
        -Title "Riverside Storehouse" `
        -IntroText "A cutthroat steps out from behind the cargo stacks with a club in one hand and a ledger ribbon tied around the other wrist."

    if ($combatResult.Defeated) {
        Write-Scene "$($Game.Hero.Name) is driven out of the storehouse before he can secure the evidence."
        Write-ColorLine ""
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The thief escapes through a side hatch, leaving Borzig with a disturbed storehouse and half a clue."
        Write-ColorLine ""
        return
    }

    Write-Scene "Among the broken crates Borzig finds false seals, rerouting marks, and a list of goods that never should have left the lawful inventory."
    Write-Scene "This is not petty theft. It is organized smuggling with handlers on both sides of the lock."
    Write-ColorLine ""

    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $Game.Town.Relationships["MerchantPatron"] = "Grateful"
    Complete-StoryQuestAndReport -Game $Game -QuestId "patron_storehouse_rats" -CompletionText "The clerk goes pale when Borzig returns the rerouting list. 'So that is where the missing stock went,' he mutters." -ProgressText "Story Progress: Borzig has linked the city's thefts to a real smuggling operation."
}

function Start-MissingHerbSatchelQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "quest_board_missing_herbs"

    if ($null -eq $quest) {
        Write-Scene "The herb notice has already been torn down."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the satchel job before setting out."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The herbalist has already been repaid with the return of the satchel."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Recover the satchel from the old road and find out why the scavengers were afraid to keep it."

    Write-SectionTitle -Text "Missing Herb Satchel" -Color "Yellow"
    Write-Scene "The satchel turns up quickly enough on the old road, wedged under a splintered cart wheel beside scattered bundles of dried leaf."
    Write-Scene "A pair of hungry scavengers lurk nearby, more scared than cruel, and one of them keeps glancing at a chalk mark cut into the stones beside the road."
    Write-ColorLine ""
    Write-ColorLine "1. Intimidate the scavengers into handing everything over" "White"
    Write-ColorLine "2. Calm them down and hear what frightened them" "White"
    Write-ColorLine "3. Search the road yourself and ignore them" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "Borzig steps in close and lets brute presence do the talking."

                if ($success) {
                    Write-Scene "The scavengers surrender the satchel and blurt out that marked runners have been using the old road at night."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }
                else {
                    Write-Scene "The scavengers bolt, but not before Borzig notices the same chalk courier mark they were staring at."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 12 -ActionText "Borzig forces himself to lower his voice and listen before the moment goes bad."

                if ($success) {
                    Write-Scene "The scavengers explain they found the satchel after a courier dropped it while fleeing someone from the city."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }
                else {
                    Write-Scene "Borzig never gets much from them, but a chalk mark near the wheel still catches his eye."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "Borzig crouches by the broken road and follows the little signs most people walk past."

                if ($success) {
                    Write-Scene "He spots the courier mark, the satchel, and a fresh heelprint pointing back toward the city."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }
                else {
                    Write-Scene "The search is clumsy, but Borzig still recovers the satchel after turning half the roadside ditch upside down."
                    $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    if (-not $Game.Town.StoryFlags["FoundStreetCourierMark"]) {
        $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "quest_board_missing_herbs" -CompletionText "The herbalist clutches the satchel to her chest and thanks Borzig more than once before the relief settles in." -ProgressText "Story Progress: Borzig has found another sign that the city's trouble moves along hidden courier routes."
}

function Start-LedgerOfAshQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "patron_ledger_of_ash"

    if ($null -eq $quest) {
        Write-Scene "The ledger assignment is nowhere to be found."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the ledger job before the clerk will risk explaining it."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The ledger has already been read and the payments traced."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Trace the false payments in the ash-stained ledger and learn who profits when city goods disappear."

    Write-SectionTitle -Text "Ledger of Ash" -Color "Yellow"
    Write-Scene "The patron's clerk spreads a smoke-smudged ledger across a narrow desk and shows Borzig which entries do not add up."
    Write-Scene "Some payments are too clean. Some names repeat in different hands. Someone is paying to move goods without asking what they are."
    Write-ColorLine ""
    Write-ColorLine "1. Intimidate the dock clerk named in the ledger" "White"
    Write-ColorLine "2. Study the ledger line by line" "White"
    Write-ColorLine "3. Lean on merchant contacts for help reading the pattern" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "Borzig corners the named clerk in a back office and lets silence do most of the work."
                if ($success) {
                    Write-Scene "The clerk folds quickly and gives up a chain of payments tied to an under-street handler called Serik."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                }
                else {
                    Write-Scene "The clerk lies badly, but Borzig still gets enough names to prove the books were cooked."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "INT" -DC 12 -ActionText "Borzig grinds through the numbers until the lies in the ink start to stand out."
                if ($success) {
                    Write-Scene "Three fake freight lines all point back to the same middleman. The name Serik surfaces again and again."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                }
                else {
                    Write-Scene "The ledger is a mess, but Borzig still proves the irregular payments are real."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "Borzig leans on the best merchant contacts he has and trades plain truth for useful insight."
                if ($success) {
                    Write-Scene "A contact quietly points Borzig to the same under-street name hidden behind the payments: Serik."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                }
                else {
                    Write-Scene "Even without a clean name, Borzig confirms the payments were not normal trade."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "patron_ledger_of_ash" -CompletionText "The clerk takes the marked names in both hands and looks sick. 'That is enough to sink careers,' he whispers." -ProgressText "Story Progress: Borzig has traced the money behind the city's disappearing goods."
}

function Start-BrokenSealPatrolQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_broken_seal"

    if ($null -eq $quest) {
        Write-Scene "The watch has no such patrol on the books."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the broken seal patrol before the watch will move."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The broken seal patrol has already been settled."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Enter the breached maintenance line, clear resistance, and confirm where the hidden route leads."

    Write-SectionTitle -Text "Broken Seal Patrol" -Color "Yellow"
    Write-Scene "Captain Halden sends Borzig with two watchmen to a maintenance hatch that should have been sealed from the inside years ago."
    Write-Scene "The lock is split, the stones are marked, and the air from below smells like wet mortar and torch smoke."
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-BrokenSealPatrolEnemy) `
        -Title "Breached Maintenance Line" `
        -IntroText "A broad-shouldered enforcer rises from the tunnel dark and tries to drive the patrol back before they see how far the route goes."

    if ($combatResult.Defeated) {
        Write-Scene "Borzig is forced up and out before the patrol can secure the line."
        Write-ColorLine ""
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The enforcer falls back deeper into the route, buying the smugglers time and leaving the patrol with only half the answer."
        Write-ColorLine ""
        return
    }

    Write-Scene "Past the broken seal, the patrol finds fresh lamps, dry crate grooves, and enough footprints to prove the line is being used regularly."
    Write-Scene "This is no forgotten drain. It is an artery."
    Write-ColorLine ""

    $Game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true
    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_broken_seal" -CompletionText "Halden listens to the report in silence, then orders the map room opened. 'Good. Now we stop guessing and start hunting.'" -ProgressText "Story Progress: Borzig has confirmed an active understreet route beneath the city."
}

function Start-NightCourierInterceptQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_night_courier"

    if ($null -eq $quest) {
        Write-Scene "The courier assignment is gone from the watch board."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to accept the courier assignment before the watch shares the route."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The night courier has already been intercepted."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Cut off the courier route through the city lanes and recover whatever message is feeding the understreet network."

    Write-SectionTitle -Text "Night Courier Intercept" -Color "Yellow"
    Write-Scene "Belor marks three back lanes on a scrap of guard paper and taps the last one with a callused finger."
    Write-Scene "'Runner moves light, keeps to shadow, and never uses the same lane twice unless he thinks no one is watching. Tonight we make him wrong.'"
    Write-ColorLine ""
    Write-ColorLine "1. Set a hard ambush and block the lane with brute presence" "White"
    Write-ColorLine "2. Trail the courier quietly until he reveals the handoff point" "White"
    Write-ColorLine "3. Step into the open and force a panicked mistake" "White"
    Write-ColorLine "" 

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "Borzig plants himself in the narrowest part of the lane and turns surprise into a wall of muscle."

                if ($success) {
                    Write-Scene "The courier freezes for half a heartbeat too long. Borzig gets a hand on him, tears the satchel free, and sends him running empty into the dark."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.Relationships["Belor"] = "Trusting"
                }
                else {
                    Write-Scene "The courier slips away, but not before dropping a marked wax strip and exposing the lane pattern the watch needed."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "Borzig hangs back and follows the courier by echoes, reflections, and the moments when a runner forgets to be invisible."

                if ($success) {
                    Write-Scene "The trail leads to a hurried exchange beneath a shuttered stair. Borzig does not get the man, but he gets the route and the signal mark."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }
                else {
                    Write-Scene "The courier senses something and breaks early, but the path he chooses still tells Borzig which streets matter."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "Borzig steps out under the lantern light and barks a challenge sharp enough to turn speed into panic."

                if ($success) {
                    Write-Scene "The courier bolts the wrong way, collides with a closed gate, and leaves his message case in Borzig's hands."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }
                else {
                    Write-Scene "The courier still escapes, but the route and the dropped signal token are enough to pin the run to the same network Borzig has been tracking."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_night_courier" -CompletionText "Belor studies the recovered markings in silence, then gives Borzig a curt nod. 'Good. Now we've got their streets as well as their tunnels.'" -ProgressText "Story Progress: Borzig has identified a real courier route feeding the understreet network."
}

function Start-WhispersBeneathBentNailQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "bent_nail_whispers"

    if ($null -eq $quest) {
        Write-Scene "Whatever whispers lived under the Bent Nail seem to have gone quiet."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "Borzig needs to take the broker's lead seriously before the back room opens up."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "Borzig has already squeezed what truth he can from the Bent Nail's under-table whispers."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Lean on the Bent Nail's broker network and learn where the city's quiet cargo routes are feeding into the understreets."

    Write-SectionTitle -Text "Whispers Beneath the Bent Nail" -Color "Yellow"
    Write-Scene "Past the loud tables and dice cups, a scarred broker finally admits Borzig into the Bent Nail's back booths."
    Write-Scene "The man calls himself Brin and talks like every sentence costs him something. 'You didn't hear this from me,' he mutters. 'But plenty of folk are moving cargo that never sees a legal ledger.'"
    Write-ColorLine ""
    Write-ColorLine "1. Press Brin hard and demand the route names" "White"
    Write-ColorLine "2. Buy him a drink and let him talk on his own terms" "White"
    Write-ColorLine "3. Leave the booth and shadow the next handoff yourself" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "Borzig leans over the table and makes it clear this is the last soft chance Brin gets."

                if ($success) {
                    Write-Scene "Brin folds fast and names a smugglers' route running beneath the river stairs, along with the warning that the work is organized."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $Game.Town.Relationships["UnderstreetBroker"] = "Useful"
                }
                else {
                    Write-Scene "Brin gives up less than Borzig wants, but enough slips loose to prove the Bent Nail has been feeding work into the same underground routes."
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $Game.Town.Relationships["UnderstreetBroker"] = "Wary"
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "Borzig pays for the next round, lowers his tone, and lets the broker believe the conversation is still his idea."

                if ($success) {
                    Write-Scene "Brin loosens up enough to name the handlers moving cargo off-book and to admit the Bent Nail has been hearing their footsteps for weeks."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $Game.Town.Relationships["UnderstreetBroker"] = "Useful"
                }
                else {
                    Write-Scene "The coin buys patience more than honesty, but Borzig still learns that the same back-room names keep circling smuggled cargo."
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "Borzig slips away from the booth, keeps to the wall, and watches who Brin speaks to once he thinks the meeting is over."

                if ($success) {
                    Write-Scene "Borzig shadows the handoff long enough to catch marked crates and a runner heading toward a hidden lower passage."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                }
                else {
                    Write-Scene "The tail is clumsy, but Borzig still sees enough to prove the Bent Nail is tied to the same cargo movement haunting the city."
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "bent_nail_whispers" -CompletionText "Brin vanishes back into the Bent Nail's smoke before Borzig is even done thinking through the lead." -ProgressText "Story Progress: Borzig has turned Bent Nail whispers into usable understreet intelligence."
}

function Start-MissingDeliveryDayJob {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "dayjob_market_delivery"

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That delivery problem is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text "Missing Delivery" -Color "Yellow"
    Write-Scene "A crate of lamp oil and cheap cloth never reached its stall, and the market runner is desperate to get paid before sunrise."
    Write-ColorLine "1. Intimidate the squatters using the alley as a shortcut" "White"
    Write-ColorLine "2. Lift the jammed crate onto the cart yourself" "White"
    Write-ColorLine "3. Talk the neighbors into helping sort out the mix-up" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "Borzig plants his feet and makes it clear the alley is not worth arguing over." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "Borzig gets his hands under the crate and solves the problem the direct way." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "Borzig forces himself to keep his temper and sort out who actually owes what to whom." }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            Write-Scene "The runner gets the crate back in one piece and pays quickly before anyone changes their mind."
        }
        else {
            Write-Scene "The solution is messy, but the crate still gets home in the end."
        }

        break
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "dayjob_market_delivery" -CompletionText "The runner presses the agreed coin into Borzig's hand and hurries back to the market before dawn." 
}

function Start-GateDutyOverflowDayJob {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "dayjob_gate_labor"

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That gate detail is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text "Gate Duty Overflow" -Color "Yellow"
    Write-Scene "At the east gate, freight has jammed the archway and three drivers are one insult away from a riot."
    Write-ColorLine "1. Bark the line straight with sheer force of presence" "White"
    Write-ColorLine "2. Shoulder the worst wagon clear yourself" "White"
    Write-ColorLine "3. Calm the loudest driver before it spreads" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "Borzig steps into the middle of the jam and makes his presence the new center of the argument." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 11 -ActionText "Borzig leans in against wood and iron until the worst wagon finally shudders free." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 12 -ActionText "Borzig tries the harder route and talks the hottest temper back down before the guards have to draw batons." }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            Write-Scene "The gate sergeant nods once when the line begins moving again. That is as close to praise as the man gets."
        }
        else {
            Write-Scene "It takes longer than anyone likes, but the line clears before sunrise and no blood gets spilled."
        }

        break
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId "dayjob_gate_labor" -CompletionText "The gate sergeant counts out Borzig's pay and tells him to come back if he wants honest work again."
}

function Start-TownQuest {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId
    )

    switch ($QuestId) {
        "guard_night_watch" { Start-NightWatchReliefQuest -Game $Game -HeroHP $HeroHP }
        "guard_night_courier" { Start-NightCourierInterceptQuest -Game $Game -HeroHP $HeroHP }
        "patron_storehouse_rats" { Start-StorehouseTroubleQuest -Game $Game -HeroHP $HeroHP }
        "quest_board_missing_herbs" { Start-MissingHerbSatchelQuest -Game $Game -HeroHP $HeroHP }
        "patron_ledger_of_ash" { Start-LedgerOfAshQuest -Game $Game -HeroHP $HeroHP }
        "guard_broken_seal" { Start-BrokenSealPatrolQuest -Game $Game -HeroHP $HeroHP }
        "bent_nail_whispers" { Start-WhispersBeneathBentNailQuest -Game $Game -HeroHP $HeroHP }
        "dayjob_market_delivery" { Start-MissingDeliveryDayJob -Game $Game -HeroHP $HeroHP }
        "dayjob_gate_labor" { Start-GateDutyOverflowDayJob -Game $Game -HeroHP $HeroHP }
        default {
            Write-Scene "That quest is not playable yet."
            Write-ColorLine ""
        }
    }
}
