# Town is split into focused scripts so city progression stays readable as it grows.
. "$PSScriptRoot\\town-shops.ps1"
. "$PSScriptRoot\\town-npcs.ps1"
. "$PSScriptRoot\\town-ring.ps1"
. "$PSScriptRoot\\town-inns.ps1"

function Get-TownSourceVisitKey {
    param([string]$Source)

    return ("QuestSourceVisited_" + ($Source -replace "[^A-Za-z0-9]", ""))
}

function Get-ClassAwareTownText {
    param(
        $Hero,
        [string]$BarbarianText,
        [string]$BardText
    )

    if ($null -ne $Hero -and $Hero.Class -eq "Bard" -and -not [string]::IsNullOrWhiteSpace($BardText)) {
        return $BardText
    }

    return $BarbarianText
}

function Get-TownShopIntroText {
    param(
        [string]$Shop,
        $Hero
    )

    switch ($Shop) {
        "Market" {
            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Canvas stalls crowd the square. Traders wave Borzig over with travel gear, blades, and battered adventuring stock. More than one set of eyes lingers on the weathered state of Borzig's older kit." `
                -BardText "Canvas stalls crowd the square. Traders call Gariand over with travel gear, strings, ribbons, lamp oil, and opportunistic smiles. The market reads him as the sort of traveler who can turn polish and timing into coin if his kit is worthy of the room.")
        }
        "Smithy" {
            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Heat and sparks pour from the forge while the smith sizes Borzig up like a problem that can be solved with steel. The look he gives Borzig's older weaponry suggests he has already judged it rough, serviceable, and overdue for replacement." `
                -BardText "Heat and sparks pour from the forge while the smith judges Gariand with a craftsman's patience. Even here the eye goes first to buckles, light armor, and anything that might keep a quick-handed performer alive without ruining his poise.")
        }
        "Apothecary" {
            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Glass vials glimmer behind the counter as the apothecary speaks in a low voice about wounds, nerves, and battle tonic. Even here, Borzig's cave-worn gear draws a faintly disapproving glance whenever old blood and rust get too close to the glass." `
                -BardText "Glass vials glimmer behind the counter as the apothecary speaks softly about calm hands, clear breath, steady nerves, and keeping a performer on his feet after a hard night. Gariand's road-worn kit earns a measured glance, but less judgment than practical advice.")
        }
    }

    return ""
}

function Get-ChapterTwoAllianceStatusText {
    param(
        [string]$Source,
        $Game
    )

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return ""
    }

    $hasGuardLead = [bool]$Game.Town.StoryFlags["FoundTunnelAccess"] -or [bool]$Game.Town.StoryFlags["ConfirmedUndergroundRoute"]
    $hasClerkLead = [bool]$Game.Town.StoryFlags["FoundEconomicIrregularity"] -or [bool]$Game.Town.StoryFlags["SecuredLedgerEvidence"] -or [bool]$Game.Town.StoryFlags["NamedUnderstreetLeader"]
    $hasBrokerLead = [bool]$Game.Town.StoryFlags["BentNailBrokerConfirmed"] -or [bool]$Game.Town.StoryFlags["FoundSmugglingLink"]

    switch ($Source) {
        "Guard Station" {
            if ($hasClerkLead -and $hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch is no longer working blind. Halden's people are comparing patrol reports against the clerk's ledger trail and the river-quarter whispers Borzig keeps bringing in." `
                    -BardText "The watch is no longer working blind. Halden's people are comparing patrol reports against the clerk's ledger trail and the river-quarter whispers Gariand has been carrying between rooms that normally never speak to one another.")
            }

            if ($hasClerkLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch hall feels tighter now. Someone inside has started taking the merchant clerk's paper trail seriously, even if no one says so loudly." `
                    -BardText "The watch hall feels tighter now. Someone inside has started taking the merchant clerk's paper trail seriously, and Gariand can hear how carefully the guards choose their words around it.")
            }

            if ($hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The guards pretend they are only following patrol work, but Borzig can tell the river-quarter whispers have reached this hall already." `
                    -BardText "The guards pretend they are only following patrol work, but Gariand can tell the river-quarter whispers have reached this hall already. Even here, the city's rumor-song is changing key.")
            }
        }
        "Quest Giver" {
            if ($hasGuardLead -and $hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk no longer treats this like a private merchant problem. His books, the watch's tunnel reports, and the Bent Nail whispers are all starting to describe the same hidden network." `
                    -BardText "The clerk no longer treats this like a private merchant problem. His books, the watch's tunnel reports, and the Bent Nail whispers Gariand keeps drawing together are all starting to describe the same hidden network.")
            }

            if ($hasGuardLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk keeps one eye on his papers and one on the watch. Whatever Borzig brought back from the patrols has made these ledgers feel more dangerous." `
                    -BardText "The clerk keeps one eye on his papers and one on the watch. Whatever Gariand has coaxed out of patrol routes and tense conversations has made these ledgers feel more dangerous.")
            }

            if ($hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk speaks like a careful man who has realized his ledgers are brushing up against the same river-quarter names Borzig hears in rougher rooms." `
                    -BardText "The clerk speaks like a careful man who has realized his ledgers are brushing up against the same river-quarter names Gariand hears in rougher rooms and better salons alike.")
            }
        }
        "Quest Board" {
            if ($hasGuardLead -or $hasClerkLead -or $hasBrokerLead) {
                return "Even the public notices feel different now. Small jobs still pay coin, but the city behind them is starting to look like one tangled knot instead of separate troubles."
            }
        }
    }

    return ""
}

function Show-PostUnderstreetHook {
    param($Game)

    if (-not $Game.Town.ChapterTwoComplete -or $Game.Town.ChapterThreeHookSeen) {
        return
    }

    Write-SectionTitle -Text "Aftermath" -Color "Green"
    Write-Scene "Word spreads faster than Borzig expected. By dawn, half the city knows the hidden route under the ward has been broken open."
    Write-Scene "Captain Halden sends quiet thanks. Merchants start asking what else was hidden below. The wrong people are suddenly too silent."
    Write-Scene "And in more than one district, Borzig hears the same uneasy thought repeated in different words: if the understreet was only one branch, what larger hand planted it here?"
    Write-EmphasisLine -Text "New Chapter Hook: Borzig's victory under the city has exposed a wider network still worth hunting." -Color "Yellow"
    Write-ColorLine ""

    $Game.Town.ChapterThreeHookSeen = $true
}

function Get-TownQuestSourceIntroText {
    param(
        [string]$Source,
        [string]$DefaultIntroText,
        $Game
    )

    $visitKey = Get-TownSourceVisitKey -Source $Source
    $isRepeatVisit = [bool]$Game.Town.StreetFlags[$visitKey]

    if ($Game.Town.ChapterTwoComplete) {
        switch ($Source) {
            "Quest Board" {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "Fresh notices have started appearing now that Borzig's name carries more weight. Some want coin-work. Some want the man who broke the understreet to look into worse things." `
                    -BardText "Fresh notices have started appearing now that Gariand's name carries more weight. Some want coin-work. Some want the man who sang his way through closed rooms and walked back out of the understreet to look into worse things.")
            }
            "Guard Station" {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch hall changes tone when Borzig enters now. Some guards step aside out of respect, and the harder jobs are no longer hidden from him." `
                    -BardText "The watch hall changes tone when Gariand enters now. Some guards still distrust a polished tongue, but none of them mistake him for a lightweight anymore, and the harder jobs are no longer hidden from him.")
            }
            "Quest Giver" {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The patron's clerk has stopped treating Borzig like hired muscle. Now the work is more careful, more valuable, and rarely clean." `
                    -BardText "The patron's clerk has stopped treating Gariand like charming decoration. Now the work is more careful, more valuable, and offered with the uneasy respect reserved for someone who can move between ledgers, guard posts, and whispered rooms.")
            }
        }
    }

    $allianceText = Get-ChapterTwoAllianceStatusText -Source $Source -Game $Game

    if (-not [string]::IsNullOrWhiteSpace($allianceText)) {
        return $allianceText
    }

    if (-not $isRepeatVisit) {
        $Game.Town.StreetFlags[$visitKey] = $true
        return $DefaultIntroText
    }

    switch ($Source) {
        "Quest Board" { return "The board looks thinner now, but there is still work on it for anyone willing to take the coin." }
        "Guard Station" { return "The watch hall is busier than it looks. Hard jobs are passed quietly from one tired hand to the next." }
        "Quest Giver" {
            return (Get-ClassAwareTownText -Hero $Game.Hero `
                -BarbarianText "The patron's clerk recognizes Borzig now and reaches for the stack of private work without wasting words." `
                -BardText "The patron's clerk recognizes Gariand now and reaches for the stack of private work without wasting words. He speaks like a man who has accepted that a polished performer can also be the sharpest knife in the room.")
        }
        default { return $DefaultIntroText }
    }
}

function Show-TownQuestSource {
    param(
        [string]$Title,
        [string]$IntroText,
        [string]$Source,
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        $quests = @(Get-TownQuestList -Game $Game -Source $Source)
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-Scene (Get-TownQuestSourceIntroText -Source $Source -DefaultIntroText $IntroText -Game $Game)
        Write-ColorLine ""

        $tierStatus = Get-StoryTierProgressStatus -Game $Game
        Write-EmphasisLine -Text $tierStatus.StatusText -Color "Yellow"
        Write-ColorLine ""

        if ($Game.Town.StoryQuestDoneToday) {
            Write-EmphasisLine -Text "Borzig has already pushed the main story forward today. Another story quest must wait until tomorrow." -Color "DarkYellow"
        }

        if ($Game.Town.DayJobDoneToday) {
            Write-EmphasisLine -Text "Borzig has already taken one paid side job today." -Color "DarkYellow"
        }

        if ($Game.Town.StoryQuestDoneToday -or $Game.Town.DayJobDoneToday) {
            Write-ColorLine ""
        }

        if ($Source -eq "Guard Station") {
            $watchQuest = $quests | Where-Object { $_.Id -eq "guard_night_watch" } | Select-Object -First 1

            if ($null -ne $watchQuest) {
                if ($watchQuest.Completed) {
                    Write-EmphasisLine -Text "Night Watch Relief stands completed on the station ledger." -Color "Green"
                }
                elseif ($watchQuest.Accepted) {
                    Write-EmphasisLine -Text "Night Watch Relief is ready to start from the guard station." -Color "Yellow"
                }
                else {
                    Write-EmphasisLine -Text "Available guard assignment: Night Watch Relief." -Color "Yellow"
                }

                Write-ColorLine ""
            }
        }

        if ($quests.Count -eq 0) {
            Write-Scene "No work is posted here right now."
            Write-ColorLine ""
        }

        for ($i = 0; $i -lt $quests.Count; $i++) {
            $quest = $quests[$i]
            $status = if ($quest.Completed) { "Complete" } elseif ($quest.Accepted) { "Accepted" } else { "Available" }
            Write-ColorLine "$($i + 1). $($quest.Name) [$status]" "White"
            $tierText = if ($quest.QuestType -eq "Story" -and [int]$quest.Tier -gt 0) { " | Tier $($quest.Tier)" } else { "" }
            Write-ColorLine "   Type: $($quest.QuestType)$tierText" "DarkGray"
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

        $selectedQuest = $quests[$index]

        if ($selectedQuest.Completed) {
            Write-Scene "$($selectedQuest.Name) is already complete."
            Write-ColorLine ""
            continue
        }

        if ($selectedQuest.Accepted) {
            Start-TownQuestPreparationMenu -Game $Game -HeroHP $HeroHP -Quest $selectedQuest
            continue
        }

        $questResult = Accept-TownQuest -Game $Game -QuestId $selectedQuest.Id
        Write-Scene $questResult.Message
        Write-ColorLine ""

        if ($questResult.Success) {
            while ($true) {
                Write-ColorLine "1. Start now" "White"
                Write-ColorLine "2. Prepare in town first" "White"
                Write-ColorLine "" "White"

                $followUpChoice = Read-Host "Choose"

                if ($followUpChoice -eq "1") {
                    Start-TownQuest -Game $Game -HeroHP $HeroHP -QuestId $selectedQuest.Id
                    break
                }

                if ($followUpChoice -eq "2") {
                    Start-TownQuestPreparationMenu -Game $Game -HeroHP $HeroHP -Quest $selectedQuest
                    break
                }

                Write-ColorLine "Choose 1 or 2." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Start-TownQuestPreparationMenu {
    param(
        $Game,
        [ref]$HeroHP,
        $Quest
    )

    while ($true) {
        Write-SectionTitle -Text "Prepare for Quest" -Color "Yellow"
        Write-Scene (Get-ClassAwareTownText -Hero $Game.Hero `
            -BarbarianText "$($Quest.Name) waits when Borzig is ready. He can make final adjustments before stepping out." `
            -BardText "$($Quest.Name) waits when Gariand is ready. He can make final adjustments, steady his nerves, and choose how he wants to carry himself before stepping out.")
        Write-ColorLine "Quest: $($Quest.Name)" "White"
        Write-ColorLine "Objective: $($Quest.Objective)" "DarkGray"
        Write-ColorLine "Reward: $(Get-QuestRewardText -Quest $Quest)" "DarkGray"
        Write-ColorLine ""
        Write-ColorLine "1. Start the quest now" "White"
        Write-ColorLine "2. Check inventory and gear" "White"
        Write-ColorLine "3. Check quest log" "White"
        Write-ColorLine "4. Return to town without starting" "White"
        if ($Game.Hero.Class -eq "Bard") {
            $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero
            $instrumentName = if ($null -ne $bardicStatus.Instrument) { $bardicStatus.Instrument.Name } else { "your instrument" }
            Write-ColorLine "5. Prepare bardic inspiration with $instrumentName" "White"
            Write-ColorLine "   Current: $($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides)" "DarkGray"
        }
        Write-TextSpeedOption
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                Start-TownQuest -Game $Game -HeroHP $HeroHP -QuestId $Quest.Id
                return
            }
            "2" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "3" {
                Start-TownQuestLogMenu -Game $Game -HeroHP $HeroHP
            }
            "4" {
                return
            }
            "5" {
                if ($Game.Hero.Class -eq "Bard") {
                    $preparation = Prepare-HeroBardicInspiration -Hero $Game.Hero
                    Write-Scene $preparation.Message
                    Write-ColorLine ""
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                }
            }
            "T" {
                Toggle-TextSpeed | Out-Null
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Get-BardPerformanceVenue {
    param([string]$VenueId)

    switch ($VenueId) {
        "market_square" {
            return [PSCustomObject]@{
                Id = "market_square"
                Name = "Market Square"
                CheckDC = 10
                IntroText = "Bardic work in the market means gathering a crowd before it drifts, turning noise into rhythm, and making sure the hat fills before the merchants chase everyone onward."
                PoorRewardCopper = 8
                GoodRewardCopper = 18
                GreatRewardCopper = 35
                SuccessText = "The crowd stays. Coins start to ring against the hat, and even the traders have to admit the square sounds better with the set in it."
                GreatSuccessText = "The whole square turns toward the performance. Traders clap time against wagon rails, children dance between boots, and Borzig leaves with the kind of heavy purse that only comes from owning the room."
                FailureText = "The square gives Borzig a few polite looks and a thin scatter of coin, but the set never fully catches."
            }
        }
        "bent_nail_stage" {
            return [PSCustomObject]@{
                Id = "bent_nail_stage"
                Name = "Bent Nail Common Room"
                CheckDC = 11
                IntroText = "The Bent Nail does not reward polish. It rewards nerve, timing, and the kind of set that can cut through smoke, bets, and bad tempers without getting laughed off the floor."
                PoorRewardCopper = 10
                GoodRewardCopper = 22
                GreatRewardCopper = 40
                SuccessText = "The room pounds tables in rough approval, and the tips come in from gamblers who appreciate anyone bold enough to hold the Bent Nail's attention."
                GreatSuccessText = "The whole room swings behind the set. Even the hard-eyed regulars grin into their cups, and the hat comes back heavy with rough silver."
                FailureText = "The room listens just enough to toss a few coins, but the Bent Nail never fully gives itself over."
            }
        }
        "lantern_rest_stage" {
            return [PSCustomObject]@{
                Id = "lantern_rest_stage"
                Name = "Lantern Rest Common Room"
                CheckDC = 10
                IntroText = "At the Lantern Rest, a good performance means reading travelers, lifting road-weary shoulders, and choosing songs that feel familiar enough to earn a second round of drink."
                PoorRewardCopper = 9
                GoodRewardCopper = 20
                GreatRewardCopper = 38
                SuccessText = "The room joins in by the second chorus, and Borzig comes away with warm applause and a respectable stack of tips."
                GreatSuccessText = "Merchants, guards, and teamsters take the whole room up in song. By the end of it, the tips are generous and Borzig's name is being repeated with easy affection."
                FailureText = "The room is kind enough, but the set fades into the usual tavern noise and only earns a few spare coins."
            }
        }
        "silver_kettle_stage" {
            return [PSCustomObject]@{
                Id = "silver_kettle_stage"
                Name = "Silver Kettle Salon"
                CheckDC = 13
                IntroText = "The Silver Kettle expects grace, confidence, and the sort of performance that makes rich patrons feel they discovered something worth boasting about tomorrow."
                PoorRewardCopper = 12
                GoodRewardCopper = 28
                GreatRewardCopper = 55
                SuccessText = "The upper tables reward the performance with measured applause and good silver, the polite sort that still spends beautifully."
                GreatSuccessText = "The room falls perfectly still for the final note, then breaks into the kind of applause that carries money, introductions, and invitations behind it."
                FailureText = "The Silver Kettle remains polite, but the room's applause never warms and the tips stay thin."
            }
        }
        "private_patron_salons" {
            return [PSCustomObject]@{
                Id = "private_patron_salons"
                Name = "Private Patron Salon"
                CheckDC = 14
                IntroText = "Private salons pay for precision, wit, and control. Here the wrong note is remembered, but the right set can travel through merchant houses faster than rumor."
                PoorRewardCopper = 18
                GoodRewardCopper = 40
                GreatRewardCopper = 70
                SuccessText = "The private room opens by the end of the set. Several patrons stay behind, smiling in that expensive, thoughtful way that usually means more work is coming."
                GreatSuccessText = "The salon gives itself over completely. By the final bow, Borzig has coin, invitations, and the quiet certainty that richer doors will keep opening if he wants them."
                FailureText = "The room stays courteous but cool. The purse is still respectable, but the performance never fully claims the evening."
            }
        }
    }

    return $null
}

function Start-BardPerformanceCheck {
    param(
        $Game,
        $Venue,
        [int]$CheckDC = 0
    )

    if ($CheckDC -le 0) {
        $CheckDC = [int]$Venue.CheckDC
    }

    $checkProfile = Get-HeroAbilityCheckModifier -Hero $Game.Hero -Ability "CHA" -CheckTag "Performance"
    $instrument = Get-HeroInstrument -Hero $Game.Hero
    $instrumentBonus = if ($null -ne $instrument -and $null -ne $instrument.PSObject.Properties["InspirationBonus"]) { [int]$instrument.InspirationBonus } else { 0 }
    $roll = Roll-Dice -Sides 20
    $bardicBonus = 0
    $bardicInstrumentBonus = 0

    if ($Game.Hero.Class -eq "Bard") {
        $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero

        if ($null -ne $bardicStatus -and $bardicStatus.CurrentDice -gt 0) {
            Write-ColorLine "Spend bardic inspiration on the performance?" "Cyan"
            Write-ColorLine "1. Yes ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
            Write-ColorLine "2. No" "White"
            Write-ColorLine ""

            while ($true) {
                $choice = Read-Host "Choose"

                if ($choice -eq "1") {
                    $inspiration = Use-HeroBardicInspirationDie -Hero $Game.Hero -UseInstrumentBonus $false

                    if ($inspiration.Success) {
                        $bardicBonus = $inspiration.Roll

                        if ($instrumentBonus -gt 0) {
                            $bardicInstrumentBonus = $instrumentBonus
                        }
                    }

                    break
                }

                if ($choice -eq "2") {
                    break
                }

                Write-ColorLine "Choose 1 or 2." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }

    $total = $roll + $checkProfile.TotalModifier + $instrumentBonus + $bardicBonus + $bardicInstrumentBonus

    Write-Scene $Venue.IntroText
    $performanceBreakdown = "d20 roll $roll $(Format-AbilityModifier -Modifier $checkProfile.AbilityModifier) + $($checkProfile.ClassBonus) proficiency"

    if ($instrumentBonus -gt 0) {
        $performanceBreakdown += " + $instrumentBonus instrument"
    }

    if ($bardicBonus -gt 0) {
        $performanceBreakdown += " + $bardicBonus inspiration"
    }

    if ($bardicInstrumentBonus -gt 0) {
        $performanceBreakdown += " + $bardicInstrumentBonus instrument+"
    }

    Write-Action "$($Game.Hero.Name) performs: $performanceBreakdown = $total" "Cyan"
    Write-ColorLine ""

    return $total
}

function Get-BardPerformanceRecognitionText {
    param(
        $Game,
        $Venue
    )

    $performanceCountTotal = [int]$Game.Town.PerformanceCountTotal

    if ($performanceCountTotal -lt 3) {
        return ""
    }

    switch ($Venue.Id) {
        "market_square" {
            if ($performanceCountTotal -ge 8) {
                return "Several faces in the square recognize $($Game.Hero.Name) before the first note lands, and the crowd starts gathering with the easy confidence reserved for someone who has already earned the street's attention."
            }

            return "A few people in the square notice $($Game.Hero.Name) setting up and drift closer early, already expecting a real performance instead of background noise."
        }
        "lantern_rest_stage" {
            if ($performanceCountTotal -ge 8) {
                return "By now the Lantern Rest treats $($Game.Hero.Name) like a welcome fixture. Tankards lift, tables turn, and the room readies itself for something warm and lively."
            }

            return "A few regulars at the Lantern Rest recognize $($Game.Hero.Name) and make space with the pleased look of people hoping the room will turn brighter for a while."
        }
        "silver_kettle_stage" {
            if ($performanceCountTotal -ge 8) {
                return "At the Silver Kettle, recognition arrives as composed glances and chairs angled just so. The room already expects polish from $($Game.Hero.Name), and expectation here is its own form of status."
            }

            return "Some of the Silver Kettle's better tables recognize $($Game.Hero.Name) and settle in with quiet, curious attention before the set even begins."
        }
        "bent_nail_stage" {
            if ($performanceCountTotal -ge 8) {
                return "The Bent Nail answers recognition its own way: a few cheers, a few bangs on tabletops, and the sense that $($Game.Hero.Name) has earned a rough kind of name in this room."
            }

            return "A couple of Bent Nail regulars clock $($Game.Hero.Name) early and start grinning like they know the room is about to get louder."
        }
        default {
            return ""
        }
    }
}

function Resolve-BardPerformance {
    param(
        $Game,
        [string]$VenueId
    )

    if ($Game.Hero.Class -ne "Bard") {
        return [PSCustomObject]@{
            Success = $false
            Message = ""
        }
    }

    if ($Game.Town.PerformanceCountToday -ge 3) {
        Write-Scene "Borzig has already played three paying sets today. His voice, hands, and audience luck will have to wait for tomorrow."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Performance limit reached."
        }
    }

    $venue = Get-BardPerformanceVenue -VenueId $VenueId

    if ($null -eq $venue) {
        return [PSCustomObject]@{
            Success = $false
            Message = ""
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($VenueId) -and [bool]$Game.Town.PerformanceVenuesToday[$VenueId]) {
        Write-Scene "$($venue.Name) has already had Borzig's set today. If he wants more coin before nightfall, he needs a different room."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Venue already used today."
        }
    }

    if ($VenueId -eq "private_patron_salons" -and -not [bool]$Game.Town.InnFlags["SilverKettlePrivateInvite"]) {
        Write-Scene "No private salon has sent for $($Game.Hero.Name) yet. He needs stronger upper-room attention before that kind of invitation starts arriving."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Private venue locked."
        }
    }

    $effectiveCheckDC = [int]$venue.CheckDC
    $permitRewardCopper = 0

    if ($VenueId -eq "market_square" -and [bool]$Game.Town.StreetFlags["BelorSquarePermit"]) {
        $effectiveCheckDC = [Math]::Max(5, $effectiveCheckDC - 1)
        $permitRewardCopper = 6
    }

    $recognitionText = Get-BardPerformanceRecognitionText -Game $Game -Venue $venue

    if (-not [string]::IsNullOrWhiteSpace($recognitionText)) {
        Write-Scene $recognitionText
        Write-ColorLine ""
    }

    $total = Start-BardPerformanceCheck -Game $Game -Venue $venue -CheckDC $effectiveCheckDC
    $rewardCopper = 0
    $outcome = "Poor"

    if ($total -ge ($effectiveCheckDC + 5)) {
        $rewardCopper = [int]$venue.GreatRewardCopper
        $outcome = "Great"
        Write-Scene ($venue.GreatSuccessText.Replace("Borzig", $Game.Hero.Name))
    }
    elseif ($total -ge $effectiveCheckDC) {
        $rewardCopper = [int]$venue.GoodRewardCopper
        $outcome = "Good"
        Write-Scene ($venue.SuccessText.Replace("Borzig", $Game.Hero.Name))
    }
    else {
        $rewardCopper = [int]$venue.PoorRewardCopper
        Write-Scene ($venue.FailureText.Replace("Borzig", $Game.Hero.Name))
    }

    if ($permitRewardCopper -gt 0 -and $outcome -ne "Poor") {
        $rewardCopper += $permitRewardCopper
        Write-EmphasisLine -Text "Belor's market permit keeps the wardens off the set and the tip hat fuller." -Color "Yellow"
    }

    Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper | Out-Null
    $Game.Town.PerformanceCountToday = [int]$Game.Town.PerformanceCountToday + 1
    $Game.Town.PerformanceCountTotal = [int]$Game.Town.PerformanceCountTotal + 1
    $Game.Town.PerformanceVenuesToday[$VenueId] = $true

    if ($VenueId -eq "market_square" -and $outcome -ne "Poor") {
        $Game.Town.Relationships["SquareAudience"] = if ($outcome -eq "Great") { "Delighted" } else { "Warm" }
    }

    if ($VenueId -eq "silver_kettle_stage" -and $outcome -eq "Great" -and -not $Game.Town.InnFlags["SilverKettlePatronFavor"]) {
        $Game.Town.InnFlags["SilverKettlePatronFavor"] = $true
        $Game.Town.Relationships["MerchantPatron"] = "Favorable"
        Write-EmphasisLine -Text "A patron remembers the set and starts asking after Borzig by name." -Color "Yellow"
    }

    if ($VenueId -eq "silver_kettle_stage" -and $outcome -eq "Great") {
        $Game.Town.InnFlags["SilverKettlePrivateInvite"] = $true
    }

    Write-EmphasisLine -Text "$($Game.Hero.Name) earns $(Convert-CopperToCurrencyText -Copper $rewardCopper) from the performance." -Color "Yellow"
    Write-ColorLine ""

    return [PSCustomObject]@{
        Success = $true
        Outcome = $outcome
        RewardCopper = $rewardCopper
    }
}

function Start-BardPerformanceMenu {
    param($Game)

    while ($true) {
        Write-SectionTitle -Text "Find an Audience" -Color "Yellow"
        Write-Scene "A bard can make coin in this city without lifting a blade, if the room is right and the performance lands."
        Write-EmphasisLine -Text "Performances today: $($Game.Town.PerformanceCountToday)/3" -Color "Yellow"
        Write-ColorLine "1. Perform in the market square" "White"
        Write-ColorLine "2. Book a private patron salon" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Return to town" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Resolve-BardPerformance -Game $Game -VenueId "market_square" | Out-Null
            }
            "2" {
                Resolve-BardPerformance -Game $Game -VenueId "private_patron_salons" | Out-Null
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $Game.Hero.HP
            }
            "0" {
                return
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Start-QuestHubMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-SectionTitle -Text "Seek Work" -Color "Yellow"
        Write-Scene (Get-ClassAwareTownText -Hero $Game.Hero `
            -BarbarianText "Borzig can ask for work from official hands, desperate citizens, or merchants with private problems." `
            -BardText "Gariand can ask for work from official hands, desperate citizens, or merchants with private problems. More and more often, each of them wants someone who can listen as well as act.")
        Write-Scene "More and more, it feels like the same trouble is being seen from different corners of the city."
        Write-EmphasisLine -Text ((Get-StoryTierProgressStatus -Game $Game).StatusText) -Color "Yellow"
        Write-ColorLine ""
        Write-ColorLine "1. Check the quest board" "White"
        Write-ColorLine "2. Visit the guard station" "White"
        Write-ColorLine "3. Speak with the quest giver's clerk" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Show-TownQuestSource -Title "Quest Board" -IntroText "Pinned notices flap in the night wind. Most offer coin, some offer trouble, and all of them want someone else to solve a problem." -Source "Quest Board" -Game $Game -HeroHP $HeroHP
            }
            "2" {
                Show-TownQuestSource -Title "Guard Station" -IntroText "The watch hall smells of lamp oil, damp cloaks, and sleepless men. Steady work hangs here, though rarely easy work." -Source "Guard Station" -Game $Game -HeroHP $HeroHP
            }
            "3" {
                Show-TownQuestSource -Title "Quest Giver" -IntroText "A clerk waits beneath the old patron's seal, ready to pass along jobs too awkward or dangerous for ordinary hirelings." -Source "Quest Giver" -Game $Game -HeroHP $HeroHP
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
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
        Show-PostUnderstreetHook -Game $Game

        # The first city night is mandatory so the tutorial always lands on the inn chapter ending.
        if ($Game.Town.MustChooseFirstInn -and -not $Game.Town.ChapterOneComplete) {
            Write-SectionTitle -Text "Night Falls" -Color "Yellow"
            Write-Scene "The city can wait until morning. Borzig needs a roof, a locked door, and one real night's sleep before the next chapter begins."
            Write-ColorLine ""

            $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

            if ($innResult -eq "Stayed") {
                $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                if ($innMenuResult -eq "EndGame") {
                    return "EndGame"
                }
            }

            continue
        }

        Write-ColorLine ""
        Write-ColorLine "===== TOWN =====" "Yellow"

        if (-not $Game.Town.StreetFlags["TownMenuVisited"]) {
            Write-Scene "Stone streets spread out before Borzig, loud with merchants, carts, and the clatter of a city living by its own stubborn rhythm."
            Write-Scene "The city no longer feels like refuge alone. It feels like a place where the next chapter might actually begin."
            $Game.Town.StreetFlags["TownMenuVisited"] = $true
        }
        elseif ($Game.Town.ChapterTwoComplete) {
            Write-Scene "The city watches Borzig differently now, with more respect and sharper attention."
        }
        else {
            Write-Scene "The city is awake around Borzig again, full of noise, work, and unfinished business."
        }
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Walk the streets" "White"
        Write-ColorLine "2. Browse the market" "White"
        Write-ColorLine "3. Visit the smithy" "White"
        Write-ColorLine "4. Visit the apothecary" "White"
        Write-ColorLine "5. Find a buyer" "White"
        Write-ColorLine "6. Seek work" "White"
        Write-ColorLine "7. Visit the fighting ring" "White"
        Write-ColorLine "8. Visit your inn" "White"
        Write-ColorLine "9. Check inventory" "White"
        Write-ColorLine "10. Check quest log" "White"
        Write-ColorLine "S. Status" "White"
        if ($Game.Hero.Class -eq "Bard") {
            Write-ColorLine "P. Find an audience and perform for coin" "White"
        }
        if ($null -eq $Game.Town.ActiveInn) {
            Write-ColorLine "L. Find lodging for the night" "White"
        }
        Write-TextSpeedOption
        Write-ColorLine "0. End the adventure for now" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                Start-TownStreetScene -Game $Game -ReturnLabel "Return to town"
            }
            "2" {
                Show-TownShop -Title "Market" -IntroText (Get-TownShopIntroText -Shop "Market" -Hero $Game.Hero) -Game $Game -Hero $Game.Hero -Offers (Get-MarketOffers -Game $Game) -BuyerType "Market"
            }
            "3" {
                Show-TownShop -Title "Smithy" -IntroText (Get-TownShopIntroText -Shop "Smithy" -Hero $Game.Hero) -Game $Game -Hero $Game.Hero -Offers (Get-SmithyOffers -Game $Game) -BuyerType "Smithy"
            }
            "4" {
                Show-TownShop -Title "Apothecary" -IntroText (Get-TownShopIntroText -Shop "Apothecary" -Hero $Game.Hero) -Game $Game -Hero $Game.Hero -Offers (Get-ApothecaryOffers -Game $Game) -BuyerType "Apothecary"
            }
            "5" {
                Open-TownSellMenu -Hero $Game.Hero -BuyerType "GeneralBuyer" -ExitLabel "Return to town"
            }
            "6" {
                Start-QuestHubMenu -Game $Game -HeroHP $HeroHP
            }
            "7" {
                Start-FightingRing -Game $Game
            }
            "8" {
                if ($null -ne $Game.Town.ActiveInn) {
                    $innMenuResult = Start-InnVisitMenu -Game $Game -HeroHP $HeroHP

                    if ($innMenuResult -eq "EndGame") {
                        return "EndGame"
                    }
                }
                else {
                    Write-Scene "Borzig has not taken a room yet."
                    Write-ColorLine ""
                }
            }
            "9" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "10" {
                Start-TownQuestLogMenu -Game $Game -HeroHP $HeroHP
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "P" {
                if ($Game.Hero.Class -eq "Bard") {
                    Start-BardPerformanceMenu -Game $Game
                }
                else {
                    Write-ColorLine "Invalid choice. Try again." "Red"
                    Write-ColorLine ""
                }
            }
            "L" {
                $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

                if ($innResult -eq "Stayed") {
                    $innMenuResult = Start-InnVisitMenu -Game $Game -HeroHP $HeroHP

                    if ($innMenuResult -eq "EndGame") {
                        return "EndGame"
                    }
                }
            }
            "T" {
                Toggle-TextSpeed | Out-Null
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
