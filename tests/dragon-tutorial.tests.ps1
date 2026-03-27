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
    function global:Read-Host { param([string]$Prompt) return "n" }
}

function Test-DeepChamberForcesRetreatWithoutCompletingQuest {
    Set-TestOutputStubs

    $game = Initialize-Game
    $heroHP = $game.HeroHP
    $heroDroppedWeapon = $game.HeroDroppedWeapon
    $currentRoomId = "shadow_sanctum"
    $game.LastRoomId = "underground_lake"
    $room = $game.Rooms[$currentRoomId]

    $result = Resolve-RoomEncounter `
        -Game $game `
        -Room $room `
        -HeroHP ([ref]$heroHP) `
        -HeroDroppedWeapon ([ref]$heroDroppedWeapon) `
        -CurrentRoomId ([ref]$currentRoomId)

    Assert-Equal -Actual $result -Expected "Fled" -Message "First shadow sanctum entry should force a retreat."
    Assert-Equal -Actual $currentRoomId -Expected "underground_lake" -Message "The hero should be moved back to the previous room."
    Assert-Equal -Actual $heroHP -Expected 20 -Message "The tutorial dragon encounter should not damage the hero."
    Assert-True -Condition $game.Quest.SeenDragon -Message "The quest should record that Borzig has seen the dragon."
    Assert-Equal -Actual $game.Quest.Completed -Expected $false -Message "The quest should not complete until the hero reports back to town."
}

Test-DeepChamberForcesRetreatWithoutCompletingQuest

Write-Host "Dragon tutorial tests passed." -ForegroundColor Green
