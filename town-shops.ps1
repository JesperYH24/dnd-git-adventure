# Town shop logic, offers, and inn storage live here so buying and carrying gear stay together.
function New-TownOffer {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Category,
        [string]$Description,
        [int]$PriceCopper
    )

    return [PSCustomObject]@{
        Id = $Id
        Name = $Name
        Category = $Category
        Description = $Description
        PriceCopper = $PriceCopper
    }
}

function Get-TownInns {
    return @(
        [PSCustomObject]@{
            Id = "bent_nail"
            Name = "The Bent Nail"
            Keeper = "Marta One-Eye"
            PriceCopper = 80
            Quality = "Rough"
            Description = "Crooked shutters, patched blankets, and the smell of old smoke. Cheap, sturdy, and honest."
            KeeperText = "Marta squints across the counter. 'You pay little, you complain little, and you leave my floor cleaner than you found it.'"
            RestText = "The mattress sags, the walls creak, and someone snores through half the night, but Borzig still gets real shelter and a locked door."
        }
        [PSCustomObject]@{
            Id = "lantern_rest"
            Name = "The Lantern Rest"
            Keeper = "Oren Vale"
            PriceCopper = 200
            Quality = "Comfortable"
            Description = "Warm stew, clean sheets, and polished wood. It is the kind of inn built for traders and mercenaries with coin to spare."
            KeeperText = "Oren smooths his apron and bows his head. 'A fair bed, a hot meal, and no questions you don't want asked. That's what your coin buys here.'"
            RestText = "The room is calm, warm, and properly kept. {HeroName} sleeps deeply for the first time since the cave."
        }
        [PSCustomObject]@{
            Id = "silver_kettle"
            Name = "The Silver Kettle"
            Keeper = "Madam Seraphine"
            PriceCopper = 450
            Quality = "Refined"
            Description = "Soft carpets, spiced wine, and silver lamp-caps. Every detail announces comfort for those wealthy enough to expect it."
            KeeperText = "Madam Seraphine studies Borzig like a noble curiosity. 'If you are to recover under my roof, darling, you will do so in dignity.'"
            RestText = "Fresh linen, a copper bath, and silence thick as velvet leave Borzig feeling almost unreal by morning."
        }
    )
}

function Get-CheapestTownInn {
    return (Get-TownInns | Sort-Object PriceCopper | Select-Object -First 1)
}

function Format-InnHeroText {
    param(
        [string]$Text,
        $Hero
    )

    $heroName = if ($null -ne $Hero -and $null -ne $Hero.PSObject.Properties["Name"] -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Name)) {
        [string]$Hero.Name
    }
    else {
        "Borzig"
    }

    return $Text.Replace("{HeroName}", $heroName).Replace("Borzig", $heroName)
}

function Get-InnRepeatRestText {
    param(
        $Inn,
        $Hero = $null
    )

    switch ($Inn.Id) {
        "bent_nail" { return (Format-InnHeroText -Text "The room is rough but serviceable, and by now Borzig knows exactly which floorboards groan before sunrise." -Hero $Hero) }
        "lantern_rest" { return (Format-InnHeroText -Text "The room is calm, warm, and properly kept. {HeroName} settles in like a paying regular instead of a desperate traveler." -Hero $Hero) }
        "silver_kettle" { return (Format-InnHeroText -Text "Fresh linen, quiet service, and practiced comfort make the night feel expensive in all the ways Madam Seraphine intended." -Hero $Hero) }
        default { return (Format-InnHeroText -Text "The room offers shelter, privacy, and a night without interruption." -Hero $Hero) }
    }
}

function Set-TownOfferDiscount {
    param(
        $Game,
        [string]$OfferId,
        [int]$DiscountCopper
    )

    $Game.Town.Discounts[$OfferId] = $DiscountCopper
}

function Get-TownOfferPrice {
    param(
        $Game,
        $Offer
    )

    $discountCopper = 0

    if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.Discounts[$Offer.Id]) {
        $discountCopper = [int]$Game.Town.Discounts[$Offer.Id]
    }

    return [Math]::Max(0, $Offer.PriceCopper - $discountCopper)
}

function Get-MarketOffers {
    param($Game = $null)

    $offers = @(
        (New-TownOffer -Id "market_healing_potion" -Name "Healing Potion" -Category "Consumable" -Description "A simple red tonic that restores 8 HP." -PriceCopper 60)
        (New-TownOffer -Id "market_dagger" -Name "Dagger" -Category "Weapon" -Description "A light backup blade with a sharp edge and a quick draw. Requires DEX 11." -PriceCopper 90)
        (New-TownOffer -Id "market_handaxe" -Name "Hand Axe" -Category "Weapon" -Description "A practical one-handed axe for close quarters. Requires STR 11." -PriceCopper 140)
        (New-TownOffer -Id "market_stage_lute" -Name "Stage Lute" -Category "Utility" -Description "A better-balanced lute with clean tuning pegs and a richer body. Adds +2 inspiration instead of the rough travel standard." -PriceCopper 220)
    )

    if ($null -ne $Game -and $Game.Hero.Level -ge 3) {
        $offers += (New-TownOffer -Id "market_throwing_axe" -Name "Balanced Throwing Axe" -Category "Weapon" -Description "A clean-weighted axe light enough for quick work and vicious enough for a close finish. Requires STR 12." -PriceCopper 190)
    }

    return $offers
}

function Get-InstrumentShopOffers {
    param($Game = $null)

    $offers = @(
        (New-TownOffer -Id "instrument_shop_stage_lute" -Name "Stage Lute" -Category "Utility" -Description "A polished stage instrument with cleaner tuning and enough presence to carry a room. Adds +2 inspiration." -PriceCopper 220)
        (New-TownOffer -Id "instrument_shop_salon_lute" -Name "Salon Lute" -Category "Utility" -Description "A richer-bodied instrument made for refined rooms, private sets, and a bard who expects to be heard. Adds +3 inspiration." -PriceCopper 340)
    )

    if ($null -ne $Game -and $Game.Hero.Level -ge 3) {
        $offers += (New-TownOffer -Id "instrument_shop_court_lute" -Name "Court Lute" -Category "Utility" -Description "A fine-crafted instrument balanced for long play, upper rooms, and a performer with real city standing. Adds +4 inspiration." -PriceCopper 520)
    }

    return $offers
}

function Get-SmithyOffers {
    param($Game = $null)

    $offers = @(
        (New-TownOffer -Id "smithy_longsword" -Name "Longsword" -Category "Weapon" -Description "A balanced soldier's blade for dependable strikes. Requires STR 11." -PriceCopper 180)
        (New-TownOffer -Id "smithy_rapier" -Name "Rapier" -Category "Weapon" -Description "A quick, precise blade built for timing, nerve, and dexterous hands. Requires DEX 12." -PriceCopper 200)
        (New-TownOffer -Id "smithy_warhammer" -Name "Warhammer" -Category "Weapon" -Description "A brutal hammer built to crush armor and bone. Requires STR 13." -PriceCopper 220)
        (New-TownOffer -Id "smithy_greataxe" -Name "Steel Great Axe" -Category "Weapon" -Description "A heavier axe with a cleaner edge than Borzig's old camp weapon. Two-Handed. Requires STR 15." -PriceCopper 260)
    )

    if ($null -ne $Game -and $Game.Hero.Level -ge 3) {
        $offers += (New-TownOffer -Id "smithy_executioner_axe" -Name "Executioner Axe" -Category "Weapon" -Description "A broad-bladed two-handed axe forged for fighters with the strength to end a battle in one committed swing. Requires STR 16." -PriceCopper 420)
    }

    return $offers
}

function Get-ArmorerOffers {
    param($Game = $null)

    $offers = @(
        (New-TownOffer -Id "armorer_studded_leather" -Name "Studded Leather Coat" -Category "Armor" -Description "A reinforced leather coat that still lets quick fighters and performers move cleanly. AC +2 and adds DEX." -PriceCopper 260)
        (New-TownOffer -Id "armorer_chain_shirt" -Name "Chain Shirt" -Category "Armor" -Description "A practical shirt of linked steel for adventurers who want more protection without turning into a wall. AC +3 and adds DEX up to +2." -PriceCopper 380)
    )

    if ($null -ne $Game -and $Game.Hero.Level -ge 3) {
        $offers += (New-TownOffer -Id "armorer_brigandine" -Name "Brigandine Coat" -Category "Armor" -Description "Layered plates stitched into a hardened coat for veterans who expect ugly work. AC +4 and adds DEX up to +1." -PriceCopper 560)
    }

    return $offers
}

function Get-ApothecaryOffers {
    param($Game = $null)

    $offers = @(
        (New-TownOffer -Id "apothecary_healing_potion" -Name "Healing Potion" -Category "Consumable" -Description "A standard restorative draught for injured adventurers." -PriceCopper 60)
        (New-TownOffer -Id "apothecary_greater_healing_potion" -Name "Greater Healing Potion" -Category "Consumable" -Description "A stronger restorative blend that heals 12 HP." -PriceCopper 180)
        (New-TownOffer -Id "apothecary_haste_potion" -Name "Potion of Haste" -Category "Consumable" -Description "A silver-bright elixir that grants initiative advantage until rest or a new buff replaces it." -PriceCopper 300)
    )

    if ($null -ne $Game -and $Game.Hero.Level -ge 3) {
        $offers += (New-TownOffer -Id "apothecary_battle_tonic" -Name "Battle Tonic" -Category "Consumable" -Description "A dense black-red tonic that restores 18 HP and is sold only to fighters with a name." -PriceCopper 420)
    }

    return $offers
}

function New-TownItemFromOfferId {
    param([string]$OfferId)

    switch ($OfferId) {
        "market_healing_potion" { return (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1) }
        "market_dagger" { return (New-WeaponItem -Name "Dagger" -Value 90 -AttackBonus 2 -DamageDiceCount 1 -DamageDiceSides 4 -Handedness "One-Handed" -Light $true -RequiredDEX 11 -SlotCost 1) }
        "market_handaxe" { return (New-WeaponItem -Name "Hand Axe" -Value 140 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -Light $true -RequiredSTR 11 -SlotCost 1) }
        "market_stage_lute" { return (New-UtilityItem -Name "Stage Lute" -Value 220 -InspirationBonus 2 -SlotCost 1) }
        "market_throwing_axe" { return (New-WeaponItem -Name "Balanced Throwing Axe" -Value 190 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -Light $true -RequiredSTR 12 -SlotCost 1) }
        "instrument_shop_stage_lute" { return (New-UtilityItem -Name "Stage Lute" -Value 220 -InspirationBonus 2 -SlotCost 1) }
        "instrument_shop_salon_lute" { return (New-UtilityItem -Name "Salon Lute" -Value 340 -InspirationBonus 3 -SlotCost 1) }
        "instrument_shop_court_lute" { return (New-UtilityItem -Name "Court Lute" -Value 520 -InspirationBonus 4 -SlotCost 1) }
        "smithy_longsword" { return (New-WeaponItem -Name "Longsword" -Value 180 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredSTR 11 -SlotCost 2) }
        "smithy_rapier" { return (New-WeaponItem -Name "Rapier" -Value 200 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredDEX 12 -SlotCost 1) }
        "smithy_warhammer" { return (New-WeaponItem -Name "Warhammer" -Value 220 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 10 -Handedness "One-Handed" -RequiredSTR 13 -SlotCost 2) }
        "smithy_greataxe" { return (New-WeaponItem -Name "Steel Great Axe" -Value 260 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 15 -SlotCost 2) }
        "smithy_executioner_axe" { return (New-WeaponItem -Name "Executioner Axe" -Value 420 -AttackBonus 2 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 16 -SlotCost 2) }
        "armorer_studded_leather" { return (New-ArmorItem -Name "Studded Leather Coat" -Value 260 -ArmorBonus 2 -AddsDexModifier $true -SlotCost 2) }
        "armorer_chain_shirt" { return (New-ArmorItem -Name "Chain Shirt" -Value 380 -ArmorBonus 3 -AddsDexModifier $true -DexBonusCap 2 -SlotCost 3) }
        "armorer_brigandine" { return (New-ArmorItem -Name "Brigandine Coat" -Value 560 -ArmorBonus 4 -AddsDexModifier $true -DexBonusCap 1 -SlotCost 3) }
        "apothecary_healing_potion" { return (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1) }
        "apothecary_greater_healing_potion" { return (New-ConsumableItem -Name "Greater Healing Potion" -Value 180 -HealAmount 12 -SlotCost 1) }
        "apothecary_haste_potion" { return (New-ConsumableItem -Name "Potion of Haste" -Value 300 -HealAmount 0 -BuffType "Haste" -BuffName "Potion of Haste" -InitiativeAdvantage $true -SlotCost 1) }
        "apothecary_battle_tonic" { return (New-ConsumableItem -Name "Battle Tonic" -Value 420 -HealAmount 18 -SlotCost 1) }
        default { return $null }
    }
}

function Get-TownBuyerLabel {
    param([string]$BuyerType)

    switch ($BuyerType) {
        "GeneralBuyer" { return "Town Buyer" }
        "Market" { return "Market Trader" }
        "InstrumentShop" { return "Instrument Maker" }
        "Smithy" { return "Smith" }
        "Armorer" { return "Armorer" }
        "Apothecary" { return "Apothecary" }
        default { return "Trader" }
    }
}

function Get-TownBuyerIntroText {
    param(
        [string]$BuyerType,
        $Game = $null
    )

    $isNight = $null -ne $Game -and (Get-TownTimeOfDay -Game $Game) -eq "Night"
    $heroName = if ($null -ne $Game -and $null -ne $Game.Hero) { [string]$Game.Hero.Name } else { "the hero" }

    switch ($BuyerType) {
        "GeneralBuyer" {
            if ($isNight) { return "The quartermaster works more quietly at night, weighing gear by lamplight and quoting prices with the tired efficiency reserved for late business and people who need coin before dawn." }
            return "A calm-eyed quartermaster weighs every piece $heroName lays down and quotes a fair working price without much drama. Even he gives the rough cave-worn gear an extra second look before naming coin."
        }
        "Market" {
            if ($isNight) { return "The market trader keeps one late table open for night business, moving goods fast and paying less for anything too bulky, too bloody, or too difficult to explain after dark." }
            return "The market trader turns goods over quickly, happy with tonics and travel-ready stock but much less impressed by heavy battlefield gear. Rusted cave salvage gets a skeptical sniff before the price comes out."
        }
        "InstrumentShop" {
            if ($isNight) { return "The instrument maker judges trade-ins by lamplight, listening for hidden cracks and bad repairs in the hush after the city's louder rooms have filled." }
            return "The instrument maker checks wood, strings, balance, and finish with the severity of someone who thinks bad care is a moral failure. Fine instruments and performer gear get the best attention here."
        }
        "Smithy" {
            if ($isNight) { return "At night the smith checks balance, grip, and metal with fewer words and less patience. Late steel trade usually means somebody expects to need the coin or the gear fast." }
            return "The smith checks balance, grip, and metal first. Weapons and armor interest the forge. Potions do not. Anything dragged out of the tutorial cave gets judged hard for chips, rust, and poor temper."
        }
        "Armorer" {
            if ($isNight) { return "The armorer inspects straps, stitching, and battered plates under close lamp-light, the way only people used to emergency repairs after dusk ever learn to do." }
            return "The armorer runs a hard eye over straps, stitching, dented plates, and any sign that the city has been trusting bad leather too long. Armor, field gear, and sturdy coats are worth real coin here."
        }
        "Apothecary" {
            if ($isNight) { return "The apothecary handles late trade like triage, studying bottles and sealed mixtures with tired care while clearly wishing fewer customers needed remedies after dark." }
            return "The apothecary studies bottles, herbs, and sealed mixtures with care, but shows little enthusiasm for bloody steel. Cave loot that smells of damp stone and old blood clearly is not a favorite."
        }
        default { return "A trader looks over $heroName's gear and starts naming coin." }
    }
}

function Get-SaleAffinityMultiplier {
    param(
        [string]$BuyerType,
        $Item
    )

    switch ($BuyerType) {
        "GeneralBuyer" { return 0.5 }
        "Market" {
            if ($Item.Type -eq "Consumable") { return 0.5 }
            if ($Item.Type -eq "Utility" -or $Item.Type -eq "Junk") { return 0.45 }
            return 0.35
        }
        "InstrumentShop" {
            if ($Item.Type -eq "Utility") { return 0.5 }
            if ($Item.Type -eq "Armor") { return 0.35 }
            return 0.25
        }
        "Smithy" {
            if ($Item.Type -in @("Weapon", "Armor")) { return 0.5 }
            return 0.3
        }
        "Armorer" {
            if ($Item.Type -eq "Armor") { return 0.5 }
            if ($Item.Type -eq "Utility") { return 0.4 }
            return 0.3
        }
        "Apothecary" {
            if ($Item.Type -eq "Consumable") { return 0.5 }
            return 0.3
        }
        default { return 0.4 }
    }
}

function Get-SaleValueForBuyer {
    param(
        [string]$BuyerType,
        $Item
    )

    $itemValue = 0

    if ($null -ne $Item.PSObject.Properties["Value"]) {
        $itemValue = [int]$Item.Value
    }

    $multiplier = Get-SaleAffinityMultiplier -BuyerType $BuyerType -Item $Item
    return [Math]::Max(1, [Math]::Floor($itemValue * $multiplier))
}

function Get-SellableHeroItems {
    param($Hero)

    $sellableItems = @()

    for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
        $item = $Hero.Inventory[$i]

        if ($item.Type -eq "Currency") {
            continue
        }

        if ($item.Type -eq "Utility" -and $item.Name -eq "Backpack" -and (Get-BackpackUsedSlots -Hero $Hero) -gt 0) {
            continue
        }

        $sellableItems += [PSCustomObject]@{
            Storage = "Inventory"
            Index = $i
            Item = $item
        }
    }

    for ($i = 0; $i -lt $Hero.BackpackInventory.Count; $i++) {
        $item = $Hero.BackpackInventory[$i]

        if ($item.Type -eq "Currency") {
            continue
        }

        $sellableItems += [PSCustomObject]@{
            Storage = "Backpack"
            Index = $i
            Item = $item
        }
    }

    return $sellableItems
}

function Complete-SaleToBuyer {
    param(
        $Hero,
        $Entry,
        [string]$BuyerType
    )

    $item = $Entry.Item
    $saleValue = Get-SaleValueForBuyer -BuyerType $BuyerType -Item $item

    if ($null -ne $item.PSObject.Properties["Equipped"]) {
        $item.Equipped = $false
    }

    Add-HeroCurrency -Hero $Hero -Denomination "CP" -Amount $saleValue | Out-Null

    if ($Entry.Storage -eq "Inventory") {
        Remove-InventoryItemAt -Hero $Hero -Index $Entry.Index
    }
    else {
        Remove-BackpackItemAt -Hero $Hero -Index $Entry.Index
    }

    return $saleValue
}

function Try-BuyTownOffer {
    param(
        $Game,
        $Hero,
        $Offer
    )

    $item = New-TownItemFromOfferId -OfferId $Offer.Id

    if ($null -eq $item) {
        return [PSCustomObject]@{
            Success = $false
            Message = "That item is not available."
        }
    }

    if (-not (Can-HeroCarryItem -Hero $Hero -Item $item) -and -not (Can-HeroStoreItemInBackpack -Hero $Hero -Item $item)) {
        return [PSCustomObject]@{
            Success = $false
            SpaceIssue = $true
            Message = "$($Hero.Name) does not have enough room for $($item.Name). Visit the inn to stash gear, sell equipment, or clear space in the backpack."
        }
    }

    $finalPriceCopper = Get-TownOfferPrice -Game $Game -Offer $Offer
    $spendResult = Spend-HeroCurrency -Hero $Hero -Copper $finalPriceCopper

    if (-not $spendResult.Success) {
        return [PSCustomObject]@{
            Success = $false
            SpaceIssue = $false
            Message = "$($Hero.Name) cannot afford $($item.Name)."
        }
    }

    $storeResult = Add-ItemToHeroStorage -Hero $Hero -Item $item

    $priceText = Convert-CopperToCurrencyText -Copper $finalPriceCopper
    $discountText = ""
    $carryText = if ($storeResult.Location -eq "Backpack") { " and stows it in the backpack" } else { "" }

    if ($finalPriceCopper -lt $Offer.PriceCopper) {
        $discountText = " after a local recommendation lowers the price"
    }

    return [PSCustomObject]@{
        Success = $true
        SpaceIssue = $false
        Item = $item
        Message = "$($Hero.Name) buys $($item.Name) for $priceText$discountText$carryText."
    }
}

function Show-TownShop {
    param(
        [string]$Title,
        [string]$IntroText,
        $Game,
        $Hero,
        [object[]]$Offers,
        [string]$BuyerType = "GeneralBuyer"
    )

    $showIntro = $true

    while ($true) {
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area $Title
        if ($showIntro) {
            Write-Scene $IntroText
            $showIntro = $false
        }
        Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Hero)" "DarkYellow"
        Write-ColorLine "Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "DarkCyan"
        Write-ColorLine ""

        for ($i = 0; $i -lt $Offers.Count; $i++) {
            $offer = $Offers[$i]
            $priceText = Convert-CopperToCurrencyText -Copper (Get-TownOfferPrice -Game $Game -Offer $offer)
            Write-ColorLine "$($i + 1). $($offer.Name) - $priceText" "White"
            Write-ColorLine "   $($offer.Description)" "DarkGray"
        }

        Write-ColorLine ""
        Write-ColorLine "S. Sell gear" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "S") {
            Open-TownSellMenu -Game $Game -Hero $Hero -BuyerType $BuyerType
            continue
        }

        if ($choice -eq "0") {
            return
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose a listed number." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $Offers.Count) {
            Write-ColorLine "That offer is not available." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $result = Try-BuyTownOffer -Game $Game -Hero $Hero -Offer $Offers[$index]
        Write-Scene $result.Message

        if (-not $result.Success -and $result.SpaceIssue) {
            $buyerLabel = Get-TownBuyerLabel -BuyerType $BuyerType
            $sellChoice = (Read-Host "Sell gear to the $buyerLabel to make room? (Y/N)").ToUpper()

            if ($sellChoice -eq "Y") {
                Open-TownSellMenu -Game $Game -Hero $Hero -BuyerType $BuyerType -ExitLabel "Back to shop"
            }
        }

        Write-ColorLine ""
    }
}

function Open-TownSellMenu {
    param(
        $Game,
        $Hero,
        [string]$BuyerType = "GeneralBuyer",
        [string]$ExitLabel = "Back to town"
    )

    $showIntro = $true

    while ($true) {
        $buyerLabel = Get-TownBuyerLabel -BuyerType $BuyerType
        Write-SectionTitle -Text "Sell to $buyerLabel" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Sell Gear"
        if ($showIntro) {
            Write-Scene (Get-TownBuyerIntroText -BuyerType $BuyerType -Game $Game)
            Write-ColorLine ""
            $showIntro = $false
        }

        $sellableItems = @(Get-SellableHeroItems -Hero $Hero)

        if ($sellableItems.Count -eq 0) {
            Write-ColorLine "$($Hero.Name) has nothing worth selling." "DarkGray"
            Write-ColorLine ""
            return
        }

        for ($i = 0; $i -lt $sellableItems.Count; $i++) {
            $entry = $sellableItems[$i]
            $saleValue = Get-SaleValueForBuyer -BuyerType $BuyerType -Item $entry.Item
            $storageLabel = if ($entry.Storage -eq "Backpack") { "backpack" } else { "on hand" }
            Write-ColorLine "$($i + 1). $(Format-InventoryItemLine -Item $entry.Item) - $storageLabel - sells for $(Convert-CopperToCurrencyText -Copper $saleValue)" "White"
        }

        Write-ColorLine ""
        Write-ColorLine "0. $ExitLabel" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose a listed number." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $selected = [int]$choice - 1

        if ($selected -lt 0 -or $selected -ge $sellableItems.Count) {
            Write-ColorLine "That item is not available." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $entry = $sellableItems[$selected]
        $item = $entry.Item
        $saleValue = Complete-SaleToBuyer -Hero $Hero -Entry $entry -BuyerType $BuyerType
        Write-Scene "$($Hero.Name) sells $($item.Name) for $(Convert-CopperToCurrencyText -Copper $saleValue)."
        Write-ColorLine ""
    }
}

function Show-HeroStash {
    param($Hero)

    Write-SectionTitle -Text "Inn Storage" -Color "Yellow"

    if (-not $Hero.StashedInventory -or $Hero.StashedInventory.Count -eq 0) {
        Write-ColorLine "Nothing is stored here yet." "DarkGray"
        Write-ColorLine ""
        return
    }

    for ($i = 0; $i -lt $Hero.StashedInventory.Count; $i++) {
        Write-ColorLine "$($i + 1). $(Format-InventoryItemLine -Item $Hero.StashedInventory[$i])" "White"
    }

    Write-ColorLine ""
}

function Move-InventoryItemToStash {
    param(
        $Hero,
        [int]$InventoryIndex
    )

    $item = $Hero.Inventory[$InventoryIndex]

    if ($item.Type -eq "Utility" -and $item.Name -eq "Backpack" -and (Get-BackpackUsedSlots -Hero $Hero) -gt 0) {
        Write-Scene "$($Hero.Name) cannot stash the backpack while it still holds gear."
        return
    }

    if ($null -ne $item.PSObject.Properties["Equipped"]) {
        $item.Equipped = $false
    }

    $Hero.StashedInventory += $item
    Remove-InventoryItemAt -Hero $Hero -Index $InventoryIndex
    Write-Scene "$($Hero.Name) leaves $($item.Name) in the inn chest."
}

function Retrieve-StashedItem {
    param(
        $Hero,
        [int]$StashIndex
    )

    $item = $Hero.StashedInventory[$StashIndex]

    if (-not (Can-HeroCarryItem -Hero $Hero -Item $item) -and -not (Can-HeroStoreItemInBackpack -Hero $Hero -Item $item)) {
        Write-Scene "$($Hero.Name) does not have enough room to carry or stow $($item.Name) right now."
        return $false
    }

    $storeResult = Add-ItemToHeroStorage -Hero $Hero -Item $item
    $Hero.StashedInventory = @(
        for ($i = 0; $i -lt $Hero.StashedInventory.Count; $i++) {
            if ($i -ne $StashIndex) {
                $Hero.StashedInventory[$i]
            }
        }
    )
    if ($storeResult.Location -eq "Backpack") {
        Write-Scene "$($Hero.Name) takes $($item.Name) back from storage and packs it away."
    }
    else {
        Write-Scene "$($Hero.Name) takes $($item.Name) back from storage."
    }
    return $true
}

function Start-InnStorageMenu {
    param(
        $Game,
        $Hero
    )

    while ($true) {
        Write-SectionTitle -Text "Manage Storage" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Storage"
        Write-Scene "A lockbox and a travel chest sit under the bed, ready to hold whatever $($Hero.Name) does not want to carry through the city."
        Write-ColorLine "Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "DarkCyan"
        Write-ColorLine ""
        Write-ColorLine "1. Store gear from inventory" "White"
        Write-ColorLine "2. Retrieve stored gear" "White"
        Write-ColorLine "3. View stored gear" "White"
        Write-ColorLine "0. Back to inn room" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Show-Inventory -Hero $Hero

                if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
                    continue
                }

                $itemChoice = Read-Host "Store which item number (0 to cancel)"

                if ($itemChoice -eq "0") {
                    continue
                }

                if ($itemChoice -notmatch '^\d+$') {
                    Write-ColorLine "Choose a listed number." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                $index = [int]$itemChoice - 1

                if ($index -lt 0 -or $index -ge $Hero.Inventory.Count) {
                    Write-ColorLine "That item is not available." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Move-InventoryItemToStash -Hero $Hero -InventoryIndex $index
                Write-ColorLine ""
            }
            "2" {
                Show-HeroStash -Hero $Hero

                if (-not $Hero.StashedInventory -or $Hero.StashedInventory.Count -eq 0) {
                    continue
                }

                $itemChoice = Read-Host "Retrieve which item number (0 to cancel)"

                if ($itemChoice -eq "0") {
                    continue
                }

                if ($itemChoice -notmatch '^\d+$') {
                    Write-ColorLine "Choose a listed number." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                $index = [int]$itemChoice - 1

                if ($index -lt 0 -or $index -ge $Hero.StashedInventory.Count) {
                    Write-ColorLine "That item is not available." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Retrieve-StashedItem -Hero $Hero -StashIndex $index | Out-Null
                Write-ColorLine ""
            }
            "3" {
                Show-HeroStash -Hero $Hero
            }
            "0" {
                return
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}


