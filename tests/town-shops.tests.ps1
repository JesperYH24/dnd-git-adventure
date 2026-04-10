. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-LevelThreeShopsUnlockBetterOffers {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    $market = @(Get-MarketOffers -Game $game)
    $smithy = @(Get-SmithyOffers -Game $game)
    $apothecary = @(Get-ApothecaryOffers -Game $game)

    Assert-True -Condition ($market.Id -contains "market_throwing_axe") -Message "Level 3 Borzig should see an upgraded market weapon offer."
    Assert-True -Condition ($smithy.Id -contains "smithy_executioner_axe") -Message "Level 3 Borzig should unlock a heavier smithy weapon offer."
    Assert-True -Condition ($apothecary.Id -contains "apothecary_battle_tonic") -Message "Level 3 Borzig should unlock a stronger apothecary tonic."
}

function Test-HeroCanBuyFromTownShop {
    $game = Initialize-Game
    $hero = $game.Hero
    $hero.CurrencyCopper = 200
    $offer = Get-SmithyOffers | Where-Object { $_.Id -eq "smithy_longsword" } | Select-Object -First 1

    $result = Try-BuyTownOffer -Game $game -Hero $hero -Offer $offer

    Assert-True -Condition $result.Success -Message "The hero should be able to buy an affordable shop item."
    Assert-Equal -Actual $hero.CurrencyCopper -Expected 20 -Message "Buying a 180 copper item should reduce the pouch correctly."
    Assert-True -Condition ([bool]($hero.Inventory | Where-Object { $_.Name -eq "Longsword" })) -Message "The purchased item should enter inventory."
}

function Test-HeroCannotBuyWithoutEnoughGold {
    $game = Initialize-Game
    $hero = $game.Hero
    $hero.CurrencyCopper = 50
    $offer = Get-ApothecaryOffers | Where-Object { $_.Id -eq "apothecary_haste_potion" } | Select-Object -First 1

    $result = Try-BuyTownOffer -Game $game -Hero $hero -Offer $offer

    Assert-Equal -Actual $result.Success -Expected $false -Message "The purchase should fail when the hero cannot afford it."
    Assert-Equal -Actual $hero.CurrencyCopper -Expected 50 -Message "Failed purchases should not change gold."
}

function Test-TownDiscountLowersShopPrice {
    $game = Initialize-Game
    $hero = $game.Hero
    $hero.CurrencyCopper = 260
    $offer = Get-SmithyOffers | Where-Object { $_.Id -eq "smithy_greataxe" } | Select-Object -First 1

    Set-TownOfferDiscount -Game $game -OfferId "smithy_greataxe" -DiscountCopper 60
    $result = Try-BuyTownOffer -Game $game -Hero $hero -Offer $offer

    Assert-Equal -Actual $result.Success -Expected $true -Message "The hero should be able to buy the discounted weapon."
    Assert-Equal -Actual $hero.CurrencyCopper -Expected 60 -Message "Discounted purchases should spend the lowered price."
}

function Test-ShopMentionsStashOrSellWhenFull {
    $game = Initialize-Game
    $hero = $game.Hero
    $hero.CurrencyCopper = 500
    $hero.Inventory += (New-WeaponItem -Name "Spare Pike" -Value 50 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "Two-Handed" -RequiredSTR 11 -SlotCost 3)
    $hero.BackpackInventory += (New-ArmorItem -Name "Packed Plates" -Value 30 -ArmorBonus 1 -SlotCost 2)
    $hero.BackpackInventory += (New-WeaponItem -Name "Packed Hammer" -Value 25 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -RequiredSTR 10 -SlotCost 2)
    $offer = Get-SmithyOffers | Where-Object { $_.Id -eq "smithy_longsword" } | Select-Object -First 1

    $result = Try-BuyTownOffer -Game $game -Hero $hero -Offer $offer

    Assert-Equal -Actual $result.Success -Expected $false -Message "Buying should fail when the hero is out of carrying room and backpack space."
    Assert-True -Condition ($result.Message -like "*stash gear*" -or $result.Message -like "*clear space in the backpack*") -Message "The shop failure should point the player toward stash, selling, or backpack space."
}

Test-HeroCanBuyFromTownShop
Test-HeroCannotBuyWithoutEnoughGold
Test-TownDiscountLowersShopPrice
Test-ShopMentionsStashOrSellWhenFull
Test-LevelThreeShopsUnlockBetterOffers

Write-Host "Town shop tests passed." -ForegroundColor Green
