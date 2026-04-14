. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-TestReadHostSequence {
    param([string[]]$Values)

    $script:ReadHostSequence = @($Values)
    $script:ReadHostIndex = 0

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:ReadHostIndex -ge $script:ReadHostSequence.Count) {
            throw "Read-Host was called more times than the test expected."
        }

        $value = $script:ReadHostSequence[$script:ReadHostIndex]
        $script:ReadHostIndex += 1
        return $value
    }
}

function Test-InnStayChargesGoldAndHealsHero {
    $game = Initialize-Game
    $heroHP = 3
    $game.Hero.CurrencyCopper = 500
    $game.Town.MustChooseFirstInn = $true
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    $result = Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99

    Assert-Equal -Actual $result -Expected $true -Message "The hero should be able to pay for an inn stay."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 300 -Message "Inn cost should be deducted from the gold pouch."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Inn stay should restore the hero to full HP."
    Assert-Equal -Actual $game.Town.ChapterOneComplete -Expected $true -Message "The first successful inn stay should complete chapter one."
    Assert-Equal -Actual $game.Town.MustChooseFirstInn -Expected $false -Message "The first inn stay should clear the forced-lodging flag."
}

function Test-TutorialArrivalStarterFundsCoverCheapestInn {
    $game = Initialize-Game
    $game.Hero.CurrencyCopper = 0

    $starterFunds = Ensure-TutorialArrivalStarterFunds -Game $game

    Assert-Equal -Actual $starterFunds.CopperGranted -Expected 80 -Message "Town arrival support should only cover the cheapest inn."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 80 -Message "The hero should receive enough coin for the cheapest room."
}

function Test-InnStayResetsDailyRingLockout {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.Ring.FoughtToday = $true
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null

    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $false -Message "A full inn stay should reset the once-per-day ring lockout."
}

function Test-BookedInnNightRestResetsDailySystems {
    $game = Initialize-Game
    $heroHP = 5
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null

    $game.Town.Ring.FoughtToday = $true
    $game.Hero.ActiveBuff = [PSCustomObject]@{
        Name = "Potion of Haste"
        Type = "Haste"
        InitiativeAdvantage = $true
    }
    $heroHP = 3

    $rested = Resolve-BookedInnNightRest -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $rested -Expected $true -Message "A booked room should allow a normal night of rest."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 100 -Message "A repeat night should charge the inn price again."
    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $false -Message "A booked-room rest should reset the daily ring lockout."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "A booked-room rest should restore the hero to full HP."
    Assert-Equal -Actual $game.Hero.ActiveBuff -Expected $null -Message "A booked-room rest should clear lingering buffs."
}

function Test-BookedInnNightRestTriggersLevelUp {
    $game = Initialize-Game
    $heroHP = 5
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1
    $game.Town.ActiveInn = $inn
    $game.Hero.CurrencyCopper = 500
    $game.Hero.Level = 2
    $game.Hero.LevelCap = 3
    $game.Hero.XP = 900

    Resolve-BookedInnNightRest -Game $game -HeroHP ([ref]$heroHP) | Out-Null

    Assert-Equal -Actual $game.Hero.Level -Expected 3 -Message "A long rest at the inn should apply the pending level 3 gain."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "The hero should wake with full HP after leveling during a long rest."
}

function Test-StashCanStoreAndRetrieveGear {
    $hero = Get-Hero
    $startingInventoryCount = $hero.Inventory.Count

    Move-InventoryItemToStash -Hero $hero -InventoryIndex 0

    Assert-Equal -Actual $hero.Inventory.Count -Expected ($startingInventoryCount - 1) -Message "Stashing an item should remove it from inventory."
    Assert-Equal -Actual $hero.StashedInventory.Count -Expected 1 -Message "Stashing an item should add it to inn storage."

    $retrieved = Retrieve-StashedItem -Hero $hero -StashIndex 0

    Assert-Equal -Actual $retrieved -Expected $true -Message "A stored item should be retrievable when there is space."
    Assert-Equal -Actual $hero.Inventory.Count -Expected $startingInventoryCount -Message "Retrieving should return the item to inventory."
    Assert-Equal -Actual $hero.StashedInventory.Count -Expected 0 -Message "Retrieving should remove the item from inn storage."
}

function Test-CannotChooseNewInnWhileBooked {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null
    $result = Start-InnSelectionMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "AlreadyBooked" -Message "A booked hero should not be offered a new inn until the current room is cancelled."
    Assert-Equal -Actual $game.Town.ActiveInn.Id -Expected "lantern_rest" -Message "The current inn booking should remain active."
}

function Test-CannotCancelInnBookingWithStoredGear {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null
    Move-InventoryItemToStash -Hero $game.Hero -InventoryIndex 0
    $cancelled = Resolve-InnBookingCancellation -Game $game

    Assert-Equal -Actual $cancelled -Expected $false -Message "A booking should not be cancellable while stored gear is still in the room chest."
    Assert-Equal -Actual $game.Town.ActiveInn.Id -Expected "lantern_rest" -Message "The inn booking should remain active when storage is not empty."
}

function Test-CanCancelInnBookingWhenStorageIsEmpty {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null
    $cancelled = Resolve-InnBookingCancellation -Game $game

    Assert-Equal -Actual $cancelled -Expected $true -Message "The hero should be able to cancel an inn booking when storage is empty."
    Assert-Equal -Actual $game.Town.ActiveInn -Expected $null -Message "Cancelling a booking should clear the active inn."
}

function Test-WorkOffRoomCoversNightAndBlocksRing {
    $game = Initialize-Game
    $heroHP = 2
    $game.Town.MustChooseFirstInn = $true
    $inn = Get-TownInns | Where-Object { $_.Id -eq "bent_nail" } | Select-Object -First 1
    $game.Hero.CurrencyCopper = 0
    Set-TestReadHostSequence -Values @("1", "1")
    function global:Roll-Dice { param([int]$Sides) return 10 }

    $result = Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99

    Assert-Equal -Actual $result -Expected $true -Message "Working off the room should still secure the inn stay."
    Assert-Equal -Actual $game.Town.ActiveInn.Id -Expected "bent_nail" -Message "Working off the room should still book the chosen inn."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 0 -Message "A simple worked-off room should not require coin."
    Assert-Equal -Actual $game.Town.WorkedForRoomToday -Expected $true -Message "Working off the room should mark the hero as fatigued for the next day."
    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $true -Message "Working off the room should block the ring for the next day."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Working off the room should still end with a full night's rest."
}

function Test-CommonRoomStaysOpenUntilBackedOut {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "bent_nail" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null
    Set-TestReadHostSequence -Values @("1", "0")

    Start-InnEveningMenu -Game $game

    Assert-Equal -Actual $game.Town.InnFlags["BentNailShadyRumor"] -Expected $true -Message "Taking a common-room action should still resolve as normal."
    Assert-Equal -Actual $game.Town.InnFlags["BentNailBrokerInfo"] -Expected $null -Message "The Bent Nail should hold back the deeper broker lead until tier 2 opens."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 2 -Message "The common room should stay open until the player explicitly backs out."
}

function Test-InnRoomReturnToTownDoesNotRouteThroughStreets {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null
    Set-TestReadHostSequence -Values @("7")

    $result = Start-InnMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "BackToTown" -Message "Leaving the inn room should return directly to town."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 1 -Message "Returning to town from the inn room should not force the streets menu first."
}

Test-InnStayChargesGoldAndHealsHero
Test-TutorialArrivalStarterFundsCoverCheapestInn
Test-InnStayResetsDailyRingLockout
Test-BookedInnNightRestResetsDailySystems
Test-BookedInnNightRestTriggersLevelUp
Test-StashCanStoreAndRetrieveGear
Test-CannotChooseNewInnWhileBooked
Test-CannotCancelInnBookingWithStoredGear
Test-CanCancelInnBookingWhenStorageIsEmpty
Test-WorkOffRoomCoversNightAndBlocksRing
Test-CommonRoomStaysOpenUntilBackedOut
Test-InnRoomReturnToTownDoesNotRouteThroughStreets

Write-Host "Town inn tests passed." -ForegroundColor Green
