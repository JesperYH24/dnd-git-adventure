. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-StoryTier {
    param(
        $Game,
        [int]$Tier
    )

    if ($Tier -ge 2) {
        (Find-TownQuest -Game $Game -QuestId "guard_night_watch").Completed = $true
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

    Assert-Equal -Actual $questBoard.Count -Expected 2 -Message "The quest board should list one opening story quest and one day job."
    Assert-Equal -Actual $guard.Count -Expected 2 -Message "The guard station should list one opening story quest and one day job before deeper clues are found."
    Assert-Equal -Actual $patron.Count -Expected 1 -Message "The quest giver should list one opening tier-1 story quest before deeper tiers open."
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
            throw "Read-Host was called more times than expected."
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
    Assert-Equal -Actual $game.Hero.XP -Expected 200 -Message "Night Watch Relief should grant 200 XP."
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
    Assert-Equal -Actual $game.Hero.XP -Expected 180 -Message "Storehouse Trouble should grant story XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 150 -Message "Storehouse Trouble should pay its listed reward."
    Assert-True -Condition ($healingPotions.Count -ge 1) -Message "Storehouse Trouble should add the listed healing potion reward."
}

function Test-DayJobPaysCoinButNoXP {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("1")

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "dayjob_market_delivery"

    $quest = Find-TownQuest -Game $game -QuestId "dayjob_market_delivery"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "The day job should complete after its scene resolves."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "Day jobs should not grant XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 90 -Message "The day job should still pay coin."
    Assert-Equal -Actual $game.Town.DayJobDoneToday -Expected $true -Message "Finishing a day job should consume the daily side-job slot."
}

function Test-DayJobVeteranRateImprovesPayAtLevelThree {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    Accept-TownQuest -Game $game -QuestId "dayjob_market_delivery" | Out-Null
    Use-ReadHostSequence -Values @("1")

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
    Use-ReadHostSequence -Values @("1")

    function global:Roll-Dice {
        param([int]$Sides)
        return 15
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "bent_nail_whispers"

    $quest = Find-TownQuest -Game $game -QuestId "bent_nail_whispers"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Whispers Beneath the Bent Nail should complete after the broker scene resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["BentNailBrokerConfirmed"] -Expected $true -Message "The Bent Nail broker quest should confirm the local broker lead."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $true -Message "The broker lead should reinforce the smuggling story flag."
    Assert-Equal -Actual $game.Hero.XP -Expected 150 -Message "Whispers Beneath the Bent Nail should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 130 -Message "Whispers Beneath the Bent Nail should pay its listed copper reward."
}

function Test-BentNailWhispersWeakOutcomeNeedsMoreTierTwoWork {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.InnFlags["BentNailBrokerInfo"] = $true

    Accept-TownQuest -Game $game -QuestId "bent_nail_whispers" | Out-Null
    Use-ReadHostSequence -Values @("1")

    function global:Roll-Dice {
        param([int]$Sides)
        return 1
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "bent_nail_whispers"

    $quest = Find-TownQuest -Game $game -QuestId "bent_nail_whispers"

    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Weak" -Message "A failed Bent Nail check should mark the quest as weak progress."
    Assert-Equal -Actual $game.Town.StoryFlags["BentNailBrokerConfirmed"] -Expected $null -Message "A weak Bent Nail outcome should not confirm the broker as a major clue."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundSmugglingLink"] -Expected $null -Message "A weak Bent Nail outcome should not grant the strong smuggling clue."
    Assert-Equal -Actual $game.Hero.XP -Expected 100 -Message "A weak Bent Nail outcome should pay reduced XP."
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
    Use-ReadHostSequence -Values @("2")

    function global:Roll-Dice {
        param([int]$Sides)
        return 14
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Night Courier Intercept should complete after the pursuit resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $true -Message "Night Courier Intercept should reveal a courier route into the understreet network."
    Assert-Equal -Actual $game.Hero.XP -Expected 160 -Message "Night Courier Intercept should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 150 -Message "Night Courier Intercept should pay its listed copper reward."
}

function Test-NightCourierWeakOutcomeOnlyFindsCourierMarks {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 2
    $game.Town.StoryFlags["FoundStreetCourierMark"] = $true

    Accept-TownQuest -Game $game -QuestId "guard_night_courier" | Out-Null
    Use-ReadHostSequence -Values @("2")

    function global:Roll-Dice {
        param([int]$Sides)
        return 1
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_night_courier"

    $quest = Find-TownQuest -Game $game -QuestId "guard_night_courier"

    Assert-Equal -Actual $quest.AdvanceOutcome -Expected "Weak" -Message "A failed courier check should mark the quest as weak progress."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundCourierRoute"] -Expected $null -Message "A weak courier outcome should not reveal the full courier route."
    Assert-Equal -Actual $game.Town.StoryFlags["FoundStreetCourierMark"] -Expected $true -Message "A weak courier outcome should still preserve the lesser courier clue."
    Assert-Equal -Actual $game.Hero.XP -Expected 110 -Message "A weak courier outcome should pay reduced XP."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 100 -Message "A weak courier outcome should pay reduced coin."
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
    Use-ReadHostSequence -Values @("2")

    function global:Roll-Dice {
        param([int]$Sides)
        return 16
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "patron_warehouse_ledger"

    $quest = Find-TownQuest -Game $game -QuestId "patron_warehouse_ledger"

    Assert-Equal -Actual $quest.Completed -Expected $true -Message "Warehouse Ledger Recovery should complete after the search resolves."
    Assert-Equal -Actual $game.Town.StoryFlags["SecuredLedgerEvidence"] -Expected $true -Message "Warehouse Ledger Recovery should secure hard ledger evidence."
    Assert-Equal -Actual $game.Town.StoryFlags["NamedUnderstreetLeader"] -Expected $true -Message "Warehouse Ledger Recovery should be able to name the leader behind the route."
    Assert-Equal -Actual $game.Hero.XP -Expected 170 -Message "Warehouse Ledger Recovery should grant its story XP reward."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 170 -Message "Warehouse Ledger Recovery should pay its listed copper reward."
}

function Test-WarehouseLedgerWeakOutcomeDoesNotOpenFinalTierByItself {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    Set-StoryTier -Game $game -Tier 3
    $game.Town.StoryFlags["FoundEconomicIrregularity"] = $true

    Accept-TownQuest -Game $game -QuestId "patron_warehouse_ledger" | Out-Null
    Use-ReadHostSequence -Values @("2")

    function global:Roll-Dice {
        param([int]$Sides)
        return 1
    }

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

function Test-UnderstreetComplexUnlocksFromBrokenSealAccessEvenWithoutNightWatch {
    $game = Initialize-Game
    $finalQuest = Find-TownQuest -Game $game -QuestId "guard_understreet_complex"

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true

    Assert-Equal -Actual (Is-TownQuestUnlocked -Game $game -Quest $finalQuest) -Expected $true -Message "The Understreet Complex should unlock for saves that reached Broken Seal Patrol without the tier-1 guard quest."
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
    Use-ReadHostSequence -Values @("1", "1", "1", "1")

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

function Test-UnderstreetShortRestHealsAndClearsBuff {
    $game = Initialize-Game
    $heroHP = 6

    Set-StoryTier -Game $game -Tier 4
    $game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3
    Apply-HeroBuff -Hero $game.Hero -BuffType "Haste" -BuffName "Potion of Haste"

    Accept-TownQuest -Game $game -QuestId "guard_understreet_complex" | Out-Null
    Use-StoryCombatWinStub
    Use-ReadHostSequence -Values @("1", "1", "R", "1", "1")

    function global:Roll-Dice {
        param([int]$Sides)
        return 6
    }

    Start-TownQuest -Game $game -HeroHP ([ref]$heroHP) -QuestId "guard_understreet_complex"

    Assert-True -Condition ($heroHP -gt 6) -Message "Securing a room in the Understreet Complex should heal Borzig during a short rest."
    Assert-Equal -Actual $game.Hero.ActiveBuff -Expected $null -Message "Taking a short rest in a secured room should clear the current dungeon buff."
}

function Test-TierTwoHidesTierOneStoryQuestsFromWorkSources {
    $game = Initialize-Game
    Set-StoryTier -Game $game -Tier 2

    $guard = @(Get-TownQuestList -Game $game -Source "Guard Station")
    $patron = @(Get-TownQuestList -Game $game -Source "Quest Giver")
    $board = @(Get-TownQuestList -Game $game -Source "Quest Board")

    Assert-Equal -Actual (@($guard | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 1 -Message "Tier 2 should replace the opening guard story job with the current tier's guard work."
    Assert-Equal -Actual (@($patron | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 1 -Message "Tier 2 should replace the opening patron story job with the current tier's patron work."
    Assert-Equal -Actual (@($board | Where-Object { $_.QuestType -eq "Story" }).Count) -Expected 0 -Message "Tier 1 board story jobs should disappear from work once tier 2 opens."
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

Test-QuestSourcesListOpeningQuestsAndDayJobs
Test-NightWatchReliefCompletesAndSetsStoryFlag
Test-StorehouseTroubleCompletesAndGrantsItemReward
Test-DayJobPaysCoinButNoXP
Test-DayJobVeteranRateImprovesPayAtLevelThree
Test-OnlyOneStoryQuestCanBeStartedPerDay
Test-BrokenSealPatrolUnlocksAfterTwoStoryClues
Test-BentNailWhispersUnlocksFromBentNailInfo
Test-BentNailWhispersCompletesAndSetsBrokerFlag
Test-BentNailWhispersWeakOutcomeNeedsMoreTierTwoWork
Test-NightCourierUnlocksFromCourierLead
Test-NightCourierCompletesAndSetsCourierRoute
Test-NightCourierWeakOutcomeOnlyFindsCourierMarks
Test-WarehouseLedgerUnlocksFromLedgerClues
Test-WarehouseLedgerCompletesAndSecuresEvidence
Test-WarehouseLedgerWeakOutcomeDoesNotOpenFinalTierByItself
Test-UnderstreetComplexStaysLockedWithoutTunnelAccess
Test-UnderstreetComplexUnlocksWithTunnelAccessAndTwoStrongClues
Test-UnderstreetComplexUnlocksFromBrokenSealAccessEvenWithoutNightWatch
Test-UnderstreetComplexCanBeAcceptedAfterUnlock
Test-UnderstreetComplexCannotStartBeforeLevelThree
Test-UnderstreetComplexCompletesAndMarksChapterTwo
Test-UnderstreetFirstSafeRoomShowsShortRestHintOnce
Test-UnderstreetShortRestHealsAndClearsBuff
Test-TierTwoHidesTierOneStoryQuestsFromWorkSources
Test-QuestLogCanOpenAcceptedQuestWithoutQuestgiverVisit
Test-StoryClueNotesReflectKnownEvidence
Test-StoryClueProgressSummaryTracksTierAndEvidence
Test-StoryClueProgressSummaryExplainsTierOneUnlockPath
Test-StoryClueProgressSummaryUsesBrokenSealAsRealLead

Write-Host "City quest tests passed." -ForegroundColor Green
