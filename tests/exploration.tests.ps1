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

function Set-TestInputSequence {
    param([string[]]$Choices)

    $script:TestInputQueue = [System.Collections.Queue]::new()

    foreach ($choice in $Choices) {
        $script:TestInputQueue.Enqueue($choice)
    }

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:TestInputQueue.Count -eq 0) {
            throw "No test input remains for prompt '$Prompt'."
        }

        return $script:TestInputQueue.Dequeue()
    }
}

function Test-RoomExplorationCanMoveBetweenGenericRooms {
    Set-TestOutputStubs
    Set-TestInputSequence -Choices @("1", "X")

    $game = Initialize-Game
    $rooms = @{
        start = (New-Room -Id "start" -Name "Start" -Description "Start room." -Exits @{ east = "market" })
        market = (New-Room -Id "market" -Name "Market" -Description "Market room." -Exits @{})
    }
    $game.Rooms = $rooms
    $game.CurrentRoomId = "start"
    $heroHP = $game.Hero.HP
    $script:SeenRooms = @()

    $null = Start-RoomExploration `
        -Game $game `
        -HeroHP ([ref]$heroHP) `
        -Rooms $rooms `
        -StartRoomId "start" `
        -ShowCurrentRoom {
            param($Game, $Room)

            $script:SeenRooms += $Room.Id
        } `
        -HandleCustomAction {
            param([string]$Choice, $Game, $Room, [ref]$HeroHP, [ref]$CurrentRoomId)

            if ($Choice -eq "X") {
                return "Return"
            }

            return "Unhandled"
        }

    Assert-Equal -Actual $game.LastRoomId -Expected "start" -Message "Generic exploration should track the previous room."
    Assert-Equal -Actual $game.CurrentRoomId -Expected "market" -Message "Generic exploration should move to the selected exit."
    Assert-True -Condition ($script:SeenRooms -contains "start") -Message "Generic exploration should show the starting room."
    Assert-True -Condition ($script:SeenRooms -contains "market") -Message "Generic exploration should show the destination room."
}

function Test-CaveExplorationStillAllowsLeavingEntrance {
    Set-TestOutputStubs
    Set-TestInputSequence -Choices @("Q")

    $game = Initialize-Game
    $game.Rooms["entrance"].EncounterChance = 0
    $heroHP = $game.Hero.HP
    $heroDroppedWeapon = $false

    Start-CaveExploration -Game $game -HeroHP ([ref]$heroHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    Assert-Equal -Actual $game.CurrentRoomId -Expected "entrance" -Message "Leaving the cave should keep the hero at the entrance."
    Assert-True -Condition (-not $game.GameWon) -Message "Leaving the cave should not mark the tutorial as won."
}

Test-RoomExplorationCanMoveBetweenGenericRooms
Test-CaveExplorationStillAllowsLeavingEntrance

Write-Host "Exploration tests passed." -ForegroundColor Green
