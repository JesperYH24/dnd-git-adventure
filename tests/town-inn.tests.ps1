. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

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

function Test-InnStayResetsDailyRingLockout {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.Ring.FoughtToday = $true
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99 | Out-Null

    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $false -Message "A full inn stay should reset the once-per-day ring lockout."
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

Test-InnStayChargesGoldAndHealsHero
Test-InnStayResetsDailyRingLockout
Test-StashCanStoreAndRetrieveGear
Test-CannotChooseNewInnWhileBooked
Test-CannotCancelInnBookingWithStoredGear
Test-CanCancelInnBookingWhenStorageIsEmpty

Write-Host "Town inn tests passed." -ForegroundColor Green
