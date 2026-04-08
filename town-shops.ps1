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
            RestText = "The room is calm, warm, and properly kept. Borzig sleeps deeply for the first time since the cave."
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

function Get-InnRepeatRestText {
    param($Inn)

    switch ($Inn.Id) {
        "bent_nail" { return "The room is rough but serviceable, and by now Borzig knows exactly which floorboards groan before sunrise." }
        "lantern_rest" { return "The room is calm, warm, and properly kept. Borzig settles in like a paying regular instead of a desperate traveler." }
        "silver_kettle" { return "Fresh linen, quiet service, and practiced comfort make the night feel expensive in all the ways Madam Seraphine intended." }
        default { return "The room offers shelter, privacy, and a night without interruption." }
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
    return @(
        (New-TownOffer -Id "market_healing_potion" -Name "Healing Potion" -Category "Consumable" -Description "A simple red tonic that restores 8 HP." -PriceCopper 60)
        (New-TownOffer -Id "market_dagger" -Name "Dagger" -Category "Weapon" -Description "A light backup blade with a sharp edge and a quick draw. Requires DEX 11." -PriceCopper 90)
        (New-TownOffer -Id "market_handaxe" -Name "Hand Axe" -Category "Weapon" -Description "A practical one-handed axe for close quarters. Requires STR 11." -PriceCopper 140)
    )
}

function Get-SmithyOffers {
    return @(
        (New-TownOffer -Id "smithy_longsword" -Name "Longsword" -Category "Weapon" -Description "A balanced soldier's blade for dependable strikes. Requires STR 11." -PriceCopper 180)
        (New-TownOffer -Id "smithy_warhammer" -Name "Warhammer" -Category "Weapon" -Description "A brutal hammer built to crush armor and bone. Requires STR 13." -PriceCopper 220)
        (New-TownOffer -Id "smithy_greataxe" -Name "Steel Great Axe" -Category "Weapon" -Description "A heavier axe with a cleaner edge than Borzig's old camp weapon. Two-Handed. Requires STR 15." -PriceCopper 260)
    )
}

function Get-ApothecaryOffers {
    return @(
        (New-TownOffer -Id "apothecary_healing_potion" -Name "Healing Potion" -Category "Consumable" -Description "A standard restorative draught for injured adventurers." -PriceCopper 60)
        (New-TownOffer -Id "apothecary_greater_healing_potion" -Name "Greater Healing Potion" -Category "Consumable" -Description "A stronger restorative blend that heals 12 HP." -PriceCopper 180)
        (New-TownOffer -Id "apothecary_haste_potion" -Name "Potion of Haste" -Category "Consumable" -Description "A silver-bright elixir that grants initiative advantage until rest or a new buff replaces it." -PriceCopper 300)
    )
}

function New-TownItemFromOfferId {
    param([string]$OfferId)

    switch ($OfferId) {
        "market_healing_potion" { return (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1) }
        "market_dagger" { return (New-WeaponItem -Name "Dagger" -Value 90 -AttackBonus 2 -DamageDiceCount 1 -DamageDiceSides 4 -Handedness "One-Handed" -Light $true -RequiredDEX 11 -SlotCost 1) }
        "market_handaxe" { return (New-WeaponItem -Name "Hand Axe" -Value 140 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 6 -Handedness "One-Handed" -Light $true -RequiredSTR 11 -SlotCost 1) }
        "smithy_longsword" { return (New-WeaponItem -Name "Longsword" -Value 180 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -Handedness "One-Handed" -RequiredSTR 11 -SlotCost 2) }
        "smithy_warhammer" { return (New-WeaponItem -Name "Warhammer" -Value 220 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 10 -Handedness "One-Handed" -RequiredSTR 13 -SlotCost 2) }
        "smithy_greataxe" { return (New-WeaponItem -Name "Steel Great Axe" -Value 260 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 15 -SlotCost 2) }
        "apothecary_healing_potion" { return (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1) }
        "apothecary_greater_healing_potion" { return (New-ConsumableItem -Name "Greater Healing Potion" -Value 180 -HealAmount 12 -SlotCost 1) }
        "apothecary_haste_potion" { return (New-ConsumableItem -Name "Potion of Haste" -Value 300 -HealAmount 0 -BuffType "Haste" -BuffName "Potion of Haste" -InitiativeAdvantage $true -SlotCost 1) }
        default { return $null }
    }
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

    if (-not (Can-HeroCarryItem -Hero $Hero -Item $item)) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) does not have enough room for $($item.Name). Visit the inn to stash gear or sell equipment to make space."
        }
    }

    $finalPriceCopper = Get-TownOfferPrice -Game $Game -Offer $Offer
    $spendResult = Spend-HeroCurrency -Hero $Hero -Copper $finalPriceCopper

    if (-not $spendResult.Success) {
        return [PSCustomObject]@{
            Success = $false
            Message = "$($Hero.Name) cannot afford $($item.Name)."
        }
    }

    $Hero.Inventory += $item

    $priceText = Convert-CopperToCurrencyText -Copper $finalPriceCopper
    $discountText = ""

    if ($finalPriceCopper -lt $Offer.PriceCopper) {
        $discountText = " after a local recommendation lowers the price"
    }

    return [PSCustomObject]@{
        Success = $true
        Item = $item
        Message = "$($Hero.Name) buys $($item.Name) for $priceText$discountText."
    }
}

function Show-TownShop {
    param(
        [string]$Title,
        [string]$IntroText,
        $Game,
        $Hero,
        [object[]]$Offers
    )

    while ($true) {
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-Scene $IntroText
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
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "S") {
            Open-TownSellMenu -Hero $Hero
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
        Write-ColorLine ""
    }
}

function Open-TownSellMenu {
    param($Hero)

    while ($true) {
        Write-SectionTitle -Text "Sell Gear" -Color "Yellow"
        Write-Scene "A trader eyes Borzig's spare equipment and starts naming prices before the dust has settled."
        Write-ColorLine ""

        $sellableItems = @()

        for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
            $item = $Hero.Inventory[$i]

            if ($item.Type -ne "Currency") {
                $sellableItems += [PSCustomObject]@{
                    InventoryIndex = $i
                    Item = $item
                }
            }
        }

        if ($sellableItems.Count -eq 0) {
            Write-ColorLine "Borzig has nothing worth selling." "DarkGray"
            Write-ColorLine ""
            return
        }

        for ($i = 0; $i -lt $sellableItems.Count; $i++) {
            $entry = $sellableItems[$i]
            $saleValue = [Math]::Max(1, [Math]::Floor(([int]$entry.Item.Value) / 2))
            Write-ColorLine "$($i + 1). $(Format-InventoryItemLine -Item $entry.Item) - sells for $(Convert-CopperToCurrencyText -Copper $saleValue)" "White"
        }

        Write-ColorLine ""
        Write-ColorLine "0. Back" "DarkGray"
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
        $saleValue = [Math]::Max(1, [Math]::Floor(([int]$item.Value) / 2))

        if ($null -ne $item.PSObject.Properties["Equipped"]) {
            $item.Equipped = $false
        }

        Add-HeroCurrency -Hero $Hero -Denomination "CP" -Amount $saleValue | Out-Null
        Remove-InventoryItemAt -Hero $Hero -Index $entry.InventoryIndex
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

    if (-not (Can-HeroCarryItem -Hero $Hero -Item $item)) {
        Write-Scene "$($Hero.Name) does not have enough room to carry $($item.Name) right now."
        return $false
    }

    $Hero.Inventory += $item
    $Hero.StashedInventory = @(
        for ($i = 0; $i -lt $Hero.StashedInventory.Count; $i++) {
            if ($i -ne $StashIndex) {
                $Hero.StashedInventory[$i]
            }
        }
    )
    Write-Scene "$($Hero.Name) takes $($item.Name) back from storage."
    return $true
}

function Start-InnStorageMenu {
    param($Hero)

    while ($true) {
        Write-SectionTitle -Text "Manage Storage" -Color "Yellow"
        Write-Scene "A lockbox and a travel chest sit under the bed, ready to hold whatever Borzig does not want to carry through the city."
        Write-ColorLine "Inventory: $(Get-InventoryUsedSlots -Hero $Hero)/$(Get-InventoryCapacity -Hero $Hero) slots" "DarkCyan"
        Write-ColorLine ""
        Write-ColorLine "1. Store gear from inventory" "White"
        Write-ColorLine "2. Retrieve stored gear" "White"
        Write-ColorLine "3. View stored gear" "White"
        Write-ColorLine "0. Back" "DarkGray"
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


