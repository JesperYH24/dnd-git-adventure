. "$PSScriptRoot\..\setup.ps1"

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected: $Expected, Actual: $Actual"
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Set-TestOutputStubs {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
    function global:Write-SectionTitle { param([string]$Text, [string]$Color) }
    function global:Write-EmphasisLine { param([string]$Text, [string]$Color) }
}

function Set-ReadHostQueue {
    param([string[]]$Responses)

    $script:ReadHostQueue = [System.Collections.Generic.Queue[string]]::new()

    foreach ($response in $Responses) {
        $script:ReadHostQueue.Enqueue($response)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:ReadHostQueue.Count -eq 0) {
            throw "No queued Read-Host response remained for prompt: $Prompt"
        }

        return $script:ReadHostQueue.Dequeue()
    }
}

function Test-TutorialDefeatResetsBackToFreshCampfireState {
    Set-TestOutputStubs
    $game = Initialize-Game -Class "Bard"
    $game.CurrentRoomId = "shadow_sanctum"
    $game.Hero.Level = 2
    $game.Hero.XP = 999
    $game.Quest.SeenDragon = $true
    $game.Hero.Inventory += (New-ConsumableItem -Name "Extra Potion" -Value 0 -HealAmount 4 -SlotCost 1)

    $heroHP = 0
    $heroDroppedWeapon = $true

    Reset-TutorialAfterDefeat -Game $game -HeroHP ([ref]$heroHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    Assert-Equal -Actual $game.CurrentRoomId -Expected "entrance" -Message "Tutorial defeat should return the hero to the start of the cave."
    Assert-Equal -Actual $game.Hero.Level -Expected 1 -Message "Tutorial defeat should reset the hero to a fresh class start."
    Assert-Equal -Actual $game.Hero.XP -Expected 0 -Message "Tutorial defeat should reset tutorial XP progress."
    Assert-Equal -Actual $game.Quest.SeenDragon -Expected $false -Message "Tutorial defeat should reset the main tutorial warning state."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Tutorial defeat should restore the hero to fresh starting HP."
    Assert-Equal -Actual $heroDroppedWeapon -Expected $false -Message "Tutorial defeat should clear dropped weapon state."
}

function Test-TownDoctorRecoveryKeepsSameDayButFailsQuest {
    Set-TestOutputStubs
    Set-ReadHostQueue -Responses @("1")

    $game = Initialize-Game -Class "Barbarian"
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"
    $quest.Accepted = $true
    $quest.Started = $true
    $game.Town.StoryQuestDoneToday = $true
    $game.Hero.CurrencyCopper = 200
    $game.HeroDroppedWeapon = $true
    $heroHP = 0

    $result = Resolve-TownQuestDefeatRecovery -Game $game -HeroHP ([ref]$heroHP) -QuestId $quest.Id

    Assert-Equal -Actual $result -Expected "Doctor" -Message "Doctor recovery should resolve through the same-day branch."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "The town doctor should restore the hero to full HP."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $true -Message "Doctor recovery should keep the current day spent."
    Assert-Equal -Actual $quest.Failed -Expected $true -Message "Quest defeat should mark the quest as failed."
    Assert-Equal -Actual $quest.Accepted -Expected $false -Message "A failed quest should leave the accepted list."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 140 -Message "The town doctor should cost 60 copper."
    Assert-Equal -Actual $game.HeroDroppedWeapon -Expected $false -Message "Doctor recovery should clear dropped weapon state."
}

function Test-InnRecoveryEndsTheDayAndResetsDailyUsage {
    Set-TestOutputStubs
    Set-ReadHostQueue -Responses @("2")

    $game = Initialize-Game -Class "Bard"
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"
    $quest.Accepted = $true
    $quest.Started = $true
    $game.Town.StoryQuestDoneToday = $true
    $game.Town.DayJobDoneToday = $true
    $game.Town.PerformanceCountToday = 2
    $game.Town.PerformanceVenuesToday["market_square"] = $true
    $game.Hero.CurrencyCopper = 300
    $game.Town.ActiveInn = Get-CheapestTownInn
    $game.Hero.CurrentBardicInspirationDice = 0
    $heroHP = 0

    $result = Resolve-TownQuestDefeatRecovery -Game $game -HeroHP ([ref]$heroHP) -QuestId $quest.Id

    Assert-Equal -Actual $result -Expected "Inn" -Message "Inn recovery should take the long-rest branch."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Inn recovery should restore the hero to full HP."
    Assert-Equal -Actual $game.Town.StoryQuestDoneToday -Expected $false -Message "Inn recovery should advance to the next day and reset story usage."
    Assert-Equal -Actual $game.Town.DayJobDoneToday -Expected $false -Message "Inn recovery should advance to the next day and reset day jobs."
    Assert-Equal -Actual $game.Town.PerformanceCountToday -Expected 0 -Message "Inn recovery should reset bard performances for the new day."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected (300 - $game.Town.ActiveInn.PriceCopper) -Message "Inn recovery should charge the next night's room price."
    Assert-Equal -Actual $quest.Failed -Expected $true -Message "Inn recovery should still mark the quest as failed."
}

Test-TutorialDefeatResetsBackToFreshCampfireState
Test-TownDoctorRecoveryKeepsSameDayButFailsQuest
Test-InnRecoveryEndsTheDayAndResetsDailyUsage

Write-Host "Defeat tests passed." -ForegroundColor Green
