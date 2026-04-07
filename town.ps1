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
        (New-TownOffer -Id "market_dagger" -Name "Dagger" -Category "Weapon" -Description "A light backup blade with a sharp edge and a quick draw." -PriceCopper 90)
        (New-TownOffer -Id "market_handaxe" -Name "Hand Axe" -Category "Weapon" -Description "A practical one-handed axe for close quarters." -PriceCopper 140)
    )
}

function Get-SmithyOffers {
    return @(
        (New-TownOffer -Id "smithy_longsword" -Name "Longsword" -Category "Weapon" -Description "A balanced soldier's blade for dependable strikes." -PriceCopper 180)
        (New-TownOffer -Id "smithy_warhammer" -Name "Warhammer" -Category "Weapon" -Description "A brutal hammer built to crush armor and bone." -PriceCopper 220)
        (New-TownOffer -Id "smithy_greataxe" -Name "Steel Great Axe" -Category "Weapon" -Description "A heavier axe with a cleaner edge than Borzig's old camp weapon." -PriceCopper 260)
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
        "market_dagger" { return (New-WeaponItem -Name "Dagger" -Value 90 -AttackBonus 2 -DamageDiceCount 1 -DamageDiceSides 4 -SlotCost 1) }
        "market_handaxe" { return (New-WeaponItem -Name "Hand Axe" -Value 140 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 6 -SlotCost 1) }
        "smithy_longsword" { return (New-WeaponItem -Name "Longsword" -Value 180 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 8 -SlotCost 2) }
        "smithy_warhammer" { return (New-WeaponItem -Name "Warhammer" -Value 220 -AttackBonus 0 -DamageDiceCount 1 -DamageDiceSides 10 -SlotCost 2) }
        "smithy_greataxe" { return (New-WeaponItem -Name "Steel Great Axe" -Value 260 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 12 -SlotCost 2) }
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
            Message = "$($Hero.Name) does not have enough room for $($item.Name)."
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
        Write-ColorLine ""

        for ($i = 0; $i -lt $Offers.Count; $i++) {
            $offer = $Offers[$i]
            $priceText = Convert-CopperToCurrencyText -Copper (Get-TownOfferPrice -Game $Game -Offer $offer)
            Write-ColorLine "$($i + 1). $($offer.Name) - $priceText" "White"
            Write-ColorLine "   $($offer.Description)" "DarkGray"
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

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $Offers.Count) {
            Write-ColorLine "That offer is not available." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $result = Try-BuyTownOffer -Game $Game -Hero $Hero -Offer $Offers[$index]

        if ($result.Success) {
            Write-Scene $result.Message
        }
        else {
            Write-Scene $result.Message
        }

        Write-ColorLine ""
    }
}

function Start-TownStreetScene {
    param($Game)

    while ($true) {
        Write-SectionTitle -Text "City Streets" -Color "Cyan"
        Write-Scene "Borzig moves through narrow lanes lit by lanterns, where relieved citizens speak his name in hushed half-whispers."
        Write-Scene "Some want to thank him. Others want to warn him. A few are already trying to sell him on the next danger."
        Write-ColorLine ""
        Write-ColorLine "1. Speak with Widow Elira" "White"
        Write-ColorLine "2. Speak with Hadrik the smith's apprentice" "White"
        Write-ColorLine "3. Speak with Watchman Belor" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene "Widow Elira grips Borzig's wrist with surprising strength. 'My son was on the road when the dragon panic started. Your warning brought him home before sunset.'"
                Write-ColorLine "1. Tell her no thanks are needed." "White"
                Write-ColorLine "2. Accept her gratitude with respect." "White"
                Write-ColorLine ""

                $widowChoice = Read-Host "Choose"

                if ($widowChoice -eq "2") {
                    if (-not $Game.Town.StreetFlags["WidowGiftClaimed"]) {
                        $Game.Town.StreetFlags["WidowGiftClaimed"] = $true
                        Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 4 | Out-Null
                        Write-Scene "Elira presses a tiny cloth purse into Borzig's palm before he can object."
                        Write-EmphasisLine -Text "Borzig receives 4 SP from the widow's grateful gift." -Color "Yellow"
                    }
                    else {
                        Write-Scene "Elira smiles sadly. 'I already gave what little I could, hero. May it still help.'"
                    }
                }
                else {
                    Write-Scene "Elira nods anyway. 'Then take my blessing instead. The city owes you more than coin.'"
                }

                Write-ColorLine ""
            }
            "2" {
                Write-Scene "Hadrik wipes soot from his brow and jerks a thumb toward the smithy. 'Master Rurik respects anyone who walks back from a dragon's shadow alive.'"
                Write-ColorLine "1. Ask if the forge has anything worth carrying into the wilds." "White"
                Write-ColorLine "2. Shrug him off and keep walking." "White"
                Write-ColorLine ""

                $smithChoice = Read-Host "Choose"

                if ($smithChoice -eq "1") {
                    if (-not $Game.Town.StreetFlags["SmithyDiscountUnlocked"]) {
                        $Game.Town.StreetFlags["SmithyDiscountUnlocked"] = $true
                        Set-TownOfferDiscount -Game $Game -OfferId "smithy_greataxe" -DiscountCopper 60
                        Write-Scene "Hadrik lowers his voice. 'Tell Rurik I sent you. He'll shave the price on the Steel Great Axe.'"
                        Write-EmphasisLine -Text "A 6 SP discount is now available on the Steel Great Axe at the smithy." -Color "Yellow"
                    }
                    else {
                        Write-Scene "Hadrik grins. 'Go on then. Rurik already knows to treat you fair.'"
                    }
                }
                else {
                    Write-Scene "Hadrik snorts and turns back to his bellows. 'Your loss. Good steel does not wait forever.'"
                }

                Write-ColorLine ""
            }
            "3" {
                Write-Scene "Watchman Belor watches the gate with tired eyes. 'If the cave held one ancient thing, do not assume it held only one.'"
                Write-Scene "'Buy healing while you can. Panic makes fools brave and merchants rich.'"
                Write-ColorLine ""
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

function Start-TownMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== TOWN =====" "Yellow"
        Write-Scene "Stone streets spread out before Borzig, loud with merchants, carts, and the clatter of a city settling after panic."
        Write-Scene "For the first time since the cave, he can breathe without darkness pressing in from every side."
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Walk the streets" "White"
        Write-ColorLine "2. Browse the market" "White"
        Write-ColorLine "3. Visit the smithy" "White"
        Write-ColorLine "4. Visit the apothecary" "White"
        Write-ColorLine "5. Check inventory" "White"
        Write-ColorLine "6. Check quest log" "White"
        Write-ColorLine "7. Head back to the campfire" "White"
        Write-ColorLine "8. End the adventure for now" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Start-TownStreetScene -Game $Game
            }
            "2" {
                Show-TownShop -Title "Market" -IntroText "Canvas stalls crowd the square. Traders wave Borzig over with travel gear, blades, and battered adventuring stock." -Game $Game -Hero $Game.Hero -Offers (Get-MarketOffers)
            }
            "3" {
                Show-TownShop -Title "Smithy" -IntroText "Heat and sparks pour from the forge while the smith sizes Borzig up like a problem that can be solved with steel." -Game $Game -Hero $Game.Hero -Offers (Get-SmithyOffers)
            }
            "4" {
                Show-TownShop -Title "Apothecary" -IntroText "Glass vials glimmer behind the counter as the apothecary speaks in a low voice about wounds, nerves, and battle tonic." -Game $Game -Hero $Game.Hero -Offers (Get-ApothecaryOffers)
            }
            "5" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "6" {
                Show-QuestLog -Quest $Game.Quest -Hero $Game.Hero
            }
            "7" {
                Write-Scene "$($Game.Hero.Name) leaves the city behind for now and returns to the camp outside the cave."
                Write-ColorLine ""
                return "LeaveTown"
            }
            "8" {
                Write-Scene "$($Game.Hero.Name) finds a quiet corner of the city and lets the day finally come to an end."
                $Game.GameWon = $true
                return "EndGame"
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}
