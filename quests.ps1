function New-TownQuest {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Source,
        [string]$Description,
        [string]$Objective,
        [int]$RewardCopper = 0,
        [string]$RewardItemName = ""
    )

    return [PSCustomObject]@{
        Id = $Id
        Name = $Name
        Source = $Source
        Description = $Description
        Objective = $Objective
        RewardCopper = $RewardCopper
        RewardItemName = $RewardItemName
        Accepted = $false
        Completed = $false
    }
}

function Initialize-TownQuests {
    return @(
        (New-TownQuest -Id "quest_board_missing_herbs" -Name "Missing Herb Satchel" -Source "Quest Board" -Description "A local herbalist needs a satchel recovered from the old road beyond the city wall." -Objective "Search the old road and return the satchel." -RewardCopper 120)
        (New-TownQuest -Id "guard_night_watch" -Name "Night Watch Relief" -Source "Guard Station" -Description "The guards need a capable arm on a short night patrol through the outer district." -Objective "Report to the watch captain for an evening patrol." -RewardCopper 180)
        (New-TownQuest -Id "patron_storehouse_rats" -Name "Storehouse Trouble" -Source "Quest Giver" -Description "A merchant patron wants someone to clear vermin and thieves from a locked riverside storehouse." -Objective "Meet the patron's clerk and investigate the storehouse." -RewardCopper 150 -RewardItemName "Healing Potion")
    )
}

function Get-QuestRewardText {
    param($Quest)

    $parts = @()

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

    $quests = @($Game.Town.Quests)

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

    return (Get-TownQuestList -Game $Game | Where-Object { $_.Id -eq $QuestId } | Select-Object -First 1)
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

function Show-QuestLog {
    param(
        $Quest = $null,
        $Hero = $null,
        $Game = $null
    )

    $mainQuest = $Quest

    if ($null -ne $Game -and $null -ne $Game.PSObject.Properties["Quest"]) {
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
