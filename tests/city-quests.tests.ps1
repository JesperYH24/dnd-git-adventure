. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-StoryTier {
    param(
        $Game,
        [int]$Tier
    )

    if ($Tier -ge 2) {
        (Find-TownQuest -Game $Game -QuestId "guard_night_watch").Completed = $true
        (Find-TownQuest -Game $Game -QuestId "patron_storehouse_rats").Completed = $true
    }

    if ($Tier -ge 3) {
        (Find-TownQuest -Game $Game -QuestId "patron_ledger_of_ash").Completed = $true
        (Find-TownQuest -Game $Game -QuestId "guard_night_courier").Completed = $true
    }

    if ($Tier -ge 4) {
        (Find-TownQuest -Game $Game -QuestId "guard_broken_seal").Completed = $true
    }
}

function Test-QuestSourcesListOpeningQuestsAndDayJobs {
    $game = Initialize-Game

    $questBoard = @(Get-TownQuestList -Game $game -Source "Quest Board")
    $guard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $patron = @(Get-TownQuestList -Game $game -Source "Quest Giver")

    Assert-Equal -Actual $questBoard.Count -Expected 3 -Message "The quest board should list one opening story quest and two day jobs."
    Assert-Equal -Actual $guard.Count -Expected 2 -Message "The guard station should list one opening story quest and one day job before deeper clues are found."
    Assert-Equal -Actual $patron.Count -Expected 2 -Message "The quest giver should list one opening tier-1 story quest and one scribe day job before deeper tiers open."
}

function Use-StoryCombatWinStub {
    $global:StoryCombatOverride = {
        param(
            $Game,
            [ref]$HeroHP,
            $Monster,
            [string]$Title,
            [string]$IntroText
        )

        return [PSCustomObject]@{
            Won = $true
            Defeated = $false
            Fled = $false
        }
    }
}

function Use-ReadHostSequence {
    param([string[]]$Values)

    $script:QuestReadHostQueue = [System.Collections.Generic.Queue[string]]::new()

    foreach ($value in $Values) {
        $script:QuestReadHostQueue.Enqueue($value)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:QuestReadHostQueue.Count -eq 0) {
            $caller = (Get-PSCallStack | Where-Object { $_.FunctionName -like "Test-*" } | Select-Object -First 1).FunctionName
            throw "Read-Host was called more times than expected. Test: $caller. Prompt: $Prompt"
        }

        return $script:QuestReadHostQueue.Dequeue()
    }
}

function Test-NightWatchReliefCompletesAndSetsStoryFlag {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Night Watch Relief should complete after a successful patrol."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundTunnelAccess"] -Expected $true -Message "Night Watch Relief should confirm tunnel access for chapter two."
    Assert-Equal -Actual $game.Hero.XP -Expected 120 -Message "Night Watch Relief should grant paced Tier 1 XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 180 -Message "Night Watch Relief should pay its listed copper reward."
    Assert-Equal -Actual $game.Town.Relationships["NightCaptain"] -Expected "Respectful" -Message "Finishing the patrol should improve the guard relationship."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $true -Message "A finished story quest should consume the daily story slot."
}

function Test-StorehouseTroubleCompletesAndGrantsItemReward {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "patron_storehouse_rats" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_storehouse_rats"

    $quest = Find-TownQuest -Game $game -QuestId "patron_storehouse_rats"
    $healingPotions = @($game.Hero.Inventory | Where-Object { $_.Name -eq "Healing Potion" })

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Storehouse Trouble should complete after a successful fight."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $true -Message "Storehouse Trouble should reveal the smuggling link."
    Assert-Equal -Actual $game.Hero.XP -Expected 120 -Message "Storehouse Trouble should grant paced Tier 1 XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 150 -Message "Storehouse Trouble should pay its listed reward."
    Assert-True -Condition ($healingPotions.Count -ge 1) -Message "Storehouse Trouble should add the listed healing potion reward."
}

function Test-DayJobPaysCoinButNoXP {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("2")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The day job should complete after its scene resolves."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "Day jobs should not grant XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "The day job should still pay coin."
    Assert-Equal -Actual $game.Town.DayJobDoneToday -Expected $true -Message "Finishing a day job should consume the daily side-job slot."
}

function Test-SilverKettlePayoutBonusAppliesOnce {
    $game = Initialize-Game
    $game.Town.QuestPayoutBonusCopper = 20

    $firstResult = Complete-TownQuest -Game $game -QuestId "dayjob_market_delivery"
    $secondResult = Complete-TownQuest -Game $game -QuestId "dayjob_gate_labor"

    Assert-Equal -Actual $firstResult.RewardCopper -Expected 110 -Message "Silver Kettle contract insight should add its bonus to the next paid quest."
    Assert-Equal -Actual $firstResult.PayoutBonusCopper -Expected 20 -Message "Completion result should expose how much of the payout came from the relationship bonus."
    Assert-Equal -Actual $game.Town.QuestPayoutBonusCopper -Expected 0 -Message "The Silver Kettle payout bonus should be spent after one paid quest."
    Assert-Equal -Actual $secondResult.RewardCopper -Expected 100 -Message "The payout bonus should not keep applying to later quests."
    Assert-Equal -Actual $secondResult.PayoutBonusCopper -Expected 0 -Message "Later quest completions should report no spent relationship bonus."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 210 -Message "Hero coin should include the one boosted payout and the normal follow-up payout."
}

function Test-QuestRewardTextShowsDynamicDayJobPay {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"
    $baseText = Get-QuestRewardText -Quest $quest -Game $game

    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3
    $veteranText = Get-QuestRewardText -Quest $quest -Game $game

    Assert-True -Condition ($baseText -like "*0 GP, 9 SP, 0 CP*" -and $baseText -notlike "*1 GP, 1 SP, 0 CP*") -Message "Reward preview should show the level 1 day-job payout before veteran rate applies."
    Assert-True -Condition ($veteranText -like "*1 GP, 1 SP, 0 CP*") -Message "Reward preview should show the level 3 veteran day-job payout."
}

function Test-QuestRewardTextShowsActiveSilverKettleBonus {
    $game = Initialize-Game
    $game.Town.QuestPayoutBonusCopper = 20
    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    $rewardText = Get-QuestRewardText -Quest $quest -Game $game

    Assert-True -Condition ($rewardText -like "*0 GP, 9 SP, 0 CP*" -and $rewardText -like "*Silver Kettle*" -and $rewardText -like "*0 GP, 2 SP, 0 CP*") -Message "Reward preview should show the active Silver Kettle payout bonus before the quest is completed."
}

function Test-DayJobVeteranRateImprovesPayAtLevelThree {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("2")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 110 -Message "Level 3 day jobs should pay a small veteran premium without granting XP."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "The veteran premium should not change the no-XP rule for day jobs."
}

function Test-OnlyOneStoryQuestCanBeStartedPerDay {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Accept-TownQuest -Game $game -QuestId "patron_storehouse_rats" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"
    $xpAfterFirst = $game.Hero.XP
    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_storehouse_rats"

    $secondQuest = Find-TownQuest -Game $game -QuestId "patron_storehouse_rats"

    Assert-Equal -Actual $game.Hero.XP -Expected $xpAfterFirst -Message "Starting a second story quest on the same day should not grant more XP."
    Assert-Equal -Actual $secondQuest.Completed -Expected $false -Message "The second story quest should wait until the next day."
}

function Test-TierTwoRequiresBothOpeningInvestigationLeads {
    $guardOnlyGame = Initialize-Game
    (Find-TownQuest -Game $guardOnlyGame -QuestId "guard_night_watch").Completed = $true

    $patronOnlyGame = Initialize-Game
    (Find-TownQuest -Game $patronOnlyGame -QuestId "patron_storehouse_rats").Completed = $true

    $bothGame = Initialize-Game
    (Find-TownQuest -Game $bothGame -QuestId "guard_night_watch").Completed = $true
    (Find-TownQuest -Game $bothGame -QuestId "patron_storehouse_rats").Completed = $true

    Assert-Equal -Actual (Get-CurrentStoryQuestTier -Game $guardOnlyGame) -Expected 1 -Message "The guard opening lead alone should not unlock Tier 2 because the clerk/storehouse half of the investigation is still missing."
    Assert-Equal -Actual (Get-CurrentStoryQuestTier -Game $patronOnlyGame) -Expected 1 -Message "The patron opening lead alone should not unlock Tier 2 because the guard/tunnel half of the investigation is still missing."
    Assert-Equal -Actual (Get-CurrentStoryQuestTier -Game $bothGame) -Expected 2 -Message "Tier 2 should unlock only after both opening investigation leads are complete."
}

function Test-ChapterTwoXpDoesNotReachLevelThreeBeforeTierThree {
    $game = Initialize-Game
    $levelThreeThreshold = Get-XPThresholdForLevel -Level 3
    $tutorialXP = 300

    $allTierOneAndTwoIds = @(
        "guard_night_watch"
        "patron_storehouse_rats"
        "quest_board_missing_herbs"
        "patron_ledger_of_ash"
        "guard_night_courier"
        "bent_nail_whispers"
    )
    $standardUnderstreetPathIds = @(
        "guard_night_watch"
        "patron_storehouse_rats"
        "patron_ledger_of_ash"
        "guard_night_courier"
        "guard_broken_seal"
    )

    $tierOneAndTwoXP = 0
    foreach ($questId in $allTierOneAndTwoIds) {
        $tierOneAndTwoXP += [int](Find-TownQuest -Game $game -QuestId $questId).RewardXP
    }

    $standardPathXP = 0
    foreach ($questId in $standardUnderstreetPathIds) {
        $standardPathXP += [int](Find-TownQuest -Game $game -QuestId $questId).RewardXP
    }

    Assert-True -Condition (($tutorialXP + $tierOneAndTwoXP) -lt $levelThreeThreshold) -Message "Even clearing every Tier 1 and Tier 2 story quest should not make the hero level 3-ready before Tier 3 opens."
    Assert-Equal -Actual ($tutorialXP + $standardPathXP) -Expected $levelThreeThreshold -Message "A normal strong Chapter Two path should reach level 3 readiness at the first Tier 3 access breakthrough."
}

function Test-BrokenSealPatrolUnlocksAfterTwoStoryClues {
    $game = Initialize-Game
    $initialGuard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $initialBrokenSeal = $initialGuard | Where-Object { $_.Id -eq "guard_broken_seal" } | Select-Object -First 1

    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true

    $updatedGuard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $unlockedBrokenSeal = $updatedGuard | Where-Object { $_.Id -eq "guard_broken_seal" } | Select-Object -First 1

    Assert-Equal -Actual $initialBrokenSeal -Expected $null -Message "Broken Seal Patrol should stay hidden until enough clues are found."
    Assert-True -Condition ($null -ne $unlockedBrokenSeal) -Message "Broken Seal Patrol should unlock after two story clues."
}

function Test-BentNailWhispersUnlocksFromBentNailInfo {
    $game = Initialize-Game
    $initialBentNailQuest = Find-TownQuest -Game $game -QuestId "bent_nail_whispers"

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $initialBentNailQuest) -Expected $false -Message "Bent Nail whispers should stay hidden until Borzig has earned shady local information."

    Set-StoryTier -Game $game -Tier 2
    $game.Town.InnFlags["BentNailBrokerInfo"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $initialBentNailQuest) -Expected $true -Message "Bent Nail whispers should unlock once Borzig has broker access at the Bent Nail."
}

function Test-BentNailWhispersCompletesAndSetsBrokerFlag {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.InnFlags["BentNailBrokerInfo"] = $true

    Accept-TownQuest -Game $game -QuestId "bent_nail_whispers" | Out-Null
    Use-ReadHostSequence -Values @("2")

    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "bent_nail_whispers"

    $quest = Find-TownQuest -Game $game -QuestId "bent_nail_whispers"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Whispers Beneath the Bent Nail should complete after the broker scene resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["BentNailBrokerConfirmed"] -Expected $true -Message "The Bent Nail broker quest should confirm the local broker lead."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $true -Message "The broker lead should reinforce the smuggling story flag."
    Assert-Equal -Actual $game.Hero.XP -Expected 90 -Message "Whispers Beneath the Bent Nail should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 130 -Message "Whispers Beneath the Bent Nail should pay its listed copper reward."
}

function Test-BentNailWhispersWeakOutcomeNeedsMoreTierTwoWork {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.InnFlags["BentNailBrokerInfo"] = $true

    Accept-TownQuest -Game $game -QuestId "bent_nail_whispers" | Out-Null
    Use-ReadHostSequence -Values @("2")

    $global:RollDiceOverride = { param([int]$Sides) return 1 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "bent_nail_whispers"

    $quest = Find-TownQuest -Game $game -QuestId "bent_nail_whispers"

    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Weak" -Message "A failed Bent Nail check should mark the quest as weak progress."
    Assert-Equal -Actual $game.Town.StoryFlags["BentNailBrokerConfirmed"] -Expected $null -Message "A weak Bent Nail outcome should not confirm the broker as a major clue."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $null -Message "A weak Bent Nail outcome should not grant the strong smuggling clue."
    Assert-Equal -Actual $game.Hero.XP -Expected 60 -Message "A weak Bent Nail outcome should pay reduced XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "A weak Bent Nail outcome should pay reduced coin."
    Assert-Equal -Actual (Get-CurrentStoryQuestTier -Game $game) -Expected 2 -Message "One weak Tier 2 quest alone should not unlock Tier 3."
}

function Test-NightCourierUnlocksFromCourierLead {
    $game = Initialize-Game
    $courierQuest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $courierQuest) -Expected $false -Message "Night Courier Intercept should stay locked before Borzig has a courier lead."

    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $courierQuest) -Expected $true -Message "Night Courier Intercept should unlock once Borzig has a courier trail to follow."
}

function Test-NightCourierCompletesAndSetsCourierRoute {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Accept-TownQuest -Game $game -QuestId "guard_night_courier" | Out-Null
    Use-ReadHostSequence -Values @("3")

    $global:RollDiceOverride = { param([int]$Sides) return 14 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Night Courier Intercept should complete after the pursuit resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $true -Message "Night Courier Intercept should reveal a courier route into the understreet network."
    Assert-Equal -Actual $game.Hero.XP -Expected 90 -Message "Night Courier Intercept should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 150 -Message "Night Courier Intercept should pay its listed copper reward."
}

function Test-NightCourierWeakOutcomeOnlyFindsCourierMarks {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Accept-TownQuest -Game $game -QuestId "guard_night_courier" | Out-Null
    Use-ReadHostSequence -Values @("3")

    $global:RollDiceOverride = { param([int]$Sides) return 1 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Weak" -Message "A failed courier check should mark the quest as weak progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $null -Message "A weak courier outcome should not reveal the full courier route."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundStreetCourierMark"] -Expected $true -Message "A weak courier outcome should still preserve the lesser courier clue."
    Assert-Equal -Actual $game.Hero.XP -Expected 60 -Message "A weak courier outcome should pay reduced XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 100 -Message "A weak courier outcome should pay reduced coin."
}

function Test-BardCanUsePerformanceStyleToSolveMissingHerbSatchel {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "quest_board_missing_herbs" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "quest_board_missing_herbs"

    $quest = Find-TownQuest -Game $game -QuestId "quest_board_missing_herbs"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A bard should be able to finish Missing Herb Satchel through the class-specific calming option."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The bard's calming performance route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundStreetCourierMark"] -Expected $true -Message "The bard's class-specific satchel route should still uncover the courier clue."
}

function Test-QuestApproachReadSceneThenChosenMethodResolves {
    $game = Initialize-Game -Class "Fighter"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "quest_board_missing_herbs" | Out-Null
    Use-ReadHostSequence -Values @("1", "3")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "quest_board_missing_herbs"

    $quest = Find-TownQuest -Game $game -QuestId "quest_board_missing_herbs"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A quest approach menu should allow reading the scene before choosing the actual resolving method."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The chosen approach after reading the scene should still determine the final outcome."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundStreetCourierMark"] -Expected $true -Message "The final approach, not the read itself, should secure the quest clue."
}

function Test-BardCanCharmSeriksNameOutOfLedgerContacts {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2

    Accept-TownQuest -Game $game -QuestId "patron_ledger_of_ash" | Out-Null
    Use-ReadHostSequence -Values @("5", "2")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_ledger_of_ash"

    $quest = Find-TownQuest -Game $game -QuestId "patron_ledger_of_ash"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A bard should be able to complete Ledger of Ash through the class-specific social route."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The bard's ledger-flattery route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["NamedUnderstreetLeader"] -Expected $true -Message "The bard's ledger route should still identify Serik as a strong clue."
}

function Test-BardCanUseStreetPerformanceToCatchNightCourier {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Accept-TownQuest -Game $game -QuestId "guard_night_courier" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A bard should be able to finish Night Courier with the staged street-performance option."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The bard's courier performance route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $true -Message "The bard's courier route should still reveal the real courier lane."
}

function Test-BardCanTalkWarehouseClerkIntoCorrectingALie {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_warehouse_ledger" | Out-Null
    Use-ReadHostSequence -Values @("5", "2")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_warehouse_ledger"

    $quest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A bard should be able to complete Warehouse Ledger Recovery through the class-specific bluff route."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The bard's warehouse bluff route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["SecuredLedgerEvidence"] -Expected $true -Message "The bard's warehouse route should still secure the hard ledger evidence."
}

function Test-BardCanResolveMissingDeliveryWithPublicShowmanship {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A bard should be able to finish Missing Delivery through public showmanship."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "The bard's day-job route should still grant no XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "The bard's day-job route should still pay the normal day-job rate."
}

function Test-BarbarianCanHoldTheRoadForMissingHerbSatchel {
    $game = Initialize-Game -Class "Barbarian"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "quest_board_missing_herbs" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "quest_board_missing_herbs"

    $quest = Find-TownQuest -Game $game -QuestId "quest_board_missing_herbs"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A barbarian should be able to finish Missing Herb Satchel through the class-specific road-holding option."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The barbarian's satchel endurance route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundStreetCourierMark"] -Expected $true -Message "The barbarian's satchel route should still uncover the courier clue."
}

function Test-BarbarianCanBreakLedgerBluffForSeriksName {
    $game = Initialize-Game -Class "Barbarian"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2

    Accept-TownQuest -Game $game -QuestId "patron_ledger_of_ash" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_ledger_of_ash"

    $quest = Find-TownQuest -Game $game -QuestId "patron_ledger_of_ash"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A barbarian should be able to complete Ledger of Ash through the class-specific pressure route."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The barbarian's ledger pressure route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["NamedUnderstreetLeader"] -Expected $true -Message "The barbarian's ledger route should still identify Serik as a strong clue."
}

function Test-BarbarianCanRunDownNightCourier {
    $game = Initialize-Game -Class "Barbarian"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Accept-TownQuest -Game $game -QuestId "guard_night_courier" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A barbarian should be able to finish Night Courier by running the courier down."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The barbarian's courier pursuit route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $true -Message "The barbarian's courier route should still reveal the real courier lane."
}

function Test-BarbarianCanRipWarehouseOfficeOpen {
    $game = Initialize-Game -Class "Barbarian"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_warehouse_ledger" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_warehouse_ledger"

    $quest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A barbarian should be able to complete Warehouse Ledger Recovery through the class-specific office-smashing route."
    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Strong" -Message "The barbarian's warehouse smash route should count as strong progress."
    Assert-Equal -Actual $game.Town.StoryFlags["SecuredLedgerEvidence"] -Expected $true -Message "The barbarian's warehouse route should still secure the hard ledger evidence."
}

function Test-BarbarianCanResolveMissingDeliveryByBruteCarry {
    $game = Initialize-Game -Class "Barbarian"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("5")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "A barbarian should be able to finish Missing Delivery through the class-specific brute-carry route."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "The barbarian's day-job route should still grant no XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "The barbarian's day-job route should still pay the normal day-job rate."
}

function Test-WarehouseLedgerUnlocksFromLedgerClues {
    $game = Initialize-Game
    $ledgerQuest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $ledgerQuest) -Expected $false -Message "Warehouse Ledger Recovery should stay locked before Borzig has real ledger clues."

    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $ledgerQuest) -Expected $true -Message "Warehouse Ledger Recovery should unlock after ledger irregularities are confirmed."
}

function Test-WarehouseLedgerCompletesAndSecuresEvidence {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_warehouse_ledger" | Out-Null
    Use-ReadHostSequence -Values @("3")

    $global:RollDiceOverride = { param([int]$Sides) return 16 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_warehouse_ledger"

    $quest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Warehouse Ledger Recovery should complete after the search resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["SecuredLedgerEvidence"] -Expected $true -Message "Warehouse Ledger Recovery should secure hard ledger evidence."
    Assert-Equal -Actual $game.Town.StoryFlags["NamedUnderstreetLeader"] -Expected $true -Message "Warehouse Ledger Recovery should be able to name the leader behind the route."
    Assert-Equal -Actual $game.Hero.XP -Expected 180 -Message "Warehouse Ledger Recovery should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 170 -Message "Warehouse Ledger Recovery should pay its listed copper reward."
}

function Test-WarehouseLedgerWeakOutcomeDoesNotOpenFinalTierByItself {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_warehouse_ledger" | Out-Null
    Use-ReadHostSequence -Values @("3")

    $global:RollDiceOverride = { param([int]$Sides) return 1 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_warehouse_ledger"

    $quest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Weak" -Message "A failed warehouse check should mark the quest as weak progress."
    Assert-Equal -Actual $game.Town.StoryFlags["SecuredLedgerEvidence"] -Expected $null -Message "A weak warehouse outcome should not secure hard ledger evidence."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundEconomicIrregularity"] -Expected $true -Message "A weak warehouse outcome should still preserve the lesser ledger clue."
    Assert-Equal -Actual $game.Hero.XP -Expected 120 -Message "A weak warehouse outcome should pay reduced XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 120 -Message "A weak warehouse outcome should pay reduced coin."
    Assert-Equal -Actual (Get-CurrentStoryQuestTier -Game $game) -Expected 3 -Message "One weak Tier 3 quest alone should not unlock Tier 4."
}

function Test-UnderstreetComplexStaysLockedWithoutTunnelAccess {
    $game = Initialize-Game
    $finalQuest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    (Find-TownQuest -Game $game -QuestId "guard_night_watch").Completed = $true
    (Find-TownQuest -Game $game -QuestId "patron_ledger_of_ash").Completed = $true
    (Find-TownQuest -Game $game -QuestId "guard_night_courier").Completed = $true
    (Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger").Completed = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["FoundCourierRoute"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $finalQuest) -Expected $false -Message "The Understreet Complex should stay locked until Borzig confirms real tunnel access."
}

function Test-UnderstreetComplexUnlocksWithTunnelAccessAndTwoStrongClues {
    $game = Initialize-Game
    $finalQuest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["FoundCourierRoute"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $finalQuest) -Expected $true -Message "The Understreet Complex should unlock once Borzig has tunnel access and at least two major story clues."
}

function Test-UnderstreetComplexStaysLockedWithoutOpeningSourcePair {
    $game = Initialize-Game
    $finalQuest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    (Find-TownQuest -Game $game -QuestId "patron_storehouse_rats").Completed = $true
    (Find-TownQuest -Game $game -QuestId "patron_ledger_of_ash").Completed = $true
    (Find-TownQuest -Game $game -QuestId "guard_night_courier").Completed = $true
    (Find-TownQuest -Game $game -QuestId "guard_broken_seal").Completed = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $finalQuest) -Expected $false -Message "The Understreet Complex should stay locked if the opening Guard Station and Quest Giver leads were not both completed."
}

function Test-SilentKnifeStaysHiddenUntilUnderstreetCleared {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "patron_silent_knife"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "The Silent Knife should stay hidden before Chapter Two is complete."

    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $true -Message "The Silent Knife should unlock as a post-Understreet Quest Giver hook."
}

function Test-SilentKnifeRevealsTheMysteriousBenefactor {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_silent_knife" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_silent_knife"

    $quest = Find-TownQuest -Game $game -QuestId "patron_silent_knife"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Silent Knife should complete after the assassination attempt is stopped."
    Assert-Equal -Actual $game.Town.StoryFlags["SilentKnifeFoiled"] -Expected $true -Message "The Silent Knife should record that the attempted murder was foiled."
    Assert-Equal -Actual $game.Town.StoryFlags["BenefactorRevealed"] -Expected $true -Message "The Silent Knife should reveal the mysterious benefactor."
    Assert-Equal -Actual $game.Town.Relationships["LadyVeyra"] -Expected "Indebted" -Message "Lady Veyra should become a tracked city relationship."
    Assert-Equal -Actual $game.Hero.XP -Expected 220 -Message "The Silent Knife should grant its listed story XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 220 -Message "The Silent Knife should pay its listed copper reward."
}

function Test-DocksBlackContractStaysHiddenUntilLadyVeyraReveal {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "docks_black_contract"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "The dockside contract quest should stay hidden before Lady Veyra is revealed."

    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $true -Message "The dockside contract quest should unlock once Lady Veyra has been revealed."
}

function Test-DocksBlackContractOpensDockDistrictWithoutHigherPatron {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["DocksUnlocked"] = $true

    Accept-TownQuest -Game $game -QuestId "docks_black_contract" | Out-Null
    Use-ReadHostSequence -Values @("3")
    Use-StoryCombatWinStub
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_black_contract"

    $quest = Find-TownQuest -Game $game -QuestId "docks_black_contract"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The dockside contract quest should complete once the killer is stopped."
    Assert-Equal -Actual $game.Town.StoryFlags["NamedVeyraContractBroker"] -Expected $true -Message "The docks quest should confirm the contract passed through a named dockside broker."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksFirstChainComplete"] -Expected $true -Message "The first docks chain should mark the river quarter as mapped enough to revisit."
    Assert-Equal -Actual ([bool]$game.Town.StoryFlags["HigherPatronSuspected"]) -Expected $false -Message "The first docks chain should not reveal the higher patron yet."
    Assert-Equal -Actual $game.Town.Relationships["LadyVeyra"] -Expected "Warned" -Message "Lady Veyra's relationship state should update once the dockside proof reaches her."
    Assert-Equal -Actual $game.Hero.XP -Expected 300 -Message "The docks quest should grant its listed story XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 250 -Message "The docks quest should pay its listed copper reward."
    $global:RollDiceOverride = $null
}

function Test-SalvageWitnessCompletesAsDocksTierOneQuest {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_salvage_witness" | Out-Null
    Use-ReadHostSequence -Values @("3")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_salvage_witness"

    $quest = Find-TownQuest -Game $game -QuestId "docks_salvage_witness"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Salvage Witness should complete as a Docks Tier 1 clue quest."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksSalvageWitnessSecured"] -Expected $true -Message "Salvage Witness should secure Auntie's evidence flag."
    Assert-Equal -Actual $game.Hero.XP -Expected 220 -Message "Salvage Witness should grant its listed story XP."
    $global:RollDiceOverride = $null
}

function Test-TideLedgerMarksCompletesAsDocksTierOneFallbackQuest {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_tide_ledger_marks" | Out-Null
    Use-ReadHostSequence -Values @("2")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_tide_ledger_marks"

    $quest = Find-TownQuest -Game $game -QuestId "docks_tide_ledger_marks"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Tide-Ledger Marks should complete as a Docks Tier 1 fallback clue quest."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksTideLedgerMarksSecured"] -Expected $true -Message "Tide-Ledger Marks should secure its paper-trail clue flag."
    Assert-Equal -Actual $game.Hero.XP -Expected 180 -Message "Tide-Ledger Marks should grant its listed story XP."
    $global:RollDiceOverride = $null
}

function Test-BrokersWakeUnlocksAfterEnoughDocksTierOneWork {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"
    $blackContract = Find-TownQuest -Game $game -QuestId "docks_black_contract"
    $salvageWitness = Find-TownQuest -Game $game -QuestId "docks_salvage_witness"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "The Broker's Wake should stay hidden before enough Docks Tier 1 work is complete."

    $blackContract.Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "One Docks Tier 1 quest should not unlock Docks Tier 2 by itself."

    $salvageWitness.Completed = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $true -Message "The Broker's Wake should unlock after two Docks Tier 1 quests are complete."
}

function Test-BrokersWakeProfilesOrganizationWithoutNobleReveal {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_brokers_wake" | Out-Null
    Use-ReadHostSequence -Values @("3")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_brokers_wake"

    $quest = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Broker's Wake should complete after the organization is profiled."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksOrganizationProfiled"] -Expected $true -Message "The quest should record what the dockside organization does."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksCharterScribeLead"] -Expected $true -Message "The quest should point toward the charter scribe as the next lead."
    Assert-Equal -Actual ([bool]$game.Town.StoryFlags["HigherPatronSuspected"]) -Expected $false -Message "The organization profile should not reveal the higher patron yet."
    Assert-Equal -Actual $game.Hero.XP -Expected 270 -Message "The Broker's Wake should grant its listed story XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 210 -Message "The Broker's Wake should pay its listed copper reward."
    $global:RollDiceOverride = $null
}

function Test-DebtHooksCompletesAsDocksTierTwoQuest {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_debt_hooks" | Out-Null
    Use-ReadHostSequence -Values @("3")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_debt_hooks"

    $quest = Find-TownQuest -Game $game -QuestId "docks_debt_hooks"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Debt Hooks should complete as a Docks Tier 2 quest."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksDebtLedgerSecured"] -Expected $true -Message "Debt Hooks should secure proof of the debt/protection scheme."
    Assert-Equal -Actual $game.Hero.XP -Expected 250 -Message "Debt Hooks should grant its listed story XP."
    $global:RollDiceOverride = $null
}

function Test-BlackmailBookCompletesAsDocksTierTwoFallbackQuest {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_blackmail_book" | Out-Null
    Use-ReadHostSequence -Values @("2")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_blackmail_book"

    $quest = Find-TownQuest -Game $game -QuestId "docks_blackmail_book"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Blackmail Book should complete as a Docks Tier 2 fallback organization quest."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksBlackmailBookRecovered"] -Expected $true -Message "The Blackmail Book should recover proof of the blackmail system."
    Assert-Equal -Actual $game.Hero.XP -Expected 230 -Message "The Blackmail Book should grant its listed story XP."
    $global:RollDiceOverride = $null
}

function Test-CharterScribeUnlocksAfterEnoughDocksTierTwoWork {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "docks_charter_scribe"
    $brokersWake = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"
    $debtHooks = Find-TownQuest -Game $game -QuestId "docks_debt_hooks"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "The Charter Scribe should stay hidden before the organization profile creates the paper trail."

    $brokersWake.Completed = $true
    $game.Town.StoryFlags["DocksOrganizationProfiled"] = $true
    $game.Town.StoryFlags["DocksCharterScribeLead"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "One Docks Tier 2 quest should not unlock Docks Tier 3 by itself."

    $debtHooks.Completed = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $true -Message "The Charter Scribe should unlock once two Docks Tier 2 quests are complete."
}

function Test-DocksProgressionUsesSeparateQuestTiers {
    $game = Initialize-Game
    $blackContract = Find-TownQuest -Game $game -QuestId "docks_black_contract"
    $salvageWitness = Find-TownQuest -Game $game -QuestId "docks_salvage_witness"
    $brokersWake = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"
    $debtHooks = Find-TownQuest -Game $game -QuestId "docks_debt_hooks"
    $charterScribe = Find-TownQuest -Game $game -QuestId "docks_charter_scribe"
    $shellCharter = Find-TownQuest -Game $game -QuestId "docks_shell_charter"
    $countingHouse = Find-TownQuest -Game $game -QuestId "docks_counting_house_pressure"

    Set-StoryTier -Game $game -Tier 4

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 0 -Message "Docks tiers should stay closed before Lady Veyra is revealed."

    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 1 -Message "The Lady Veyra reveal should open Docks Tier 1."
    Assert-Equal -Actual (Get-TownQuestTierLabel -Quest $blackContract) -Expected "Docks Tier 1" -Message "Black Contract should be labeled as the first Docks tier."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $blackContract) -Expected $true -Message "Docks Tier 1 should unlock Black Contract on the Tide."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $salvageWitness) -Expected $true -Message "Docks Tier 1 should also offer a second clue quest."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $brokersWake) -Expected $false -Message "Docks Tier 2 should not unlock before the first docks chain is complete."

    $blackContract.Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 1 -Message "One Docks Tier 1 quest should keep the current Docks tier at 1."

    $salvageWitness.Completed = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 2 -Message "Completing two Docks Tier 1 quests should open Docks Tier 2."
    Assert-Equal -Actual (Get-TownQuestTierLabel -Quest $brokersWake) -Expected "Docks Tier 2" -Message "The Broker's Wake should be labeled as Docks Tier 2."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $brokersWake) -Expected $true -Message "Docks Tier 2 should unlock The Broker's Wake."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $debtHooks) -Expected $true -Message "Docks Tier 2 should also offer a second organization quest."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $charterScribe) -Expected $false -Message "Docks Tier 3 should not unlock before the organization is profiled."

    $brokersWake.Completed = $true
    $game.Town.StoryFlags["DocksOrganizationProfiled"] = $true
    $game.Town.StoryFlags["DocksCharterScribeLead"] = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 2 -Message "One Docks Tier 2 quest should keep the current Docks tier at 2."

    $debtHooks.Completed = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 3 -Message "Completing two Docks Tier 2 quests should open Docks Tier 3."
    Assert-Equal -Actual (Get-TownQuestTierLabel -Quest $charterScribe) -Expected "Docks Tier 3" -Message "The Charter Scribe should be labeled as Docks Tier 3."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $charterScribe) -Expected $true -Message "Docks Tier 3 should unlock The Charter Scribe."

    $charterScribe.Completed = $true
    $game.Town.StoryFlags["DocksCharterScribeExposed"] = $true
    $game.Hero.Level = 3

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 4 -Message "Completing the Charter Scribe should advance the docks to Tier 4."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $shellCharter) -Expected $false -Message "Docks Tier 4 should wait for the level 4 long rest before offering the shell charter."

    $game.Hero.Level = 4

    Assert-Equal -Actual (Get-TownQuestTierLabel -Quest $shellCharter) -Expected "Docks Tier 4" -Message "The Shell Charter should be labeled as Docks Tier 4."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $shellCharter) -Expected $true -Message "Docks Tier 4 should unlock The Shell Charter at level 4."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $countingHouse) -Expected $true -Message "Docks Tier 4 should also offer Counting House Pressure at level 4."
}

function Test-DocksWeakTierOneNeedsFallbackQuest {
    $game = Initialize-Game
    $blackContract = Find-TownQuest -Game $game -QuestId "docks_black_contract"
    $salvageWitness = Find-TownQuest -Game $game -QuestId "docks_salvage_witness"
    $tideLedger = Find-TownQuest -Game $game -QuestId "docks_tide_ledger_marks"
    $brokersWake = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    $blackContract.Completed = $true
    $blackContract.AdvanceOutcome = "Weak"
    $salvageWitness.Completed = $true
    $salvageWitness.AdvanceOutcome = "Weak"

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 1 -Message "Two weak Docks Tier 1 quests should not unlock Tier 2 by themselves."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $brokersWake) -Expected $false -Message "The Broker's Wake should wait when Tier 1 only has weak progress."

    $tideLedger.Completed = $true
    $tideLedger.AdvanceOutcome = "Weak"
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 2 -Message "Three completed weak Docks Tier 1 quests should unlock Tier 2 as fallback progress."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $brokersWake) -Expected $true -Message "The Broker's Wake should unlock through fallback completed Docks Tier 1 work."
}

function Test-CharterScribeSetsLevelFourReadiness {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3
    $game.Hero.XP = 2400
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_brokers_wake").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_debt_hooks").Completed = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $game.Town.StoryFlags["DocksOrganizationProfiled"] = $true
    $game.Town.StoryFlags["DocksCharterScribeLead"] = $true
    $game.Town.StoryQuestDoneToday = $false

    Accept-TownQuest -Game $game -QuestId "docks_charter_scribe" | Out-Null
    Use-ReadHostSequence -Values @("2")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_charter_scribe"

    $quest = Find-TownQuest -Game $game -QuestId "docks_charter_scribe"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Charter Scribe should complete once the legal shield is cracked."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksCharterScribeExposed"] -Expected $true -Message "The quest should mark the scribe behind the clean-paper trail as exposed."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksLevelFourReady"] -Expected $true -Message "The quest should mark the story beat that prepares the hero for level 4."
    Assert-Equal -Actual $game.Hero.LevelCap -Expected 4 -Message "Completing the charter-scribe quest should raise the level cap to 4."
    Assert-Equal -Actual $game.Hero.XP -Expected 2700 -Message "The charter-scribe quest should complete the natural Docks-chain XP curve to level 4."
    Assert-Equal -Actual (Get-HeroAvailableLevelUps -Hero $game.Hero) -Expected 1 -Message "The hero should be level-up ready after the charter-scribe breakthrough."
    $global:RollDiceOverride = $null
}

function Test-DocksQuestXpCurveNaturallyReachesLevelFour {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 4
    $game.Hero.XP = 1360

    $blackContract = Find-TownQuest -Game $game -QuestId "docks_black_contract"
    $salvageWitness = Find-TownQuest -Game $game -QuestId "docks_salvage_witness"
    $brokersWake = Find-TownQuest -Game $game -QuestId "docks_brokers_wake"
    $debtHooks = Find-TownQuest -Game $game -QuestId "docks_debt_hooks"
    $charterScribe = Find-TownQuest -Game $game -QuestId "docks_charter_scribe"

    Grant-HeroXP -Hero $game.Hero -XP ([int]$blackContract.RewardXP)
    Assert-Equal -Actual $game.Hero.XP -Expected 1660 -Message "Black Contract on the Tide should make meaningful progress toward level 4 without reaching it alone."
    Assert-Equal -Actual (Get-HeroAvailableLevelUps -Hero $game.Hero) -Expected 0 -Message "The first docks quest should not trigger level 4 by itself."

    Grant-HeroXP -Hero $game.Hero -XP ([int]$salvageWitness.RewardXP)
    Assert-Equal -Actual $game.Hero.XP -Expected 1880 -Message "Completing Docks Tier 1 should move the hero meaningfully toward level 4."

    Grant-HeroXP -Hero $game.Hero -XP ([int]$brokersWake.RewardXP)
    Assert-Equal -Actual $game.Hero.XP -Expected 2150 -Message "The Broker's Wake should keep building the Docks XP curve."
    Assert-Equal -Actual (Get-HeroAvailableLevelUps -Hero $game.Hero) -Expected 0 -Message "The organization profile should still leave the level-up for the pre-climax breakthrough."

    Grant-HeroXP -Hero $game.Hero -XP ([int]$debtHooks.RewardXP)
    Assert-Equal -Actual $game.Hero.XP -Expected 2400 -Message "Completing Docks Tier 2 should leave the final tier as the pre-climax breakthrough."

    Grant-HeroXP -Hero $game.Hero -XP ([int]$charterScribe.RewardXP)
    Assert-Equal -Actual $game.Hero.XP -Expected 2700 -Message "The Docks quest chain should naturally reach the level 4 threshold after The Charter Scribe."
    Assert-Equal -Actual (Get-HeroAvailableLevelUps -Hero $game.Hero) -Expected 1 -Message "The completed Docks XP curve should make the hero level 4-ready."
}

function Test-DocksTierFourRequiresLevelFourAfterCharterScribe {
    $game = Initialize-Game
    $shellCharter = Find-TownQuest -Game $game -QuestId "docks_shell_charter"
    $countingHouse = Find-TownQuest -Game $game -QuestId "docks_counting_house_pressure"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_brokers_wake").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_debt_hooks").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_charter_scribe").Completed = $true
    $game.Town.StoryFlags["DocksCharterScribeExposed"] = $true
    $game.Hero.Level = 3

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 4 -Message "The post-charter docks tier should be active after the scribe is exposed."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $shellCharter) -Expected $false -Message "The Shell Charter should stay locked until the hero has taken the level 4 rest."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $countingHouse) -Expected $false -Message "Counting House Pressure should stay locked until the hero has taken the level 4 rest."

    $game.Hero.Level = 4

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $shellCharter) -Expected $true -Message "The Shell Charter should unlock after the hero reaches level 4."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $countingHouse) -Expected $true -Message "Counting House Pressure should unlock after the hero reaches level 4."
}

function Test-DocksWeakTierFourNeedsFallbackQuest {
    $game = Initialize-Game
    $shellCharter = Find-TownQuest -Game $game -QuestId "docks_shell_charter"
    $countingHouse = Find-TownQuest -Game $game -QuestId "docks_counting_house_pressure"
    $customsStamp = Find-TownQuest -Game $game -QuestId "docks_customs_stamp"

    Set-StoryTier -Game $game -Tier 4
    $game.Hero.Level = 4
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_brokers_wake").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_debt_hooks").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_charter_scribe").Completed = $true
    $game.Town.StoryFlags["DocksCharterScribeExposed"] = $true

    $shellCharter.Completed = $true
    $shellCharter.AdvanceOutcome = "Weak"
    $countingHouse.Completed = $true
    $countingHouse.AdvanceOutcome = "Weak"

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 4 -Message "Two weak Docks Tier 4 quests should not finish the current Docks chain."

    $customsStamp.Completed = $true
    $customsStamp.AdvanceOutcome = "Weak"

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 5 -Message "Three completed weak Docks Tier 4 quests should finish the current Docks chain as fallback progress."
}

function Test-DocksTierFourQuestsExposeHigherCityTrail {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Hero.Level = 4
    $game.Hero.LevelCap = 4
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    (Find-TownQuest -Game $game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_salvage_witness").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_brokers_wake").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_debt_hooks").Completed = $true
    (Find-TownQuest -Game $game -QuestId "docks_charter_scribe").Completed = $true
    $game.Town.StoryFlags["DocksCharterScribeExposed"] = $true

    Accept-TownQuest -Game $game -QuestId "docks_shell_charter" | Out-Null
    Use-ReadHostSequence -Values @("2")
    $global:RollDiceOverride = { param([int]$Sides) return 15 }
    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_shell_charter"

    $game.Town.StoryQuestDoneToday = $false
    Accept-TownQuest -Game $game -QuestId "docks_counting_house_pressure" | Out-Null
    Use-ReadHostSequence -Values @("3")
    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_counting_house_pressure"

    $shellCharter = Find-TownQuest -Game $game -QuestId "docks_shell_charter"
    $countingHouse = Find-TownQuest -Game $game -QuestId "docks_counting_house_pressure"

    Assert-Equal -Actual $shellCharter.Completed -Expected $true -Message "The Shell Charter should complete as a Docks Tier 4 quest."
    Assert-Equal -Actual $countingHouse.Completed -Expected $true -Message "Counting House Pressure should complete as a Docks Tier 4 quest."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksShellCharterSecured"] -Expected $true -Message "The Shell Charter should secure the shell-company proof flag."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksCountingHouseExposed"] -Expected $true -Message "Counting House Pressure should secure the counting-house proof flag."
    Assert-Equal -Actual $game.Town.StoryFlags["HigherPatronSuspected"] -Expected $true -Message "Completing both Docks Tier 4 quests should finally point toward higher city hands."
    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 5 -Message "Completing both Docks Tier 4 quests should finish the current Docks tier chain."
    $global:RollDiceOverride = $null
}

function Set-DocksCivicVaultReadyState {
    param($Game)

    Set-StoryTier -Game $Game -Tier 4
    $Game.Town.ChapterTwoComplete = $true
    $Game.Town.StoryFlags["BenefactorRevealed"] = $true
    $Game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $Game.Town.StoryFlags["DocksOrganizationProfiled"] = $true
    $Game.Town.StoryFlags["DocksCharterScribeLead"] = $true
    $Game.Town.StoryFlags["DocksCharterScribeExposed"] = $true
    $Game.Town.StoryFlags["HigherPatronSuspected"] = $true
    $Game.Hero.Level = 4
    $Game.Hero.LevelCap = 4

    (Find-TownQuest -Game $Game -QuestId "docks_black_contract").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_salvage_witness").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_brokers_wake").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_debt_hooks").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_charter_scribe").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_shell_charter").Completed = $true
    (Find-TownQuest -Game $Game -QuestId "docks_counting_house_pressure").Completed = $true
}

function Test-CivicVaultUnlocksAfterDocksHigherPatronTrail {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "docks_civic_vault"

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $false -Message "The Civic Vault should stay hidden before the Docks higher-patron trail is complete."

    Set-DocksCivicVaultReadyState -Game $game

    Assert-Equal -Actual (Get-CurrentDocksQuestTier -Game $game) -Expected 5 -Message "The completed Docks paper trail should advance to the Civic Vault tier."
    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $quest) -Expected $true -Message "The Civic Vault should unlock after enough Docks Tier 4 proof points above the docks."
}

function Test-CivicVaultIncludesDungeonRoomsRestAndLoot {
    $rooms = Get-CivicVaultRooms

    Assert-True -Condition ($rooms.Count -ge 8) -Message "The Civic Vault should be a real dungeon-sized room layout."
    Assert-Equal -Actual $rooms["hidden_culvert"].Exits["east"] -Expected "seal_lift" -Message "The Civic Vault should start from a secret culvert entrance."
    Assert-True -Condition $rooms["ledger_refuge"].CanShortRest -Message "The Civic Vault should include a defensible short-rest room."
    Assert-True -Condition ($rooms["charter_archive"].LockedCacheLoot.Count -ge 2) -Message "The Civic Vault archive should include locked progression loot."
    Assert-Equal -Actual $rooms["hidden_court"].BossRoom -Expected $true -Message "The Civic Vault should end in a boss chamber."
}

function Test-CivicVaultCompletesAndNamesHalewick {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-DocksCivicVaultReadyState -Game $game

    Accept-TownQuest -Game $game -QuestId "docks_civic_vault" | Out-Null
    Use-StoryCombatWinStub
    Use-ReadHostSequence -Values @("1", "1", "1", "1", "1", "1", "1")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "docks_civic_vault"

    $quest = Find-TownQuest -Game $game -QuestId "docks_civic_vault"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Civic Vault should complete after the hidden court boss is defeated."
    Assert-Equal -Actual $game.Town.StoryFlags["CivicVaultCleared"] -Expected $true -Message "Completing the Civic Vault should mark the dungeon as cleared."
    Assert-Equal -Actual $game.Town.StoryFlags["LordHalewickNamed"] -Expected $true -Message "The Civic Vault should name Lord Varric Halewick as the higher patron."
    Assert-Equal -Actual $game.Town.StoryFlags["VeyraContractOrderFound"] -Expected $true -Message "The Civic Vault should secure the order behind Lady Veyra's contract."
    Assert-Equal -Actual $game.Town.StoryFlags["LordHalewickDragonRevealed"] -Expected $true -Message "The Civic Vault finale should reveal Halewick's draconic nature."
    Assert-Equal -Actual $game.Town.StoryFlags["LordHalewickEscaped"] -Expected $true -Message "The Civic Vault finale should leave Halewick alive as an escaped threat."
    Assert-Equal -Actual $game.Hero.XP -Expected 420 -Message "The Civic Vault should grant its listed XP reward."
}

function Test-StorySummaryTracksEscapedHalewick {
    $game = Initialize-Game
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true
    $game.Town.StoryFlags["HigherPatronSuspected"] = $true
    $game.Town.StoryFlags["LordHalewickEscaped"] = $true

    $summary = Get-StoryClueProgressSummary -Game $game
    $notes = @(Get-StoryClueNotes -Game $game)
    $dragonNote = $notes | Where-Object { $_.Flag -eq "LordHalewickEscaped" } | Select-Object -First 1

    Assert-True -Condition ($summary -like "*Halewick*draconic*escaped*") -Message "The story progress summary should prioritize the post-Civic-Vault escaped dragon state."
    Assert-True -Condition ($null -ne $dragonNote) -Message "The quest log should include a story note for Halewick's public draconic escape."
    Assert-Equal -Actual $dragonNote.Category -Expected "Dragon" -Message "Halewick's escape should be categorized as a dragon-state clue."
}

function Test-UnderstreetComplexCanBeAcceptedAfterUnlock {
    $game = Initialize-Game

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true

    $result = Accept-TownQuest -Game $game -QuestId "guard_understreet_complex"
    $quest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    Assert-Equal -Actual $result.Success -Expected $true -Message "The Understreet Complex should be acceptible once its evidence requirements are met."
    Assert-Equal -Actual $quest.Accepted -Expected $true -Message "Accepting the Understreet Complex should add it to Borzig's quest log."
}

function Test-UnderstreetComplexCannotStartBeforeLevelThree {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Hero.XP = 900

    Accept-TownQuest -Game $game -QuestId "guard_understreet_complex" | Out-Null
    Use-ReadHostSequence -Values @()

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_understreet_complex"

    $quest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    Assert-Equal -Actual $quest.Completed -Expected $false -Message "The Understreet Complex should not start while Borzig is still level 2."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $false -Message "Trying to start the final quest early should not consume the daily story slot."
}

function Test-UnderstreetComplexCompletesAndMarksChapterTwo {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    Accept-TownQuest -Game $game -QuestId "guard_understreet_complex" | Out-Null
    Use-StoryCombatWinStub
    Use-ReadHostSequence -Values @("1", "1", "1", "1", "1")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_understreet_complex"

    $quest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The Understreet Complex should complete after Borzig wins the final assault."
    Assert-Equal -Actual $game.Town.ChapterTwoComplete -Expected $true -Message "Finishing the Understreet Complex should mark chapter two as complete."
    Assert-Equal -Actual $game.Town.StoryFlags["UnderstreetComplexCleared"] -Expected $true -Message "Finishing the final quest should mark the complex as cleared."
    Assert-Equal -Actual $game.Hero.XP -Expected 240 -Message "The Understreet Complex should grant its final story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 230 -Message "The Understreet Complex should pay its listed copper reward."
}

function Test-UnderstreetFirstSafeRoomShowsShortRestHintOnce {
    $rooms = Get-UnderstreetComplexRooms
    $safeRoom = $rooms["cistern_refuge"]

    $firstHint = Get-UnderstreetRoomRestHintText -Room $safeRoom
    $safeRoom.RestHintShown = $true
    $secondHint = Get-UnderstreetRoomRestHintText -Room $safeRoom

    Assert-True -Condition (-not [string]::IsNullOrWhiteSpace($firstHint)) -Message "The first compatible Understreet room should explain that Borzig can secure it for a short rest."
    Assert-Equal -Actual $secondHint -Expected "" -Message "The short-rest hint should only appear once per room."
}

function Test-UnderstreetHoundCritIsDangerousButNotBardErasing {
    $hound = Get-UnderstreetHoundEnemy
    $global:RollDiceOverride = { param([int]$Sides) return $Sides }

    $criticalDamage = Get-MonsterCriticalDamage -Monster $hound

    Assert-Equal -Actual $hound.attackBonus -Expected 4 -Message "The tunnel hound should be accurate but not tuned like a boss."
    Assert-Equal -Actual $hound.damageDiceSides -Expected 6 -Message "The tunnel hound should use a d6 damage die after the burst tuning pass."
    Assert-True -Condition ($criticalDamage.Damage -le 14) -Message "A max tunnel hound crit should stay dangerous without one-shotting a healthy level 3 bard."
}

function Test-UnderstreetEncountersAddSimpleLootAfterVictory {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $rooms = Get-UnderstreetComplexRooms
    $room = $rooms["flooded_switchback"]
    $currentRoomId = "flooded_switchback"

    Use-StoryCombatWinStub

    Assert-Equal -Actual $room.Loot.Count -Expected 0 -Message "Encounter loot should not be visible before the room fight is won."

    $result = Resolve-UnderstreetRoomEncounter -Game $game -Room $room -HeroHP ([ref]$heroHP) -PreviousRoomId "sentry_turn" -CurrentRoomId ([ref]$currentRoomId)

    Assert-Equal -Actual $result -Expected "Won" -Message "The hound room should resolve as won under the combat stub."
    Assert-Equal -Actual $room.EncounterResolved -Expected $true -Message "Winning the encounter should mark the room resolved."
    Assert-True -Condition (@($room.Loot | Where-Object { $_.Name -eq "Waterlogged Handler Purse" }).Count -eq 1) -Message "The hound encounter should add its coin purse to room loot."
    Assert-True -Condition (@($room.Loot | Where-Object { $_.Name -eq "Bandage Roll" }).Count -eq 1) -Message "The hound encounter should add a small utility heal item."
    Assert-Equal -Actual @($room.EncounterRewardLoot).Count -Expected 0 -Message "Encounter reward loot should be moved only once."
}

function Test-UnderstreetShortRestHealsAndClearsBuff {
    $game = Initialize-Game
    $heroHP = 6
    $global:RollDiceOverride = $null

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3
    Apply-HeroBuff -Hero $game.Hero -BuffType "Haste" -BuffName "Potion of Haste"

    Accept-TownQuest -Game $game -QuestId "guard_understreet_complex" | Out-Null
    Use-StoryCombatWinStub
    Use-ReadHostSequence -Values @("1", "1", "3", "R", "1", "1", "1", "1")

    function global:Roll-Dice {
        param([int]$Sides)
        return 6
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_understreet_complex"

    Assert-True -Condition ($heroHP -gt 6) -Message "Securing a room in the Understreet Complex should heal Borzig during a short rest."
    Assert-Equal -Actual $game.Hero.ActiveBuff -Expected $null -Message "Taking a short rest in a secured room should clear the current dungeon buff."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardCanCastInvisibilityInCalmUnderstreetRoom {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.Level = 4
    Initialize-HeroSpellcasting -Hero $game.Hero | Out-Null
    Restore-HeroSpellSlots -Hero $game.Hero | Out-Null
    $heroHP = $game.Hero.HP

    $script:UnderstreetInput = [System.Collections.Queue]::new()
    foreach ($choice in @("V", "Q")) {
        $script:UnderstreetInput.Enqueue($choice)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:UnderstreetInput.Count -eq 0) {
            throw "No understreet test input remains for prompt '$Prompt'."
        }

        return $script:UnderstreetInput.Dequeue()
    }

    try {
        $result = Start-UnderstreetComplexExploration -Game $game -HeroHP ([ref]$heroHP)
    }
    finally {
        Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
    }

    Assert-Equal -Actual $result -Expected "Withdrawn" -Message "The test should withdraw after casting Invisibility in the calm starting room."
    Assert-Equal -Actual $game.Hero.ActiveBuff.Type -Expected "Invisibility" -Message "A calm Understreet room should let a level 4 bard cast Invisibility out of combat."
    Assert-Equal -Actual $game.Hero.CurrentSpellSlots.Level2 -Expected 2 -Message "Dungeon-room Invisibility should spend one level 2 spell slot."
}

function Test-BardInvisibilityCanBypassUnderstreetEncounter {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    $rooms = Get-UnderstreetComplexRooms
    $room = $rooms["sentry_turn"]
    $currentRoomId = "sentry_turn"

    Apply-HeroBuff -Hero $game.Hero -BuffType "Invisibility" -BuffName "Invisibility"
    Use-ReadHostSequence -Values @("1")

    $result = Resolve-UnderstreetRoomEncounter -Game $game -Room $room -HeroHP ([ref]$heroHP) -PreviousRoomId "contraband_hall" -CurrentRoomId ([ref]$currentRoomId)

    Assert-Equal -Actual $result -Expected "Avoided" -Message "Invisibility should let a bard slip past a normal Understreet encounter."
    Assert-Equal -Actual $room.EncounterResolved -Expected $true -Message "Bypassing the encounter should mark the room resolved."
    Assert-Equal -Actual $game.Hero.ActiveBuff -Expected $null -Message "Using the hidden angle to bypass a room should spend the active Invisibility buff."
    Assert-Equal -Actual $room.Loot.Count -Expected 0 -Message "Bypassing an encounter should not create defeated-enemy loot."
}

function Test-BardInvisibilityCanOpenUnderstreetEncounterOffBalance {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    $rooms = Get-UnderstreetComplexRooms
    $room = $rooms["contraband_hall"]
    $currentRoomId = "contraband_hall"
    $script:StoryCombatHeroStartsOverride = $false
    $script:StoryCombatHasHeroStartsOverride = $false
    $script:StoryCombatMonsterStartsOffBalance = $false

    Apply-HeroBuff -Hero $game.Hero -BuffType "Invisibility" -BuffName "Invisibility"
    Use-ReadHostSequence -Values @("2")

    $global:StoryCombatOverride = {
        param(
            $Game,
            [ref]$HeroHP,
            $Monster,
            [string]$Title,
            [string]$IntroText,
            [bool]$HeroStartsOverride,
            [bool]$HasHeroStartsOverride,
            [bool]$MonsterStartsOffBalance
        )

        $script:StoryCombatHeroStartsOverride = $HeroStartsOverride
        $script:StoryCombatHasHeroStartsOverride = $HasHeroStartsOverride
        $script:StoryCombatMonsterStartsOffBalance = $MonsterStartsOffBalance

        return [PSCustomObject]@{
            Won = $true
            Defeated = $false
            Fled = $false
        }
    }

    try {
        $result = Resolve-UnderstreetRoomEncounter -Game $game -Room $room -HeroHP ([ref]$heroHP) -PreviousRoomId "sealed_descent" -CurrentRoomId ([ref]$currentRoomId)
    }
    finally {
        $global:StoryCombatOverride = $null
    }

    Assert-Equal -Actual $result -Expected "Won" -Message "Choosing the ambush route should still resolve through combat."
    Assert-Equal -Actual $script:StoryCombatHasHeroStartsOverride -Expected $true -Message "Invisibility ambush should override the normal detection opening."
    Assert-Equal -Actual $script:StoryCombatHeroStartsOverride -Expected $true -Message "Invisibility ambush should make the hero act first."
    Assert-Equal -Actual $script:StoryCombatMonsterStartsOffBalance -Expected $true -Message "Invisibility ambush should start the monster off balance."
    Assert-Equal -Actual $game.Hero.ActiveBuff -Expected $null -Message "Breaking cover for the first strike should spend the active Invisibility buff."
}

function Test-UnderstreetComplexIncludesExtendedMazeLayout {
    $rooms = Get-UnderstreetComplexRooms

    Assert-True -Condition ($rooms.Count -ge 10) -Message "The Understreet Complex should now contain a larger maze of rooms."
    Assert-Equal -Actual $rooms["contraband_hall"].Exits["north"] -Expected "sentry_turn" -Message "Contraband Hall should branch north into the deeper maze."
    Assert-Equal -Actual $rooms["tally_crossing"].Exits["south"] -Expected "sump_gallery" -Message "The central crossing should connect into the lower sump route."
    Assert-Equal -Actual $rooms["old_armory"].Exits["north"] -Expected "smugglers_lockup" -Message "The armory should lead into an additional dead-end lockup branch."
}

function Test-UnderstreetSearchCanRevealKeyAndLockedCacheLoot {
    $game = Initialize-Game
    $rooms = Get-UnderstreetComplexRooms
    $whisperCells = $rooms["whisper_cells"]
    $oldArmory = $rooms["old_armory"]
    $global:RollDiceOverride = { param([int]$Sides) return 20 }

    Search-UnderstreetRoom -Game $game -Room $whisperCells

    Assert-Equal -Actual $game.Town.StoryFlags["UnderstreetArmoryKey"] -Expected $true -Message "Searching the whisper cells should be able to reveal the armory key."

    Use-ReadHostSequence -Values @("3")
    Resolve-UnderstreetLockedCache -Game $game -Room $oldArmory

    Assert-Equal -Actual $oldArmory.LockedCacheOpened -Expected $true -Message "The old armory locker should open once Borzig has the recovered key."
    Assert-True -Condition ($oldArmory.Loot.Count -ge 2) -Message "Opening the armory locker should move its rewards into room loot."
}

function Test-BardUnderstreetFinaleUsesClassAwareText {
    $game = Initialize-Game -Class "Bard"
    $rooms = Get-UnderstreetComplexRooms
    $sentryRoom = $rooms["sentry_turn"]

    $briefing = Get-UnderstreetFinalClassText -Hero $game.Hero -Key "BriefingClues"
    $approach = Get-UnderstreetFinalClassText -Hero $game.Hero -Key "ApproachBroker"
    $formattedRoomText = Format-UnderstreetHeroText -Text $sentryRoom.Description -Hero $game.Hero

    Assert-True -Condition ($briefing -like "*Gariand*" -and $briefing -like "*social pressure*") -Message "Bard finale briefing should use Gariand and bard-shaped clue language."
    Assert-True -Condition ($approach -like "*half-truth*" -and $approach -like "*quiet smile*") -Message "Bard finale approach text should not read like the barbarian route."
    Assert-True -Condition ($formattedRoomText -like "*Gariand*" -and $formattedRoomText -notlike "*Borzig*") -Message "Understreet room text should render with the current hero name for Bard."
}

function Test-TierTwoKeepsRequiredOpeningLeadsAndAddsCurrentWork {
    $game = Initialize-Game
    Set-StoryTier -Game $game -Tier 2

    $guard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $patron = @(Get-TownQuestList -Game $game -Source "Quest Giver")
    $board = @(Get-TownQuestList -Game $game -Source "Quest Board")

    Assert-Equal -Actual (@($guard | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 1 -Message "Tier 2 should keep the completed opening guard lead visible without adding unrelated guard work before its clue exists."
    Assert-Equal -Actual (@($patron | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 2 -Message "Tier 2 should keep the completed opening patron lead visible and add the current ledger work."
    Assert-Equal -Actual (@($board | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 0 -Message "Tier 1 board story jobs should disappear from work once tier 2 opens."
}

function Test-QuestBoardGetsNewStoryQuestsAfterUnderstreet {
    $game = Initialize-Game
    $game.Hero.Level = 3
    Set-StoryTier -Game $game -Tier 4

    $beforeBoard = @(Get-TownQuestList -Game $game -Source "Quest Board" | Where-Object { $_.QuestType -eq "Story" -and $_.Id -like "quest_board_*" })

    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true
    $afterBoard = @(Get-TownQuestList -Game $game -Source "Quest Board" | Where-Object { $_.QuestType -eq "Story" -and $_.Id -like "quest_board_*" })

    Assert-Equal -Actual (@($beforeBoard | Where-Object { $_.Id -eq "quest_board_sealed_grate" }).Count) -Expected 0 -Message "The post-understreet sealed-grate notice should stay hidden before the Understreet Complex is cleared."
    Assert-Equal -Actual (@($beforeBoard | Where-Object { $_.Id -eq "quest_board_missing_masons" }).Count) -Expected 0 -Message "The post-understreet mason notice should stay hidden before the Understreet Complex is cleared."
    Assert-Equal -Actual (@($afterBoard | Where-Object { $_.Id -eq "quest_board_sealed_grate" }).Count) -Expected 1 -Message "The quest board should gain the sealed-grate story quest after Understreet."
    Assert-Equal -Actual (@($afterBoard | Where-Object { $_.Id -eq "quest_board_missing_masons" }).Count) -Expected 1 -Message "The quest board should gain the missing-mason story quest after Understreet."
}

function Test-PostUnderstreetQuestBoardQuestIsPlayable {
    $game = Initialize-Game
    $game.Hero.Level = 3
    Set-StoryTier -Game $game -Tier 4
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "quest_board_sealed_grate" | Out-Null
    Use-ReadHostSequence -Values @("2")
    function global:Roll-Dice {
        param([int]$Sides)
        return $Sides
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "quest_board_sealed_grate"

    $quest = Find-TownQuest -Game $game -QuestId "quest_board_sealed_grate"
    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The new sealed-grate board quest should complete through its playable handler."
    Assert-Equal -Actual $game.Town.StoryFlags["BoardSealedGrateSolved"] -Expected $true -Message "The sealed-grate quest should set its success flag when the skill approach succeeds."

    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-QuestLogCanOpenAcceptedQuestWithoutQuestgiverVisit {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $script:PreparedQuestId = $null

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Use-ReadHostSequence -Values @("1", "1", "0", "0")

    $global:TownQuestPreparationOverride = {
        param($Game, [ref]$HeroHP, $Quest)
        $script:PreparedQuestId = $Quest.Id
    }

    Start-TownQuestLogMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $script:PreparedQuestId -Expected "guard_night_watch" -Message "The quest log should let Borzig reopen an accepted quest directly."
    $global:TownQuestPreparationOverride = $null
}

function Test-StoryClueNotesReflectKnownEvidence {
    $game = Initialize-Game
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["NamedUnderstreetLeader"] = $true

    $notes = @(Get-StoryClueNotes -Game $game)

    Assert-Equal -Actual $notes.Count -Expected 3 -Message "Story clue notes should list each discovered clue once."
    Assert-Equal -Actual $notes[0].Flag -Expected "FoundTunnelAccess" -Message "Story clue notes should keep a stable readable order."
    Assert-True -Condition ($notes[2].Text -like "*Serik*") -Message "Leader notes should mention the named understreet contact."
}

function Test-StoryClueNotesCondenseCompletedUnderstreetArc {
    $game = Initialize-Game
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["FoundCourierRoute"] = $true
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
    $game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["UnderstreetComplexCleared"] = $true

    $notes = @(Get-StoryClueNotes -Game $game)
    $detailedNotes = @(Get-StoryClueNotes -Game $game -Detailed)

    Assert-Equal -Actual $notes.Count -Expected 1 -Message "Completed Understreet arcs should collapse their raw clue list into one readable summary."
    Assert-Equal -Actual $notes[0].Flag -Expected "UnderstreetArcSummary" -Message "The visible note should identify itself as the Understreet arc summary."
    Assert-True -Condition ($notes[0].Text -like "*Serik*" -and $notes[0].Text -like "*ledger*" -and $notes[0].Text -like "*above ground*") -Message "The Understreet summary should reflect the evidence the player actually found."
    Assert-True -Condition ($detailedNotes.Count -gt $notes.Count) -Message "Detailed story notes should still expose raw evidence for future submenu/detail views."
}

function Test-StoryClueProgressSummaryTracksTierAndEvidence {
    $game = Initialize-Game
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["FoundCourierRoute"] = $true

    $summary = Get-StoryClueProgressSummary -Game $game

    Assert-True -Condition ($summary -like "*Tier 3 active*") -Message "The story clue summary should report the currently active story tier."
    Assert-True -Condition ($summary -like "*2/6*") -Message "The story clue summary should count major evidence toward the chapter finale."
}

function Test-StoryClueProgressSummaryExplainsTierOneUnlockPath {
    $game = Initialize-Game

    $summary = Get-StoryClueProgressSummary -Game $game

    Assert-True -Condition ($summary -like "*Tier 1 active*") -Message "The story clue summary should clearly report when Borzig is still on tier 1."
    Assert-True -Condition ($summary -like "*unlock Tier 2 city work*") -Message "The story clue summary should explain how Borzig advances out of tier 1."
}

function Test-StoryClueProgressSummaryUsesBrokenSealAsRealLead {
    $game = Initialize-Game
    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["NamedUnderstreetLeader"] = $true

    $summary = Get-StoryClueProgressSummary -Game $game

    Assert-True -Condition ($summary -like "*Tier 4 active*") -Message "The story clue summary should treat Broken Seal access as a real understreet lead."
    Assert-True -Condition ($summary -like "*3/6*") -Message "The story clue summary should still count major evidence when access came from Broken Seal Patrol."
}

function Test-BardStoryClueProgressSummaryUsesHeroName {
    $game = Initialize-Game -Class "Bard"
    Set-StoryTier -Game $game -Tier 3

    $summary = Get-StoryClueProgressSummary -Game $game

    Assert-True -Condition ($summary -like "*Gariand*") -Message "The story clue summary should use the bard's hero name when calling out missing progress."
}

function Test-QuestOutcomeTextDefaultsStrongForCompletedStoryQuest {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"
    $quest.Completed = $true

    Assert-Equal -Actual (Get-TownQuestOutcomeText -Quest $quest) -Expected "Strong" -Message "Completed story quests should read as strong by default."
}

function Test-BardicInspirationCanBoostQuestChecks {
    $hero = Get-Hero -Class "Bard"
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Use-ReadHostSequence -Values @("1")

    $global:RollDiceOverride = {
        param([int]$Sides)
        if ($Sides -eq 20) { return 5 }
        if ($Sides -eq 6) { return 4 }
        return 1
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 10 -ActionText "Borzig leans into a calm, practiced line."

    Assert-Equal -Actual $success -Expected $true -Message "A bard should be able to spend bardic inspiration to push a quest check over the DC."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 1 -Message "Spending bardic inspiration on a quest check should consume one prepared die."
}

function Test-BardCharmPersonCanBoostSocialQuestChecks {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    Use-ReadHostSequence -Values @("1")

    $script:CharmPersonRolls = [System.Collections.Generic.Queue[int]]::new()
    $script:CharmPersonRolls.Enqueue(2)
    $script:CharmPersonRolls.Enqueue(5)
    $script:CharmPersonRolls.Enqueue(3)
    $script:CharmPersonRolls.Enqueue(14)

    function global:Roll-Dice {
        param([int]$Sides)
        if ($Sides -eq 20) {
            return $script:CharmPersonRolls.Dequeue()
        }

        return 1
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 16 -ActionText "Gariand softens the clerk's suspicion into curiosity." -CheckTag "Social"

    Assert-Equal -Actual $success -Expected $true -Message "Charm Person should grant advantage to a tagged social CHA quest check when the target fails its Wisdom save."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "Charm Person should spend one level 1 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardCharmPersonCanBeResisted {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    Use-ReadHostSequence -Values @("1")

    $script:CharmPersonRolls = [System.Collections.Generic.Queue[int]]::new()
    $script:CharmPersonRolls.Enqueue(15)
    $script:CharmPersonRolls.Enqueue(18)
    $script:CharmPersonRolls.Enqueue(3)

    function global:Roll-Dice {
        param([int]$Sides)
        if ($Sides -eq 20) {
            return $script:CharmPersonRolls.Dequeue()
        }

        return 1
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 16 -ActionText "Gariand tries to soften the clerk's suspicion." -CheckTag "Social"

    Assert-Equal -Actual $success -Expected $false -Message "A successful target Wisdom save should deny Charm Person advantage."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 1 -Message "A resisted Charm Person should still spend one level 1 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardCharmPersonCanBeDeclined {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    Use-ReadHostSequence -Values @("2")
    function global:Roll-Dice {
        param([int]$Sides)
        return 15
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 12 -ActionText "Gariand keeps the conversation mundane." -CheckTag "Social"

    Assert-Equal -Actual $success -Expected $true -Message "Declining Charm Person should still allow the normal check to resolve."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 2 -Message "Declining Charm Person should not spend a spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardCharmPersonDoesNotTriggerOnPerformanceChecks {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    function global:Read-Host {
        param([string]$Prompt)
        throw "Charm Person should not prompt on a Performance check."
    }

    function global:Roll-Dice {
        param([int]$Sides)
        return 12
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 10 -ActionText "Gariand turns the room with a song." -CheckTag "Performance"

    Assert-Equal -Actual $success -Expected $true -Message "Performance checks should continue to resolve without Charm Person prompts."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level1 -Expected 2 -Message "Performance checks should not spend Charm Person slots."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardSuggestionCanResolveTaggedSocialQuestChecks {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 3
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Use-ReadHostSequence -Values @("1")

    function global:Roll-Dice {
        param([int]$Sides)
        return 5
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 25 -ActionText "Gariand offers the clerk one reasonable way out." -CheckTag "Suggestion"

    Assert-Equal -Actual $success -Expected $true -Message "Suggestion should turn a tagged social check into success when the target fails its Wisdom save."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 1 -Message "Suggestion should spend one level 2 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardSuggestionCanBeResisted {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 3
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Use-ReadHostSequence -Values @("1")

    $script:SuggestionRolls = [System.Collections.Generic.Queue[int]]::new()
    $script:SuggestionRolls.Enqueue(18)
    $script:SuggestionRolls.Enqueue(3)

    function global:Roll-Dice {
        param([int]$Sides)
        if ($Sides -eq 20) {
            return $script:SuggestionRolls.Dequeue()
        }

        return 1
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 16 -ActionText "Gariand offers the clerk one reasonable way out." -CheckTag "Suggestion"

    Assert-Equal -Actual $success -Expected $false -Message "A successful target Wisdom save should make Suggestion fall back to the normal social check."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 1 -Message "A resisted Suggestion should still spend one level 2 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-LowLevelBardCannotUseSuggestionPrompt {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 2
    Initialize-HeroSpellcasting -Hero $hero | Out-Null

    function global:Read-Host {
        param([string]$Prompt)
        throw "Suggestion should not prompt before the bard knows the spell and has level 2 slots."
    }

    function global:Roll-Dice {
        param([int]$Sides)
        return 15
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "CHA" -DC 12 -ActionText "Gariand keeps the request mundane." -CheckTag "Suggestion"

    Assert-Equal -Actual $success -Expected $true -Message "A low-level bard should still resolve the normal check when Suggestion is unavailable."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 0 -Message "A low-level bard should not spend level 2 slots."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
}

function Test-BardEnhanceAbilityGrantsQuestCheckAdvantage {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Use-ReadHostSequence -Values @("1")

    $script:EnhanceAbilityRolls = [System.Collections.Generic.Queue[int]]::new()
    $script:EnhanceAbilityRolls.Enqueue(4)
    $script:EnhanceAbilityRolls.Enqueue(15)

    function global:Roll-Dice {
        param([int]$Sides)

        if ($Sides -eq 20) {
            return $script:EnhanceAbilityRolls.Dequeue()
        }

        return 1
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "INT" -DC 16 -ActionText "Gariand sharpens the pattern until the ledger stops looking random."

    Assert-Equal -Actual $success -Expected $true -Message "Enhance Ability should grant advantage on the chosen ability check."
    Assert-Equal -Actual (Get-HeroEnhancedAbility -Hero $hero) -Expected "INT" -Message "Enhance Ability should record the chosen ability on the active buff."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 2 -Message "Enhance Ability should spend one level 2 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-BardEnhanceAbilityCanBeDeclined {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Use-ReadHostSequence -Values @("2")

    function global:Roll-Dice {
        param([int]$Sides)
        return 15
    }

    $success = Start-NonCombatQuestCheck -Hero $hero -Ability "WIS" -DC 16 -ActionText "Gariand reads the route by what fear has left behind."

    Assert-Equal -Actual $success -Expected $true -Message "Declining Enhance Ability should still resolve the normal check."
    Assert-Equal -Actual (Get-HeroEnhancedAbility -Hero $hero) -Expected "" -Message "Declining Enhance Ability should not set an active ability buff."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 3 -Message "Declining Enhance Ability should not spend a level 2 spell slot."
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}

function Test-AcceptTownQuestUsesCurrentHeroNameInQuestLogMessage {
    $game = Initialize-Game -Class "Bard"

    $result = Accept-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $result.Success -Expected $true -Message "The bard should still be able to accept town quests normally."
    Assert-True -Condition ($result.Message -like "*Gariand*") -Message "Quest acceptance text should use the current hero's name in the quest log message."
}

function Test-BarbarianStrengthChecksUseAbilityAndProficiency {
    $hero = Get-Hero -Class "Barbarian"
    $profile = Get-HeroAbilityCheckModifier -Hero $hero -Ability "STR"

    Assert-Equal -Actual $profile.AbilityModifier -Expected 2 -Message "A barbarian STR check should use the STR modifier."
    Assert-Equal -Actual $profile.ClassBonus -Expected 2 -Message "A barbarian STR check should add proficiency."
    Assert-Equal -Actual $profile.TotalModifier -Expected 4 -Message "A barbarian STR check total should be modifier plus proficiency."
}

function Test-BardCharismaChecksUseAbilityAndProficiency {
    $hero = Get-Hero -Class "Bard"
    $profile = Get-HeroAbilityCheckModifier -Hero $hero -Ability "CHA"

    Assert-Equal -Actual $profile.AbilityModifier -Expected 2 -Message "A bard CHA check should use the CHA modifier."
    Assert-Equal -Actual $profile.ClassBonus -Expected 2 -Message "A bard CHA check should add proficiency."
    Assert-Equal -Actual $profile.TotalModifier -Expected 4 -Message "A bard CHA check total should be modifier plus proficiency."
}

function Test-BardPerformanceChecksUsePerformanceProficiency {
    $hero = Get-Hero -Class "Bard"
    $profile = Get-HeroAbilityCheckModifier -Hero $hero -Ability "CHA" -CheckTag "Performance"
    $instrument = Get-HeroInstrument -Hero $hero

    Assert-Equal -Actual $profile.AbilityModifier -Expected 2 -Message "A bard performance check should use the CHA modifier."
    Assert-Equal -Actual $profile.ClassBonus -Expected 2 -Message "A bard performance check should add performance proficiency."
    Assert-Equal -Actual $instrument.InspirationBonus -Expected 1 -Message "A bard's starting instrument should still add its own separate performance bonus."
}

function Test-FullDndSkillListIsAvailable {
    $skills = @(Get-HeroSkillNames)

    Assert-Equal -Actual $skills.Count -Expected 18 -Message "The core DnD 5e skill list should include all 18 skills."
    Assert-True -Condition ($skills -contains "Acrobatics") -Message "The skill list should include Acrobatics."
    Assert-True -Condition ($skills -contains "Animal Handling") -Message "The skill list should include Animal Handling."
    Assert-True -Condition ($skills -contains "Sleight of Hand") -Message "The skill list should include Sleight of Hand."
    Assert-True -Condition ($skills -contains "Survival") -Message "The skill list should include Survival."
}

function Test-DndSkillChecksUseMappedAbilitiesAndProficiencies {
    $hero = Get-Hero -Class "Fighter"

    $athletics = Get-HeroSkillCheckModifier -Hero $hero -Skill "athletics"
    $sleight = Get-HeroSkillCheckModifier -Hero $hero -Skill "sleight-of-hand"
    $insight = Get-HeroSkillCheckModifier -Hero $hero -Skill "Insight"

    Assert-Equal -Actual $athletics.Ability -Expected "STR" -Message "Athletics should map to STR."
    Assert-Equal -Actual $athletics.IsProficient -Expected $true -Message "Fighter should start proficient in Athletics."
    Assert-Equal -Actual $athletics.TotalModifier -Expected 4 -Message "Fighter Athletics should include STR and proficiency."
    Assert-Equal -Actual $sleight.Ability -Expected "DEX" -Message "Sleight of Hand should map to DEX."
    Assert-Equal -Actual $sleight.IsProficient -Expected $false -Message "Fighter should not start proficient in Sleight of Hand."
    Assert-Equal -Actual $sleight.TotalModifier -Expected 1 -Message "Unproficient Sleight of Hand should use only DEX at level 1."
    Assert-Equal -Actual $insight.IsProficient -Expected $false -Message "A broad WIS save/check proficiency should not make every WIS skill proficient."
}

function Test-RawAbilityProficiencyDoesNotLeakIntoSkillTree {
    $bard = Get-Hero -Class "Bard"
    $fighter = Get-Hero -Class "Fighter"

    $bardDeception = Get-HeroSkillCheckModifier -Hero $bard -Skill "Deception"
    $fighterMedicine = Get-HeroSkillCheckModifier -Hero $fighter -Skill "Medicine"
    $rawBardCharisma = Get-HeroAbilityCheckModifier -Hero $bard -Ability "CHA"
    $rawFighterWisdom = Get-HeroAbilityCheckModifier -Hero $fighter -Ability "WIS"

    Assert-Equal -Actual $bardDeception.IsProficient -Expected $false -Message "Bard CHA proficiency should not mark untrained Deception as proficient."
    Assert-Equal -Actual $fighterMedicine.IsProficient -Expected $false -Message "Fighter WIS proficiency should not mark untrained Medicine as proficient."
    Assert-Equal -Actual $rawBardCharisma.IsProficient -Expected $true -Message "Raw Bard CHA checks should keep the legacy ability proficiency."
    Assert-Equal -Actual $rawFighterWisdom.IsProficient -Expected $true -Message "Raw Fighter WIS checks should keep the legacy ability proficiency."
}

function Test-QuestChecksResolveDefaultAbilitiesToSkills {
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "STR") -Expected "Athletics" -Message "Quest STR checks should default to Athletics."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "DEX") -Expected "Sleight of Hand" -Message "Quest DEX checks should default to Sleight of Hand."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "INT") -Expected "Investigation" -Message "Quest INT checks should default to Investigation."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "WIS") -Expected "Insight" -Message "Quest WIS checks should default to Insight."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "CHA") -Expected "Persuasion" -Message "Quest CHA checks should default to Persuasion."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "CON") -Expected "" -Message "Quest CON checks should stay raw ability checks because 5e has no CON skill."
}

function Test-QuestCheckTagsOverrideDefaultSkills {
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "WIS" -CheckTag "Perception") -Expected "Perception" -Message "Explicit skill tags should override the default ability mapping."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "CHA" -CheckTag "Social") -Expected "Persuasion" -Message "Social quest tags should resolve to Persuasion."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "CHA" -CheckTag "Suggestion") -Expected "Persuasion" -Message "Suggestion quest tags should resolve to Persuasion while keeping the spell hook."
    Assert-Equal -Actual (Resolve-NonCombatQuestCheckSkill -Ability "DEX" -Skill "Stealth") -Expected "Stealth" -Message "Explicit skill parameters should override the ability default."
}

function Test-QuestChecksCanUseAlternateSkillAbilities {
    $hero = Get-Hero -Class "Fighter"
    $script:AlternateAbilityRolls = [System.Collections.Generic.Queue[int]]::new()
    $script:AlternateAbilityRolls.Enqueue(1)

    $global:RollDiceOverride = {
        param([int]$Sides)
        if ($Sides -eq 20 -and $script:AlternateAbilityRolls.Count -gt 0) {
            return $script:AlternateAbilityRolls.Dequeue()
        }

        return 1
    }

    try {
        $success = Start-NonCombatQuestCheck -Hero $hero -Ability "STR" -Skill "Intimidation" -DC 5 -ActionText "Lubert uses muscle and presence instead of courtly charm."
    }
    finally {
        $global:RollDiceOverride = $null
    }

    Assert-Equal -Actual $success -Expected $true -Message "Explicit STR Intimidation checks should preserve STR as the ability instead of forcing CHA."
}

function Test-BardJackOfAllTradesAppliesToUntrainedDndSkills {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 2

    $profile = Get-HeroSkillCheckModifier -Hero $hero -Skill "Medicine"

    Assert-Equal -Actual $profile.Ability -Expected "WIS" -Message "Medicine should map to WIS."
    Assert-Equal -Actual $profile.IsProficient -Expected $false -Message "The current Bard should not start proficient in Medicine."
    Assert-Equal -Actual $profile.ClassBonus -Expected 1 -Message "Jack of All Trades should apply to untrained DnD skills."
    Assert-Equal -Actual $profile.BonusSource -Expected "JackOfAllTrades" -Message "The bonus source should still identify Jack of All Trades."
}

function Test-BardJackOfAllTradesStartsAtLevelTwo {
    $hero = Get-Hero -Class "Bard"

    $levelOne = Get-HeroAbilityCheckModifier -Hero $hero -Ability "DEX" -CheckTag "Stealth"
    $hero.Level = 2
    $levelTwo = Get-HeroAbilityCheckModifier -Hero $hero -Ability "DEX" -CheckTag "Stealth"

    Assert-Equal -Actual $levelOne.ClassBonus -Expected 0 -Message "Jack of All Trades should not apply at Bard level 1."
    Assert-Equal -Actual $levelTwo.ClassBonus -Expected 1 -Message "Jack of All Trades should add half proficiency at Bard level 2."
    Assert-Equal -Actual $levelTwo.BonusSource -Expected "JackOfAllTrades" -Message "Jack of All Trades checks should identify their bonus source."
    Assert-Equal -Actual (Format-HeroAbilityCheckBonusText -CheckProfile $levelTwo) -Expected " + 1 Jack of All Trades" -Message "Check result text should name Jack of All Trades."
}

function Test-InvisibilityBoostsBardStealthChecks {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 4
    Restore-HeroSpellSlots -Hero $hero | Out-Null
    Invoke-HeroInvisibility -Hero $hero | Out-Null

    $profile = Get-HeroAbilityCheckModifier -Hero $hero -Ability "DEX" -CheckTag "Stealth"

    Assert-Equal -Actual $profile.BuffBonus -Expected 10 -Message "Invisibility should add a strong stealth bonus."
    Assert-Equal -Actual $profile.TotalModifier -Expected ($profile.AbilityModifier + $profile.ClassBonus + 10) -Message "Invisibility should be included in stealth totals."
    Assert-Equal -Actual (Format-HeroAbilityCheckBonusText -CheckProfile $profile) -Expected " + 1 Jack of All Trades + 10 Invisibility" -Message "Stealth check text should include Jack of All Trades and Invisibility."
    Assert-Equal -Actual $hero.CurrentSpellSlots.Level2 -Expected 2 -Message "Casting Invisibility should spend one level 2 spell slot."
}

function Test-BardExpertiseStartsAtLevelThree {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 3

    $profile = Get-HeroAbilityCheckModifier -Hero $hero -Ability "CHA" -CheckTag "Performance"

    Assert-Equal -Actual $profile.IsExpertise -Expected $true -Message "Lore Bard expertise should start at level 3."
    Assert-Equal -Actual $profile.ClassBonus -Expected 4 -Message "Expertise should double proficiency for the selected Bard skill."
    Assert-Equal -Actual $profile.BonusSource -Expected "Expertise" -Message "Expertise checks should identify their bonus source."
    Assert-Equal -Actual (Format-HeroAbilityCheckBonusText -CheckProfile $profile) -Expected " + 4 Expertise" -Message "Check result text should name Expertise."
}

function Test-QuestOutcomeTextReturnsWeakForWeakStoryQuest {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"
    $quest.Completed = $true
    $quest.AdvanceOutcome = "Weak"

    Assert-Equal -Actual (Get-TownQuestOutcomeText -Quest $quest) -Expected "Weak" -Message "Weak story outcomes should stay visible in the quest log."
}

function Test-QuestOutcomeTextStaysBlankForDayJobs {
    $game = Initialize-Game
    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"
    $quest.Completed = $true

    Assert-Equal -Actual (Get-TownQuestOutcomeText -Quest $quest) -Expected "" -Message "Day jobs should not show strong or weak story labels."
}

function Test-FighterHasClassSpecificCityQuestOptions {
    $questScript = Get-Content -Path "$PSScriptRoot\..\city-quests.ps1" -Raw
    $fighterOptionCount = ([regex]::Matches($questScript, '-Class "Fighter"|elseif \(\$Game\.Hero\.Class -eq "Fighter"\)')).Count

    Assert-True -Condition ($fighterOptionCount -ge 18) -Message "Fighter should have its own city quest option branches across day jobs and docks quests."
    Assert-True -Condition ($questScript.Contains("Read the handoff pattern and close the lane without spooking it")) -Message "Fighter should have a Night Courier special option."
    Assert-True -Condition ($questScript.Contains("Treat the counting room like a formal inquiry and hold every exit")) -Message "Fighter should have a Charter Scribe special option."
    Assert-True -Condition ($questScript.Contains("Run the gate like a shield drill and clear one lane at a time")) -Message "Fighter should have a gate duty special option."
}

function Test-ClassStoryApproachStateStartsEmpty {
    $game = Initialize-Game

    Assert-Equal -Actual $game.Town.ClassStoryApproach["BarbarianHardProof"] -Expected 0 -Message "Barbarian hard-proof story track should start at zero."
    Assert-Equal -Actual $game.Town.ClassStoryApproach["BardSoftPower"] -Expected 0 -Message "Bard soft-power story track should start at zero."
    Assert-Equal -Actual $game.Town.ClassStoryApproach["FighterCivicTrust"] -Expected 0 -Message "Fighter civic-trust story track should start at zero."
    Assert-True -Condition ($null -ne $game.Town.ClassStoryApproach["QuestMarks"]) -Message "Class story approach should keep per-quest marks."
}

function Test-ClassStoryApproachOnlyCountsAQuestOnce {
    $game = Initialize-Game -Class "Fighter"

    Register-ClassStoryApproach -Game $game -QuestId "guard_night_watch" -ApproachKey "CivicTrustPatrolDiscipline"
    Register-ClassStoryApproach -Game $game -QuestId "guard_night_watch" -ApproachKey "CivicTrustPatrolDiscipline"

    Assert-Equal -Actual $game.Town.ClassStoryApproach["FighterCivicTrust"] -Expected 1 -Message "Repeating a class mark for the same quest should not inflate the Fighter story track."
    Assert-Equal -Actual $game.Town.ClassStoryApproach["QuestMarks"]["guard_night_watch"] -Expected "CivicTrustPatrolDiscipline" -Message "The per-quest class story mark should be saved."
}

function Test-FighterNightWatchDoesNotBuildCivicTrustWithoutClassChoice {
    $game = Initialize-Game -Class "Fighter"
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "guard_night_watch" | Out-Null
    Use-StoryCombatWinStub

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_watch"

    Assert-Equal -Actual $game.Town.ClassStoryApproach["FighterCivicTrust"] -Expected 0 -Message "A Fighter should not gain civic-trust story identity just for completing combat without choosing a class-specific route."
    Assert-Equal -Actual $game.Town.ClassStoryApproach["QuestMarks"].ContainsKey("guard_night_watch") -Expected $false -Message "Night Watch should not receive a class story mark without a class-specific player choice."
}

function Test-BardLedgerRouteBuildsSoftPower {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2

    Accept-TownQuest -Game $game -QuestId "patron_ledger_of_ash" | Out-Null
    Use-ReadHostSequence -Values @("5", "2")

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_ledger_of_ash"

    Assert-Equal -Actual $game.Town.ClassStoryApproach["BardSoftPower"] -Expected 1 -Message "A Bard who solves Ledger of Ash socially should build soft-power story identity."
    Assert-Equal -Actual $game.Town.ClassStoryApproach["QuestMarks"]["patron_ledger_of_ash"] -Expected "SoftPowerMerchantContradictions" -Message "Ledger of Ash should remember the Bard's social contradiction route."
}

Test-QuestSourcesListOpeningQuestsAndDayJobs
Test-NightWatchReliefCompletesAndSetsStoryFlag
Test-StorehouseTroubleCompletesAndGrantsItemReward
Test-DayJobPaysCoinButNoXP
Test-SilverKettlePayoutBonusAppliesOnce
Test-QuestRewardTextShowsDynamicDayJobPay
Test-QuestRewardTextShowsActiveSilverKettleBonus
Test-DayJobVeteranRateImprovesPayAtLevelThree
Test-OnlyOneStoryQuestCanBeStartedPerDay
Test-TierTwoRequiresBothOpeningInvestigationLeads
Test-ChapterTwoXpDoesNotReachLevelThreeBeforeTierThree
Test-BrokenSealPatrolUnlocksAfterTwoStoryClues
Test-BentNailWhispersUnlocksFromBentNailInfo
Test-BentNailWhispersCompletesAndSetsBrokerFlag
Test-BentNailWhispersWeakOutcomeNeedsMoreTierTwoWork
Test-NightCourierUnlocksFromCourierLead
Test-NightCourierCompletesAndSetsCourierRoute
Test-NightCourierWeakOutcomeOnlyFindsCourierMarks
Test-BardCanUsePerformanceStyleToSolveMissingHerbSatchel
Test-QuestApproachReadSceneThenChosenMethodResolves
Test-BardCanCharmSeriksNameOutOfLedgerContacts
Test-BardCanUseStreetPerformanceToCatchNightCourier
Test-BardCanTalkWarehouseClerkIntoCorrectingALie
Test-BardCanResolveMissingDeliveryWithPublicShowmanship
Test-BarbarianCanHoldTheRoadForMissingHerbSatchel
Test-BarbarianCanBreakLedgerBluffForSeriksName
Test-BarbarianCanRunDownNightCourier
Test-BarbarianCanRipWarehouseOfficeOpen
Test-BarbarianCanResolveMissingDeliveryByBruteCarry
Test-WarehouseLedgerUnlocksFromLedgerClues
Test-WarehouseLedgerCompletesAndSecuresEvidence
Test-WarehouseLedgerWeakOutcomeDoesNotOpenFinalTierByItself
Test-UnderstreetComplexStaysLockedWithoutTunnelAccess
Test-UnderstreetComplexUnlocksWithTunnelAccessAndTwoStrongClues
Test-UnderstreetComplexStaysLockedWithoutOpeningSourcePair
Test-SilentKnifeStaysHiddenUntilUnderstreetCleared
Test-SilentKnifeRevealsTheMysteriousBenefactor
Test-DocksBlackContractStaysHiddenUntilLadyVeyraReveal
Test-DocksBlackContractOpensDockDistrictWithoutHigherPatron
Test-SalvageWitnessCompletesAsDocksTierOneQuest
Test-TideLedgerMarksCompletesAsDocksTierOneFallbackQuest
Test-BrokersWakeUnlocksAfterEnoughDocksTierOneWork
Test-BrokersWakeProfilesOrganizationWithoutNobleReveal
Test-DebtHooksCompletesAsDocksTierTwoQuest
Test-BlackmailBookCompletesAsDocksTierTwoFallbackQuest
Test-CharterScribeUnlocksAfterEnoughDocksTierTwoWork
Test-DocksProgressionUsesSeparateQuestTiers
Test-DocksWeakTierOneNeedsFallbackQuest
Test-CharterScribeSetsLevelFourReadiness
Test-DocksQuestXpCurveNaturallyReachesLevelFour
Test-DocksTierFourRequiresLevelFourAfterCharterScribe
Test-DocksWeakTierFourNeedsFallbackQuest
Test-DocksTierFourQuestsExposeHigherCityTrail
Test-CivicVaultUnlocksAfterDocksHigherPatronTrail
Test-CivicVaultIncludesDungeonRoomsRestAndLoot
Test-CivicVaultCompletesAndNamesHalewick
Test-StorySummaryTracksEscapedHalewick
Test-UnderstreetComplexCanBeAcceptedAfterUnlock
Test-UnderstreetComplexCannotStartBeforeLevelThree
Test-UnderstreetComplexCompletesAndMarksChapterTwo
Test-UnderstreetFirstSafeRoomShowsShortRestHintOnce
Test-UnderstreetHoundCritIsDangerousButNotBardErasing
Test-UnderstreetEncountersAddSimpleLootAfterVictory
Test-UnderstreetShortRestHealsAndClearsBuff
Test-BardCanCastInvisibilityInCalmUnderstreetRoom
Test-BardInvisibilityCanBypassUnderstreetEncounter
Test-BardInvisibilityCanOpenUnderstreetEncounterOffBalance
Test-UnderstreetComplexIncludesExtendedMazeLayout
Test-UnderstreetSearchCanRevealKeyAndLockedCacheLoot
Test-BardUnderstreetFinaleUsesClassAwareText
Test-TierTwoKeepsRequiredOpeningLeadsAndAddsCurrentWork
Test-QuestBoardGetsNewStoryQuestsAfterUnderstreet
Test-PostUnderstreetQuestBoardQuestIsPlayable
Test-QuestLogCanOpenAcceptedQuestWithoutQuestgiverVisit
Test-StoryClueNotesReflectKnownEvidence
Test-StoryClueNotesCondenseCompletedUnderstreetArc
Test-StoryClueProgressSummaryTracksTierAndEvidence
Test-StoryClueProgressSummaryExplainsTierOneUnlockPath
Test-StoryClueProgressSummaryUsesBrokenSealAsRealLead
Test-BardStoryClueProgressSummaryUsesHeroName
Test-QuestOutcomeTextDefaultsStrongForCompletedStoryQuest
Test-QuestOutcomeTextReturnsWeakForWeakStoryQuest
Test-QuestOutcomeTextStaysBlankForDayJobs
Test-FighterHasClassSpecificCityQuestOptions
Test-ClassStoryApproachStateStartsEmpty
Test-ClassStoryApproachOnlyCountsAQuestOnce
Test-FighterNightWatchDoesNotBuildCivicTrustWithoutClassChoice
Test-BardLedgerRouteBuildsSoftPower
Test-BardicInspirationCanBoostQuestChecks
Test-BardCharmPersonCanBoostSocialQuestChecks
Test-BardCharmPersonCanBeResisted
Test-BardCharmPersonCanBeDeclined
Test-BardCharmPersonDoesNotTriggerOnPerformanceChecks
Test-BardSuggestionCanResolveTaggedSocialQuestChecks
Test-BardSuggestionCanBeResisted
Test-LowLevelBardCannotUseSuggestionPrompt
Test-BardEnhanceAbilityGrantsQuestCheckAdvantage
Test-BardEnhanceAbilityCanBeDeclined
Test-AcceptTownQuestUsesCurrentHeroNameInQuestLogMessage
Test-BarbarianStrengthChecksUseAbilityAndProficiency
Test-BardCharismaChecksUseAbilityAndProficiency
Test-BardPerformanceChecksUsePerformanceProficiency
Test-FullDndSkillListIsAvailable
Test-DndSkillChecksUseMappedAbilitiesAndProficiencies
Test-RawAbilityProficiencyDoesNotLeakIntoSkillTree
Test-QuestChecksResolveDefaultAbilitiesToSkills
Test-QuestCheckTagsOverrideDefaultSkills
Test-QuestChecksCanUseAlternateSkillAbilities
Test-BardJackOfAllTradesAppliesToUntrainedDndSkills
Test-BardJackOfAllTradesStartsAtLevelTwo
Test-InvisibilityBoostsBardStealthChecks
Test-BardExpertiseStartsAtLevelThree

Write-Host "City quest tests passed." -ForegroundColor Green
$global:StoryCombatOverride = $null
$global:TownQuestPreparationOverride = $null
$global:RollDiceOverride = $null
if (Test-Path Function:\global:Roll-Dice) {
    Remove-Item Function:\global:Roll-Dice -ErrorAction SilentlyContinue
}
if (Test-Path Function:\global:Read-Host) {
    Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
}
