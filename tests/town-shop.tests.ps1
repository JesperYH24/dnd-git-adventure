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

function Test-InnStayChargesGoldAndHealsHero {
    $game = Initialize-Game
    $heroHP = 3
    $game.Hero.CurrencyCopper = 500
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    $result = Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99

    Assert-Equal -Actual $result -Expected $true -Message "The hero should be able to pay for an inn stay."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 300 -Message "Inn cost should be deducted from the gold pouch."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Inn stay should restore the hero to full HP."
    Assert-Equal -Actual $game.Town.ChapterOneComplete -Expected $true -Message "The first successful inn stay should complete chapter one."
}

function Test-StreetChoicesAreRemembered {
    $game = Initialize-Game

    $first = Resolve-HadrikChoice -Game $game -Choice "2"
    $second = Resolve-HadrikChoice -Game $game -Choice "1"

    Assert-True -Condition ($first -like "*Your loss*") -Message "The first declined smith conversation should store the refusal."
    Assert-True -Condition ($second -like "*Already told you*") -Message "The second smith conversation should not grant a late discount."
    Assert-True -Condition (-not [bool]$game.Town.StreetFlags["SmithyDiscountUnlocked"]) -Message "Declining the first time should permanently forfeit the smith discount."
}

function Test-TownQuestCanBeAcceptedOnce {
    $game = Initialize-Game

    $first = Accept-TownQuest -Game $game -QuestId "guard_night_watch"
    $second = Accept-TownQuest -Game $game -QuestId "guard_night_watch"
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $first.Success -Expected $true -Message "A new town quest should be accepted the first time."
    Assert-Equal -Actual $second.Success -Expected $false -Message "The same town quest should not be accepted twice."
    Assert-Equal -Actual $quest.Accepted -Expected $true -Message "Accepted quests should stay marked in the quest log."
}

function Test-RingTrainingUnlocksUnarmedBonus {
    $game = Initialize-Game
    $before = Get-HeroUnarmedProfile -Hero $game.Hero

    $partial = Grant-RingTraining -Hero $game.Hero -Wins 6
    $training = Grant-RingTraining -Hero $game.Hero -Wins 4
    $after = Get-HeroUnarmedProfile -Hero $game.Hero

    Assert-Equal -Actual $partial.Unlocked -Expected $false -Message "Six ring wins should still be too few to unlock unarmed training."
    Assert-Equal -Actual $training.Unlocked -Expected $true -Message "Ten total ring wins should unlock the first unarmed training tier."
    Assert-Equal -Actual $after.TotalAttackBonus -Expected ($before.TotalAttackBonus + 1) -Message "Unarmed training should raise hit chance by 1."
    Assert-Equal -Actual $after.DamageBonus -Expected ($before.DamageBonus + 1) -Message "Unarmed training should raise bare-hand damage by 1."
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

Test-HeroCanBuyFromTownShop
Test-HeroCannotBuyWithoutEnoughGold
Test-TownDiscountLowersShopPrice
Test-InnStayChargesGoldAndHealsHero
Test-StreetChoicesAreRemembered
Test-TownQuestCanBeAcceptedOnce
Test-RingTrainingUnlocksUnarmedBonus
Test-InnStayResetsDailyRingLockout

Write-Host "Town shop tests passed." -ForegroundColor Green
