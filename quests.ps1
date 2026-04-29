function New-TownQuest {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Source,
        [string]$Description,
        [string]$Objective,
        [string]$QuestType = "Story",
        [int]$Tier = 0,
        [int]$RewardCopper = 0,
        [int]$RewardXP = 0,
        [string]$RewardItemName = "",
        [int]$RequiredStoryClues = 0,
        [int]$DocksTier = 0,
        [string]$DayJobTrackId = "",
        [int]$DayJobStep = 0,
        [int]$RequiredHeroLevel = 1
    )

    return [PSCustomObject]@{
        Id = $Id
        Name = $Name
        Source = $Source
        Description = $Description
        Objective = $Objective
        QuestType = $QuestType
        Tier = $Tier
        RewardCopper = $RewardCopper
        RewardXP = $RewardXP
        RewardItemName = $RewardItemName
        RequiredStoryClues = $RequiredStoryClues
        DocksTier = $DocksTier
        DayJobTrackId = $DayJobTrackId
        DayJobStep = $DayJobStep
        RequiredHeroLevel = $RequiredHeroLevel
        Accepted = $false
        Started = $false
        Completed = $false
        Failed = $false
        AdvanceOutcome = ""
    }
}

function Get-QuestHeroName {
    param($Game)

    if ($null -ne $Game -and $null -ne $Game.Hero -and $null -ne $Game.Hero.PSObject.Properties["Name"] -and -not [string]::IsNullOrWhiteSpace([string]$Game.Hero.Name)) {
        return [string]$Game.Hero.Name
    }

    return "Borzig"
}

function Initialize-TownQuests {
    return @(
        (New-TownQuest -Id "guard_night_watch" -Name "Night Watch Relief" -Source "Guard Station" -Description "The guards need a capable arm on a short night patrol through the outer district." -Objective "Report to the watch captain for an evening patrol." -QuestType "Story" -Tier 1 -RewardCopper 180 -RewardXP 200)
        (New-TownQuest -Id "patron_storehouse_rats" -Name "Storehouse Trouble" -Source "Quest Giver" -Description "A merchant patron wants someone to clear vermin and thieves from a locked riverside storehouse." -Objective "Meet the patron's clerk and investigate the storehouse." -QuestType "Story" -Tier 1 -RewardCopper 150 -RewardXP 180 -RewardItemName "Healing Potion")
        (New-TownQuest -Id "quest_board_missing_herbs" -Name "Missing Herb Satchel" -Source "Quest Board" -Description "A local herbalist needs a satchel recovered from the old road beyond the city wall." -Objective "Search the old road and return the satchel." -QuestType "Story" -Tier 1 -RewardCopper 120 -RewardXP 120)
        (New-TownQuest -Id "patron_ledger_of_ash" -Name "Ledger of Ash" -Source "Quest Giver" -Description "A merchant clerk suspects false entries and hush money in a ledger tied to missing goods." -Objective "Question the clerk, inspect the ledger, and trace the irregular payments." -QuestType "Story" -Tier 2 -RewardCopper 140 -RewardXP 160)
        (New-TownQuest -Id "guard_night_courier" -Name "Night Courier Intercept" -Source "Guard Station" -Description "The watch believes a marked courier is moving messages between the city's surface contacts and the understreet routes." -Objective "Intercept the night courier and secure whatever they are carrying." -QuestType "Story" -Tier 2 -RewardCopper 150 -RewardXP 160)
        (New-TownQuest -Id "bent_nail_whispers" -Name "Whispers Beneath the Bent Nail" -Source "Bent Nail" -Description "A back-room fixer at the Bent Nail knows more about the city's quiet cargo routes than any honest merchant should." -Objective "Follow the broker lead inside the Bent Nail and learn where the smugglers are moving goods." -QuestType "Story" -Tier 2 -RewardCopper 130 -RewardXP 150)
        (New-TownQuest -Id "guard_broken_seal" -Name "Broken Seal Patrol" -Source "Guard Station" -Description "Now that real clues have surfaced, the watch wants a harder patrol into a breached maintenance route beneath the ward." -Objective "Join the guard patrol and confirm what is moving below the city." -QuestType "Story" -Tier 3 -RewardCopper 190 -RewardXP 180 -RequiredStoryClues 2)
        (New-TownQuest -Id "patron_warehouse_ledger" -Name "Warehouse Ledger Recovery" -Source "Quest Giver" -Description "A hidden warehouse ledger may tie the smugglers' route, false payments, and missing stock to a single hand." -Objective "Secure the warehouse ledger before it disappears into the understreet network." -QuestType "Story" -Tier 3 -RewardCopper 170 -RewardXP 170)
        (New-TownQuest -Id "guard_understreet_complex" -Name "The Understreet Complex" -Source "Guard Station" -Description "With enough clues in hand, the watch is finally ready to move on the hidden complex beneath the city." -Objective "Gather the final evidence, then descend into the understreet complex." -QuestType "Story" -Tier 4 -RewardCopper 230 -RewardXP 240)
        (New-TownQuest -Id "patron_silent_knife" -Name "The Silent Knife" -Source "Quest Giver" -Description "Someone is trying to cut the patron's clerk out of the story before he can reveal who has been directing the private investigation." -Objective "Protect the clerk, stop the assassins, and learn who the mysterious patron really is." -QuestType "Story" -Tier 4 -RewardCopper 220 -RewardXP 220)
        (New-TownQuest -Id "docks_black_contract" -Name "Black Contract on the Tide" -Source "Docks" -Description "Lady Veyra's enemies hired the killing hand through the docks. The river quarter may know who took the contract, and who stood behind it." -Objective "Go to the docks, find the contract trail, and learn who truly wanted Lady Veyra dead." -QuestType "Story" -Tier 4 -DocksTier 1 -RewardCopper 250 -RewardXP 300)
        (New-TownQuest -Id "docks_salvage_witness" -Name "Salvage Witness" -Source "Docks" -Description "Auntie Brindle has found a thrown-away thing that remembers more about Lady Veyra's contract than its owner intended." -Objective "Work Auntie's salvage clue into usable witness proof before the docks bury it again." -QuestType "Story" -Tier 4 -DocksTier 1 -RewardCopper 160 -RewardXP 220)
        (New-TownQuest -Id "docks_tide_ledger_marks" -Name "Tide-Ledger Marks" -Source "Docks" -Description "The tide-ledger shack has copied marks that do not belong to honest freight. Even a weak contract trail may be strengthened by the paper it left behind." -Objective "Audit the tide-ledger marks and turn dockside paperwork into another contract clue." -QuestType "Story" -Tier 4 -DocksTier 1 -RewardCopper 140 -RewardXP 180)
        (New-TownQuest -Id "docks_brokers_wake" -Name "The Broker's Wake" -Source "Docks" -Description "With Marris Vane's berth exposed, the docks can finally show what the organization behind the contract actually does." -Objective "Revisit the open docks, question the people left in Marris Vane's wake, and learn what business the contract network protects." -QuestType "Story" -Tier 4 -DocksTier 2 -RewardCopper 210 -RewardXP 270)
        (New-TownQuest -Id "docks_debt_hooks" -Name "Debt Hooks on Warehouse Row" -Source "Docks" -Description "Warehouse workers keep paying debts that no honest ledger can explain. The organization may be buying obedience one family at a time." -Objective "Follow the debt pressure on Warehouse Row and secure proof of the protection scheme." -QuestType "Story" -Tier 4 -DocksTier 2 -RewardCopper 190 -RewardXP 250)
        (New-TownQuest -Id "docks_blackmail_book" -Name "The Blackmail Book" -Source "Docks" -Description "Someone in the old knife berth kept a little book of names, favors, and shame. It may show why honest dock folk keep obeying the organization." -Objective "Recover the blackmail book and learn how the organization keeps useful people afraid." -QuestType "Story" -Tier 4 -DocksTier 2 -RewardCopper 180 -RewardXP 230)
        (New-TownQuest -Id "docks_charter_scribe" -Name "The Charter Scribe" -Source "Docks" -Description "The dockside organization survives because someone makes dirty freight look lawful. Lady Veyra needs the charter scribe found before the next strike." -Objective "Find the scribe who cleans the organization's papers and crack its legal shield before the next climax." -QuestType "Story" -Tier 4 -DocksTier 3 -RewardCopper 260 -RewardXP 300)
        (New-TownQuest -Id "docks_shell_charter" -Name "The Shell Charter" -Source "Docks" -Description "Odran Pell's exposed seal points to a clean charter with no honest owner. Someone above the docks is hiding money behind a paper company." -Objective "Trace the shell charter through the river quarter and find whose respectable name keeps dirty cargo safe." -QuestType "Story" -Tier 4 -DocksTier 4 -RewardCopper 280 -RewardXP 320 -RequiredHeroLevel 4)
        (New-TownQuest -Id "docks_counting_house_pressure" -Name "Counting House Pressure" -Source "Docks" -Description "A counting house near the tide-ledgers keeps balancing losses that should ruin it. The dockside organization may be laundering protection coin through legal desks." -Objective "Pressure the counting house trail and secure proof that dockside crime is being cleaned for higher city hands." -QuestType "Story" -Tier 4 -DocksTier 4 -RewardCopper 300 -RewardXP 340 -RequiredHeroLevel 4)
        (New-TownQuest -Id "docks_customs_stamp" -Name "The Customs Stamp" -Source "Docks" -Description "A customs stamp keeps appearing on cargo that should never pass inspection. The mark may show which official desk helps dockside money climb." -Objective "Trace the false customs stamp and secure one more higher-city paper trail." -QuestType "Story" -Tier 4 -DocksTier 4 -RewardCopper 260 -RewardXP 300 -RequiredHeroLevel 4)
        (New-TownQuest -Id "docks_civic_vault" -Name "The Civic Vault" -Source "Docks" -Description "Mira Kest has found a hidden way beneath the Civic Keep. The patron behind Lady Veyra's death contract keeps a private dungeon of ledgers, cells, and hired steel under the rooms where the city is ruled." -Objective "Enter the hidden Civic Vault, gather proof, survive the secret rooms, and confront Lord Varric Halewick." -QuestType "Story" -Tier 4 -DocksTier 5 -RewardCopper 360 -RewardXP 420 -RequiredHeroLevel 4)
        (New-TownQuest -Id "dayjob_market_delivery" -Name "Missing Delivery" -Source "Quest Board" -Description "A market runner needs someone reliable to recover a missing crate before the market eats the loss." -Objective "Find the missing crate and settle the problem without bloodshed." -QuestType "DayJob" -RewardCopper 90 -DayJobTrackId "market_runner" -DayJobStep 1 -RequiredHeroLevel 1)
        (New-TownQuest -Id "dayjob_market_delivery_2" -Name "Market Runner: Wrong Ledger" -Source "Quest Board" -Description "The market runners trust {hero} with a touchier problem: a paid delivery logged under the wrong stall." -Objective "Sort out the bad ledger mark and get the right goods to the right hands." -QuestType "DayJob" -RewardCopper 115 -DayJobTrackId "market_runner" -DayJobStep 2 -RequiredHeroLevel 2)
        (New-TownQuest -Id "dayjob_market_delivery_3" -Name "Market Runner: High-Value Hand-Off" -Source "Quest Board" -Description "A better-paying runner job needs a known face to move sealed goods through crowded daylight." -Objective "Carry the sealed goods across the market without losing the package or the crowd." -QuestType "DayJob" -RewardCopper 140 -DayJobTrackId "market_runner" -DayJobStep 3 -RequiredHeroLevel 3)
        (New-TownQuest -Id "dayjob_gate_labor" -Name "Gate Duty Overflow" -Source "Guard Station" -Description "The gate sergeant needs a strong back and a hard stare to keep freight moving without panic." -Objective "Help the gate detail clear a jam and keep tempers under control." -QuestType "DayJob" -RewardCopper 100 -DayJobTrackId "gate_labor" -DayJobStep 1 -RequiredHeroLevel 1)
        (New-TownQuest -Id "dayjob_gate_labor_2" -Name "Gate Duty: Toll Dispute" -Source "Guard Station" -Description "A toll argument is slowing the morning gate, and the watch wants it solved without drawing steel." -Objective "Break the dispute, keep the wagons moving, and leave the sergeant with clean paperwork." -QuestType "DayJob" -RewardCopper 125 -DayJobTrackId "gate_labor" -DayJobStep 2 -RequiredHeroLevel 2)
        (New-TownQuest -Id "dayjob_gate_labor_3" -Name "Gate Duty: Noble Convoy" -Source "Guard Station" -Description "A noble convoy has snarled the gate with pride, guards, and expensive impatience." -Objective "Clear the convoy jam before the gate detail loses control of the street." -QuestType "DayJob" -RewardCopper 150 -DayJobTrackId "gate_labor" -DayJobStep 3 -RequiredHeroLevel 3)
        (New-TownQuest -Id "dayjob_dock_loading" -Name "Dock Work: Morning Load" -Source "Quest Board" -Description "The river crews need extra hands before the tide schedule ruins the morning freight." -Objective "Move cargo, hold the line, and keep the dock boss from losing the whole shift." -QuestType "DayJob" -RewardCopper 95 -DayJobTrackId "dock_work" -DayJobStep 1 -RequiredHeroLevel 1)
        (New-TownQuest -Id "dayjob_dock_loading_2" -Name "Dock Work: Split Cargo" -Source "Quest Board" -Description "The dock boss has a better-paying mess: two crews claim the same marked cargo and both are angry." -Objective "Sort the split cargo before dockside shouting turns into broken teeth." -QuestType "DayJob" -RewardCopper 120 -DayJobTrackId "dock_work" -DayJobStep 2 -RequiredHeroLevel 2)
        (New-TownQuest -Id "dayjob_dock_loading_3" -Name "Dock Work: Heavy Tide" -Source "Quest Board" -Description "A high tide, late barge, and expensive cargo have created a job only trusted hands are offered." -Objective "Keep the heavy freight moving before the river schedule collapses." -QuestType "DayJob" -RewardCopper 150 -DayJobTrackId "dock_work" -DayJobStep 3 -RequiredHeroLevel 3)
        (New-TownQuest -Id "dayjob_scribe_copy" -Name "Scribe Work: Clean Copies" -Source "Quest Giver" -Description "A clerk needs clean duplicate contracts made before the afternoon seal-run." -Objective "Copy the contracts accurately and catch any obvious mistakes before they become expensive." -QuestType "DayJob" -RewardCopper 85 -DayJobTrackId "scribe_work" -DayJobStep 1 -RequiredHeroLevel 1)
        (New-TownQuest -Id "dayjob_scribe_copy_2" -Name "Scribe Work: Margin Errors" -Source "Quest Giver" -Description "The clerk trusts {hero} with touchier copy work: mismatched margins, missing sums, and a patron who notices." -Objective "Correct the draft copies without embarrassing the office." -QuestType "DayJob" -RewardCopper 115 -DayJobTrackId "scribe_work" -DayJobStep 2 -RequiredHeroLevel 2)
        (New-TownQuest -Id "dayjob_scribe_copy_3" -Name "Scribe Work: Sealed Abstract" -Source "Quest Giver" -Description "A sealed contract abstract needs a steady hand, sharp eye, and enough discretion to leave questions unasked." -Objective "Prepare the abstract cleanly and keep the patron's business private." -QuestType "DayJob" -RewardCopper 145 -DayJobTrackId "scribe_work" -DayJobStep 3 -RequiredHeroLevel 3)
    )
}

function New-TownQuestRewardItem {
    param([string]$RewardItemName)

    switch ($RewardItemName) {
        "Healing Potion" { return (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1) }
        "Greater Healing Potion" { return (New-ConsumableItem -Name "Greater Healing Potion" -Value 180 -HealAmount 12 -SlotCost 1) }
        default { return $null }
    }
}

function Get-StoryClueCount {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.StoryFlags) {
        return 0
    }

    return @($Game.Town.StoryFlags.Keys | Where-Object { $Game.Town.StoryFlags[$_] -eq $true }).Count
}

function Test-OpeningGuardAndPatronLeadsComplete {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    $guardQuest = Find-TownQuest -Game $Game -QuestId "guard_night_watch"
    $patronQuest = Find-TownQuest -Game $Game -QuestId "patron_storehouse_rats"

    return ($null -ne $guardQuest -and $guardQuest.Completed -and $null -ne $patronQuest -and $patronQuest.Completed)
}

function Get-StoryClueNotes {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.StoryFlags) {
        return @()
    }

    $storyFlags = $Game.Town.StoryFlags
    $notes = @()
    $definitions = @(
        @{ Flag = "FoundTunnelAccess"; Category = "Access"; Text = "The old city tunnels are active again, and the broken seal was opened from below." }
        @{ Flag = "FoundSmugglingLink"; Category = "Smuggling"; Text = "Missing goods and hidden cargo routes are tied to the same understreet traffic." }
        @{ Flag = "FoundStreetCourierMark"; Category = "Courier"; Text = "A marked courier trail links street handoffs to the underground operation." }
        @{ Flag = "FoundCourierRoute"; Category = "Courier"; Text = "A working courier route into the understreet network has been confirmed." }
        @{ Flag = "FoundEconomicIrregularity"; Category = "Ledger"; Text = "The books do not balance. Someone has been moving coin and stock off-book." }
        @{ Flag = "NamedUnderstreetLeader"; Category = "Leadership"; Text = "The name Serik surfaced as a real hand behind the understreet route." }
        @{ Flag = "BentNailBrokerConfirmed"; Category = "Broker"; Text = "Bent Nail whispers led to a broker who confirmed the hidden cargo traffic." }
        @{ Flag = "ConfirmedUndergroundRoute"; Category = "Route"; Text = "A breached maintenance route proved the smugglers are guarding a deeper path." }
        @{ Flag = "SecuredLedgerEvidence"; Category = "Evidence"; Text = "Hard ledger evidence now ties the missing goods to the underground network." }
        @{ Flag = "HelpedLocalVictim"; Category = "Street"; Text = "A shaken local witness added weight to the courier trail moving through the district." }
        @{ Flag = "UnderstreetComplexCleared"; Category = "Resolution"; Text = "The Understreet Complex was broken and its command structure exposed." }
        @{ Flag = "SilentKnifeFoiled"; Category = "Assassins"; Text = "An attempted murder against the patron's clerk failed before it could silence the ledger trail." }
        @{ Flag = "BenefactorRevealed"; Category = "Patron"; Text = "The mysterious Quest Giver is Lady Veyra of the High Ledger, a higher city power than the clerk ever admitted." }
        @{ Flag = "NamedVeyraContractBroker"; Category = "Docks"; Text = "A dockside broker admitted who carried Lady Veyra's death contract through the river quarter." }
        @{ Flag = "DocksFirstChainComplete"; Category = "Docks"; Text = "The first dockside trail mapped Auntie Brindle's salvage shop, the tide-ledger shack, Warehouse Row, and the old knife berth." }
        @{ Flag = "DocksOrganizationProfiled"; Category = "Docks"; Text = "The docks revealed the organization behind Lady Veyra's contract moves forged freight, debt pressure, blackmail, and paid knives through the river quarter." }
        @{ Flag = "DocksCharterScribeExposed"; Category = "Docks"; Text = "The charter scribe who cleaned the organization's dirty dock papers has been exposed, leaving the next city-level shield vulnerable." }
        @{ Flag = "DocksShellCharterSecured"; Category = "Docks"; Text = "Odran Pell's shell charter now links the dockside organization to respectable ownership above the river quarter." }
        @{ Flag = "DocksCountingHouseExposed"; Category = "Docks"; Text = "The counting-house trail shows protection money being washed through legal desks before it leaves the docks." }
        @{ Flag = "HigherPatronSuspected"; Category = "Conspiracy"; Text = "The order to kill Lady Veyra came from higher city hands, not a local dockside grudge." }
    )

    foreach ($definition in $definitions) {
        if ([bool]$storyFlags[$definition.Flag]) {
            $notes += [PSCustomObject]@{
                Flag = $definition.Flag
                Category = $definition.Category
                Text = $definition.Text
            }
        }
    }

    return @($notes)
}

function Get-StoryClueProgressSummary {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return ""
    }

    $currentTier = Get-CurrentStoryQuestTier -Game $Game
    $majorEvidenceFlags = @(
        "FoundSmugglingLink"
        "NamedUnderstreetLeader"
        "FoundCourierRoute"
        "ConfirmedUndergroundRoute"
        "SecuredLedgerEvidence"
        "BentNailBrokerConfirmed"
    )
    $majorEvidenceCount = @($majorEvidenceFlags | Where-Object { [bool]$Game.Town.StoryFlags[$_] }).Count

    if ([bool]$Game.Town.StoryFlags["UnderstreetComplexCleared"]) {
        if ([bool]$Game.Town.StoryFlags["HigherPatronSuspected"]) {
            return "Chapter Three Notes: The docks have confirmed Lady Veyra's enemies answer to higher city powers still hiding behind charters, clerks, and paid blades."
        }

        if ([bool]$Game.Town.StoryFlags["DocksCharterScribeExposed"]) {
            return "Chapter Three Notes: The dockside organization has lost the scribe who made its dirty work look legal. $($Game.Hero.Name) is ready to grow before the next climax."
        }

        if ([bool]$Game.Town.StoryFlags["DocksOrganizationProfiled"]) {
            return "Chapter Three Notes: The docks now show what the contract organization does: forged freight, debt pressure, blackmail, and paid blades. The patron behind it is still hidden."
        }

        if ([bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]) {
            return "Chapter Three Notes: The first docks trail exposed where Lady Veyra's assassin came from. The river quarter is now open for deeper leads."
        }

        if ([bool]$Game.Town.StoryFlags["BenefactorRevealed"]) {
            return "Chapter Three Notes: Lady Veyra has been revealed, and fresh leads now point toward the docks where her enemies hired the knife."
        }

        return "Chapter Two Notes: The understreet network has been broken, but the fallout is still moving through the city."
    }

    if (Test-UnderstreetAccessUnlocked -Game $Game) {
        return "Chapter Two Notes: Tier $currentTier active. Major evidence gathered: $majorEvidenceCount/6."
    }

    if ($currentTier -le 1) {
        return "Chapter Two Notes: Tier 1 active. Complete both the Guard Station patrol and the Quest Giver storehouse lead to unlock Tier 2 city work."
    }

    return "Chapter Two Notes: Tier $currentTier active. $(Get-QuestHeroName -Game $Game) still needs a confirmed understreet access lead."
}

function Get-CompletedStoryQuestCount {
    param($Game)

    return @(Get-TownQuestList -Game $Game | Where-Object { $_.QuestType -eq "Story" -and $_.Completed }).Count
}

function Get-TownQuestDailyLimitReached {
    param(
        $Game,
        $Quest
    )

    if ($Quest.QuestType -eq "DayJob") {
        return [bool]$Game.Town.DayJobDoneToday
    }

    return [bool]$Game.Town.StoryQuestDoneToday
}

function Get-TownQuestDailyLockText {
    param(
        $Quest,
        $Game = $null
    )

    $heroName = Get-QuestHeroName -Game $Game

    if ($Quest.QuestType -eq "DayJob") {
        return "$heroName has already taken on a paid side job today. Another day job will have to wait until tomorrow."
    }

    return "$heroName has already spent today's real story effort. Another story quest will have to wait until after a night's rest."
}

function Get-TownQuestRequiredTimeOfDay {
    param($Quest)

    if ($null -eq $Quest) {
        return ""
    }

    if ($Quest.QuestType -eq "DayJob") {
        return "Day"
    }

    switch ($Quest.Id) {
        "guard_night_watch" { return "Night" }
        "guard_night_courier" { return "Night" }
        "bent_nail_whispers" { return "Night" }
        default { return "" }
    }
}

function Get-TownQuestTimeLockText {
    param(
        $Quest,
        $Game = $null
    )

    $requiredTime = Get-TownQuestRequiredTimeOfDay -Quest $Quest

    if ([string]::IsNullOrWhiteSpace($requiredTime)) {
        return ""
    }

    $heroName = Get-QuestHeroName -Game $Game

    if ($requiredTime -eq "Night") {
        return "$heroName needs to wait until nightfall before starting $($Quest.Name)."
    }

    return "$($Quest.Name) is day work. $heroName will need to come back in the morning."
}

function Get-CurrentStoryQuestTier {
    param($Game)

    if (-not (Test-OpeningGuardAndPatronLeadsComplete -Game $Game)) {
        return 1
    }

    $tierThreeStrong = Get-StrongStoryQuestCountForTier -Game $Game -Tier 3
    $tierThreeCompleted = Get-CompletedStoryQuestCountForTier -Game $Game -Tier 3

    if ($tierThreeStrong -ge 1 -or $tierThreeCompleted -ge 2) {
        return 4
    }

    $tierTwoStrong = Get-StrongStoryQuestCountForTier -Game $Game -Tier 2
    $tierTwoCompleted = Get-CompletedStoryQuestCountForTier -Game $Game -Tier 2

    if ($tierTwoStrong -ge 2 -or $tierTwoCompleted -ge 3) {
        return 3
    }

    return 2
}

function Get-CurrentDocksQuestTier {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.StoryFlags) {
        return 0
    }

    if (-not [bool]$Game.Town.StoryFlags["BenefactorRevealed"]) {
        return 0
    }

    $tierOneStrong = Get-StrongDocksQuestCountForTier -Game $Game -DocksTier 1
    $tierOneCompleted = Get-CompletedDocksQuestCountForTier -Game $Game -DocksTier 1

    if ($tierOneStrong -lt 2 -and $tierOneCompleted -lt 3) {
        return 1
    }

    $tierTwoStrong = Get-StrongDocksQuestCountForTier -Game $Game -DocksTier 2
    $tierTwoCompleted = Get-CompletedDocksQuestCountForTier -Game $Game -DocksTier 2

    if ($tierTwoStrong -lt 2 -and $tierTwoCompleted -lt 3) {
        return 2
    }

    $tierThreeStrong = Get-StrongDocksQuestCountForTier -Game $Game -DocksTier 3
    $tierThreeCompleted = Get-CompletedDocksQuestCountForTier -Game $Game -DocksTier 3

    if ($tierThreeStrong -lt 1 -and $tierThreeCompleted -lt 1) {
        return 3
    }

    $tierFourStrong = Get-StrongDocksQuestCountForTier -Game $Game -DocksTier 4
    $tierFourCompleted = Get-CompletedDocksQuestCountForTier -Game $Game -DocksTier 4

    if ($tierFourStrong -lt 2 -and $tierFourCompleted -lt 3) {
        return 4
    }

    return 5
}

function Get-TownQuestTierLabel {
    param($Quest)

    if ($null -eq $Quest -or $Quest.QuestType -ne "Story") {
        return ""
    }

    if ($null -ne $Quest.PSObject.Properties["DocksTier"] -and [int]$Quest.DocksTier -gt 0) {
        return "Docks Tier $($Quest.DocksTier)"
    }

    if ([int]$Quest.Tier -gt 0) {
        return "Tier $($Quest.Tier)"
    }

    return ""
}

function Get-TownQuestTierSuffix {
    param($Quest)

    $tierLabel = Get-TownQuestTierLabel -Quest $Quest

    if ([string]::IsNullOrWhiteSpace($tierLabel)) {
        return ""
    }

    return " | $tierLabel"
}

function Get-CompletedDocksQuestCountForTier {
    param(
        $Game,
        [int]$DocksTier
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests) {
        return 0
    }

    return @($Game.Town.Quests | Where-Object {
        $_.QuestType -eq "Story" -and
        $_.Source -eq "Docks" -and
        $_.Completed -and
        $null -ne $_.PSObject.Properties["DocksTier"] -and
        [int]$_.DocksTier -eq $DocksTier
    }).Count
}

function Get-StrongDocksQuestCountForTier {
    param(
        $Game,
        [int]$DocksTier
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests) {
        return 0
    }

    return @($Game.Town.Quests | Where-Object {
        $_.QuestType -eq "Story" -and
        $_.Source -eq "Docks" -and
        $_.Completed -and
        $null -ne $_.PSObject.Properties["DocksTier"] -and
        [int]$_.DocksTier -eq $DocksTier -and
        ($null -eq $_.PSObject.Properties["AdvanceOutcome"] -or $_.AdvanceOutcome -ne "Weak")
    }).Count
}

function Get-DocksTierStrongNeededCount {
    param([int]$DocksTier)

    switch ($DocksTier) {
        1 { return 2 }
        2 { return 2 }
        3 { return 1 }
        4 { return 2 }
        default { return 0 }
    }
}

function Get-DocksTierFallbackCompletedCount {
    param([int]$DocksTier)

    switch ($DocksTier) {
        1 { return 3 }
        2 { return 3 }
        3 { return 1 }
        4 { return 3 }
        default { return 0 }
    }
}

function Get-DocksTierRequiredCompletedCount {
    param([int]$DocksTier)

    return Get-DocksTierFallbackCompletedCount -DocksTier $DocksTier
}

function Get-DocksTierProgressStatus {
    param($Game)

    $currentTier = Get-CurrentDocksQuestTier -Game $Game

    if ($currentTier -le 0) {
        return [PSCustomObject]@{
            CurrentTier = 0
            CompletedCount = 0
            RequiredCount = 0
            StatusText = "Docks Tiers are locked. Lady Veyra must be revealed before the river quarter becomes a real lead."
        }
    }

    if ($currentTier -ge 5) {
        return [PSCustomObject]@{
            CurrentTier = 5
            CompletedCount = 0
            RequiredCount = 0
            StatusText = "Docks Tier chain complete. The shell papers and counting-house trail now point above the docks."
        }
    }

    if ($currentTier -eq 4 -and $null -ne $Game.Hero -and [int]$Game.Hero.Level -lt 4) {
        return [PSCustomObject]@{
            CurrentTier = 4
            CompletedCount = 0
            RequiredCount = 3
            StrongCount = 0
            StrongNeeded = 2
            FallbackCompletedNeeded = 3
            StatusText = "Docks Tier 4 is almost open. $($Game.Hero.Name) should take the level 4 long rest before chasing the higher-city paper trail."
        }
    }

    $completedCount = Get-CompletedDocksQuestCountForTier -Game $Game -DocksTier $currentTier
    $strongCount = Get-StrongDocksQuestCountForTier -Game $Game -DocksTier $currentTier
    $strongNeeded = Get-DocksTierStrongNeededCount -DocksTier $currentTier
    $fallbackCompletedNeeded = Get-DocksTierFallbackCompletedCount -DocksTier $currentTier
    $statusText = "Docks Tier $currentTier is active. Strong progress on this tier: $strongCount/$strongNeeded."

    if ($strongCount -lt $strongNeeded) {
        $statusText += " Weak outcomes still complete quests, but $($Game.Hero.Name) may need $fallbackCompletedNeeded total Docks Tier $currentTier quests to unlock the next dockside tier."
    }

    return [PSCustomObject]@{
        CurrentTier = $currentTier
        CompletedCount = $completedCount
        RequiredCount = $fallbackCompletedNeeded
        StrongCount = $strongCount
        StrongNeeded = $strongNeeded
        FallbackCompletedNeeded = $fallbackCompletedNeeded
        StatusText = $statusText
    }
}

function Get-CompletedStoryQuestCountForTier {
    param(
        $Game,
        [int]$Tier
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests) {
        return 0
    }

    return @($Game.Town.Quests | Where-Object { $_.QuestType -eq "Story" -and $_.Completed -and [int]$_.Tier -eq $Tier }).Count
}

function Get-StrongStoryQuestCountForTier {
    param(
        $Game,
        [int]$Tier
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests) {
        return 0
    }

    return @($Game.Town.Quests | Where-Object {
        $_.QuestType -eq "Story" -and
        $_.Completed -and
        [int]$_.Tier -eq $Tier -and
        ($null -eq $_.PSObject.Properties["AdvanceOutcome"] -or $_.AdvanceOutcome -ne "Weak")
    }).Count
}

function Get-StoryTierProgressStatus {
    param($Game)

    $currentTier = Get-CurrentStoryQuestTier -Game $Game

    if ($currentTier -ge 4) {
        return [PSCustomObject]@{
            CurrentTier = 4
            NextTier = $null
            StrongCount = 0
            CompletedCount = 0
            StrongNeeded = 0
            FallbackCompletedNeeded = 0
            StatusText = "Story Tier 4 is active. $(Get-QuestHeroName -Game $Game) has reached the chapter finale tier."
        }
    }

    $strongNeeded = 1
    $fallbackCompletedNeeded = 2

    if ($currentTier -eq 1) {
        $strongNeeded = 2
        $fallbackCompletedNeeded = 2
    }

    if ($currentTier -eq 2) {
        $strongNeeded = 2
        $fallbackCompletedNeeded = 3
    }

    $strongCount = Get-StrongStoryQuestCountForTier -Game $Game -Tier $currentTier
    $completedCount = Get-CompletedStoryQuestCountForTier -Game $Game -Tier $currentTier
    $nextTier = $currentTier + 1
    $statusText = "Story Tier $currentTier is active. Strong progress on this tier: $strongCount/$strongNeeded."

    if ($currentTier -eq 1 -and -not (Test-OpeningGuardAndPatronLeadsComplete -Game $Game)) {
        $statusText += " Tier 2 requires both the Guard Station patrol and the Quest Giver storehouse lead."
    }
    elseif ($strongCount -lt $strongNeeded) {
        $statusText += " Weak outcomes can still complete quests, but $(Get-QuestHeroName -Game $Game) may need $fallbackCompletedNeeded total Tier $currentTier story quests to unlock Tier $nextTier."
    }

    return [PSCustomObject]@{
        CurrentTier = $currentTier
        NextTier = $nextTier
        StrongCount = $strongCount
        CompletedCount = $completedCount
        StrongNeeded = $strongNeeded
        FallbackCompletedNeeded = $fallbackCompletedNeeded
        StatusText = $statusText
    }
}

function Test-UnderstreetAccessUnlocked {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    if ([bool]$Game.Town.StoryFlags["FoundTunnelAccess"]) {
        return $true
    }

    if ([bool]$Game.Town.StoryFlags["ConfirmedUndergroundRoute"]) {
        return $true
    }

    $brokenSealQuest = Find-TownQuest -Game $Game -QuestId "guard_broken_seal"
    return ($null -ne $brokenSealQuest -and $brokenSealQuest.Completed)
}

function Test-TownQuestBaseUnlock {
    param(
        $Game,
        $Quest
    )

    if ($Quest.Completed -or $Quest.Accepted) {
        return $true
    }

    if ($Quest.Id -eq "bent_nail_whispers") {
        return [bool]$Game.Town.InnFlags["BentNailBrokerInfo"] -or [bool]$Game.Town.InnFlags["BentNailShadyRumor"]
    }

    if ($Quest.Id -eq "guard_night_courier") {
        return [bool]$Game.Town.StoryFlags["FoundStreetCourierMark"] -or [bool]$Game.Town.Relationships["Belor"]
    }

    if ($Quest.Id -eq "patron_warehouse_ledger") {
        return [bool]$Game.Town.StoryFlags["FoundEconomicIrregularity"] -or [bool]$Game.Town.StoryFlags["NamedUnderstreetLeader"]
    }

    if ($Quest.Id -eq "guard_understreet_complex") {
        if (-not (Test-UnderstreetAccessUnlocked -Game $Game)) {
            return $false
        }

        $finalEvidenceFlags = @(
            "FoundSmugglingLink"
            "NamedUnderstreetLeader"
            "FoundCourierRoute"
            "ConfirmedUndergroundRoute"
            "SecuredLedgerEvidence"
            "BentNailBrokerConfirmed"
        )

        $evidenceCount = @($finalEvidenceFlags | Where-Object { [bool]$Game.Town.StoryFlags[$_] }).Count
        return $evidenceCount -ge 2
    }

    if ($Quest.Id -eq "patron_silent_knife") {
        return [bool]$Game.Town.ChapterTwoComplete -or [bool]$Game.Town.StoryFlags["UnderstreetComplexCleared"]
    }

    if ($Quest.Id -eq "docks_black_contract") {
        return [bool]$Game.Town.StoryFlags["BenefactorRevealed"]
    }

    if ($Quest.Id -eq "docks_brokers_wake") {
        return [bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]
    }

    if ($Quest.Id -eq "docks_charter_scribe") {
        return [bool]$Game.Town.StoryFlags["DocksCharterScribeLead"] -or (Get-CurrentDocksQuestTier -Game $Game) -ge 3
    }

    if ($Quest.RequiredStoryClues -le 0) {
        return $true
    }

    return (Get-StoryClueCount -Game $Game) -ge [int]$Quest.RequiredStoryClues
}

function Is-TownQuestUnlocked {
    param(
        $Game,
        $Quest
    )

    if (-not (Test-TownQuestBaseUnlock -Game $Game -Quest $Quest)) {
        return $false
    }

    if ($Quest.QuestType -eq "DayJob") {
        return Test-DayJobStepAvailable -Game $Game -Quest $Quest
    }

    if ($Quest.QuestType -ne "Story") {
        return $true
    }

    if ($null -ne $Quest.PSObject.Properties["RequiredHeroLevel"] -and [int]$Quest.RequiredHeroLevel -gt 1 -and [int]$Game.Hero.Level -lt [int]$Quest.RequiredHeroLevel) {
        return $false
    }

    if ($Quest.Completed -or $Quest.Accepted) {
        return $true
    }

    if ($Quest.Source -eq "Docks" -and $null -ne $Quest.PSObject.Properties["DocksTier"] -and [int]$Quest.DocksTier -gt 0) {
        return [int]$Quest.DocksTier -eq (Get-CurrentDocksQuestTier -Game $Game)
    }

    $currentTier = Get-CurrentStoryQuestTier -Game $Game
    return [int]$Quest.Tier -eq $currentTier
}

function Get-DayJobTrackId {
    param($Quest)

    if ($null -eq $Quest) {
        return ""
    }

    if ($null -ne $Quest.PSObject.Properties["DayJobTrackId"] -and -not [string]::IsNullOrWhiteSpace([string]$Quest.DayJobTrackId)) {
        return [string]$Quest.DayJobTrackId
    }

    return [string]$Quest.Id
}

function Get-DayJobStep {
    param($Quest)

    if ($null -ne $Quest -and $null -ne $Quest.PSObject.Properties["DayJobStep"] -and [int]$Quest.DayJobStep -gt 0) {
        return [int]$Quest.DayJobStep
    }

    return 1
}

function Get-DayJobRequiredHeroLevel {
    param($Quest)

    if ($null -ne $Quest -and $null -ne $Quest.PSObject.Properties["RequiredHeroLevel"] -and [int]$Quest.RequiredHeroLevel -gt 0) {
        return [int]$Quest.RequiredHeroLevel
    }

    return 1
}

function Test-DayJobStepAvailable {
    param(
        $Game,
        $Quest
    )

    if ($null -eq $Game -or $null -eq $Quest -or $Quest.QuestType -ne "DayJob") {
        return $false
    }

    if ($Quest.Accepted -and -not $Quest.Completed) {
        return $true
    }

    if ($Quest.Completed) {
        return $false
    }

    if ([int]$Game.Hero.Level -lt (Get-DayJobRequiredHeroLevel -Quest $Quest)) {
        return $false
    }

    $trackId = Get-DayJobTrackId -Quest $Quest
    $availableSteps = @($Game.Town.Quests | Where-Object {
        $_.QuestType -eq "DayJob" -and
        (Get-DayJobTrackId -Quest $_) -eq $trackId -and
        -not $_.Completed -and
        [int]$Game.Hero.Level -ge (Get-DayJobRequiredHeroLevel -Quest $_)
    } | Sort-Object @{ Expression = { Get-DayJobStep -Quest $_ }; Ascending = $true })

    if ($availableSteps.Count -eq 0) {
        return $false
    }

    return [string]$availableSteps[0].Id -eq [string]$Quest.Id
}

function Get-UnderstreetFinalEntryMessage {
    param($Hero)

    if ($Hero.Level -ge 3) {
        return ""
    }

    if ((Get-HeroAvailableLevelUps -Hero $Hero) -gt 0) {
        return "$($Hero.Name) is not ready to descend yet. He needs a long rest at the inn to reach level 3 before taking on the Understreet Complex."
    }

    return "$($Hero.Name) is not ready to descend yet. He needs to grow stronger and reach level 3 before taking on the Understreet Complex."
}

function Get-QuestRewardText {
    param($Quest)

    $parts = @()

    if ($Quest.QuestType -eq "DayJob") {
        $parts += "No XP"
    }

    if ($null -ne $Quest.PSObject.Properties["RewardXP"] -and [int]$Quest.RewardXP -gt 0) {
        $parts += "$($Quest.RewardXP) XP"
    }

    if ($null -ne $Quest.PSObject.Properties["RewardCopper"] -and [int]$Quest.RewardCopper -gt 0) {
        $parts += (Convert-CopperToCurrencyText -Copper ([int]$Quest.RewardCopper))
    }

    if ($null -ne $Quest.PSObject.Properties["RewardItemName"] -and -not [string]::IsNullOrWhiteSpace($Quest.RewardItemName)) {
        $parts += $Quest.RewardItemName
    }

    if ($parts.Count -eq 0) {
        return "No reward listed"
    }

    return ($parts -join " + ")
}

function Get-TownQuestOutcomeText {
    param($Quest)

    if ($null -eq $Quest -or $Quest.QuestType -ne "Story" -or -not $Quest.Completed) {
        return ""
    }

    if ($Quest.AdvanceOutcome -eq "Weak") {
        return "Weak"
    }

    return "Strong"
}

function Get-DayJobRewardCopper {
    param(
        $Game,
        $Quest
    )

    $rewardCopper = [int]$Quest.RewardCopper

    if ($Quest.QuestType -eq "DayJob" -and $null -ne $Game -and $Game.Hero.Level -ge 3) {
        $rewardCopper += 20
    }

    return $rewardCopper
}

function Get-TownQuestList {
    param(
        $Game,
        [string]$Source = ""
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests) {
        return @()
    }

    $quests = @($Game.Town.Quests | Where-Object { Is-TownQuestUnlocked -Game $Game -Quest $_ })

    if ([string]::IsNullOrWhiteSpace($Source)) {
        return $quests
    }

    return @($quests | Where-Object { $_.Source -eq $Source })
}

function Find-TownQuest {
    param(
        $Game,
        [string]$QuestId
    )

    return ($Game.Town.Quests | Where-Object { $_.Id -eq $QuestId } | Select-Object -First 1)
}

function Accept-TownQuest {
    param(
        $Game,
        [string]$QuestId
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest) {
        return [PSCustomObject]@{
            Success = $false
            Message = "That quest is no longer available."
        }
    }

    if (-not (Is-TownQuestUnlocked -Game $Game -Quest $quest)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$(Get-QuestHeroName -Game $Game) does not have enough clues to take that quest yet."
        }
    }

    if ($quest.Completed) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($quest.Name) is already complete."
        }
    }

    if ($quest.Accepted) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($quest.Name) is already in $(Get-QuestHeroName -Game $Game)'s quest log."
        }
    }

    $quest.Accepted = $true

    return [PSCustomObject]@{
        Success = $true
        Message = "$($quest.Name) is added to $(Get-QuestHeroName -Game $Game)'s quest log."
        Quest = $quest
    }
}

function Start-TownQuestAttempt {
    param(
        $Game,
        [string]$QuestId
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest) {
        return [PSCustomObject]@{
            Success = $false
            Message = "That quest is no longer available."
        }
    }

    if (Get-TownQuestDailyLimitReached -Game $Game -Quest $quest) {
        return [PSCustomObject]@{
            Success = $false
            Message = (Get-TownQuestDailyLockText -Quest $quest -Game $Game)
        }
    }

    $requiredTime = Get-TownQuestRequiredTimeOfDay -Quest $quest

    if ($requiredTime -eq "Night" -and (Get-TownTimeOfDay -Game $Game) -ne "Night") {
        Write-Scene "$($Game.Hero.Name) lets the city turn over until nightfall before stepping into $($quest.Name)."
        Write-ColorLine ""
        Set-TownTimeOfDay -Game $Game -TimeOfDay "Night"
    }
    elseif ($requiredTime -eq "Day" -and (Get-TownTimeOfDay -Game $Game) -ne "Day") {
        return [PSCustomObject]@{
            Success = $false
            Message = (Get-TownQuestTimeLockText -Quest $quest -Game $Game)
        }
    }

    if ($quest.QuestType -eq "DayJob") {
        $Game.Town.DayJobDoneToday = $true
    }
    else {
        $Game.Town.StoryQuestDoneToday = $true
    }

        $quest.Started = $true

    return [PSCustomObject]@{
        Success = $true
        Quest = $quest
    }
}

function Complete-TownQuest {
    param(
        $Game,
        [string]$QuestId,
        [Nullable[int]]$RewardCopperOverride = $null,
        [Nullable[int]]$RewardXPOverride = $null,
        [string]$RewardItemNameOverride = $null,
        [string]$AdvanceOutcome = ""
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest) {
        return [PSCustomObject]@{
            Success = $false
            Message = "That quest could not be completed."
        }
    }

    if ($quest.Completed) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($quest.Name) is already complete."
            Quest = $quest
        }
    }

    $quest.Completed = $true
    $quest.Failed = $false
    $quest.Started = $false
    $quest.AdvanceOutcome = $AdvanceOutcome

    $rewardCopper = if ($null -ne $RewardCopperOverride) { [int]$RewardCopperOverride } else { Get-DayJobRewardCopper -Game $Game -Quest $quest }

    if ($rewardCopper -gt 0 -and $Game.Town.QuestPayoutBonusCopper -gt 0) {
        $rewardCopper += [int]$Game.Town.QuestPayoutBonusCopper
    }

    $currencyResult = $null

    if ($rewardCopper -gt 0) {
        $currencyResult = Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper
    }

    $rewardXP = if ($null -ne $RewardXPOverride) { [int]$RewardXPOverride } else { [int]$quest.RewardXP }

    if ($rewardXP -gt 0) {
        Grant-HeroXP -Hero $Game.Hero -XP $rewardXP
    }

    $rewardItem = $null

    $rewardItemName = if ($null -ne $RewardItemNameOverride) { $RewardItemNameOverride } else { $quest.RewardItemName }

    if (-not [string]::IsNullOrWhiteSpace($rewardItemName)) {
        $rewardItem = New-TownQuestRewardItem -RewardItemName $rewardItemName

        if ($null -ne $rewardItem -and (Can-HeroCarryItem -Hero $Game.Hero -Item $rewardItem)) {
            $Game.Hero.Inventory += $rewardItem
        }
    }

    return [PSCustomObject]@{
        Success = $true
        Quest = $quest
        RewardCopper = $rewardCopper
        CurrencyResult = $currencyResult
        RewardXP = $rewardXP
        RewardItem = $rewardItem
    }
}

function Fail-TownQuest {
    param(
        $Game,
        [string]$QuestId
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest) {
        return [PSCustomObject]@{
            Success = $false
            Message = "That quest could not be marked as failed."
        }
    }

    $quest.Failed = $true
    $quest.Started = $false
    $quest.Accepted = $false

    return [PSCustomObject]@{
        Success = $true
        Quest = $quest
    }
}

function Show-QuestLog {
    param(
        $Quest = $null,
        $Hero = $null,
        $Game = $null
    )

    $mainQuest = $Quest

    if ($null -ne $Game -and (($Game -is [hashtable] -and $Game.ContainsKey("Quest")) -or $null -ne $Game.PSObject.Properties["Quest"])) {
        $mainQuest = $Game.Quest
    }

    Write-ColorLine ""
    Write-ColorLine "===== QUEST LOG =====" "Yellow"

    $showMainQuestDetails = $null -ne $mainQuest -and (-not $mainQuest.Completed -or $null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Quests)

    if ($showMainQuestDetails) {
        $status = "Active"

        if ($mainQuest.Completed) {
            $status = "Complete"
        }
        elseif ($mainQuest.SeenDragon) {
            $status = "Turn In"
        }

        Write-ColorLine $mainQuest.Name "White"
        Write-ColorLine $mainQuest.Description "DarkGray"
        Write-ColorLine "Objective: $($mainQuest.Objective)" "White"
        Write-ColorLine "Status: $status" "Cyan"
    }

    if ($Hero) {
        $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Hero
        $displayXP = [Math]::Min($Hero.XP, $nextLevelXP)
        Write-ColorLine "XP: $displayXP/$nextLevelXP" "White"

        if ((Get-HeroAvailableLevelUps -Hero $Hero) -gt 0) {
            Write-ColorLine "Level Up Ready: Take a long rest to reach level $($Hero.Level + 1)." "Yellow"
        }
    }

    if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.Quests) {
        $acceptedQuests = @($Game.Town.Quests | Where-Object { $_.Accepted -and -not $_.Completed })
        $completedQuests = @($Game.Town.Quests | Where-Object { $_.Completed })
        $storyNotes = @(Get-StoryClueNotes -Game $Game)

        if ($acceptedQuests.Count -gt 0) {
            Write-ColorLine ""
            Write-ColorLine "Accepted Town Quests" "Yellow"

            foreach ($townQuest in $acceptedQuests) {
                Write-ColorLine "- $($townQuest.Name) [$($townQuest.Source)]" "White"
                $tierText = Get-TownQuestTierSuffix -Quest $townQuest
                Write-ColorLine "  Type: $($townQuest.QuestType)$tierText" "DarkGray"
                Write-ColorLine "  Objective: $($townQuest.Objective)" "DarkGray"
                Write-ColorLine "  Reward: $(Get-QuestRewardText -Quest $townQuest)" "DarkGray"
            }
        }

        if ($completedQuests.Count -gt 0) {
            Write-ColorLine ""
            Write-ColorLine "Completed Town Quests" "Yellow"

            foreach ($townQuest in $completedQuests) {
                $outcomeText = Get-TownQuestOutcomeText -Quest $townQuest
                $labelSuffix = if ([string]::IsNullOrWhiteSpace($outcomeText)) { "" } else { " [$outcomeText]" }
                Write-ColorLine "- $($townQuest.Name)$labelSuffix" "White"
            }
        }

        if ($storyNotes.Count -gt 0) {
            Write-ColorLine ""
            Write-ColorLine "Story Notes" "Yellow"
            Write-ColorLine (Get-StoryClueProgressSummary -Game $Game) "DarkYellow"

            foreach ($note in $storyNotes) {
                Write-ColorLine "- [$($note.Category)] $($note.Text)" "DarkGray"
            }
        }
    }

    Write-ColorLine ""
}

function Show-QuestLogSummary {
    param(
        $Hero,
        $Game
    )

    Write-ColorLine ""
    Write-ColorLine "===== QUEST LOG =====" "Yellow"

    if ($Hero) {
        $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Hero
        $displayXP = [Math]::Min($Hero.XP, $nextLevelXP)
        Write-ColorLine "XP: $displayXP/$nextLevelXP" "White"

        if ((Get-HeroAvailableLevelUps -Hero $Hero) -gt 0) {
            Write-ColorLine "Level Up Ready: Take a long rest to reach level $($Hero.Level + 1)." "Yellow"
        }
    }

    if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.Quests) {
        $acceptedCount = @($Game.Town.Quests | Where-Object { $_.Accepted -and -not $_.Completed -and -not $_.Failed }).Count
        $completedCount = @($Game.Town.Quests | Where-Object { $_.Completed }).Count
        $failedCount = @($Game.Town.Quests | Where-Object { $_.Failed }).Count
        $storyNotes = @(Get-StoryClueNotes -Game $Game)
        $currentTier = Get-CurrentStoryQuestTier -Game $Game
        $storyQuestStatus = if ($Game.Town.StoryQuestDoneToday) { "Used" } else { "Ready" }
        $dayJobStatus = if ($Game.Town.DayJobDoneToday) { "Used" } else { "Ready" }

        Write-ColorLine "Story Tier: $currentTier | Accepted: $acceptedCount | Completed: $completedCount | Story Clues: $($storyNotes.Count) | Failed: $failedCount" "DarkYellow"
        Write-ColorLine "Story Quest Today: $storyQuestStatus | Day Job Today: $dayJobStatus" "DarkYellow"
    }

    Write-ColorLine ""
}

function Show-StoryClueLog {
    param($Game)

    Write-ColorLine ""
    Write-ColorLine "===== STORY CLUES =====" "Yellow"

    $storyNotes = @(Get-StoryClueNotes -Game $Game)

    if ($storyNotes.Count -eq 0) {
        Write-ColorLine "$(Get-QuestHeroName -Game $Game) has not pieced together any real city clues yet." "DarkGray"
        Write-ColorLine ""
        return
    }

    Write-ColorLine (Get-StoryClueProgressSummary -Game $Game) "DarkYellow"

    foreach ($note in $storyNotes) {
        Write-ColorLine "- [$($note.Category)] $($note.Text)" "White"
    }

    Write-ColorLine ""
}

function Show-CompletedTownQuestLog {
    param($Game)

    Write-ColorLine ""
    Write-ColorLine "===== COMPLETED QUESTS =====" "Yellow"

    $completedQuests = @($Game.Town.Quests | Where-Object { $_.Completed })

    if ($null -ne $Game.Quest -and $Game.Quest.Completed) {
        $mainOutcomeText = Get-TownQuestOutcomeText -Quest $Game.Quest
        $mainLabelSuffix = if ([string]::IsNullOrWhiteSpace($mainOutcomeText)) { "" } else { " [$mainOutcomeText]" }
        Write-ColorLine "- $($Game.Quest.Name)$mainLabelSuffix" "White"
    }

    if ($completedQuests.Count -eq 0) {
        Write-ColorLine "No town quests are completed yet." "DarkGray"
        Write-ColorLine ""
        return
    }

    foreach ($townQuest in $completedQuests) {
        $outcomeText = Get-TownQuestOutcomeText -Quest $townQuest
        $labelSuffix = if ([string]::IsNullOrWhiteSpace($outcomeText)) { "" } else { " [$outcomeText]" }
        Write-ColorLine "- $($townQuest.Name)$labelSuffix" "White"
    }

    Write-ColorLine ""
}

function Show-FailedTownQuestLog {
    param($Game)

    Write-ColorLine ""
    Write-ColorLine "===== FAILED QUESTS =====" "Yellow"

    $failedQuests = @($Game.Town.Quests | Where-Object { $_.Failed })

    if ($failedQuests.Count -eq 0) {
        Write-ColorLine "$(Get-QuestHeroName -Game $Game) has not failed any town quests." "DarkGray"
        Write-ColorLine ""
        return
    }

    foreach ($townQuest in $failedQuests) {
        Write-ColorLine "- $($townQuest.Name)" "White"
    }

    Write-ColorLine ""
}

function Start-TownQuestLogMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        $acceptedQuests = @($Game.Town.Quests | Where-Object { $_.Accepted -and -not $_.Completed })
        Show-QuestLogSummary -Game $Game -Hero $Game.Hero
        Write-TownTimeTracker -Game $Game -Area "Quest Log" -HeroHP $HeroHP.Value

        Write-ColorLine "1. Accepted quests" "White"
        Write-ColorLine "2. Story clues" "White"
        Write-ColorLine "3. Completed quests" "White"
        Write-ColorLine "4. Failed quests" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "0") {
            return
        }

        switch ($choice) {
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "1" {
                if ($acceptedQuests.Count -eq 0) {
                    Write-ColorLine ""
                    Write-ColorLine "===== ACCEPTED QUESTS =====" "Yellow"
                    Write-ColorLine "$(Get-QuestHeroName -Game $Game) has no accepted town quests right now." "DarkGray"
                    Write-ColorLine ""
                    continue
                }

                while ($true) {
                    Write-ColorLine ""
                    Write-ColorLine "===== ACCEPTED QUESTS =====" "Yellow"
                    Write-TownTimeTracker -Game $Game -Area "Quest Log" -HeroHP $HeroHP.Value

                    for ($i = 0; $i -lt $acceptedQuests.Count; $i++) {
                        $quest = $acceptedQuests[$i]
                        $tierText = Get-TownQuestTierSuffix -Quest $quest
                        Write-ColorLine "$($i + 1). $($quest.Name) [$($quest.Source)$tierText]" "White"
                        Write-ColorLine "   Objective: $($quest.Objective)" "DarkGray"
                        Write-ColorLine "   Reward: $(Get-QuestRewardText -Quest $quest)" "DarkGray"
                    }

                    Write-ColorLine ""
                    Write-ColorLine "0. Back to quest log" "DarkGray"
                    Write-ColorLine ""

                    $acceptedChoice = Read-Host "Choose a quest to prepare or start"

                    if ($acceptedChoice -eq "0") {
                        break
                    }

                    if ($acceptedChoice -notmatch '^\d+$') {
                        Write-ColorLine "Choose a listed number." "DarkYellow"
                        Write-ColorLine ""
                        continue
                    }

                    $index = [int]$acceptedChoice - 1

                    if ($index -lt 0 -or $index -ge $acceptedQuests.Count) {
                        Write-ColorLine "That quest is not listed." "DarkYellow"
                        Write-ColorLine ""
                        continue
                    }

                    if ($null -ne $global:TownQuestPreparationOverride) {
                        & $global:TownQuestPreparationOverride $Game $HeroHP $acceptedQuests[$index]
                    }
                    else {
                        Start-TownQuestPreparationMenu -Game $Game -HeroHP $HeroHP -Quest $acceptedQuests[$index]
                    }

                    $acceptedQuests = @($Game.Town.Quests | Where-Object { $_.Accepted -and -not $_.Completed })
                }
            }
            "2" {
                Show-StoryClueLog -Game $Game
            }
            "3" {
                Show-CompletedTownQuestLog -Game $Game
            }
            "4" {
                Show-FailedTownQuestLog -Game $Game
            }
            default {
                Write-ColorLine "Choose a listed number." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}
