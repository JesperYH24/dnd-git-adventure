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

    $heroName = $Game.Hero.Name

    switch ($Inn.Id) {
        "bent_nail" {
            if ($EventRoll -le 35) {
                Write-Scene "A drunken carter mistakes $heroName's silence for mockery, and the common room suddenly wants a fight."
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
                    Write-Scene "Marta barks the room quiet and tosses $heroName 3 SP from the pile of side bets."
                }
                else {
                    Write-Scene "Marta hauls the loser out by the collar and tells both fools to sleep it off."
                }

                return
            }

            if ($EventRoll -le 65) {
                if (-not $Game.Town.InnFlags["BentNailShadyRumor"]) {
                    $Game.Town.InnFlags["BentNailShadyRumor"] = $true
                    Write-Scene "A smuggler at the next table mutters about easy coin moving goods through back alleys. $heroName learns where the city's shadier business tends to gather."
                }
                else {
                    Write-Scene "The same hard-eyed smugglers are here again, still talking low and watching everyone."
                }

                return
            }
        }
        "lantern_rest" {
            if ($EventRoll -le 15) {
                Write-Scene "A mercenary with too much ale and too much pride takes offense when $heroName refuses to trade boasts."
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
                    Write-Scene "The room settles fast once Pell hits the boards. Oren sends $heroName's stew up free of charge."
                }
                else {
                    Write-Scene "Oren breaks it up before it turns ugly and quietly warns $heroName that not every paying guest deserves patience."
                }

                return
            }

            if ($EventRoll -le 55) {
                if (-not $Game.Town.InnFlags["LanternMerchantDiscount"]) {
                    $Game.Town.InnFlags["LanternMerchantDiscount"] = $true
                    if ($Game.Hero.Class -eq "Bard") {
                        $Game.Town.Relationships["LanternAudience"] = "Warm"
                        Set-TownOfferDiscount -Game $Game -OfferId "instrument_shop_stage_lute" -DiscountCopper 20
                        Write-Scene "A caravan factor shares road gossip over supper, then decides $heroName belongs in better company than the back corner. By dessert, the instrument maker near the square has been told to shave the price on a Stage Lute."
                    }
                    else {
                        Set-TownOfferDiscount -Game $Game -OfferId "market_healing_potion" -DiscountCopper 10
                        Write-Scene "A caravan factor shares road gossip over supper, then tells the market to give $heroName a better rate on basic healing supplies."
                    }
                }
                else {
                    Write-Scene "Travelers trade the latest road rumors across the room, but nothing sharper than that reaches $heroName tonight."
                }

                return
            }
        }
        "silver_kettle" {
            if ($EventRoll -le 10) {
                Write-Scene "A silk-draped bravo mistakes $heroName's plain clothes for weakness and ends up demanding satisfaction with bare hands."
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
                    Write-Scene "The house guards end it the instant $heroName is outmatched, which is still kinder than most cheap inns manage."
                }

                return
            }

            if ($EventRoll -le 70) {
                if (-not $Game.Town.InnFlags["SilverKettleContact"]) {
                    $Game.Town.InnFlags["SilverKettleContact"] = $true
                    if ($Game.Hero.Class -eq "Bard") {
                        $Game.Town.InnFlags["SilverKettleArtistWelcome"] = $true
                        $Game.Town.InnFlags["SilverKettlePrivateInvite"] = $true
                        $Game.Town.Relationships["MerchantPatron"] = "Favorable"
                        Write-Scene "Between candlelight and quiet music, a patron at the upper tables takes notice of $heroName and quietly decides the performer belongs in smaller, richer rooms. Before the night is done, a private salon invitation is left waiting with the bill."
                    }
                    else {
                        $Game.Town.Relationships["MagistrateClerk"] = "Introduced"
                        Set-TownOfferDiscount -Game $Game -OfferId "apothecary_greater_healing_potion" -DiscountCopper 30
                        Write-Scene "Between candlelight and quiet music, a magistrate's clerk takes notice of $heroName and offers a proper introduction to more respectable circles."
                    }
                }
                else {
                    Write-Scene "The upper tables continue their soft, expensive gossip. $heroName is watched now with recognition instead of suspicion."
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

    $heroName = $Game.Hero.Name

    if ($Choice -eq "1") {
        $currentTier = Get-CurrentStoryQuestTier -Game $Game

        if ($currentTier -lt 2) {
            if (-not $Game.Town.InnFlags["BentNailShadyRumor"]) {
                $Game.Town.InnFlags["BentNailShadyRumor"] = $true
                Write-Scene "$heroName catches fragments about quiet cargo and sealed doors, but the scarred fixer in the back only gives the table one measuring look before it closes around its own secrets."
                Write-EmphasisLine -Text "The Bent Nail lead is noted. Come back once Tier 2 city work opens and the room has reason to take $heroName seriously." -Color "Yellow"
            }
            else {
                Write-Scene "The same hard-eyed regulars are still here, but they are not ready to trust $heroName with more than dockside rumor yet."
                Write-EmphasisLine -Text "The deeper Bent Nail lead should open once Tier 2 story quests are available." -Color "Yellow"
            }

            return
        }

        if (-not $Game.Town.InnFlags["BentNailBrokerInfo"]) {
            $Game.Town.InnFlags["BentNailBrokerInfo"] = $true
            $Game.Town.Relationships["UnderstreetBroker"] = "Named"
            Write-Scene "$heroName keeps low and listens while a scarred fixer maps out which alleys carry stolen cargo, hush money, and desperate errands."
            Write-EmphasisLine -Text "$heroName leaves the table with a cleaner read on who in the Bent Nail still knows the understreet routes by name." -Color "Yellow"
        }
        else {
            Write-Scene "The same smugglers are still talking around $heroName, but tonight they offer nothing sharper than what was already learned."
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
            Write-Scene "For once the table laughs with $heroName instead of at the joke, and the winnings come away clean: 2 SP."
        }

        return
    }

    Write-Scene "$heroName keeps to the wall and lets the room talk around the silence."
}

function Resolve-LanternRestEveningChoice {
    param(
        $Game,
        [string]$Choice,
        [int]$RiskRoll = 0
    )

    $heroName = $Game.Hero.Name

        if ($Choice -eq "1") {
            if (-not $Game.Town.InnFlags["LanternTradeAdvice"]) {
                $Game.Town.InnFlags["LanternTradeAdvice"] = $true
                if ($Game.Hero.Class -eq "Bard") {
                    Set-TownOfferDiscount -Game $Game -OfferId "instrument_shop_stage_lute" -DiscountCopper 20
                    $Game.Town.Relationships["LanternAudience"] = "Warm"
                    Write-Scene "Merchants and factors wave $($Game.Hero.Name) into the better half of the room, compare supper-room tastes, and quietly point him toward the instrument maker who outfits performers that travelers actually remember."
                    Write-EmphasisLine -Text "$($Game.Hero.Name) earns warm standing at the Lantern Rest. The Stage Lute is now cheaper at the instrument shop." -Color "Yellow"
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $Game.Town.Relationships["LanternMercenaries"] = "Warm"

                    if ($Game.Hero.Level -ge 3) {
                        Set-TownOfferDiscount -Game $Game -OfferId "market_throwing_axe" -DiscountCopper 30
                        Write-Scene "The caravan guards make room for $heroName, compare bruises, and point toward a trader carrying balanced axes meant for fighters who expect a chase before the real violence starts."
                        Write-EmphasisLine -Text "$heroName earns warm standing among the Lantern Rest mercenaries. The Balanced Throwing Axe is now cheaper at the market." -Color "Yellow"
                    }
                    else {
                        Set-TownOfferDiscount -Game $Game -OfferId "market_handaxe" -DiscountCopper 20
                        Write-Scene "Merchants and caravan guards swap practical road talk with $heroName and end up pointing toward a market hand axe that suits ugly work in alleys, wagons, and close quarters."
                        Write-EmphasisLine -Text "$heroName earns practical market favor at the Lantern Rest. The Hand Axe is now cheaper at the market." -Color "Yellow"
                    }
                }
                else {
                    Set-TownOfferDiscount -Game $Game -OfferId "market_handaxe" -DiscountCopper 20
                    Write-Scene "Merchants compare ledgers over stew and quietly point $heroName toward which traders gouge and which ones fear a hard bargain."
                    Write-EmphasisLine -Text "$heroName learns practical market information. The Hand Axe is now cheaper at the market." -Color "Yellow"
                }
        }
        else {
            if ($Game.Hero.Class -eq "Bard") {
                Write-Scene "The merchant tables still make room for $($Game.Hero.Name), and more than one traveler asks whether he will be taking the room's song again tomorrow."
            }
            else {
                Write-Scene "The merchant tables are good company, but their useful advice has already been spent once."
            }
        }

        return
    }

    if ($Choice -eq "2") {
        if (-not $Game.Town.InnFlags["LanternGuardRumor"]) {
            $Game.Town.InnFlags["LanternGuardRumor"] = $true
            $Game.Town.Relationships["NightCaptain"] = "Mentioned"
            if ($Game.Hero.Class -eq "Bard") {
                Write-Scene "Caravan guards and watch hands admit that a smooth tongue settles almost as many roadside problems as a drawn blade. Before the cups empty, they point $($Game.Hero.Name) toward captains who remember a face that can hold a room without starting a riot."
                Write-EmphasisLine -Text "$($Game.Hero.Name) hears guard-station rumors that suit a bard's public touch as much as a fighter's nerve." -Color "Yellow"
            }
            else {
                Write-Scene "Caravan guards swap route warnings with watchmen and mention a captain who pays well for reliable steel on dirty night work."
                Write-EmphasisLine -Text "$heroName hears new guard-station rumors that can feed later city jobs." -Color "Yellow"
            }
        }
        else {
            if ($Game.Hero.Class -eq "Bard") {
                Write-Scene "The guards greet $($Game.Hero.Name) like a man who might solve a bad scene before it becomes a report, but tonight they have no fresher rumor than that."
            }
            else {
                Write-Scene "The guards nod to $heroName like a familiar face now, but tonight they have no fresh work to whisper about."
            }
        }

        return
    }

    if ($RiskRoll -le 0) {
        $RiskRoll = Roll-Dice -Sides 100
    }

    if ($RiskRoll -le 25) {
        Write-Scene "Too much ale and too many boasts sour the room, and a visiting sword hand decides $heroName looks like trouble worth testing."
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
        Write-Scene "The common room stays loud but harmless, and $heroName comes away with nothing worse than a sore voice."
    }
}

function Resolve-SilverKettleEveningChoice {
    param(
        $Game,
        [string]$Choice,
        [int]$RiskRoll = 0
    )

    $heroName = $Game.Hero.Name

        if ($Choice -eq "1") {
            if (-not $Game.Town.InnFlags["SilverKettleEconomicInsight"]) {
                $Game.Town.InnFlags["SilverKettleEconomicInsight"] = $true
                $Game.Town.QuestPayoutBonusCopper = 20
                if ($Game.Hero.Class -eq "Bard") {
                    $Game.Town.InnFlags["SilverKettleArtistWelcome"] = $true
                    Write-Scene "Under silver lamps and careful laughter, $($Game.Hero.Name) listens while patrons discuss salon fees, private invitations, and which houses pay best for talent they can call their own for an evening."
                    Write-EmphasisLine -Text "$($Game.Hero.Name) learns how upper-room patrons spend. Future city payouts can improve, and the Silver Kettle starts treating him like an artist worth remembering." -Color "Yellow"
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    Set-TownOfferDiscount -Game $Game -OfferId "apothecary_greater_healing_potion" -DiscountCopper 30
                    Set-TownOfferDiscount -Game $Game -OfferId "apothecary_battle_tonic" -DiscountCopper 40
                    Write-Scene "$heroName listens while quiet money talks about hard work no clerk can be seen asking for. Before the glasses are empty, one patron has already named the apothecary who keeps stronger restoratives aside for fighters expected to finish ugly contracts."
                    Write-EmphasisLine -Text "$heroName gains upper-room contract insight. Future city payouts can improve, and stronger healing supplies are now easier to afford." -Color "Yellow"
                }
                else {
                    Write-Scene "$heroName listens while minor nobles and clerks talk contracts, tariffs, and which patrons always pay above the board for fast results."
                    Write-EmphasisLine -Text "$heroName gains economic insight. Future city quest payouts can be improved later." -Color "Yellow"
                }
        }
        else {
            if ($Game.Hero.Class -eq "Bard") {
                Write-Scene "The contract talk has changed now that $($Game.Hero.Name) is known. The room speaks around him less like hired muscle and more like expensive company."
            }
            else {
                Write-Scene "The contract talk is still there if $heroName wants it, but the useful part has already been learned."
            }
        }

        return
    }

    if ($Choice -eq "2") {
        if (-not $Game.Town.InnFlags["SilverKettlePatronFavor"]) {
            $Game.Town.InnFlags["SilverKettlePatronFavor"] = $true
            $Game.Town.Relationships["MerchantPatron"] = "Favorable"
            if ($Game.Hero.Class -eq "Bard") {
                Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 5 | Out-Null
                $Game.Town.InnFlags["SilverKettlePrivateInvite"] = $true
                Write-Scene "A patron with taste, money, and too much free time decides $($Game.Hero.Name) belongs closer to the candlelight than the wall. By the end of the introduction, Madam Seraphine is holding 5 SP in room credit and a private card for a future salon."
                Write-EmphasisLine -Text "$($Game.Hero.Name) earns upper-table favor and an early private invitation." -Color "Yellow"
            }
            else {
                Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 5 | Out-Null
                Write-Scene "A wealthy patron takes to $heroName's plain honesty and leaves 5 SP with Madam Seraphine to cover the next meal and wine."
                Write-EmphasisLine -Text "$heroName earns a small favor among the upper tables." -Color "Yellow"
            }
        }
        else {
            if ($Game.Hero.Class -eq "Bard") {
                Write-Scene "The upper room remembers $($Game.Hero.Name) well enough now that introductions come easier than requests. The Silver Kettle clearly expects to see him again."
            }
            else {
                Write-Scene "The upper room remembers $heroName well enough now, and that alone opens more doors than a second introduction would."
            }
        }

        return
    }

    if ($RiskRoll -le 0) {
        $RiskRoll = Roll-Dice -Sides 100
    }

    if ($RiskRoll -le 10) {
        Write-Scene "A silk-clad bravo mistakes $heroName's silence for contempt, and even this polished room cannot stop the old language of fists."
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
        Write-Scene "$heroName takes the evening in quiet comfort, and the room's easy courtesy leaves the stay feeling better received than expected."
    }
}

function Start-InnEveningMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn
    $showIntro = $true
    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

    while ($true) {
        $roomTitle = if ($isNight) { "Common Room" } else { "Dining Room" }
        Write-SectionTitle -Text $roomTitle -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Common Room"

        switch ($inn.Id) {
            "bent_nail" {
                if ($showIntro) {
                    if ($isNight) {
                        Write-Scene "The Bent Nail is all smoke, elbows, and hard stares. Trouble is never far away, but neither are the people who know where the city's dirt is buried."
                    }
                    else {
                        Write-Scene "By day the Bent Nail runs on thick stew, coarse bread, and the sort of tired dockside silence that only slowly turns back into rumor."
                    }

                    if ($isNight -and (Get-CurrentStoryQuestTier -Game $Game) -lt 2) {
                        Write-EmphasisLine -Text "The back tables are watching $($Game.Hero.Name), but the real Bent Nail whispers will likely open up once Tier 2 city work is unlocked." -Color "Yellow"
                    }
                }
                if ($isNight) {
                    Write-ColorLine "1. Listen to the smugglers and dockside fixers over dark ale" "White"
                    Write-ColorLine "2. Join a loud dice table" "White"
                }
                else {
                    Write-ColorLine "1. Share rough stew with the dockers and fixers" "White"
                    Write-ColorLine "2. Sit with the room and nurse a bitter midday drink" "White"
                }
                if ($isNight -and $Game.Hero.Class -eq "Bard") {
                    Write-ColorLine "4. Play a rough set for the room" "White"
                }
                $bentNailQuest = Find-TownQuest -Game $Game -QuestId "bent_nail_whispers"

                if ($isNight -and $null -ne $bentNailQuest -and (Is-TownQuestUnlocked -Game $Game -Quest $bentNailQuest) -and -not $bentNailQuest.Completed) {
                    $questStatus = if ($bentNailQuest.Accepted) { "Accepted" } else { "Available" }
                    Write-ColorLine "3. Follow up the Bent Nail whispers [$questStatus]" "White"
                }
            }
            "lantern_rest" {
                if ($showIntro) {
                    if (-not $isNight -and $Game.Hero.Class -eq "Bard") {
                        Write-Scene "The Lantern Rest opens into a bright, orderly dining room where hot breakfast and midday meals give merchants a reason to linger and listen."
                    }
                    elseif (-not $isNight) {
                        Write-Scene "The Lantern Rest feels steady by day: hot plates, clean tables, and practical people taking real meals before the next road or ledger starts making demands again."
                    }
                    elseif ($Game.Hero.Class -eq "Bard") {
                        Write-Scene "The Lantern Rest feels built for a working bard: warm light, decent listeners, and enough merchants under one roof to turn a good evening into tomorrow's invitation."
                    }
                    else {
                        Write-Scene "The Lantern Rest sits in the middle ground: traders, caravan guards, and practical folk who know something useful if you earn their patience."
                    }
                }
                if ($isNight) {
                    Write-ColorLine "1. Share supper with the merchants" "White"
                    Write-ColorLine "2. Sit with the guards and caravan hands over dinner and drink" "White"
                    Write-ColorLine "3. Join the room's drinking song" "White"
                }
                else {
                    Write-ColorLine "1. Sit down to breakfast with the merchants" "White"
                    Write-ColorLine "2. Take a meal with the guards and caravan hands" "White"
                    Write-ColorLine "3. Linger over coffee, broth, and road gossip" "White"
                }
                if ($isNight -and $Game.Hero.Class -eq "Bard") {
                    Write-ColorLine "4. Take over the room with a traveler's set" "White"
                }
            }
            "silver_kettle" {
                if ($showIntro) {
                    if (-not $isNight -and $Game.Hero.Class -eq "Bard") {
                        Write-Scene "The Silver Kettle by day is all fine service and quiet luncheon talk, where contracts, taste, and opportunity are plated as carefully as the food."
                    }
                    elseif (-not $isNight) {
                        Write-Scene "The Silver Kettle by day hums with polished luncheon conversation, careful silverware, and the sort of expensive calm that expects to be obeyed."
                    }
                    elseif ($Game.Hero.Class -eq "Bard") {
                        Write-Scene "The Silver Kettle hums with polished manners, private money, and the dangerous possibility that the right performance could lift $($Game.Hero.Name) into rooms the rest of the city only serves."
                    }
                    else {
                        Write-Scene "The Silver Kettle hums with careful laughter, polished manners, and the kind of money that changes lives without ever raising its voice."
                    }
                }
                if ($isNight) {
                    Write-ColorLine "1. Listen to the contract talk over wine and a fine dinner" "White"
                    Write-ColorLine "2. Make a polished introduction to the upper tables" "White"
                    Write-ColorLine "3. Stay visible and see who takes offense" "White"
                }
                else {
                    Write-ColorLine "1. Listen to the contract talk over luncheon" "White"
                    Write-ColorLine "2. Accept a polite seat at the upper tables" "White"
                    Write-ColorLine "3. Stay visible through the meal service and watch the room" "White"
                }
                if ($isNight -and $Game.Hero.Class -eq "Bard") {
                    Write-ColorLine "4. Offer a polished evening performance" "White"
                }
            }
        }

        $showIntro = $false

        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to inn" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "0") {
            return
        }

        if ($choice -eq "S") {
            Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            Write-ColorLine ""
            continue
        }

        switch ($inn.Id) {
            "bent_nail" {
                if ($choice -eq "4" -and $isNight -and $Game.Hero.Class -eq "Bard") {
                    Resolve-BardPerformance -Game $Game -VenueId "bent_nail_stage" | Out-Null
                    Write-ColorLine ""
                    continue
                }

                if ($choice -eq "3" -and $isNight) {
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
                            Write-EmphasisLine -Text "This lead is now in the quest log. Start it or prepare for it there." -Color "Yellow"
                        }
                    }
                    else {
                        Write-EmphasisLine -Text "This lead is handled from the quest log. Start it or prepare for it there." -Color "Yellow"
                    }

                    Write-ColorLine ""
                    continue
                }

                Resolve-BentNailEveningChoice -Game $Game -Choice $choice
            }
            "lantern_rest" {
                if ($choice -eq "4" -and $isNight -and $Game.Hero.Class -eq "Bard") {
                    Resolve-BardPerformance -Game $Game -VenueId "lantern_rest_stage" | Out-Null
                    Write-ColorLine ""
                    continue
                }

                Resolve-LanternRestEveningChoice -Game $Game -Choice $choice
            }
            "silver_kettle" {
                if ($choice -eq "4" -and $isNight -and $Game.Hero.Class -eq "Bard") {
                    Resolve-BardPerformance -Game $Game -VenueId "silver_kettle_stage" | Out-Null
                    Write-ColorLine ""
                    continue
                }

                Resolve-SilverKettleEveningChoice -Game $Game -Choice $choice
            }
        }

        Write-ColorLine ""
    }
}

function Get-InnAmbientVisitText {
    param(
        $Game,
        $Inn
    )

    $flagKey = "InnAmbientIndex_$($Inn.Id)"
    $currentIndex = if ($null -ne $Game.Town.InnFlags[$flagKey]) { [int]$Game.Town.InnFlags[$flagKey] } else { 0 }
    $isBard = $Game.Hero.Class -eq "Bard"
    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

    $lines = switch ($Inn.Id) {
        "bent_nail" {
            if ($isNight) {
                @(
                    "The Bent Nail leans into the hour with rough laughter, chipped mugs, and the feeling that half the room has heard something useful and plans to sell it badly.",
                    "Tonight the Bent Nail sounds like dice, boots, and low arguments that never quite become fights.",
                    $(if ($isBard) { "A few eyes follow $($Game.Hero.Name) with the half-grin reserved for someone this room already considers worth hearing." } else { "A few hard cases glance $($Game.Hero.Name)'s way and then think better of turning curiosity into a challenge." })
                )
            }
            else {
                @(
                    "By daylight the Bent Nail is more stew kettle than brawl pit, full of dockworkers chewing through thick bread and bad tempers slowly.",
                    "The room smells of boiled onions, stale ale, and a floor that survived last night well enough to host today's meal service.",
                    $(if ($isBard) { "A few regulars watch $($Game.Hero.Name) over chipped bowls like they are deciding whether a performer belongs in a room this blunt before sundown." } else { "A few hard-used laborers give $($Game.Hero.Name) the short nod reserved for someone who looks like they eat without complaint and leave without fuss." })
                )
            }
        }
        "lantern_rest" {
            if ($isNight) {
                @(
                    "The Lantern Rest feels bright in a practical way: warm plates, steady voices, and travelers trying to believe tomorrow's road will be kinder than the last one.",
                    "Caravan talk and merchant gossip weave through the Lantern Rest tonight, easy enough to listen to without ever fully trusting.",
                    $(if ($isBard) { "At the Lantern Rest, the room seems glad to have $($Game.Hero.Name) under the same roof again, as if good company might yet turn into a good evening." } else { "At the Lantern Rest, the room gives $($Game.Hero.Name) the respectful space reserved for someone who looks capable of finishing bad business without making more of it." })
                )
            }
            else {
                @(
                    "The Lantern Rest carries the comfort of a proper meal service by day: hot bread, decent stew, and ledgers being discussed over plates instead of cups.",
                    "Merchants and caravan hands eat like people planning routes, repairs, and tomorrow's departures one mouthful at a time.",
                    $(if ($isBard) { "At the Lantern Rest by day, $($Game.Hero.Name) looks less like entertainment and more like the sort of guest worth inviting to the better table before the coffee cools." } else { "At the Lantern Rest by day, the room gives $($Game.Hero.Name) the practical courtesy reserved for someone who might travel out on the same dangerous roads." })
                )
            }
        }
        "silver_kettle" {
            if ($isNight) {
                @(
                    "The Silver Kettle carries itself with polished calm, all measured voices and the soft certainty that somebody important is always one table away from overhearing everything.",
                    "Soft glass, lower laughter, and carefully aimed conversation make the Silver Kettle feel expensive long before the bill arrives.",
                    $(if ($isBard) { "More than one table at the Silver Kettle seems to notice $($Game.Hero.Name) on arrival and quietly adjust the room around that fact." } else { "The Silver Kettle still studies $($Game.Hero.Name) like an unusual guest, but by now even its finer tables do so with more curiosity than doubt." })
                )
            }
            else {
                @(
                    "By day the Silver Kettle serves its elegance on plates as much as in manners, with polished cutlery, quiet luncheon talk, and servants who move like part of the decor.",
                    "The room sounds softer in daylight: fine dishes, measured voices, and people discussing contracts as if appetite and ambition were the same course.",
                    $(if ($isBard) { "At the Silver Kettle by day, more than one table seems to recognize that $($Game.Hero.Name) might be worth hearing later, even while the room is still pretending lunch is only lunch." } else { "The Silver Kettle studies $($Game.Hero.Name) over white linen and bright silver, as if deciding whether this is a curiosity, a contract, or both." })
                )
            }
        }
        default {
            if ($isNight) {
                @("The inn settles around the night in its own rhythm, offering shelter, noise, and the promise of a door that closes behind it all.")
            }
            else {
                @("The inn moves through the day on food, voices, and the steady comfort of a room built to hold travelers between roads.")
            }
        }
    }

    if ($lines.Count -eq 0) {
        return ""
    }

    $selectedLine = $lines[$currentIndex % $lines.Count]
    $Game.Town.InnFlags[$flagKey] = $currentIndex + 1
    return $selectedLine
}

function Start-InnVisitMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        Write-Scene "$($Game.Hero.Name) has not taken a room yet."
        Write-ColorLine ""
        return "NoInn"
    }

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== $($inn.Name.ToUpper()) =====" "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Inn Visit"
        $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"
        if (-not [bool]$Game.Town.InnFlags["InnVisitSeen_$($inn.Id)"]) {
            Write-Scene "$($inn.Name) wraps around $($Game.Hero.Name) like its own little world of floorboards, low voices, and people who plan to sleep under the same roof tonight."
            $Game.Town.InnFlags["InnVisitSeen_$($inn.Id)"] = $true
        }
        else {
            Write-Scene (Get-InnAmbientVisitText -Game $Game -Inn $inn)
        }
        Write-ColorLine "Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine $(if ($isNight) { "How do you want to spend the evening here?" } else { "What do you want to do?" }) "Cyan"
        Write-ColorLine "1. Go to your room" "White"
        if ($isNight) {
            Write-ColorLine "2. Spend time in the common room" "White"
        }
        else {
            Write-ColorLine "2. Sit down in the dining room" "White"
        }
        Write-ColorLine "3. Speak with the innkeeper" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "G. Save adventure" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                if ($innMenuResult -eq "EndGame") {
                    return "EndGame"
                }

                if ($innMenuResult -eq "BackToInn") {
                    continue
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
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "G" {
                Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null
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

    $heroName = $Game.Hero.Name

    while ($true) {
        Write-SectionTitle -Text "Work Off the Room" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Inn Visit"
        Write-Scene "$($Inn.Keeper) looks $heroName over, then points toward the sort of work that keeps an inn alive after dark."
        Write-Scene "If $heroName cannot pay in coin tonight, the bill can be paid in sweat."
        Write-ColorLine ""
        Write-ColorLine "1. Haul kegs and split firewood (STR)" "White"
        Write-ColorLine "2. Scrub tables and reset the room (CON)" "White"
        Write-ColorLine "3. Hold the late door and break up trouble (STR)" "White"
        Write-ColorLine "0. Back to inn selection" "DarkGray"
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
                $taskText = "$heroName shoulders casks, drags split wood, and keeps the cellar moving until every breath feels earned."
            }
            "2" {
                $ability = "CON"
                $taskText = "$heroName spends the late hours hauling benches straight, scrubbing down tables, and staying upright long past comfort."
            }
            "3" {
                $ability = "STR"
                $taskText = "$heroName stands the late door, hauling drunks apart before fists become blood on the floorboards."
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
            Write-Scene "$($Inn.Keeper) grudgingly admits the work was worth more than a bed and slips $heroName a small tip."
        }
        elseif ($total -ge $dc) {
            Write-Scene "$($Inn.Keeper) decides the work settles the bill well enough."
        }
        else {
            Write-Scene "$($Inn.Keeper) is not impressed, but the work is done and the room is covered."
        }

        $Game.Town.ActiveInn = $Inn
        $Game.Town.MustChooseFirstInn = $false
        Advance-TownToNextDay -Game $Game -StartingTimeOfDay "Day" -WorkedForRoomToday $true -RingFoughtToday $true
        Restore-HeroBardicInspiration -Hero $Game.Hero | Out-Null
        Restore-HeroRages -Hero $Game.Hero
        Clear-HeroBuff -Hero $Game.Hero
        $HeroHP.Value = $Game.Hero.HP
        Resolve-InnLongRestLevelUp -Game $Game -HeroHP $HeroHP | Out-Null

        Write-Scene "$heroName drops into bed exhausted. The room is paid for, but the night leaves the body too worn out for the fighting ring tomorrow."

        if ($tipCopper -gt 0) {
            Write-EmphasisLine -Text "$($Game.Hero.Name) also earns $(Convert-CopperToCurrencyText -Copper $tipCopper) for the effort." -Color "Yellow"
        }

        if (-not $Game.Town.ChapterOneComplete) {
            $Game.Town.ChapterOneComplete = $true
            Write-ColorLine ""
            Write-SectionTitle -Text "Chapter One Complete" -Color "Green"
            Write-EmphasisLine -Text "$heroName survives the cave, reaches the city, and earns the first true night behind safe walls." -Color "Green"
            Write-Scene "The tutorial ends with sore hands, a cheap room, and the feeling that city life has to be earned one hard night at a time."
        }

        Write-ColorLine ""
        return $true
    }
}

function Resolve-InnLongRestLevelUp {
    param(
        $Game,
        [ref]$HeroHP
    )

    $hpMode = ""

    if (Get-UiOutputSuppressed) {
        $hpMode = "F"
    }

    $levelUpResult = Resolve-HeroLongRestLevelUp -Hero $Game.Hero -HeroHP $HeroHP -HPMode $hpMode

    if (-not $levelUpResult.LeveledUp) {
        return $levelUpResult
    }

    Write-SectionTitle -Text "Level Up" -Color "Green"

    foreach ($result in $levelUpResult.Results) {
        Write-EmphasisLine -Text "$($Game.Hero.Name) reaches level $($result.Level)." -Color "Green"

        if ($result.Mode -eq "R") {
            Write-Scene "He rolls a $($result.Roll) on the hit die and gains $($result.Gain) max HP."
        }
        else {
            Write-Scene "He takes the fixed increase and gains $($result.Gain) max HP."
        }
    }

    Write-Scene "$($Game.Hero.Name) wakes fully restored at $($Game.Hero.HP) max HP."
    Write-ColorLine ""

    return $levelUpResult
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
        Write-ColorLine "0. Back to inn selection" "DarkGray"
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

    Write-SectionTitle -Text $Inn.Name -Color "Yellow"
    Write-Scene (Get-InnKeeperGreeting -Inn $Inn -Hero $Game.Hero -RepeatVisit $false)
    Write-EmphasisLine -Text "$($Game.Hero.Name) pays $(Convert-CopperToCurrencyText -Copper $Inn.PriceCopper) for a $($Inn.Quality.ToLower()) room." -Color "Yellow"
    Resolve-InnEvent -Game $Game -HeroHP $HeroHP -Inn $Inn -EventRoll $EventRoll
    Clear-HeroBuff -Hero $Game.Hero
    $HeroHP.Value = $Game.Hero.HP
    Advance-TownToNextDay -Game $Game -StartingTimeOfDay "Day"
    Restore-HeroBardicInspiration -Hero $Game.Hero | Out-Null
    Restore-HeroRages -Hero $Game.Hero
    Resolve-InnLongRestLevelUp -Game $Game -HeroHP $HeroHP | Out-Null
    if (-not $Game.Town.ChapterOneComplete) {
        Write-Scene (Format-InnHeroText -Text $Inn.RestText -Hero $Game.Hero)
    }
    else {
        Write-Scene (Get-InnRepeatRestText -Inn $Inn -Hero $Game.Hero)
    }
    Write-Scene "A full night's rest restores $($Game.Hero.Name) to full health, and any lingering combat tonic fades with the morning."
    Write-ColorLine ""

    if (-not $Game.Town.ChapterOneComplete) {
        $Game.Town.ChapterOneComplete = $true
        Write-SectionTitle -Text "Chapter One Complete" -Color "Green"
        Write-EmphasisLine -Text "$($Game.Hero.Name) survives the cave, reaches the city, and earns his first true night behind safe walls." -Color "Green"
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
        Write-Scene "$($Game.Hero.Name) has no room to return to tonight."
        Write-ColorLine ""
        return $false
    }

    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $inn.PriceCopper

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) does not have enough coin to cover another night at $($inn.Name)."
        Write-ColorLine "1. Work off the room tonight" "White"
        Write-ColorLine "2. Keep walking the city instead" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
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

    Write-Scene "$($Game.Hero.Name) closes the shutters, pays $(Convert-CopperToCurrencyText -Copper $inn.PriceCopper) for another night, and lets the city fade to a muffled hum beyond the walls."
    Write-Scene (Get-InnRepeatRestText -Inn $inn -Hero $Game.Hero)
    Clear-HeroBuff -Hero $Game.Hero
    $HeroHP.Value = $Game.Hero.HP
    Advance-TownToNextDay -Game $Game -StartingTimeOfDay "Day"
    Restore-HeroBardicInspiration -Hero $Game.Hero | Out-Null
    Restore-HeroRages -Hero $Game.Hero
    Resolve-InnLongRestLevelUp -Game $Game -HeroHP $HeroHP | Out-Null
    Write-Scene "A full night's rest restores $($Game.Hero.Name) to full health, clears the day from his head, and resets the city for morning."
    Write-ColorLine ""

    return $true
}

function Resolve-InnBookingCancellation {
    param($Game)

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        Write-Scene "$($Game.Hero.Name) does not currently have a room booked."
        Write-ColorLine ""
        return $false
    }

    if ($Game.Hero.StashedInventory.Count -gt 0) {
        Write-Scene "$($inn.Keeper) folds their arms and points toward the room chest."
        Write-Scene "'Clear out your stored gear before you give up the room,' the keeper says."
        Write-ColorLine ""
        return $false
    }

    Write-Scene "$($inn.Keeper) nods once and scratches $($Game.Hero.Name)'s name off the room ledger."
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
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"] = $true
                    return "Marta scratches at the bar and gives $($Game.Hero.Name) a sideways look. 'Strange thing. Ever since you broke that mess under the ward, even the rough houses are sleeping lighter.'"
                }

                return "Marta grunts. 'House is rough as ever, but the whole quarter feels less trapped than it did.'"
            }

            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "'This place stands because the roof leaks slower than the patrons bleed,' Marta says. 'That counts as luxury in this quarter.'"
            }

            return "Marta wipes down the same scarred patch of bar. 'Bent Nail's still standing. That's the whole business plan.'"
        }
        "lantern_rest" {
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"] = $true
                    return "Oren smooths the counter with quiet satisfaction. 'Trade came back faster than I expected once the understreet route was broken. Stable houses notice stable nights.'"
                }

                return "Oren smiles faintly. 'Better for business when the city thinks tomorrow will arrive on time.'"
            }

            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Oren smooths a hand over the polished counter. 'Merchants pay for predictability. Warm food, clean rooms, and no knives in the hall. That keeps a house alive.'"
            }

            return "Oren smiles faintly. 'A quiet house is good business. If people sleep well, they come back with coin.'"
        }
        "silver_kettle" {
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperHouseTalk_Post_$($inn.Id)"] = $true
                    return "Madam Seraphine folds her hands and studies $($Game.Hero.Name) with frank approval. 'Victory changes a room long before it changes a ledger. People are spending more confidently because you reminded them fear can fail.'"
                }

                return "Madam Seraphine smiles into her glass. 'Confidence suits the city better than panic ever did.'"
            }

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

function Get-InnConversationServiceText {
    param(
        $Game,
        [string]$Topic = ""
    )

    $inn = $Game.Town.ActiveInn

    if ($null -eq $inn) {
        return ""
    }

    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

    switch ($inn.Id) {
        "bent_nail" {
            if ($isNight) {
                return "A chipped mug and whatever cheap bottle survived the first rush land on the table while the room keeps one ear on dice, boots, and brewing trouble."
            }

            return "A rough bowl of stew, heel of bread, and watered beer arrive with the kind of efficiency that assumes anyone sitting down at midday means to eat first and talk second."
        }
        "lantern_rest" {
            if ($isNight) {
                return "A proper supper plate and an honest pour of ale arrive first, the kind of service that invites a guest to settle in before the talk gets useful."
            }

            return "Oren's people set down hot breakfast, fresh bread, and a decent pot to drink from, as if good conversation deserves to start with a real meal."
        }
        "silver_kettle" {
            if ($isNight) {
                return "Wine, fine dinner, and polished silver appear in careful order before the real conversation is allowed to begin."
            }

            return "Luncheon is laid out with quiet precision: a light course, bright tea, and the sort of table service that makes even gossip feel expensive."
        }
        default {
            if ($isNight) {
                return "A drink is set down before the talk begins."
            }

            return "A simple meal is set down before the talk begins."
        }
    }
}

function Format-InnConversationText {
    param(
        $Game,
        [string]$Line,
        [string]$Topic = ""
    )

    $serviceText = Get-InnConversationServiceText -Game $Game -Topic $Topic

    if ([string]::IsNullOrWhiteSpace($serviceText)) {
        return $Line
    }

    return "$serviceText $Line"
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
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"] = $true
                    return "Marta lowers her voice. 'Now the talk is not whether the understreet was real. It's who paid Serik and why some coin trails went cold the second you won.'"
                }

                return "Marta's eye narrows. 'The river quarter smells cleaner. The money behind it does not.'"
            }

            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Marta tips her head toward the back booths. 'If city trouble is looking for a quiet door, it usually finds the river quarter first. Cheap locks and desperate people make easy cover.'"
            }

            return "Marta grunts. 'Same river talk as before. Too many crates moving at bad hours and too many folk pretending not to notice.'"
        }
        "lantern_rest" {
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"] = $true
                    return "Oren lowers his voice. 'Trade captains think the road ahead clears now. The smarter ones think someone will try to rebuild what you broke, only quieter.'"
                }

                return "Oren folds a towel over one arm. 'Calmer traffic, sharper rumors. That's usually a sign of money moving into new hands.'"
            }

            if (-not $Game.Town.InnFlags[$flag]) {
                $Game.Town.InnFlags[$flag] = $true
                return "Oren lowers his voice. 'Road captains are nervous. Not panicked, just cautious. That is worse. It means the trouble has pattern, not noise.'"
            }

            return "Oren folds a towel over one arm. 'Travelers still talk like they expect the city to stabilize. None of them sound convinced.'"
        }
        "silver_kettle" {
            if ($Game.Hero.Level -ge 3) {
                if (-not $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"]) {
                    $Game.Town.InnFlags["InnkeeperLocalRumorTalk_Post_$($inn.Id)"] = $true
                    return "Madam Seraphine's smile never quite reaches her eyes. 'The elegant version is that the city is recovering. The honest version is that someone just lost a profitable machine and will hate you properly for it.'"
                }

                return "Madam Seraphine tilts her head. 'Panic recedes. Ambition does not.'"
            }

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
        Write-ColorLine "0. Back to innkeeper" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene "$($inn.Keeper) gives a short nod and leaves the room booked under $($Game.Hero.Name)'s name."
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
    $showIntro = $true

    while ($true) {
        Write-SectionTitle -Text "Innkeeper" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Innkeeper"
        if ($showIntro) {
            if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
                Write-Scene "$($inn.Keeper) keeps one eye on the room, the other on $($Game.Hero.Name), and the rest of their attention on the sort of evening service that can turn rowdy or profitable without warning."
            }
            else {
                Write-Scene "$($inn.Keeper) moves through the day's service with practiced calm, pausing long enough to give $($Game.Hero.Name) the attention due a paying guest."
            }
            $metInnkeeperKey = "InnkeeperMet_$($inn.Id)"
            $repeatVisit = [bool]$Game.Town.InnFlags[$metInnkeeperKey]
            Write-Scene (Get-InnKeeperGreeting -Inn $inn -Hero $Game.Hero -RepeatVisit $repeatVisit)
            $Game.Town.InnFlags[$metInnkeeperKey] = $true
            $showIntro = $false
        }
        Write-ColorLine ""
        Write-ColorLine "1. Ask about the house" "White"
        Write-ColorLine "2. Ask what sort of people stay here" "White"
        Write-ColorLine "3. Ask what people have been saying lately" "White"
        Write-ColorLine "4. Discuss your room booking" "White"
        Write-ColorLine "0. Back to inn" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Format-InnConversationText -Game $Game -Topic "House" -Line (Get-InnkeeperHouseTalk -Game $Game))
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Format-InnConversationText -Game $Game -Topic "Clientele" -Line (Get-InnkeeperClienteleTalk -Game $Game))
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Format-InnConversationText -Game $Game -Topic "Rumor" -Line (Get-InnkeeperLocalRumorTalk -Game $Game))
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
        Write-TownTimeTracker -Game $Game -Area "Inn Room"
        $roomVisitKey = "InnRoomVisited_$($inn.Id)"

        if (-not $Game.Town.InnFlags[$roomVisitKey]) {
            Write-Scene "$($Game.Hero.Name)'s room at $($inn.Name) is modestly lit, closed off from the street below, and blessedly still."
            $Game.Town.InnFlags[$roomVisitKey] = $true
        }
        else {
            Write-Scene "$($Game.Hero.Name)'s room at $($inn.Name) waits in welcome silence above the city's noise."
        }

        Write-ColorLine "Inn: $($inn.Name) | Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkYellow"
        Write-ColorLine "Next night here: $(Convert-CopperToCurrencyText -Copper $inn.PriceCopper)" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Rest for the night" "White"
        Write-ColorLine "2. Check inventory" "White"
        Write-ColorLine "3. Check quest log" "White"
        Write-ColorLine "4. Manage stored gear" "White"
        Write-ColorLine "5. Status" "White"
        Write-ColorLine "6. Back to inn" "White"
        if ($Game.Hero.Class -eq "Bard") {
            $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero
            $instrumentName = if ($null -ne $bardicStatus.Instrument) { $bardicStatus.Instrument.Name } else { "your instrument" }
            Write-ColorLine "7. Prepare bardic inspiration with $instrumentName" "White"
            Write-ColorLine "   Current: $($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides)" "DarkGray"
        }
        Write-ColorLine "G. Save adventure" "White"
        Write-ColorLine "0. End adventure for now" "White"
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
                Start-TownQuestLogMenu -Game $Game -HeroHP $HeroHP
            }
            "4" {
                Start-InnStorageMenu -Game $Game -Hero $Game.Hero
            }
            "5" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "6" {
                return "BackToInn"
            }
            "7" {
                if ($Game.Hero.Class -eq "Bard") {
                    $preparation = Prepare-HeroBardicInspiration -Hero $Game.Hero
                    Write-Scene $preparation.Message
                    Write-ColorLine ""
                }
                else {
                    Write-ColorLine "Invalid choice. Try again." "Red"
                    Write-ColorLine ""
                }
            }
            "G" {
                Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null
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
        Write-TownTimeTracker -Game $Game -Area "Lodging"
        Write-Scene "Night settles over the city, and $($Game.Hero.Name) must choose what kind of roof will hold until morning."
        Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
        Write-ColorLine ""

        for ($i = 0; $i -lt $inns.Count; $i++) {
            $inn = $inns[$i]
            Write-ColorLine "$($i + 1). $($inn.Name) - $(Convert-CopperToCurrencyText -Copper $inn.PriceCopper)" "White"
            Write-ColorLine "   Keeper: $($inn.Keeper) | Standard: $($inn.Quality)" "DarkGray"
            Write-ColorLine "   $($inn.Description)" "DarkGray"
        }

        Write-ColorLine ""
        Write-ColorLine "G. Save adventure" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice.ToUpper() -eq "G") {
            Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null
            continue
        }

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


