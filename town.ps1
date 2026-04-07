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
        Write-Scene $result.Message
        Write-ColorLine ""
    }
}

function Resolve-WidowEliraChoice {
    param(
        $Game,
        [string]$Choice
    )

    if ($Game.Town.StreetFlags["WidowEliraResolved"]) {
        return "Elira folds Borzig's hand between both of hers. 'You made your answer already, hero. I remember kindness when I see it.'"
    }

    $Game.Town.StreetFlags["WidowEliraResolved"] = $true

    if ($Choice -eq "2") {
        Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 4 | Out-Null
        $Game.Town.StreetFlags["WidowGiftClaimed"] = $true
        return "Elira presses a tiny cloth purse into Borzig's palm before he can object. Borzig receives 4 SP from the widow's grateful gift."
    }

    $Game.Town.StreetFlags["WidowGiftDeclined"] = $true
    return "Elira nods anyway. 'Then take my blessing instead. The city owes you more than coin.'"
}

function Resolve-HadrikChoice {
    param(
        $Game,
        [string]$Choice
    )

    if ($Game.Town.StreetFlags["HadrikResolved"]) {
        return "Hadrik jerks a thumb toward the forge. 'Already told you what I know. Rurik won't hear a better word from me.'"
    }

    $Game.Town.StreetFlags["HadrikResolved"] = $true

    if ($Choice -eq "1") {
        $Game.Town.StreetFlags["SmithyDiscountUnlocked"] = $true
        Set-TownOfferDiscount -Game $Game -OfferId "smithy_greataxe" -DiscountCopper 60
        return "Hadrik lowers his voice. 'Tell Rurik I sent you. He'll shave the price on the Steel Great Axe.' A 6 SP discount is now available on the Steel Great Axe at the smithy."
    }

    $Game.Town.StreetFlags["SmithyDiscountDeclined"] = $true
    return "Hadrik snorts and turns back to his bellows. 'Your loss. Good steel does not wait forever.'"
}

function Resolve-BelorChoice {
    param(
        $Game,
        [string]$Choice
    )

    if ($Game.Town.StreetFlags["BelorResolved"]) {
        return "Belor gives Borzig a short nod. 'Told you what mattered. The rest is on you.'"
    }

    $Game.Town.StreetFlags["BelorResolved"] = $true

    if ($Choice -eq "1") {
        $Game.Town.Relationships["Belor"] = "Trusting"
        return "Belor leans in and points across the square. 'The guard station pays steady coin for ugly work. If you want honest jobs, start there.'"
    }

    return "Belor shrugs. 'Fine. Then keep your head down and buy healing before the city empties the shelves.'"
}

function Start-TownStreetScene {
    param($Game)

    while ($true) {
        Write-SectionTitle -Text "City Streets" -Color "Cyan"
        Write-Scene "Borzig moves through narrow lanes lit by lanterns, where relieved citizens speak his name in hushed half-whispers."
        Write-Scene "Some want to thank him. Others want to warn him. A few are already trying to pull him toward the next kind of trouble."
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
                Write-Scene (Resolve-WidowEliraChoice -Game $Game -Choice $widowChoice)
                Write-ColorLine ""
            }
            "2" {
                Write-Scene "Hadrik wipes soot from his brow and jerks a thumb toward the smithy. 'Master Rurik respects anyone who walks back from a dragon's shadow alive.'"
                Write-ColorLine "1. Ask if the forge has anything worth carrying into the wilds." "White"
                Write-ColorLine "2. Shrug him off and keep walking." "White"
                Write-ColorLine ""

                $smithChoice = Read-Host "Choose"
                Write-Scene (Resolve-HadrikChoice -Game $Game -Choice $smithChoice)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene "Watchman Belor watches the gate with tired eyes. 'If the cave held one ancient thing, do not assume it held only one.'"
                Write-ColorLine "1. Ask where a capable fighter can find decent work." "White"
                Write-ColorLine "2. Thank him and move on." "White"
                Write-ColorLine ""

                $guardChoice = Read-Host "Choose"
                Write-Scene (Resolve-BelorChoice -Game $Game -Choice $guardChoice)
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

function Show-TownQuestSource {
    param(
        [string]$Title,
        [string]$IntroText,
        [string]$Source,
        $Game
    )

    while ($true) {
        $quests = Get-TownQuestList -Game $Game -Source $Source
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-Scene $IntroText
        Write-ColorLine ""

        for ($i = 0; $i -lt $quests.Count; $i++) {
            $quest = $quests[$i]
            $status = if ($quest.Completed) { "Complete" } elseif ($quest.Accepted) { "Accepted" } else { "Available" }
            Write-ColorLine "$($i + 1). $($quest.Name) [$status]" "White"
            Write-ColorLine "   $($quest.Description)" "DarkGray"
            Write-ColorLine "   Reward: $(Get-QuestRewardText -Quest $quest)" "DarkGray"
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

        if ($index -lt 0 -or $index -ge $quests.Count) {
            Write-ColorLine "That quest is not listed." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $questResult = Accept-TownQuest -Game $Game -QuestId $quests[$index].Id
        Write-Scene $questResult.Message
        Write-ColorLine ""
    }
}

function Start-QuestHubMenu {
    param($Game)

    while ($true) {
        Write-SectionTitle -Text "Seek Work" -Color "Yellow"
        Write-Scene "Borzig can ask for work from official hands, desperate citizens, or merchants with private problems."
        Write-ColorLine ""
        Write-ColorLine "1. Check the quest board" "White"
        Write-ColorLine "2. Visit the guard station" "White"
        Write-ColorLine "3. Speak with the quest giver's clerk" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Show-TownQuestSource -Title "Quest Board" -IntroText "Pinned notices flap in the night wind. Most offer coin, some offer trouble, and all of them want someone else to solve a problem." -Source "Quest Board" -Game $Game
            }
            "2" {
                Show-TownQuestSource -Title "Guard Station" -IntroText "The watch hall smells of lamp oil, damp cloaks, and sleepless men. Steady work hangs here, though rarely easy work." -Source "Guard Station" -Game $Game
            }
            "3" {
                Show-TownQuestSource -Title "Quest Giver" -IntroText "A clerk waits beneath the old patron's seal, ready to pass along jobs too awkward or dangerous for ordinary hirelings." -Source "Quest Giver" -Game $Game
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

function Get-RingOpponents {
    return @(
        [PSCustomObject]@{
            Name = "Dockhand Vero"
            Definite = "Dockhand Vero"
            ArmorClass = 11
            HP = 8
            AttackBonus = 2
            DamageDiceSides = 4
            DamageBonus = 1
            Intro = "A square-shouldered dockhand cracks his knuckles and grins through a split lip."
        }
        [PSCustomObject]@{
            Name = "Pit Runner Sella"
            Definite = "Pit Runner Sella"
            ArmorClass = 12
            HP = 10
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 1
            Intro = "Sella circles lightly on her feet, measuring Borzig with the patience of someone used to tiring out bigger foes."
        }
        [PSCustomObject]@{
            Name = "Ironjaw Marn"
            Definite = "Ironjaw Marn"
            ArmorClass = 13
            HP = 12
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            Intro = "Ironjaw Marn steps into the lantern light to a chorus of shouts. The crowd knows him, and that alone is warning enough."
        }
    )
}

function Get-RingRewardCopper {
    param([int]$Wins)

    switch ($Wins) {
        1 { return 100 }
        2 { return 220 }
        3 { return 350 }
        default { return 0 }
    }
}

function Grant-RingTraining {
    param(
        $Hero,
        [int]$Wins
    )

    $Hero.RingWinsTotal += $Wins
    $unlocked = $false

    if ($Hero.UnarmedTrainingLevel -lt 1 -and $Hero.RingWinsTotal -ge 3) {
        $Hero.UnarmedTrainingLevel = 1
        $unlocked = $true
    }

    return [PSCustomObject]@{
        Unlocked = $unlocked
        TotalWins = $Hero.RingWinsTotal
    }
}

function Invoke-HeroBrawlAttack {
    param(
        $Hero,
        $Opponent,
        [ref]$OpponentHP
    )

    $profile = Get-HeroUnarmedProfile -Hero $Hero
    $roll = Roll-Dice -Sides 20
    $total = $roll + $profile.TotalAttackBonus
    Write-Action "$($Hero.Name) swings with bare hands: roll $roll, total $total vs AC $($Opponent.ArmorClass)" "Cyan"

    if ($roll -eq 20) {
        $extraRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $profile.DamageMax + $extraRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) lands a brutal hook for $damage damage! ($($profile.DamageMax) + $extraRoll + $($profile.DamageBonus))" "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Hero.Name) overcommits and stumbles wide." "DarkGray"
    }
    elseif ($total -ge $Opponent.ArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $damageRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "$($Hero.Name) hits for $damage damage! ($damageRoll + $($profile.DamageBonus))" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) misses!" "DarkGray"
    }

    if ($OpponentHP.Value -lt 0) {
        $OpponentHP.Value = 0
    }

    Write-ColorLine ""
}

function Invoke-OpponentBrawlAttack {
    param(
        $Hero,
        $Opponent,
        [ref]$HeroHP
    )

    $heroArmorClass = 10 + [Math]::Max((Get-HeroAbilityModifier -Hero $Hero -Ability "STR"), (Get-HeroAbilityModifier -Hero $Hero -Ability "DEX"))
    $roll = Roll-Dice -Sides 20
    $total = $roll + $Opponent.AttackBonus

    Write-Action "$($Opponent.Definite) throws a punch: roll $roll, total $total vs AC $heroArmorClass" "DarkCyan"

    if ($roll -eq 20) {
        $firstDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $secondDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $firstDamage + $secondDamage + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Opponent.Definite) crashes through Borzig's guard for $damage damage! ($firstDamage + $secondDamage + $($Opponent.DamageBonus))" "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Opponent.Definite) slips and loses the angle." "DarkGray"
    }
    elseif ($total -ge $heroArmorClass) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $damageRoll + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "$($Opponent.Definite) hits for $damage damage! ($damageRoll + $($Opponent.DamageBonus))" "Yellow"
    }
    else {
        Write-Action "$($Opponent.Definite) misses!" "DarkGray"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
    }

    Write-ColorLine ""
}

function Start-BrawlLoop {
    param(
        $Hero,
        $Opponent,
        [string]$Title = "Brawl"
    )

    $heroBrawlHP = $Hero.HP
    $opponentHP = $Opponent.HP

    Write-SectionTitle -Text $Title -Color "Yellow"
    Write-Scene $Opponent.Intro
    Write-ColorLine ""

    while ($heroBrawlHP -gt 0 -and $opponentHP -gt 0) {
        Write-ColorLine "Borzig: $heroBrawlHP HP | $($Opponent.Name): $opponentHP HP" "Green"
        Write-ColorLine "P. Punch" "White"
        Write-ColorLine "C. Concede" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "C") {
            Write-Scene "$($Hero.Name) raises a hand and backs out before the beating gets worse."
            return $false
        }

        if ($choice -ne "P") {
            Write-ColorLine "Choose P or C." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP)

        if ($opponentHP -le 0) {
            Write-Scene "$($Opponent.Name) drops to one knee and yields the fight."
            return $true
        }

        Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP)

        if ($heroBrawlHP -le 0) {
            Write-Scene "$($Hero.Name) is forced down and the referee calls the bout."
            return $false
        }
    }

    return $false
}

function Start-FightingRing {
    param($Game)

    $entryFee = 100
    Write-SectionTitle -Text "Fighting Ring" -Color "Yellow"
    Write-Scene "In a sunken pit behind heavy canvas, wagers trade hands faster than greetings and every bruise is worth an opinion."
    Write-Scene "Weapons stay out. Pride stays in. Coin changes hands either way."
    Write-ColorLine "Entry Fee: $(Convert-CopperToCurrencyText -Copper $entryFee)" "DarkYellow"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
    Write-ColorLine ""
    Write-ColorLine "1. Enter the ring" "White"
    Write-ColorLine "0. Back" "DarkGray"
    Write-ColorLine ""

    $choice = Read-Host "Choose"

    if ($choice -ne "1") {
        return
    }

    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $entryFee

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) does not have enough coin to register for the ring."
        Write-ColorLine ""
        return
    }

    $Game.Hero.RingVisits += 1
    $Game.Town.Ring.Visits += 1

    $wins = 0

    foreach ($opponent in (Get-RingOpponents)) {
        $wonBout = Start-BrawlLoop -Hero $Game.Hero -Opponent $opponent -Title "Ring Round $($wins + 1)"

        if (-not $wonBout) {
            break
        }

        $wins += 1
        Write-Scene "The crowd roars as Borzig survives another round."
        Write-ColorLine ""
    }

    $rewardCopper = Get-RingRewardCopper -Wins $wins

    if ($rewardCopper -gt 0) {
        Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper | Out-Null
        Write-EmphasisLine -Text "Borzig leaves the pit with $(Convert-CopperToCurrencyText -Copper $rewardCopper) in prize money." -Color "Yellow"
    }
    else {
        Write-Scene "Borzig leaves the ring with bruises, noise in his ears, and no prize money."
    }

    if ($wins -gt 0) {
        $trainingResult = Grant-RingTraining -Hero $Game.Hero -Wins $wins

        if ($trainingResult.Unlocked) {
            Write-SectionTitle -Text "Skill Gained" -Color "Green"
            Write-EmphasisLine -Text "Pit-Fighter Basics unlocked: Borzig gains +1 to hit and +1 damage with bare hands." -Color "Green"
        }
    }

    Write-ColorLine ""
}

function Resolve-InnEvent {
    param(
        $Game,
        [ref]$HeroHP,
        $Inn,
        [int]$EventRoll = 0
    )

    if ($EventRoll -le 0) {
        $EventRoll = Roll-Dice -Sides 100
    }

    switch ($Inn.Id) {
        "bent_nail" {
            if ($EventRoll -le 35) {
                Write-Scene "A drunken carter mistakes Borzig's silence for mockery, and the common room suddenly wants a fight."
                $wonBrawl = Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
                    Name = "Ropearm Jerek"
                    Definite = "Ropearm Jerek"
                    ArmorClass = 11
                    HP = 8
                    AttackBonus = 2
                    DamageDiceSides = 4
                    DamageBonus = 1
                    Intro = "Ropearm Jerek barrels in with dockside confidence and absolutely no plan beyond throwing hands."
                }) -Title "Bent Nail Brawl"

                if ($wonBrawl) {
                    Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 3 | Out-Null
                    Write-Scene "Marta barks the room quiet and tosses Borzig 3 SP from the pile of side bets."
                }
                else {
                    Write-Scene "Marta hauls the loser out by the collar and tells both fools to sleep it off."
                }

                return
            }

            if ($EventRoll -le 65) {
                if (-not $Game.Town.InnFlags["BentNailShadyRumor"]) {
                    $Game.Town.InnFlags["BentNailShadyRumor"] = $true
                    Write-Scene "A smuggler at the next table mutters about easy coin moving goods through back alleys. Borzig learns where the city's shadier business tends to gather."
                }
                else {
                    Write-Scene "The same hard-eyed smugglers are here again, still talking low and watching everyone."
                }

                return
            }
        }
        "lantern_rest" {
            if ($EventRoll -le 15) {
                Write-Scene "A mercenary with too much ale and too much pride takes offense when Borzig refuses to trade boasts."
                $wonBrawl = Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
                    Name = "Mercenary Pell"
                    Definite = "Mercenary Pell"
                    ArmorClass = 12
                    HP = 9
                    AttackBonus = 3
                    DamageDiceSides = 4
                    DamageBonus = 1
                    Intro = "Mercenary Pell steps clear of the tables, shoulders loose, chin tucked, and smile mean."
                }) -Title "Lantern Rest Scuffle"

                if ($wonBrawl) {
                    Write-Scene "The room settles fast once Pell hits the boards. Oren sends Borzig's stew up free of charge."
                }
                else {
                    Write-Scene "Oren breaks it up before it turns ugly and quietly warns Borzig that not every paying guest deserves patience."
                }

                return
            }

            if ($EventRoll -le 55) {
                if (-not $Game.Town.InnFlags["LanternMerchantDiscount"]) {
                    $Game.Town.InnFlags["LanternMerchantDiscount"] = $true
                    Set-TownOfferDiscount -Game $Game -OfferId "market_healing_potion" -DiscountCopper 10
                    Write-Scene "A caravan factor shares road gossip over supper, then tells the market to give Borzig a better rate on basic healing supplies."
                }
                else {
                    Write-Scene "Travelers trade the latest road rumors across the room, but nothing sharper than that reaches Borzig tonight."
                }

                return
            }
        }
        "silver_kettle" {
            if ($EventRoll -le 10) {
                Write-Scene "A silk-draped bravo mistakes Borzig's plain clothes for weakness and ends up demanding satisfaction with bare hands."
                $wonBrawl = Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
                    Name = "House Duelist Corven"
                    Definite = "House Duelist Corven"
                    ArmorClass = 13
                    HP = 10
                    AttackBonus = 4
                    DamageDiceSides = 4
                    DamageBonus = 2
                    Intro = "Corven rolls his shoulders beneath embroidered sleeves, moving like someone used to applause."
                }) -Title "Silver Kettle Altercation"

                if ($wonBrawl) {
                    Write-Scene "Even the shocked nobles have to admit the result. Madam Seraphine has the mess erased before dawn."
                }
                else {
                    Write-Scene "The house guards end it the instant Borzig is outmatched, which is still kinder than most cheap inns manage."
                }

                return
            }

            if ($EventRoll -le 70) {
                if (-not $Game.Town.InnFlags["SilverKettleContact"]) {
                    $Game.Town.InnFlags["SilverKettleContact"] = $true
                    $Game.Town.Relationships["MagistrateClerk"] = "Introduced"
                    Set-TownOfferDiscount -Game $Game -OfferId "apothecary_greater_healing_potion" -DiscountCopper 30
                    Write-Scene "Between candlelight and quiet music, a magistrate's clerk takes notice of Borzig and offers a proper introduction to more respectable circles."
                }
                else {
                    Write-Scene "The upper tables continue their soft, expensive gossip. Borzig is watched now with recognition instead of suspicion."
                }

                return
            }
        }
    }

    Write-Scene "The evening passes without incident, leaving only food, quiet, and the luxury of not being hunted."
}

function Resolve-InnStay {
    param(
        $Game,
        [ref]$HeroHP,
        $Inn,
        [int]$EventRoll = 0
    )

    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $Inn.PriceCopper

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) cannot afford a room at $($Inn.Name)."
        Write-ColorLine ""
        return $false
    }

    $Game.Town.ActiveInn = $Inn

    Write-SectionTitle -Text $Inn.Name -Color "Yellow"
    Write-Scene $Inn.KeeperText
    Write-EmphasisLine -Text "$($Game.Hero.Name) pays $(Convert-CopperToCurrencyText -Copper $Inn.PriceCopper) for a $($Inn.Quality.ToLower()) room." -Color "Yellow"
    Resolve-InnEvent -Game $Game -HeroHP $HeroHP -Inn $Inn -EventRoll $EventRoll
    Clear-HeroBuff -Hero $Game.Hero
    $HeroHP.Value = $Game.Hero.HP
    Write-Scene $Inn.RestText
    Write-Scene "A full night's rest restores Borzig to full health, and any lingering combat tonic fades with the morning."
    Write-ColorLine ""

    if (-not $Game.Town.ChapterOneComplete) {
        $Game.Town.ChapterOneComplete = $true
        Write-SectionTitle -Text "Chapter One Complete" -Color "Green"
        Write-EmphasisLine -Text "Borzig survives the cave, reaches the city, and earns his first true night behind safe walls." -Color "Green"
        Write-Scene "The tutorial ends not at a lonely campfire, but in a rented room above the noise of a living city."
        Write-ColorLine ""
    }

    return $true
}

function Start-InnMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== INN ROOM =====" "Yellow"
        Write-Scene "Borzig's room at $($inn.Name) is modestly lit, closed off from the street below, and blessedly still."
        Write-ColorLine "Inn: $($inn.Name) | Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Rest for the night and end the adventure for now" "White"
        Write-ColorLine "2. Check inventory" "White"
        Write-ColorLine "3. Check quest log" "White"
        Write-ColorLine "4. Return to the city streets" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene "$($Game.Hero.Name) bars the door, sets down the weight of the day, and lets sleep finally claim him."
                $Game.GameWon = $true
                return "EndGame"
            }
            "2" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "3" {
                Show-QuestLog -Game $Game -Hero $Game.Hero
            }
            "4" {
                return "BackToTown"
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}

function Start-InnSelectionMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inns = Get-TownInns

    while ($true) {
        Write-SectionTitle -Text "Find Lodging" -Color "Yellow"
        Write-Scene "Night settles over the city, and Borzig must choose what kind of roof he wants over his head."
        Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
        Write-ColorLine ""

        for ($i = 0; $i -lt $inns.Count; $i++) {
            $inn = $inns[$i]
            Write-ColorLine "$($i + 1). $($inn.Name) - $(Convert-CopperToCurrencyText -Copper $inn.PriceCopper)" "White"
            Write-ColorLine "   Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkGray"
            Write-ColorLine "   $($inn.Description)" "DarkGray"
        }

        Write-ColorLine ""
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return "BackToTown"
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose a listed number." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $inns.Count) {
            Write-ColorLine "That inn is not available." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $selectedInn = $inns[$index]
        $staySucceeded = Resolve-InnStay -Game $Game -HeroHP $HeroHP -Inn $selectedInn

        if ($staySucceeded) {
            return "Stayed"
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
        Write-ColorLine "5. Seek work" "White"
        Write-ColorLine "6. Visit the fighting ring" "White"
        Write-ColorLine "7. Check inventory" "White"
        Write-ColorLine "8. Check quest log" "White"
        Write-ColorLine "9. Find lodging for the night" "White"
        Write-ColorLine "0. End the adventure for now" "White"
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
                Start-QuestHubMenu -Game $Game
            }
            "6" {
                Start-FightingRing -Game $Game
            }
            "7" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "8" {
                Show-QuestLog -Game $Game -Hero $Game.Hero
            }
            "9" {
                $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

                if ($innResult -eq "Stayed") {
                    Start-InnMenu -Game $Game -HeroHP $HeroHP | Out-Null
                }
            }
            "0" {
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
