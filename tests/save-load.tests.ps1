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

function New-TestSaveDirectory {
    $path = Join-Path $PSScriptRoot (".tmp-save-" + [Guid]::NewGuid().ToString("N"))
    New-Item -ItemType Directory -Path $path -Force | Out-Null
    return $path
}

function Remove-TestSaveDirectory {
    param([string]$Path)

    if (-not [string]::IsNullOrWhiteSpace($Path) -and (Test-Path $Path)) {
        Remove-Item -LiteralPath $Path -Recurse -Force
    }
}

function Test-SaveLoadRoundTripPreservesAdventureState {
    $saveDirectory = New-TestSaveDirectory
    $global:AdventureSaveDirectoryOverride = $saveDirectory

    try {
        $game = Initialize-Game -Class "Bard"
        $game.Quest.Completed = $true
        $game.Hero.Level = 2
        $game.Hero.XP = 450
        $game.Town.StoryQuestDoneToday = $true
        $game.Town.PerformanceCountToday = 2
        $game.Town.PerformanceCountTotal = 5
        $game.Town.DayNumber = 4
        $game.Town.TimeOfDay = "Night"
        $game.Town.StoryFlags["FoundSmugglingLink"] = $true
        $game.Town.InnFlags["SilverKettlePrivateInvite"] = $true
        $game.Town.ActiveInn = [PSCustomObject]@{
            Id = "silver_kettle"
            Name = "Silver Kettle"
            Keeper = "Madam Seraphine"
            Quality = "Fine"
            PriceCopper = 50
        }

        $saveMetadata = Save-AdventureGame -Game $game -HeroHP 7 -HeroDroppedWeapon $true -Slot 1
        $loadedGame = Load-AdventureGame -Slot 1

        Assert-Equal -Actual $saveMetadata.Metadata.HeroName -Expected "Gariand" -Message "Save metadata should capture the active hero."
        Assert-Equal -Actual $loadedGame.Hero.Name -Expected "Gariand" -Message "Loading should restore the bard hero."
        Assert-Equal -Actual $loadedGame.HeroHP -Expected 7 -Message "Loading should preserve current HP."
        Assert-Equal -Actual $loadedGame.HeroDroppedWeapon -Expected $true -Message "Loading should preserve dropped-weapon state."
        Assert-Equal -Actual $loadedGame.Town.PerformanceCountToday -Expected 2 -Message "Loading should preserve bard performance usage."
        Assert-Equal -Actual $loadedGame.Town.PerformanceCountTotal -Expected 5 -Message "Loading should preserve total bard recognition progress."
        Assert-Equal -Actual $loadedGame.Town.DayNumber -Expected 4 -Message "Loading should preserve the current town day count."
        Assert-Equal -Actual $loadedGame.Town.TimeOfDay -Expected "Night" -Message "Loading should preserve the current town time of day."
        Assert-Equal -Actual $loadedGame.Town.StoryQuestDoneToday -Expected $true -Message "Loading should preserve daily story quest usage."
        Assert-Equal -Actual $loadedGame.Town.StoryFlags["FoundSmugglingLink"] -Expected $true -Message "Loading should preserve story flags."
        Assert-Equal -Actual $loadedGame.Town.InnFlags["SilverKettlePrivateInvite"] -Expected $true -Message "Loading should preserve inn flags."
        Assert-Equal -Actual $loadedGame.Town.ActiveInn.Name -Expected "Silver Kettle" -Message "Loading should preserve the current inn booking."
    }
    finally {
        $global:AdventureSaveDirectoryOverride = $null
        Remove-TestSaveDirectory -Path $saveDirectory
    }
}

function Test-OlderSaveDataGetsNewDefaultsOnLoad {
    $saveDirectory = New-TestSaveDirectory
    $global:AdventureSaveDirectoryOverride = $saveDirectory

    try {
        $hero = Get-Hero -Class "Barbarian"
        $legacyGame = [PSCustomObject]@{
            Hero = $hero
            Quest = [PSCustomObject]@{
                Name = "Scout the Cave"
                Description = "Legacy quest"
                Objective = "Legacy objective"
                SeenDragon = $true
                Completed = $true
            }
            Town = @{
                StreetFlags = @{}
                Discounts = @{}
                Quests = (Initialize-TownQuests)
            }
            Rooms = @{}
            CurrentRoomId = "entrance"
            LastRoomId = $null
            GameWon = $false
            ShadowSanctumRewardTaken = $true
        }

        $legacyWrapper = [PSCustomObject]@{
            Version = 0
            SavedAtUtc = [DateTime]::UtcNow
            Metadata = $null
            Game = $legacyGame
        }

        $path = Get-AdventureSaveSlotPath -Slot 2
        Ensure-AdventureSaveDirectory | Out-Null
        Export-Clixml -Path $path -InputObject $legacyWrapper -Force

        $loadedGame = Load-AdventureGame -Slot 2

        Assert-Equal -Actual $loadedGame.HeroHP -Expected $hero.HP -Message "Older saves should default current HP to full if it was not stored."
        Assert-Equal -Actual $loadedGame.HeroDroppedWeapon -Expected $false -Message "Older saves should default dropped weapon state to false."
        Assert-True -Condition $loadedGame.Town.ContainsKey("PerformanceVenuesToday") -Message "Older saves should gain new town performance tracking keys."
        Assert-True -Condition $loadedGame.Town.ContainsKey("Ring") -Message "Older saves should gain ring state defaults."
        Assert-True -Condition $loadedGame.Town.ContainsKey("DayNumber") -Message "Older saves should gain a default town day counter."
        Assert-True -Condition $loadedGame.Town.ContainsKey("TimeOfDay") -Message "Older saves should gain a default town time-of-day field."
        Assert-True -Condition $loadedGame.Town["Ring"].ContainsKey("FoughtToday") -Message "Older saves should gain nested ring defaults."
    }
    finally {
        $global:AdventureSaveDirectoryOverride = $null
        Remove-TestSaveDirectory -Path $saveDirectory
    }
}

Test-SaveLoadRoundTripPreservesAdventureState
Test-OlderSaveDataGetsNewDefaultsOnLoad

Write-Host "Save/load tests passed." -ForegroundColor Green
