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
    $global:CapturedScenes = @()
    $script:readHostResponses = @("1")
    $script:readHostIndex = 0
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) $global:CapturedScenes += $Text }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-BlinkingLine { param([string]$Text, [string]$Color1, [string]$Color2, [int]$Times) }
    function global:Write-SectionTitle { param([string]$Text, [string]$Color) }
    function global:Write-EmphasisLine { param([string]$Text, [string]$Color) }
    function global:Read-Host {
        param([string]$Prompt)

        if ($script:readHostIndex -lt $script:readHostResponses.Count) {
            $response = $script:readHostResponses[$script:readHostIndex]
            $script:readHostIndex += 1
            return $response
        }

        return "1"
    }
}

function Test-DeepChamberForcesRetreatWithoutCompletingQuest {
    Set-TestOutputStubs

    $game = Initialize-Game
    $heroHP = $game.HeroHP
    $heroDroppedWeapon = $game.HeroDroppedWeapon
    $currentRoomId = "shadow_sanctum"
    $game.LastRoomId = "ashen_threshold"
    $room = $game.Rooms[$currentRoomId]

    $result = Resolve-RoomEncounter `
        -Game $game `
        -Room $room `
        -HeroHP ([ref]$heroHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -CurrentRoomId ([ref]$currentRoomId)

    Assert-Equal -Actual $result -Expected "Fled" -Message "First shadow sanctum entry should force a retreat."
    Assert-Equal -Actual $currentRoomId -Expected "ashen_threshold" -Message "The hero should be moved back to the previous room."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "The tutorial dragon encounter should not damage the hero."
    Assert-True -Condition $game.Quest.SeenDragon -Message "The quest should record that Borzig has seen the dragon."
    Assert-Equal -Actual $game.Quest.Completed -Expected $false -Message "The quest should not complete until the hero reports back to town."
}

function Test-BardCanPrepareAtCampfireBeforeEnteringTutorialCave {
    Set-TestOutputStubs

    $script:readHostResponses = @("2", "1")
    $script:readHostIndex = 0

    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP

    $result = Start-CampfireMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "EnterCave" -Message "A bard should still be able to enter the cave directly from the campfire menu."
    Assert-Equal -Actual $game.Hero.CurrentBardicInspirationDice -Expected 3 -Message "Choosing to prepare before the tutorial cave should ready the bard's full inspiration pool."
}

function Test-BardTutorialCombatExplainsBonusActionFlow {
    Set-TestOutputStubs

    function global:Read-Host {
        param([string]$Prompt)
        return "R"
    }

    $hero = Get-Hero -Class "Bard"
    $heroHP = $hero.HP
    $monsterHP = 8
    $heroDroppedWeapon = $false
    $monsterOffBalance = $false
    $encounterFled = $false
    $monster = [PSCustomObject]@{
        name = "tutorial goblin"
        definite = "The Tutorial Goblin"
        hp = 8
        armorClass = 12
        attackBonus = 2
        damageDiceCount = 1
        damageDiceSides = 4
        damageBonus = 0
        isBoss = $false
    }

    Prepare-HeroBardicInspiration -Hero $hero | Out-Null

    Start-CombatLoop -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon) -MonsterOffBalance ([ref]$monsterOffBalance) -EncounterFled ([ref]$encounterFled)

    Assert-True -Condition $hero.TutorialCombatHintShown -Message "The bard should be taught about bonus-action inspiration during the tutorial fights."
}

Test-DeepChamberForcesRetreatWithoutCompletingQuest
Test-BardCanPrepareAtCampfireBeforeEnteringTutorialCave
Test-BardTutorialCombatExplainsBonusActionFlow

Write-Host "Dragon tutorial tests passed." -ForegroundColor Green
