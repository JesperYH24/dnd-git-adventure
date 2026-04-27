. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-LevelThreeShopsUnlockBetterOffers {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3

    $market = @(Get-MarketOffers -Game $game)
    $instrumentShop = @(Get-InstrumentShopOffers -Game $game)
    $smithy = @(Get-SmithyOffers -Game $game)
    $armorer = @(Get-ArmorerOffers -Game $game)
    $apothecary = @(Get-ApothecaryOffers -Game $game)

    Assert-True -Condition ($market.Id -contains "market_throwing_axe") -Message "Level 3 Borzig should see an upgraded market weapon offer."
    Assert-True -Condition ($instrumentShop.Id -contains "instrument_shop_court_lute") -Message "Level 3 bards should unlock a finer instrument tier in the instrument shop."
    Assert-True -Condition ($smithy.Id -contains "smithy_executioner_axe") -Message "Level 3 Borzig should unlock a heavier smithy weapon offer."
    Assert-True -Condition ($armorer.Id -contains "armorer_brigandine") -Message "Level 3 heroes should unlock the heavier armorer coat."
    Assert-True -Condition ($apothecary.Id -contains "apothecary_battle_tonic") -Message "Level 3 Borzig should unlock a stronger apothecary tonic."
}

function Test-MarketStocksAnInstrumentUpgradeForBards {
    $game = Initialize-Game -Class "Bard"
    $offers = @(Get-MarketOffers -Game $game)
    $stageLuteOffer = $offers | Where-Object { $_.Id -eq "market_stage_lute" } | Select-Object -First 1

    Assert-True -Condition ($null -ne $stageLuteOffer) -Message "The market should stock an upgraded instrument for bard characters."

    $item = New-TownItemFromOfferId -OfferId "market_stage_lute"

    Assert-Equal -Actual $item.Type -Expected "Utility" -Message "The Stage Lute should be created as a utility item."
    Assert-Equal -Actual $item.InspirationBonus -Expected 2 -Message "The Stage Lute should improve bardic inspiration more than the starting lute."
}

function Test-DedicatedBuyerMatchesSpecialistForOwnGoods {
    $potion = New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1
    $weapon = New-WeaponItem -Name "Longsword" -Value 180 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredSTR 11 -SlotCost 2
    $instrument = New-UtilityItem -Name "Stage Lute" -Value 220 -InspirationBonus 2 -SlotCost 1
    $armor = New-ArmorItem -Name "Studded Leather Coat" -Value 260 -ArmorBonus 2 -AddsDexModifier $true -SlotCost 2

    Assert-Equal -Actual (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $potion) -Expected (Get-SaleValueForBuyer -BuyerType "Apothecary" -Item $potion) -Message "The apothecary should match the dedicated buyer for potions."
    Assert-Equal -Actual (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $weapon) -Expected (Get-SaleValueForBuyer -BuyerType "Smithy" -Item $weapon) -Message "The smith should match the dedicated buyer for weapons."
    Assert-Equal -Actual (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $instrument) -Expected (Get-SaleValueForBuyer -BuyerType "InstrumentShop" -Item $instrument) -Message "The instrument maker should match the dedicated buyer for bard gear."
    Assert-Equal -Actual (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $armor) -Expected (Get-SaleValueForBuyer -BuyerType "Armorer" -Item $armor) -Message "The armorer should match the dedicated buyer for armor."
}

function Test-OffSpecialtyBuyersPayLess {
    $potion = New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1
    $weapon = New-WeaponItem -Name "Longsword" -Value 180 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredSTR 11 -SlotCost 2
    $instrument = New-UtilityItem -Name "Stage Lute" -Value 220 -InspirationBonus 2 -SlotCost 1
    $armor = New-ArmorItem -Name "Studded Leather Coat" -Value 260 -ArmorBonus 2 -AddsDexModifier $true -SlotCost 2

    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "Smithy" -Item $potion) -lt (Get-SaleValueForBuyer -BuyerType "Apothecary" -Item $potion)) -Message "The smith should pay less for potions than the apothecary."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "Apothecary" -Item $weapon) -lt (Get-SaleValueForBuyer -BuyerType "Smithy" -Item $weapon)) -Message "The apothecary should pay less for weapons than the smith."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "Market" -Item $instrument) -lt (Get-SaleValueForBuyer -BuyerType "InstrumentShop" -Item $instrument)) -Message "The market should pay less for instruments than the instrument maker."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $armor) -gt (Get-SaleValueForBuyer -BuyerType "Apothecary" -Item $armor)) -Message "The apothecary should pay less for armor than a normal town buyer."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "Apothecary" -Item $armor) -lt (Get-SaleValueForBuyer -BuyerType "Armorer" -Item $armor)) -Message "The armorer should pay better for armor than a clearly wrong buyer."
}

function Test-NewSpecialtyShopsStockRealClassGear {
    $bardGame = Initialize-Game -Class "Bard"
    $fighterGame = Initialize-Game -Class "Barbarian"

    $instrumentOffers = @(Get-InstrumentShopOffers -Game $bardGame)
    $armorerOffers = @(Get-ArmorerOffers -Game $fighterGame)
    $salonLute = New-TownItemFromOfferId -OfferId "instrument_shop_salon_lute"
    $chainShirt = New-TownItemFromOfferId -OfferId "armorer_chain_shirt"

    Assert-True -Condition ($instrumentOffers.Id -contains "instrument_shop_stage_lute") -Message "The instrument shop should stock the bard's first proper upgrade."
    Assert-True -Condition ($instrumentOffers.Id -contains "instrument_shop_salon_lute") -Message "The instrument shop should carry a stronger salon-grade lute."
    Assert-True -Condition ($armorerOffers.Id -contains "armorer_studded_leather") -Message "The armorer should stock mobile leather protection."
    Assert-True -Condition ($armorerOffers.Id -contains "armorer_chain_shirt") -Message "The armorer should stock a mid-tier chain option."
    Assert-Equal -Actual $salonLute.InspirationBonus -Expected 3 -Message "The salon lute should grant a larger inspiration bonus than the stage lute."
    Assert-Equal -Actual $chainShirt.ArmorBonus -Expected 3 -Message "The chain shirt should provide its advertised armor bonus."
    Assert-Equal -Actual $chainShirt.DexBonusCap -Expected 2 -Message "The chain shirt should cap added dexterity as intended."
}

function Test-TutorialLootHasUsefulButModestSaleValue {
    $skeletonLoot = Get-MonsterLoot -Monster @{ name = "skeleton" }
    $goblinLoot = Get-MonsterLoot -Monster @{ name = "goblin" }
    $zombieLoot = Get-MonsterLoot -Monster @{ name = "zombie" }
    $ratLoot = Get-MonsterLoot -Monster @{ name = "giant rat" }

    $rustySword = $skeletonLoot | Where-Object { $_.Name -eq "Rusty Sword" } | Select-Object -First 1
    $dagger = $goblinLoot | Where-Object { $_.Name -eq "Dagger" } | Select-Object -First 1
    $smallPotion = $goblinLoot | Where-Object { $_.Name -eq "Small Healing Potion" } | Select-Object -First 1
    $scraps = $zombieLoot | Where-Object { $_.Name -eq "Rotten Armor Scraps" } | Select-Object -First 1
    $tail = $ratLoot | Where-Object { $_.Name -eq "Rat Tail" } | Select-Object -First 1

    $totalGeneralSale = `
        (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $rustySword) + `
        (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $dagger) + `
        (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $smallPotion) + `
        (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $scraps) + `
        (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $tail)

    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $rustySword) -gt 1) -Message "Rusty Sword should now sell for more than token coin."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $dagger) -gt 1) -Message "Goblin dagger should feel worth carrying home."
    Assert-True -Condition ($totalGeneralSale -ge 25 -and $totalGeneralSale -le 40) -Message "Tutorial loot should be worth carrying without breaking the city's early economy."
}

function Test-DocksideOdditiesPaysWellForJunk {
    $junk = [PSCustomObject]@{
        Name = "Cracked Basilisk Scale"
        Type = "Junk"
        Value = 40
        SlotCost = 1
    }
    $weapon = New-WeaponItem -Name "Rusty Knife" -Value 40 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 4 -Handedness "One-Handed" -RequiredSTR 8 -SlotCost 1

    Assert-Equal -Actual (Get-TownBuyerLabel -BuyerType "DocksideOddities") -Expected "Rag-and-Bone Collector" -Message "The docks oddity shop should have its own buyer label."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "DocksideOddities" -Item $junk) -gt (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $junk)) -Message "Auntie Brindle should pay better than normal buyers for strange junk."
    Assert-True -Condition ((Get-SaleValueForBuyer -BuyerType "DocksideOddities" -Item $weapon) -le (Get-SaleValueForBuyer -BuyerType "GeneralBuyer" -Item $weapon)) -Message "The oddity shop should not outpay normal buyers for ordinary weapons."
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
    $hero.Inventory += (New-WeaponItem -Name "Spare Pike" -Value 50 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "Two-Handed" -RequiredSTR 11 -SlotCost 4)
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
Test-MarketStocksAnInstrumentUpgradeForBards
Test-DedicatedBuyerMatchesSpecialistForOwnGoods
Test-OffSpecialtyBuyersPayLess
Test-NewSpecialtyShopsStockRealClassGear
Test-TutorialLootHasUsefulButModestSaleValue
Test-DocksideOdditiesPaysWellForJunk

Write-Host "Town shop tests passed." -ForegroundColor Green
