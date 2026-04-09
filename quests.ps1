function New-TownQuest {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Source,
        [string]$Description,
        [string]$Objective,
        [string]$QuestType = "Story",
        [int]$RewardCopper = 0,
        [int]$RewardXP = 0,
        [string]$RewardItemName = "",
        [int]$RequiredStoryClues = 0
    )

    return [PSCustomObject]@{
        Id = $Id
        Name = $Name
        Source = $Source
        Description = $Description
        Objective = $Objective
        QuestType = $QuestType
        RewardCopper = $RewardCopper
        RewardXP = $RewardXP
        RewardItemName = $RewardItemName
        RequiredStoryClues = $RequiredStoryClues
        Accepted = $false
        Started = $false
        Completed = $false
    }
}

function Initialize-TownQuests {
    return @(
        (New-TownQuest -Id "guard_night_watch" -Name "Night Watch Relief" -Source "Guard Station" -Description "The guards need a capable arm on a short night patrol through the outer district." -Objective "Report to the watch captain for an evening patrol." -QuestType "Story" -RewardCopper 180 -RewardXP 200)
        (New-TownQuest -Id "patron_storehouse_rats" -Name "Storehouse Trouble" -Source "Quest Giver" -Description "A merchant patron wants someone to clear vermin and thieves from a locked riverside storehouse." -Objective "Meet the patron's clerk and investigate the storehouse." -QuestType "Story" -RewardCopper 150 -RewardXP 180 -RewardItemName "Healing Potion")
        (New-TownQuest -Id "quest_board_missing_herbs" -Name "Missing Herb Satchel" -Source "Quest Board" -Description "A local herbalist needs a satchel recovered from the old road beyond the city wall." -Objective "Search the old road and return the satchel." -QuestType "Story" -RewardCopper 120 -RewardXP 120)
        (New-TownQuest -Id "patron_ledger_of_ash" -Name "Ledger of Ash" -Source "Quest Giver" -Description "A merchant clerk suspects false entries and hush money in a ledger tied to missing goods." -Objective "Question the clerk, inspect the ledger, and trace the irregular payments." -QuestType "Story" -RewardCopper 140 -RewardXP 160)
        (New-TownQuest -Id "patron_warehouse_ledger" -Name "Warehouse Ledger Recovery" -Source "Quest Giver" -Description "A hidden warehouse ledger may tie the smugglers' route, false payments, and missing stock to a single hand." -Objective "Secure the warehouse ledger before it disappears into the understreet network." -QuestType "Story" -RewardCopper 170 -RewardXP 170)
        (New-TownQuest -Id "guard_broken_seal" -Name "Broken Seal Patrol" -Source "Guard Station" -Description "Now that real clues have surfaced, the watch wants a harder patrol into a breached maintenance route beneath the ward." -Objective "Join the guard patrol and confirm what is moving below the city." -QuestType "Story" -RewardCopper 190 -RewardXP 180 -RequiredStoryClues 2)
        (New-TownQuest -Id "guard_night_courier" -Name "Night Courier Intercept" -Source "Guard Station" -Description "The watch believes a marked courier is moving messages between the city's surface contacts and the understreet routes." -Objective "Intercept the night courier and secure whatever they are carrying." -QuestType "Story" -RewardCopper 150 -RewardXP 160)
        (New-TownQuest -Id "guard_understreet_complex" -Name "The Understreet Complex" -Source "Guard Station" -Description "With enough clues in hand, the watch is finally ready to move on the hidden complex beneath the city." -Objective "Gather the final evidence, then descend into the understreet complex." -QuestType "Story" -RewardCopper 230 -RewardXP 240)
        (New-TownQuest -Id "bent_nail_whispers" -Name "Whispers Beneath the Bent Nail" -Source "Bent Nail" -Description "A back-room fixer at the Bent Nail knows more about the city's quiet cargo routes than any honest merchant should." -Objective "Follow the broker lead inside the Bent Nail and learn where the smugglers are moving goods." -QuestType "Story" -RewardCopper 130 -RewardXP 150)
        (New-TownQuest -Id "dayjob_market_delivery" -Name "Missing Delivery" -Source "Quest Board" -Description "A market runner needs someone reliable to recover a missing crate before dawn." -Objective "Find the missing crate and settle the problem without bloodshed." -QuestType "DayJob" -RewardCopper 90)
        (New-TownQuest -Id "dayjob_gate_labor" -Name "Gate Duty Overflow" -Source "Guard Station" -Description "The gate sergeant needs a strong back and a hard stare to keep freight moving without panic." -Objective "Help the gate detail clear a jam and keep tempers under control." -QuestType "DayJob" -RewardCopper 100)
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
    param($Quest)

    if ($Quest.QuestType -eq "DayJob") {
        return "Borzig has already taken on a paid side job today. Another day job will have to wait until tomorrow."
    }

    return "Borzig has already spent today's real story effort. Another story quest will have to wait until after a night's rest."
}

function Is-TownQuestUnlocked {
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
        if (-not [bool]$Game.Town.StoryFlags["FoundTunnelAccess"]) {
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

    if ($Quest.RequiredStoryClues -le 0) {
        return $true
    }

    return (Get-StoryClueCount -Game $Game) -ge [int]$Quest.RequiredStoryClues
}

function Get-UnderstreetFinalEntryMessage {
    param($Hero)

    if ($Hero.Level -ge 3) {
        return ""
    }

    if ((Get-HeroAvailableLevelUps -Hero $Hero) -gt 0) {
        return "Borzig is not ready to descend yet. He needs a long rest at the inn to reach level 3 before taking on the Understreet Complex."
    }

    return "Borzig is not ready to descend yet. He needs to grow stronger and reach level 3 before taking on the Understreet Complex."
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
            Message = "Borzig does not have enough clues to take that quest yet."
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
            Message = "$($quest.Name) is already in Borzig's quest log."
        }
    }

    $quest.Accepted = $true

    return [PSCustomObject]@{
        Success = $true
        Message = "$($quest.Name) is added to Borzig's quest log."
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
            Message = (Get-TownQuestDailyLockText -Quest $quest)
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
        [string]$QuestId
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
    $quest.Started = $false

    $rewardCopper = [int]$quest.RewardCopper

    if ($rewardCopper -gt 0 -and $Game.Town.QuestPayoutBonusCopper -gt 0) {
        $rewardCopper += [int]$Game.Town.QuestPayoutBonusCopper
    }

    $currencyResult = $null

    if ($rewardCopper -gt 0) {
        $currencyResult = Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper
    }

    $rewardXP = [int]$quest.RewardXP

    if ($rewardXP -gt 0) {
        Grant-HeroXP -Hero $Game.Hero -XP $rewardXP
    }

    $rewardItem = $null

    if (-not [string]::IsNullOrWhiteSpace($quest.RewardItemName)) {
        $rewardItem = New-TownQuestRewardItem -RewardItemName $quest.RewardItemName

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

    if ($null -ne $mainQuest) {
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

        if ($acceptedQuests.Count -gt 0) {
            Write-ColorLine ""
            Write-ColorLine "Accepted Town Quests" "Yellow"

            foreach ($townQuest in $acceptedQuests) {
                Write-ColorLine "- $($townQuest.Name) [$($townQuest.Source)]" "White"
                Write-ColorLine "  Type: $($townQuest.QuestType)" "DarkGray"
                Write-ColorLine "  Objective: $($townQuest.Objective)" "DarkGray"
                Write-ColorLine "  Reward: $(Get-QuestRewardText -Quest $townQuest)" "DarkGray"
            }
        }

        if ($completedQuests.Count -gt 0) {
            Write-ColorLine ""
            Write-ColorLine "Completed Town Quests" "Yellow"

            foreach ($townQuest in $completedQuests) {
                Write-ColorLine "- $($townQuest.Name)" "White"
            }
        }
    }

    Write-ColorLine ""
}
