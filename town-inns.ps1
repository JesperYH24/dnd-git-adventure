# Inn data, events, and room management stay together so lodging flow is easier to extend later.

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

function Resolve-BentNailEveningChoice {
    param(
        $Game,
        [string]$Choice,
        [int]$RiskRoll = 0
    )

    if ($Choice -eq "1") {
        if (-not $Game.Town.InnFlags["BentNailBrokerInfo"]) {
            $Game.Town.InnFlags["BentNailBrokerInfo"] = $true
            $Game.Town.Relationships["UnderstreetBroker"] = "Named"
            Write-Scene "Borzig keeps his head down and listens while a scarred fixer maps out which alleys carry stolen cargo, hush money, and desperate errands."
            Write-EmphasisLine -Text "Borzig gains understreet information that can be built into shady city quests later." -Color "Yellow"
        }
        else {
            Write-Scene "The same smugglers are still talking around Borzig, but tonight they offer nothing sharper than what he already knows."
        }

        return
    }

    if ($Choice -eq "2") {
        if ($RiskRoll -le 0) {
            $RiskRoll = Roll-Dice -Sides 100
        }

        if ($RiskRoll -le 60) {
            Write-Scene "The dice game turns sour almost immediately, and one ugly joke later the table wants fists instead of coins."
            Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
                Name = "Dockside Bruiser Kel"
                Definite = "Dockside Bruiser Kel"
                ArmorClass = 11
                HP = 8
                AttackBonus = 2
                DamageDiceSides = 4
                DamageBonus = 1
                GrappleBonus = 2
                Intro = "Kel lunges up from the bench with knuckles already half-curled."
            }) -Title "Bent Nail Dice Table" | Out-Null
        }
        else {
            Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 2 | Out-Null
            Write-Scene "For once the table laughs with Borzig instead of at him, and he walks away with 2 SP in easy winnings."
        }

        return
    }

    Write-Scene "Borzig keeps to the wall and lets the room talk around him."
}

function Resolve-LanternRestEveningChoice {
    param(
        $Game,
        [string]$Choice,
        [int]$RiskRoll = 0
    )

    if ($Choice -eq "1") {
        if (-not $Game.Town.InnFlags["LanternTradeAdvice"]) {
            $Game.Town.InnFlags["LanternTradeAdvice"] = $true
            Set-TownOfferDiscount -Game $Game -OfferId "market_handaxe" -DiscountCopper 20
            Write-Scene "Merchants compare ledgers over stew and quietly point Borzig toward which traders gouge and which ones fear a hard bargain."
            Write-EmphasisLine -Text "Borzig learns practical market information. The Hand Axe is now cheaper at the market." -Color "Yellow"
        }
        else {
            Write-Scene "The merchant tables are good company, but their useful advice has already been spent once."
        }

        return
    }

    if ($Choice -eq "2") {
        if (-not $Game.Town.InnFlags["LanternGuardRumor"]) {
            $Game.Town.InnFlags["LanternGuardRumor"] = $true
            $Game.Town.Relationships["NightCaptain"] = "Mentioned"
            Write-Scene "Caravan guards swap route warnings with watchmen and mention a captain who pays well for reliable steel on dirty night work."
            Write-EmphasisLine -Text "Borzig hears new guard-station rumors that can feed later city jobs." -Color "Yellow"
        }
        else {
            Write-Scene "The guards nod to Borzig like a familiar face now, but tonight they have no fresh work to whisper about."
        }

        return
    }

    if ($RiskRoll -le 0) {
        $RiskRoll = Roll-Dice -Sides 100
    }

    if ($RiskRoll -le 25) {
        Write-Scene "Too much ale and too many boasts sour the room, and a visiting sword hand decides Borzig looks like trouble worth testing."
        Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
            Name = "Road Guard Hestin"
            Definite = "Road Guard Hestin"
            ArmorClass = 12
            HP = 9
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 3
            Intro = "Hestin cracks his neck, grins once, and comes in straight-backed like a trained man trying to look relaxed."
        }) -Title "Lantern Rest Dispute" | Out-Null
    }
    else {
        Write-Scene "The common room stays loud but harmless, and Borzig comes away with nothing worse than a sore voice."
    }
}

function Resolve-SilverKettleEveningChoice {
    param(
        $Game,
        [string]$Choice,
        [int]$RiskRoll = 0
    )

    if ($Choice -eq "1") {
        if (-not $Game.Town.InnFlags["SilverKettleEconomicInsight"]) {
            $Game.Town.InnFlags["SilverKettleEconomicInsight"] = $true
            $Game.Town.QuestPayoutBonusCopper = 20
            Write-Scene "Borzig listens while minor nobles and clerks talk contracts, tariffs, and which patrons always pay above the board for fast results."
            Write-EmphasisLine -Text "Borzig gains economic insight. Future city quest payouts can be improved later." -Color "Yellow"
        }
        else {
            Write-Scene "The contract talk is still there if Borzig wants it, but the useful part has already been learned."
        }

        return
    }

    if ($Choice -eq "2") {
        if (-not $Game.Town.InnFlags["SilverKettlePatronFavor"]) {
            $Game.Town.InnFlags["SilverKettlePatronFavor"] = $true
            $Game.Town.Relationships["MerchantPatron"] = "Favorable"
            Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 5 | Out-Null
            Write-Scene "A wealthy patron takes to Borzig's plain honesty and leaves 5 SP with Madam Seraphine to cover his next meal and wine."
            Write-EmphasisLine -Text "Borzig earns a small favor among the upper tables." -Color "Yellow"
        }
        else {
            Write-Scene "The upper room remembers Borzig well enough now, and that alone opens more doors than a second introduction would."
        }

        return
    }

    if ($RiskRoll -le 0) {
        $RiskRoll = Roll-Dice -Sides 100
    }

    if ($RiskRoll -le 10) {
        Write-Scene "A silk-clad bravo mistakes Borzig's silence for contempt, and even this polished room cannot stop the old language of fists."
        Start-BrawlLoop -Hero $Game.Hero -Opponent ([PSCustomObject]@{
            Name = "Velvet-Hand Corin"
            Definite = "Velvet-Hand Corin"
            ArmorClass = 13
            HP = 10
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 3
            Intro = "Corin slips off his rings one by one and smiles like this happens often enough to bore him."
        }) -Title "Silver Kettle Insult" | Out-Null
    }
    else {
        Write-Scene "Borzig takes the evening in quiet comfort, and the room's easy courtesy leaves him feeling better received than expected."
    }
}

function Start-InnEveningMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn

    while ($true) {
        Write-SectionTitle -Text "Common Room" -Color "Yellow"

        switch ($inn.Id) {
            "bent_nail" {
                Write-Scene "The Bent Nail is all smoke, elbows, and hard stares. Trouble is never far away, but neither are the people who know where the city's dirt is buried."
                Write-ColorLine "1. Listen to the smugglers and dockside fixers" "White"
                Write-ColorLine "2. Join a loud dice table" "White"
                $bentNailQuest = Find-TownQuest -Game $Game -QuestId "bent_nail_whispers"

                if ($null -ne $bentNailQuest -and (Is-TownQuestUnlocked -Game $Game -Quest $bentNailQuest) -and -not $bentNailQuest.Completed) {
                    $questStatus = if ($bentNailQuest.Accepted) { "Accepted" } else { "Available" }
                    Write-ColorLine "3. Follow up the Bent Nail whispers [$questStatus]" "White"
                }
            }
            "lantern_rest" {
                Write-Scene "The Lantern Rest sits in the middle ground: traders, caravan guards, and practical folk who know something useful if you earn their patience."
                Write-ColorLine "1. Share supper with the merchants" "White"
                Write-ColorLine "2. Sit with the guards and caravan hands" "White"
                Write-ColorLine "3. Join the room's drinking song" "White"
            }
            "silver_kettle" {
                Write-Scene "The Silver Kettle hums with careful laughter, polished manners, and the kind of money that changes lives without ever raising its voice."
                Write-ColorLine "1. Listen to the contract talk over wine" "White"
                Write-ColorLine "2. Make a polished introduction to the upper tables" "White"
                Write-ColorLine "3. Stay visible and see who takes offense" "White"
            }
        }

        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return
        }

        switch ($inn.Id) {
            "bent_nail" {
                if ($choice -eq "3") {
                    $quest = Find-TownQuest -Game $Game -QuestId "bent_nail_whispers"

                    if ($null -eq $quest -or -not (Is-TownQuestUnlocked -Game $Game -Quest $quest) -or $quest.Completed) {
                        Write-Scene "No one in the back booths is ready to say more tonight."
                        Write-ColorLine ""
                        continue
                    }

                    if (-not $quest.Accepted) {
                        $questResult = Accept-TownQuest -Game $Game -QuestId $quest.Id
                        Write-Scene $questResult.Message
                        Write-ColorLine ""

                        if ($questResult.Success) {
                            while ($true) {
                                Write-ColorLine "1. Start now" "White"
                                Write-ColorLine "2. Prepare in town first" "White"
                                Write-ColorLine "" "White"

                                $followUpChoice = Read-Host "Choose"

                                if ($followUpChoice -eq "1") {
                                    Start-TownQuest -Game $Game -HeroHP $HeroHP -QuestId $quest.Id
                                    break
                                }

                                if ($followUpChoice -eq "2") {
                                    Start-TownQuestPreparationMenu -Game $Game -HeroHP $HeroHP -Quest $quest
                                    break
                                }

                                Write-ColorLine "Choose 1 or 2." "DarkYellow"
                                Write-ColorLine ""
                            }
                        }
                    }
                    else {
                        Start-TownQuestPreparationMenu -Game $Game -HeroHP $HeroHP -Quest $quest
                    }

                    Write-ColorLine ""
                    continue
                }

                Resolve-BentNailEveningChoice -Game $Game -Choice $choice
            }
            "lantern_rest" { Resolve-LanternRestEveningChoice -Game $Game -Choice $choice }
            "silver_kettle" { Resolve-SilverKettleEveningChoice -Game $Game -Choice $choice }
        }

        Write-ColorLine ""
    }
}

function Start-InnVisitMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        Write-Scene "Borzig has not taken a room yet."
        Write-ColorLine ""
        return "NoInn"
    }

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== $($inn.Name.ToUpper()) =====" "Yellow"
        Write-Scene "$($inn.Name) wraps around Borzig like its own little world of floorboards, low voices, and people who plan to sleep under the same roof tonight."
        Write-ColorLine "Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Go to your room" "White"
        Write-ColorLine "2. Spend time in the common room" "White"
        Write-ColorLine "3. Speak with the innkeeper" "White"
        Write-ColorLine "0. Return to town" "DarkGray"
        Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                if ($innMenuResult -eq "EndGame") {
                    return "EndGame"
                }
            }
            "2" {
                Start-InnEveningMenu -Game $Game -HeroHP $HeroHP
            }
            "3" {
                $innkeeperResult = Start-InnkeeperMenu -Game $Game

                if ($innkeeperResult -eq "Cancelled") {
                    return "BookingCancelled"
                }
            }
            "0" {
                return "BackToTown"
            }
            "T" {
                Toggle-TextSpeed | Out-Null
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}

function Resolve-InnWorkOffRoom {
    param(
        $Game,
        [ref]$HeroHP,
        $Inn
    )

    while ($true) {
        Write-SectionTitle -Text "Work Off the Room" -Color "Yellow"
        Write-Scene "$($Inn.Keeper) looks Borzig over, then points toward the sort of work that keeps an inn alive after dark."
        Write-Scene "If he cannot pay in coin tonight, he can pay in sweat."
        Write-ColorLine ""
        Write-ColorLine "1. Haul kegs and split firewood (STR)" "White"
        Write-ColorLine "2. Scrub tables and reset the room (CON)" "White"
        Write-ColorLine "3. Hold the late door and break up trouble (STR)" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return $false
        }

        $ability = ""
        $taskText = ""

        switch ($choice) {
            "1" {
                $ability = "STR"
                $taskText = "Borzig shoulders casks, drags split wood, and keeps the cellar moving until his back burns."
            }
            "2" {
                $ability = "CON"
                $taskText = "Borzig spends the late hours hauling benches straight, scrubbing down tables, and keeping on his feet long past comfort."
            }
            "3" {
                $ability = "STR"
                $taskText = "Borzig stands the late door, hauling drunks apart before fists become blood on the floorboards."
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        $modifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability $ability
        $roll = Roll-Dice -Sides 20
        $total = $roll + $modifier
        $dc = switch ($Inn.Id) {
            "silver_kettle" { 15 }
            "lantern_rest" { 12 }
            default { 10 }
        }

        Write-Scene $taskText
        Write-Action "$($Game.Hero.Name) works the night: roll $roll $(Format-AbilityModifier -Modifier $modifier) = $total" "Cyan"

        $tipCopper = 0

        if ($total -ge ($dc + 5)) {
            $tipCopper = switch ($Inn.Id) {
                "silver_kettle" { 30 }
                "lantern_rest" { 20 }
                default { 10 }
            }
            Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $tipCopper | Out-Null
            Write-Scene "$($Inn.Keeper) grudgingly admits the work was worth more than a bed and slips Borzig a small tip."
        }
        elseif ($total -ge $dc) {
            Write-Scene "$($Inn.Keeper) decides the work settles the bill well enough."
        }
        else {
            Write-Scene "$($Inn.Keeper) is not impressed, but the work is done and the room is covered."
        }

        $Game.Town.ActiveInn = $Inn
        $Game.Town.MustChooseFirstInn = $false
        $Game.Town.WorkedForRoomToday = $true
        $Game.Town.Ring.FoughtToday = $true
        $Game.Town.StoryQuestDoneToday = $false
        $Game.Town.DayJobDoneToday = $false
        Clear-HeroBuff -Hero $Game.Hero
        $HeroHP.Value = $Game.Hero.HP

        Write-Scene "Borzig drops into bed exhausted. The room is paid for, but the night leaves him too worn out for the fighting ring tomorrow."

        if ($tipCopper -gt 0) {
            Write-EmphasisLine -Text "$($Game.Hero.Name) also earns $(Convert-CopperToCurrencyText -Copper $tipCopper) for the effort." -Color "Yellow"
        }

        if (-not $Game.Town.ChapterOneComplete) {
            $Game.Town.ChapterOneComplete = $true
            Write-ColorLine ""
            Write-SectionTitle -Text "Chapter One Complete" -Color "Green"
            Write-EmphasisLine -Text "Borzig survives the cave, reaches the city, and earns his first true night behind safe walls." -Color "Green"
            Write-Scene "The tutorial ends with sore hands, a cheap room, and the feeling that city life has to be earned one hard night at a time."
        }

        Write-ColorLine ""
        return $true
    }
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
        Write-ColorLine "1. Work off the room tonight" "White"
        Write-ColorLine "2. Choose another inn" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        while ($true) {
            $choice = Read-Host "Choose"

            switch ($choice) {
                "1" { return (Resolve-InnWorkOffRoom -Game $Game -HeroHP $HeroHP -Inn $Inn) }
                "2" { return $false }
                "0" { return $false }
                default {
                    Write-ColorLine "Choose 1, 2 or 0." "DarkYellow"
                    Write-ColorLine ""
                }
            }
        }
    }

    $Game.Town.ActiveInn = $Inn
    $Game.Town.MustChooseFirstInn = $false
    $Game.Town.WorkedForRoomToday = $false

    Write-SectionTitle -Text $Inn.Name -Color "Yellow"
    Write-Scene (Get-InnKeeperGreeting -Inn $Inn -Hero $Game.Hero -RepeatVisit $false)
    Write-EmphasisLine -Text "$($Game.Hero.Name) pays $(Convert-CopperToCurrencyText -Copper $Inn.PriceCopper) for a $($Inn.Quality.ToLower()) room." -Color "Yellow"
    Resolve-InnEvent -Game $Game -HeroHP $HeroHP -Inn $Inn -EventRoll $EventRoll
    Clear-HeroBuff -Hero $Game.Hero
    $HeroHP.Value = $Game.Hero.HP
    $Game.Town.Ring.FoughtToday = $false
    $Game.Town.StoryQuestDoneToday = $false
    $Game.Town.DayJobDoneToday = $false
    if (-not $Game.Town.ChapterOneComplete) {
        Write-Scene $Inn.RestText
    }
    else {
        Write-Scene (Get-InnRepeatRestText -Inn $Inn)
    }
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

function Resolve-BookedInnNightRest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        Write-Scene "Borzig has no room to return to tonight."
        Write-ColorLine ""
        return $false
    }

    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $inn.PriceCopper

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) does not have enough coin to cover another night at $($inn.Name)."
        Write-ColorLine "1. Work off the room tonight" "White"
        Write-ColorLine "2. Keep walking the city instead" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        while ($true) {
            $choice = Read-Host "Choose"

            switch ($choice) {
                "1" { return (Resolve-InnWorkOffRoom -Game $Game -HeroHP $HeroHP -Inn $inn) }
                "2" { return $false }
                "0" { return $false }
                default {
                    Write-ColorLine "Choose 1, 2 or 0." "DarkYellow"
                    Write-ColorLine ""
                }
            }
        }
    }

    Write-Scene "$($Game.Hero.Name) closes the shutters, pays for another night, and lets the city fade to a muffled hum beyond the walls."
    Write-Scene (Get-InnRepeatRestText -Inn $inn)
    Clear-HeroBuff -Hero $Game.Hero
    $HeroHP.Value = $Game.Hero.HP
    $Game.Town.WorkedForRoomToday = $false
    $Game.Town.Ring.FoughtToday = $false
    $Game.Town.StoryQuestDoneToday = $false
    $Game.Town.DayJobDoneToday = $false
    Write-Scene "A full night's rest restores Borzig to full health, clears the day from his head, and resets the city for morning."
    Write-ColorLine ""

    return $true
}

function Resolve-InnBookingCancellation {
    param($Game)

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        Write-Scene "Borzig does not currently have a room booked."
        Write-ColorLine ""
        return $false
    }

    if ($Game.Hero.StashedInventory.Count -gt 0) {
        Write-Scene "$($inn.Keeper) folds their arms and points toward the room chest."
        Write-Scene "'Clear out your stored gear before you give up the room,' the keeper says."
        Write-ColorLine ""
        return $false
    }

    Write-Scene "$($inn.Keeper) nods once and scratches Borzig's name off the room ledger."
    Write-Scene "$($Game.Hero.Name) is no longer booked at $($inn.Name)."
    Write-ColorLine ""
    $Game.Town.ActiveInn = $null
    return $true
}

function Get-InnkeeperHouseTalk {
    param($Game)

    $inn = $Game.Town.ActiveInn
    $flag = "InnkeeperHouseTalk_$($inn.Id)"

    switch ($inn.Id) {
        "bent_nail" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "'This place stands because the roof leaks slower than the patrons bleed,' Marta says. 'That counts as luxury in this quarter.'"
            }

            return "Marta wipes down the same scarred patch of bar. 'Bent Nail's still standing. That's the whole business plan.'"
        }
        "lantern_rest" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Oren smooths a hand over the polished counter. 'Merchants pay for predictability. Warm food, clean rooms, and no knives in the hall. That keeps a house alive.'"
            }

            return "Oren smiles faintly. 'A quiet house is good business. If people sleep well, they come back with coin.'"
        }
        "silver_kettle" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Madam Seraphine glances across the lamp-lit room with proprietary pride. 'Comfort is theater, darling. People pay to believe they are safer, softer, and more important than the city outside allows.'"
            }

            return "Madam Seraphine adjusts a silver lamp-cap by a fraction. 'Standards are maintained one tiny correction at a time.'"
        }
        default {
            return "$($inn.Keeper) shrugs. 'A roof, a ledger, and enough patience to outlast the city. That's innkeeping.'"
        }
    }
}

function Get-InnkeeperClienteleTalk {
    param($Game)

    $inn = $Game.Town.ActiveInn
    $flag = "InnkeeperClienteleTalk_$($inn.Id)"

    switch ($inn.Id) {
        "bent_nail" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Marta jerks a thumb at the room. 'Dockers, bruisers, runners, and people too tired to lie about who they are. Best kind of guest, if you ask me.'"
            }

            return "Marta snorts. 'Same lot as always. Hard hands, bad tempers, and the occasional useful rumor.'"
        }
        "lantern_rest" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Oren lowers his voice a little. 'Caravan guards, factors, road captains, and sensible sellswords. People who like steady terms more than surprises.'"
            }

            return "Oren glances toward the tables. 'Traders and traveling steel. Enough stories to fill the room, but not many fools.'"
        }
        "silver_kettle" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Madam Seraphine smiles over the rim of a crystal glass. 'Clerks with ambitions, patrons with money, and people who would rather whisper than shout. They are easier to serve and far harder to impress.'"
            }

            return "Madam Seraphine's eyes flick over the upper tables. 'The same soft voices, the same expensive worries, and the same dangerous little favors.'"
        }
        default {
            return "$($inn.Keeper) glances around the room. 'Mostly regulars, and regulars are how a house survives.'"
        }
    }
}

function Get-InnkeeperLocalRumorTalk {
    param($Game)

    $inn = $Game.Town.ActiveInn
    $flag = "InnkeeperLocalRumorTalk_$($inn.Id)"

    switch ($inn.Id) {
        "bent_nail" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Marta tips her head toward the back booths. 'If city trouble is looking for a quiet door, it usually finds the river quarter first. Cheap locks and desperate people make easy cover.'"
            }

            return "Marta grunts. 'Same river talk as before. Too many crates moving at bad hours and too many folk pretending not to notice.'"
        }
        "lantern_rest" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Oren lowers his voice. 'Road captains are nervous. Not panicked, just cautious. That is worse. It means the trouble has pattern, not noise.'"
            }

            return "Oren folds a towel over one arm. 'Travelers still talk like they expect the city to stabilize. None of them sound convinced.'"
        }
        "silver_kettle" {
            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Madam Seraphine smiles without warmth. 'The polished version is that commerce is under strain. The honest version is that someone is profiting from fear while better-dressed people pretend to be surprised.'"
            }

            return "Madam Seraphine's gaze drifts toward the upper tables. 'The wealthy are still pretending this is temporary. That usually means it is not.'"
        }
        default {
            return "$($inn.Keeper) shrugs. 'People talk. Most of it is nerves, some of it is useful.'"
        }
    }
}

function Start-InnBookingConversation {
    param($Game)

    $inn = $Game.Town.ActiveInn

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "1. Keep the room" "White"
        Write-ColorLine "2. Cancel the booking" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene "$($inn.Keeper) gives a short nod and leaves the room booked under Borzig's name."
                Write-ColorLine ""
                return "Keep"
            }
            "2" {
                if (Resolve-InnBookingCancellation -Game $Game) {
                    return "Cancelled"
                }
            }
            "0" {
                return "Back"
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}

function Start-InnkeeperMenu {
    param($Game)

    $inn = $Game.Town.ActiveInn

    while ($true) {
        Write-SectionTitle -Text "Innkeeper" -Color "Yellow"
        Write-Scene "$($inn.Keeper) stands behind the bar, keeping one eye on the room and the other on Borzig."
        $metInnkeeperKey = "InnkeeperMet_$($inn.Id)"
        $repeatVisit = [bool]$Game.Town.InnFlags[$metInnkeeperKey]
        Write-Scene (Get-InnKeeperGreeting -Inn $inn -Hero $Game.Hero -RepeatVisit $repeatVisit)
        $Game.Town.InnFlags[$metInnkeeperKey] = $true
        Write-ColorLine ""
        Write-ColorLine "1. Ask about the house" "White"
        Write-ColorLine "2. Ask what sort of people stay here" "White"
        Write-ColorLine "3. Ask what people have been saying lately" "White"
        Write-ColorLine "4. Discuss your room booking" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Get-InnkeeperHouseTalk -Game $Game)
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Get-InnkeeperClienteleTalk -Game $Game)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Get-InnkeeperLocalRumorTalk -Game $Game)
                Write-ColorLine ""
            }
            "4" {
                $bookingResult = Start-InnBookingConversation -Game $Game

                if ($bookingResult -eq "Cancelled") {
                    return "Cancelled"
                }
            }
            "0" {
                return "Back"
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
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
        $roomVisitKey = "InnRoomVisited_$($inn.Id)"

        if (-not $Game.Town.InnFlags[$roomVisitKey]) {
            Write-Scene "Borzig's room at $($inn.Name) is modestly lit, closed off from the street below, and blessedly still."
            $Game.Town.InnFlags[$roomVisitKey] = $true
        }
        else {
            Write-Scene "Borzig's room at $($inn.Name) waits in welcome silence above the city's noise."
        }

        Write-ColorLine "Inn: $($inn.Name) | Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Rest for the night" "White"
        Write-ColorLine "2. Check inventory" "White"
        Write-ColorLine "3. Check quest log" "White"
        Write-ColorLine "4. Spend time in the common room" "White"
        Write-ColorLine "5. Manage stored gear" "White"
        Write-ColorLine "6. Speak with the innkeeper" "White"
        Write-ColorLine "7. Return to the city streets" "White"
        Write-ColorLine "0. End the adventure for now" "White"
        Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Resolve-BookedInnNightRest -Game $Game -HeroHP $HeroHP | Out-Null
            }
            "0" {
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
                Start-InnEveningMenu -Game $Game
            }
            "5" {
                Start-InnStorageMenu -Hero $Game.Hero
            }
            "6" {
                $innkeeperResult = Start-InnkeeperMenu -Game $Game

                if ($innkeeperResult -eq "Cancelled") {
                    return "BookingCancelled"
                }
            }
            "7" {
                return "BackToTown"
            }
            "T" {
                Toggle-TextSpeed | Out-Null
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

    if ($null -ne $Game.Town.ActiveInn) {
        Write-Scene "$($Game.Hero.Name) already has a room at $($Game.Town.ActiveInn.Name)."
        Write-Scene "If he wants to move, he needs to speak with the keeper and cancel that booking first."
        Write-ColorLine ""
        return "AlreadyBooked"
    }

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


