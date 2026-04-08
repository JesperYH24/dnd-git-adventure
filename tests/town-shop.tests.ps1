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
    $game.Town.MustChooseFirstInn = $true
    $inn = Get-TownInns | Where-Object { $_.Id -eq "lantern_rest" } | Select-Object -First 1

    $result = Resolve-InnStay -Game $game -HeroHP ([ref]$heroHP) -Inn $inn -EventRoll 99

    Assert-Equal -Actual $result -Expected $true -Message "The hero should be able to pay for an inn stay."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 300 -Message "Inn cost should be deducted from the gold pouch."
    Assert-Equal -Actual $heroHP -Expected $game.Hero.HP -Message "Inn stay should restore the hero to full HP."
    Assert-Equal -Actual $game.Town.ChapterOneComplete -Expected $true -Message "The first successful inn stay should complete chapter one."
    Assert-Equal -Actual $game.Town.MustChooseFirstInn -Expected $false -Message "The first inn stay should clear the forced-lodging flag."
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

function Test-ShopMentionsStashOrSellWhenFull {
    $game = Initialize-Game
    $hero = $game.Hero
    $hero.CurrencyCopper = 500
    $hero.Inventory += (New-WeaponItem -Name "Spare Pike" -Value 50 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "Two-Handed" -RequiredSTR 11 -SlotCost 3)
    $offer = Get-SmithyOffers | Where-Object { $_.Id -eq "smithy_longsword" } | Select-Object -First 1

    $result = Try-BuyTownOffer -Game $game -Hero $hero -Offer $offer

    Assert-Equal -Actual $result.Success -Expected $false -Message "Buying should fail when the hero is out of carrying room."
    Assert-True -Condition ($result.Message -like "*stash gear or sell equipment*") -Message "The shop failure should point the player toward stash or selling."
}

function Test-BentNailShadyInfoIsRemembered {
    $game = Initialize-Game

    Resolve-BentNailEveningChoice -Game $game -Choice "1"
    $relationshipBefore = $game.Town.Relationships["UnderstreetBroker"]
    Resolve-BentNailEveningChoice -Game $game -Choice "1" | Out-Null

    Assert-Equal -Actual $game.Town.InnFlags["BentNailBrokerInfo"] -Expected $true -Message "Bent Nail shady information should set a persistent inn flag."
    Assert-Equal -Actual $game.Town.Relationships["UnderstreetBroker"] -Expected $relationshipBefore -Message "Repeated Bent Nail rumor fishing should not unlock extra broker progress."
}

function Test-SilverKettleEconomicInfoSetsFutureHook {
    $game = Initialize-Game

    Resolve-SilverKettleEveningChoice -Game $game -Choice "1"

    Assert-Equal -Actual $game.Town.InnFlags["SilverKettleEconomicInsight"] -Expected $true -Message "Silver Kettle economic information should set a persistent inn flag."
    Assert-Equal -Actual $game.Town.QuestPayoutBonusCopper -Expected 20 -Message "Silver Kettle information should prime a future quest payout bonus."
}

function Test-InnkeeperGreetingChangesWithHeroStyle {
    $barbarian = Get-Hero
    $bard = Get-Hero
    $bard.Class = "Bard"
    $bard.CHA = 16
    $silverKettle = Get-TownInns | Where-Object { $_.Id -eq "silver_kettle" } | Select-Object -First 1

    $barbarianGreeting = Get-InnKeeperGreeting -Inn $silverKettle -Hero $barbarian
    $bardGreeting = Get-InnKeeperGreeting -Inn $silverKettle -Hero $bard

    Assert-True -Condition ($barbarianGreeting -like "*wolf invited into a ballroom*") -Message "Silver Kettle should greet a barbarian with a rougher tone."
    Assert-True -Condition ($bardGreeting -like "*understands the value of presentation*") -Message "Silver Kettle should greet a bard more warmly."
}

function Test-RingMasterRespectsPhysicalProwess {
    $barbarian = Get-Hero
    $rogueLikeHero = Get-Hero
    $rogueLikeHero.Class = "Rogue"
    $rogueLikeHero.STR = 10
    $rogueLikeHero.DEX = 16
    $rogueLikeHero.CON = 12

    $barbarianGreeting = Get-RingMasterGreeting -Hero $barbarian
    $rogueGreeting = Get-RingMasterGreeting -Hero $rogueLikeHero

    Assert-True -Condition ($barbarianGreeting -like "*Real shoulders, real lungs, real scars*") -Message "The ring master should admire strong and hardy heroes."
    Assert-True -Condition ($rogueGreeting -like "*Fast feet survive longer*") -Message "The ring master should notice quick fighters differently."
}

Set-TestOutputStubs

Test-HeroCanBuyFromTownShop
Test-HeroCannotBuyWithoutEnoughGold
Test-TownDiscountLowersShopPrice
Test-InnStayChargesGoldAndHealsHero
Test-StreetChoicesAreRemembered
Test-TownQuestCanBeAcceptedOnce
Test-RingTrainingUnlocksUnarmedBonus
Test-InnStayResetsDailyRingLockout
Test-StashCanStoreAndRetrieveGear
Test-CannotChooseNewInnWhileBooked
Test-CannotCancelInnBookingWithStoredGear
Test-CanCancelInnBookingWhenStorageIsEmpty
Test-ShopMentionsStashOrSellWhenFull
Test-BentNailShadyInfoIsRemembered
Test-SilverKettleEconomicInfoSetsFutureHook
Test-InnkeeperGreetingChangesWithHeroStyle
Test-RingMasterRespectsPhysicalProwess

Write-Host "Town shop tests passed." -ForegroundColor Green
