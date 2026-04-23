# Social reactions and street interactions are isolated here so future classes can get their own tone and rewards.
function Get-HeroTownPersona {
    param($Hero)

    $className = ""

    if ($null -ne $Hero.PSObject.Properties["Class"]) {
        $className = [string]$Hero.Class
    }

    $strength = Get-HeroAbilityScore -Hero $Hero -Ability "STR"
    $dexterity = Get-HeroAbilityScore -Hero $Hero -Ability "DEX"
    $constitution = Get-HeroAbilityScore -Hero $Hero -Ability "CON"
    $charisma = Get-HeroAbilityScore -Hero $Hero -Ability "CHA"

    $isBardLike = $className -match "Bard"
    $isKnightLike = $className -match "Knight|Paladin"
    $isBarbarian = $className -eq "Barbarian"
    $isStrong = $strength -ge 15
    $isQuick = $dexterity -ge 14
    $isTough = $constitution -ge 15
    $isCharming = $charisma -ge 14

    return [PSCustomObject]@{
        IsBarbarian = $isBarbarian
        IsBardLike = $isBardLike
        IsKnightLike = $isKnightLike
        IsStrong = $isStrong
        IsQuick = $isQuick
        IsTough = $isTough
        IsCharming = $isCharming
    }
}

function Get-HeroTownName {
    param($Hero)

    if ($null -ne $Hero -and $null -ne $Hero.PSObject.Properties["Name"] -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Name)) {
        return [string]$Hero.Name
    }

    return "Borzig"
}

function Get-InnKeeperGreeting {
    param(
        $Inn,
        $Hero,
        [bool]$RepeatVisit = $false
    )

    $persona = Get-HeroTownPersona -Hero $Hero
    $heroName = Get-HeroTownName -Hero $Hero

    switch ($Inn.Id) {
        "bent_nail" {
            if ($RepeatVisit) {
                return "Marta jerks her chin toward the bar. 'Room's still yours if the coin keeps showing up and the trouble stays manageable.'"
            }

            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Marta squints up at $heroName's shoulders and grunts. 'You look like the kind who breaks furniture instead of rules. Pay first and keep the trouble pointed away from my bar.'"
            }

            if ($persona.IsBardLike -or $persona.IsCharming) {
                return "Marta gives $heroName a narrow look. 'Pretty words do not buy a bed here. Coin does. If you've got both, keep the words short and the purse visible.'"
            }

            if ($persona.IsKnightLike) {
                return "Marta eyes $heroName's posture like it belongs in a cleaner room. 'You'll not fix this place by standing straighter, soldier. Pay, sleep, and mind your temper.'"
            }

            return $Inn.KeeperText
        }
        "lantern_rest" {
            if ($RepeatVisit) {
                return "Oren gives $heroName an easy nod. 'Back again. Same room, same clean sheets, same promise that this place stays calmer than most.'"
            }

            if ($persona.IsBardLike -or $persona.IsCharming) {
                return "Oren's smile comes easier as he sizes $(Get-HeroTownName -Hero $Hero) up. 'A good room, a better meal, and company willing to listen if you speak like you mean it. That is what the Lantern Rest is for.'"
            }

            if ($persona.IsKnightLike) {
                return "Oren dips his head with almost formal respect. 'Discipline is welcome here, and so is coin. You'll find both the sheets and the service in proper order.'"
            }

            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Oren measures $heroName with a practiced host's calm. 'We've had caravan guards rougher than you and merchants softer. Leave both at the door and we'll get along well enough.'"
            }

            return $Inn.KeeperText
        }
        "silver_kettle" {
            if ($RepeatVisit) {
                return "Madam Seraphine's smile turns knowing. 'Welcome back. Try not to look surprised that refined company remembers its own.'"
            }

            if ($persona.IsBardLike -or $persona.IsCharming) {
                return "Madam Seraphine's expression warms at once. 'Ah, there you are. Someone in this city still understands the value of presentation. Recover here, and do try not to make the rest of them look drab.'"
            }

            if ($persona.IsKnightLike) {
                return "Madam Seraphine inclines her head as if greeting a lesser noble. 'Bearing, restraint, and decent posture. At last, a guest who understands the difference between paying for comfort and merely occupying it.'"
            }

            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Madam Seraphine studies $heroName like a wolf invited into a ballroom. 'Strength has its uses, darling, but under my roof it will wear boots clean enough not to offend the carpets.'"
            }

            return $Inn.KeeperText
        }
        default {
            return $Inn.KeeperText
        }
    }
}

function Get-WidowEliraIntro {
    param(
        $Hero,
        $Game = $null
    )

    $persona = Get-HeroTownPersona -Hero $Hero
    $heroName = Get-HeroTownName -Hero $Hero
    $isNight = $null -ne $Game -and (Get-TownTimeOfDay -Game $Game) -eq "Night"

    if ($isNight) {
        if ($Hero.Level -ge 3) {
            return "Widow Elira keeps close to the lantern glow and smiles when she sees $heroName. 'Nights used to feel longer here. Folk still listen for bad news after dark, but they do not freeze the way they did before.'"
        }

        return "Widow Elira stands close to a doorway lamp, shawl tight around her shoulders. 'People still listen harder at night now, hero. Your warning taught the district how quickly dark can carry fear.'"
    }

    if ($Hero.Level -ge 3) {
        return "Widow Elira squeezes $heroName's forearm and smiles with more pride than fear now. 'They say you went under the city and came back with the dark broken behind you. Folk sleep easier for it.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Widow Elira reaches for $heroName's hand with watery eyes. 'The city said you carried yourself gently, and now I see why. Your warning brought my son home before sunset.'"
    }

    if ($persona.IsKnightLike) {
        return "Widow Elira bows her head before speaking. 'You carry yourself like someone who still believes duty matters. Your warning brought my son home before sunset.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Widow Elira grips $heroName's wrist with surprising strength. 'I feared a hard man would bring only hard news, but your warning brought my son home before sunset.'"
    }

    return "Widow Elira grips $heroName's wrist with surprising strength. 'My son was on the road when the dragon panic started. Your warning brought him home before sunset.'"
}

function Get-HadrikIntro {
    param(
        $Hero,
        $Game = $null
    )

    $persona = Get-HeroTownPersona -Hero $Hero
    $heroName = Get-HeroTownName -Hero $Hero
    $isNight = $null -ne $Game -and (Get-TownTimeOfDay -Game $Game) -eq "Night"

    if ($isNight) {
        if ($Hero.Level -ge 3) {
            return "Hadrik's grin flashes in the forge-light. 'Night shift's the honest one. Day buys polish. Night buys what people are afraid to be without before dawn.'"
        }

        return "Hadrik works under forge-light and shadow now, soot brighter against his face. 'Anyone shopping for steel at night already expects trouble,' he says, sounding almost pleased by it."
    }

    if ($Hero.Level -ge 3) {
        return "Hadrik's grin comes faster now. 'So it is true. You broke the smugglers' den under the ward. Master's been saying steel feels different in the hands of someone the city finally believes in, especially when he walked in the first time with half-patched kit and cave salvage on his belt.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Hadrik wipes soot from his brow and grins at $heroName's build. 'Master Rurik respects shoulders like those. Anyone who walks back from a dragon's shadow alive is worth arming properly. Looking at that axe and those scraps, you could use better steel too.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Hadrik wipes soot from his brow and gives $heroName a curious look. 'You do not look like the forge's usual customer, but anyone who comes back from a dragon's shadow deserves a fair word with Rurik. Even a performer needs buckles that hold and armor that does not fall apart under bad luck.'"
    }

    if ($persona.IsKnightLike) {
        return "Hadrik straightens a little before speaking. 'Master Rurik says a disciplined arm is worth twice the steel in it. Walk in there like that and he'll treat you seriously.'"
    }

    return "Hadrik wipes soot from his brow and jerks a thumb toward the smithy. 'Master Rurik respects anyone who walks back from a dragon's shadow alive. He also notices when a man is still carrying more rust than craft.'"
}

function Get-BelorIntro {
    param(
        $Hero,
        $Game = $null
    )

    $persona = Get-HeroTownPersona -Hero $Hero
    $heroName = Get-HeroTownName -Hero $Hero
    $isNight = $null -ne $Game -and (Get-TownTimeOfDay -Game $Game) -eq "Night"

    if ($isNight) {
        if ($Hero.Level -ge 3) {
            return "Watchman Belor barely looks away from the dark lanes. 'Night's when the city remembers what work like yours is for. Day lets people talk brave. Dark tells us what they actually believe.'"
        }

        return "Watchman Belor's eyes stay on the darker end of the street. 'Night makes honest guards out of some men and liars out of others. Best time there is to learn which is which.'"
    }

    if ($Hero.Level -ge 3) {
        return "Watchman Belor's nod is small but real. 'The halls under the ward are yours now, as far as the watch is concerned. Means the next work we hand you won't be small.'"
    }

    if ($persona.IsKnightLike) {
        return "Watchman Belor gives $heroName the kind of look guards save for people they might one day salute. 'If the cave held one ancient thing, do not assume it held only one.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Watchman Belor studies $heroName a moment longer than most guards bother to. 'You speak well enough to be listened to. Use that well if the cave's trouble spreads further. The watch has use for people who can get the truth before steel has to.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Watchman Belor watches the gate with tired eyes. 'You look like the sort they send where words fail. If the cave held one ancient thing, do not assume it held only one.'"
    }

    return "Watchman Belor watches the gate with tired eyes. 'If the cave held one ancient thing, do not assume it held only one.'"
}

function Get-RingMasterGreeting {
    param($Hero)

    $persona = Get-HeroTownPersona -Hero $Hero
    $heroName = Get-HeroTownName -Hero $Hero
    $ringWins = 0

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"]) {
        $ringWins = [int]$Hero.RingWinsTotal
    }

    if ($ringWins -ge 10) {
        if ($Hero.Level -ge 3) {
            return "Ringmaster Dorr slaps the rail and laughs once. 'Champion and city-breaker both. Good. Means the next ones stepping in won't come for purse alone. They'll come for your name.'"
        }

        return "Ringmaster Dorr slaps the rail hard enough to wake the whole pit. 'Champion's back. Good. The easy money cleared out weeks ago, so now the real challengers come looking for your name.'"
    }

    if ($ringWins -ge 5) {
        return "Ringmaster Dorr gives $heroName a harder look than before, half measuring and half approving. 'The crowd knows you now. That means the next lot will come in sharper.'"
    }

    if ($ringWins -gt 0) {
        return "Ringmaster Dorr points at $heroName with two thick fingers. 'You're not new anymore. The pit remembers faces that win.'"
    }

    if ($persona.IsStrong -and $persona.IsTough) {
        return "Ringmaster Dorr looks $heroName over and bares his teeth in approval. 'Good. Real shoulders, real lungs, real scars. The crowd knows what to do with that.'"
    }

    if ($persona.IsQuick) {
        return "Ringmaster Dorr watches $heroName's footwork before he says a word. 'Fast feet survive longer than loud mouths in my pit. Keep them moving and the crowd might remember you.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Ringmaster Dorr snorts at first, then catches the way $heroName holds the room. 'If you can fight half as well as you carry yourself, the bettors will love you.'"
    }

    if ($persona.IsKnightLike) {
        return "Ringmaster Dorr folds his arms. 'You carry yourself like a drill yard, not a pit. Fine. Show me that discipline still works once the sand starts flying.'"
    }

    return "Ringmaster Dorr drums thick fingers on the rail. 'Weapons stay out. Pride stays in. If you want the purse, earn it with your hands.'"
}

function Resolve-WidowEliraChoice {
    param(
        $Game,
        [string]$Choice
    )

    if ($Game.Town.StreetFlags["WidowEliraResolved"]) {
        return "Elira folds $(Get-HeroTownName -Hero $Game.Hero)'s hand between both of hers. 'You made your answer already, hero. I remember kindness when I see it.'"
    }

    $Game.Town.StreetFlags["WidowEliraResolved"] = $true

    if ($Choice -eq "2") {
        Add-HeroCurrency -Hero $Game.Hero -Denomination "SP" -Amount 4 | Out-Null
        $Game.Town.StreetFlags["WidowGiftClaimed"] = $true
        return "Elira presses a tiny cloth purse into $(Get-HeroTownName -Hero $Game.Hero)'s palm before he can object. $(Get-HeroTownName -Hero $Game.Hero) receives 4 SP from the widow's grateful gift."
    }

    $Game.Town.StreetFlags["WidowGiftDeclined"] = $true
    return "Elira nods anyway. 'Then take my blessing instead. The city owes you more than coin.'"
}

function Resolve-HadrikChoice {
    param(
        $Game,
        [string]$Choice
    )

    $persona = Get-HeroTownPersona -Hero $Game.Hero

    if ($Game.Town.StreetFlags["HadrikResolved"]) {
        return "Hadrik jerks a thumb toward the forge. 'Already told you what I know. Rurik won't hear a better word from me.'"
    }

    $Game.Town.StreetFlags["HadrikResolved"] = $true

    if ($Choice -eq "1") {
        if ($persona.IsBardLike -or $persona.IsCharming) {
            $Game.Town.StreetFlags["HadrikRapierDiscountUnlocked"] = $true
            Set-TownOfferDiscount -Game $Game -OfferId "smithy_rapier" -DiscountCopper 60
            return "Hadrik rubs soot into one palm and nods toward the forge. 'Rurik has a slim rapier in the back that never fit the caravan guards. For someone quick with timing, it'd do better than a butcher's blade. Tell him I sent you and he'll shave the price.' A 6 SP discount is now available on the Rapier at the smithy."
        }

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

    $persona = Get-HeroTownPersona -Hero $Game.Hero

    if ($Game.Town.StreetFlags["BelorResolved"]) {
        return "Belor gives $(Get-HeroTownName -Hero $Game.Hero) a short nod. 'Told you what mattered. The rest is on you.'"
    }

    $Game.Town.StreetFlags["BelorResolved"] = $true

    if ($Choice -eq "1") {
        if ($persona.IsBardLike -or $persona.IsCharming) {
            $Game.Town.StreetFlags["BelorSquarePermit"] = $true
            $Game.Town.Relationships["Belor"] = "Respectful"
            return "Belor glances over the market and grunts. 'If your tongue and hands can hold a crowd, do it where the watch can see you. Tell the square wardens I cleared you to work the market. They'll give you better space and leave the hat alone.' $(Get-HeroTownName -Hero $Game.Hero) gains a market performance permit from the watch."
        }

        if ($persona.IsBarbarian -or $persona.IsStrong -or $persona.IsTough) {
            $Game.Town.StreetFlags["BelorWatchFavor"] = $true
            $Game.Town.Relationships["Belor"] = "Trusting"
            Set-TownOfferDiscount -Game $Game -OfferId "apothecary_healing_potion" -DiscountCopper 15
            Set-TownOfferDiscount -Game $Game -OfferId "apothecary_greater_healing_potion" -DiscountCopper 20
            Set-TownOfferDiscount -Game $Game -OfferId "apothecary_battle_tonic" -DiscountCopper 40
            return "Belor jerks a thumb toward the apothecary and lowers his voice. 'If you're taking the kind of work that ends bloody, tell Nessa the watch sent you. She keeps better bottles behind the shelf for people we expect to come back standing.' $(Get-HeroTownName -Hero $Game.Hero) gains a quiet watch favor for healing supplies."
        }

        $Game.Town.Relationships["Belor"] = "Trusting"
        return "Belor leans in and points across the square. 'The guard station pays steady coin for ugly work. If you want honest jobs, start there.'"
    }

    return "Belor shrugs. 'Fine. Then keep your head down and buy healing before the city empties the shelves.'"
}

function Get-WidowEliraFamilyTalk {
    param($Game)

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["WidowFamilyTalk_Post"]) {
            $Game.Town.StreetFlags["WidowFamilyTalk_Post"] = $true
            return "Elira's eyes brighten. 'My son says the wagoners talk about you like a wall the city can move. That matters more than most soldiers understand.'"
        }

        return "Elira smiles softly. 'It is easier to send family out on the road now that people believe the city can fight back.'"
    }

    if (-not $Game.Town.StreetFlags["WidowFamilyTalk"]) {
        $Game.Town.StreetFlags["WidowFamilyTalk"] = $true
        return "Elira's face softens. 'My boy drives grain in from the outer farms. One rumor about the cave and half the district thought the road was cursed. Your warning got him home before the panic got worse.'"
    }

    return "Elira smiles more easily now. 'He's still home, still complaining about city bread, and still alive. I call that a good week.'"
}

function Get-WidowEliraDistrictTalk {
    param($Game)

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["WidowDistrictTalk_Post"]) {
            $Game.Town.StreetFlags["WidowDistrictTalk_Post"] = $true
            return "Elira glances down the lane and nods once. 'The district still knows fear, but not helplessness. That is new. People stand a little straighter when your name comes up.'"
        }

        return "Elira folds her hands. 'The district is healing. Slow, stubborn, and real.'"
    }

    if (-not $Game.Town.StreetFlags["WidowDistrictTalk"]) {
        $Game.Town.StreetFlags["WidowDistrictTalk"] = $true
        return "Elira glances down the lane before she answers. 'People here act brave in daylight, but every loud sound after dusk still sends shutters closing. The city is upright, not calm.'"
    }

    return "Elira lowers her voice. 'The district is breathing easier than it was, but not easy. Not yet.'"
}

function Get-HadrikForgeTalk {
    param($Game)

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["HadrikForgeTalk_Post"]) {
            $Game.Town.StreetFlags["HadrikForgeTalk_Post"] = $true
            return "Hadrik jerks his chin toward the forge. 'Now that you've proved yourself under the city, Rurik's started talking about steel for named fighters, not just caravan bruisers. Better than that cave-picked junk you first hauled in, anyway.'"
        }

        return "Hadrik laughs under his breath. 'Funny how a forge gets more serious once the hero walking in has already broken a hidden war below the streets instead of showing up with rust, cracks, and dead men's leftovers.'"
    }

    if (-not $Game.Town.StreetFlags["HadrikForgeTalk"]) {
        $Game.Town.StreetFlags["HadrikForgeTalk"] = $true
        return "Hadrik jerks a thumb toward the sparks. 'Rurik says a blade tells you what kind of fool bought it. Fancy steel for nobles, practical steel for survivors, and heavy steel for people who solve things the hard way. The things pulled out of that cave mostly tell him nobody loved them before they died.'"
    }

    return "Hadrik grins through the soot. 'Forge is the same as ever. Too hot, too loud, and somehow still not finished by dusk.'"
}

function Get-HadrikCityTalk {
    param($Game)

    $persona = Get-HeroTownPersona -Hero $Game.Hero
    $heroName = Get-HeroTownName -Hero $Game.Hero

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["HadrikCityTalk_Post"]) {
            $Game.Town.StreetFlags["HadrikCityTalk_Post"] = $true
            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Hadrik lowers his voice. 'Merchants pay faster now that the understreet route is broken, and the rougher ones keep asking what $heroName carries when a real fight is expected. City's gone from frightened to opportunistic in record time.'"
            }

            return "Hadrik lowers his voice. 'Merchants pay faster now that the understreet route is broken. The city has gone from frightened to opportunistic in record time.'"
        }

        if ($persona.IsBarbarian -or $persona.IsStrong) {
            return "Hadrik snorts. 'Same city, more confidence, and twice the demand for good steel. Folk see $heroName now and think of contracts, not cave salvage.'"
        }

        return "Hadrik snorts. 'Same city, more confidence, and twice the demand for good steel.'"
    }

    if (-not $Game.Town.StreetFlags["HadrikCityTalk"]) {
        $Game.Town.StreetFlags["HadrikCityTalk"] = $true
        if ($persona.IsBarbarian -or $persona.IsStrong) {
            return "Hadrik lowers his voice and leans on the doorframe. 'Funny thing about the city: the rich buy polished blades, but the real money comes from the folk who know they'll need $heroName or someone built like that before the week is out.'"
        }

        return "Hadrik lowers his voice and leans on the doorframe. 'Funny thing about the city: the rich buy polished blades, but the real money comes from the folk who know they'll need steel before the week is out.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Hadrik scratches soot from his jaw. 'City still wants steel, and folk glance at $heroName like proof of why. Means the forge sleeps last.'"
    }

    return "Hadrik scratches soot from his jaw. 'City still wants steel. City always wants steel. Means the forge sleeps last.'"
}

function Get-BelorWatchTalk {
    param($Game)

    $persona = Get-HeroTownPersona -Hero $Game.Hero

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["BelorWatchTalk_Post"]) {
            $Game.Town.StreetFlags["BelorWatchTalk_Post"] = $true
            if ($persona.IsBarbarian -or $persona.IsStrong -or $persona.IsTough) {
                return "Belor keeps his eyes on the gate. 'You broke the understreet and now the watch has proof the rot was organized. Means the next enemy will hide smarter, hit dirtier, and need someone stubborn enough to stand there when the line bends.'"
            }

            return "Belor keeps his eyes on the gate. 'You broke the understreet and now the watch has proof the rot was organized. Means the next enemy will hide smarter.'"
        }

        if ($persona.IsBarbarian -or $persona.IsStrong -or $persona.IsTough) {
            return "Belor's mouth tightens. 'The city trusts the walls more today, but walls still need hard people willing to be the part that does not move.'"
        }

        return "Belor's mouth tightens. 'The city trusts the walls more today, but walls only matter if we learn faster than the next lot of liars.'"
    }

    if (-not $Game.Town.StreetFlags["BelorWatchTalk"]) {
        $Game.Town.StreetFlags["BelorWatchTalk"] = $true
        if ($persona.IsBarbarian -or $persona.IsStrong -or $persona.IsTough) {
            return "Belor keeps his eyes on the gate as he talks. 'People think walls keep danger out. Truth is, walls only help if someone broad enough and mean enough can hold the bad lane when it finally turns ugly.'"
        }

        return "Belor keeps his eyes on the gate as he talks. 'People think walls keep danger out. Truth is, walls only help if tired men on watch still know what to look for.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong -or $persona.IsTough) {
        return "Belor's mouth tightens. 'Too many small problems in a city turn into one large one unless someone stands in the right doorway and refuses to move.'"
    }

    return "Belor's mouth tightens. 'Too many small problems in a city turn into one large one if nobody stays awake long enough to connect them.'"
}

function Get-BelorDistrictRumorTalk {
    param($Game)

    if ($Game.Hero.Level -ge 3) {
        if (-not $Game.Town.StreetFlags["BelorDistrictRumorTalk_Post"]) {
            $Game.Town.StreetFlags["BelorDistrictRumorTalk_Post"] = $true
            return "Belor's voice drops. 'People are already whispering that Serik answered to someone else. You know how cities work. Once one hidden hand is cut off, everyone starts looking for the arm.'"
        }

        return "Belor exhales through his nose. 'The streets are calmer. The rumors are not.'"
    }

    if (-not $Game.Town.StreetFlags["BelorDistrictRumorTalk"]) {
        $Game.Town.StreetFlags["BelorDistrictRumorTalk"] = $true
        return "Belor keeps his tone flat. 'Outer lanes are jumpy, river quarter is lying about something, and half the city still thinks the trouble lives outside the walls. It doesn't.'"
    }

    return "Belor exhales through his nose. 'Same rumors, sharper edges. That usually means some of them are true.'"
}

function Test-TownStreetContactAvailableAtCurrentTime {
    param(
        $Game,
        [string]$ContactId
    )

    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

    switch ($ContactId) {
        "WidowElira" { return -not $isNight }
        "Hadrik" { return -not $isNight }
        default { return $true }
    }
}

function Get-TownStreetContactUnavailableText {
    param(
        $Game,
        [string]$ContactId
    )

    switch ($ContactId) {
        "WidowElira" { return "Widow Elira has gone inside for the night. The district keeps its doors shut earlier when darkness starts pressing on the lanes." }
        "Hadrik" { return "Hadrik has long since withdrawn behind the forge doors, leaving only banked coals and late hammer echoes." }
        default { return "That contact is not out on the street right now." }
    }
}

function Start-WidowEliraConversation {
    param($Game)

    $showIntro = $true

    while ($true) {
        if ($showIntro) {
            Write-Scene (Get-WidowEliraIntro -Hero $Game.Hero -Game $Game)
            $showIntro = $false
        }
        Write-TownTimeTracker -Game $Game -Area "Elira"
        Write-ColorLine "1. Ask after her family" "White"
        Write-ColorLine "2. Ask how the district is holding up" "White"
        Write-ColorLine "3. Tell her no thanks are needed" "White"
        Write-ColorLine "4. Accept her gratitude with respect" "White"
        Write-ColorLine "0. Back to streets" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Get-WidowEliraFamilyTalk -Game $Game)
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Get-WidowEliraDistrictTalk -Game $Game)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Resolve-WidowEliraChoice -Game $Game -Choice "1")
                Write-ColorLine ""
            }
            "4" {
                Write-Scene (Resolve-WidowEliraChoice -Game $Game -Choice "2")
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

function Start-HadrikConversation {
    param($Game)

    $showIntro = $true

    while ($true) {
        if ($showIntro) {
            Write-Scene (Get-HadrikIntro -Hero $Game.Hero -Game $Game)
            $showIntro = $false
        }
        Write-TownTimeTracker -Game $Game -Area "Hadrik"
        Write-ColorLine "1. Ask about the forge and its steel" "White"
        Write-ColorLine "2. Ask how business in the city has changed" "White"
        $workQuestion = if ($Game.Hero.Class -eq "Bard") { "3. Ask if the forge knows anyone outfitting duelists and performers" } else { "3. Ask if the forge has anything worth carrying into the wilds" }
        Write-ColorLine $workQuestion "White"
        Write-ColorLine "4. Shrug him off and keep walking" "White"
        Write-ColorLine "0. Back to streets" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Get-HadrikForgeTalk -Game $Game)
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Get-HadrikCityTalk -Game $Game)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Resolve-HadrikChoice -Game $Game -Choice "1")
                Write-ColorLine ""
            }
            "4" {
                Write-Scene (Resolve-HadrikChoice -Game $Game -Choice "2")
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

function Start-BelorConversation {
    param($Game)

    $showIntro = $true

    while ($true) {
        if ($showIntro) {
            Write-Scene (Get-BelorIntro -Hero $Game.Hero -Game $Game)
            $showIntro = $false
        }
        Write-TownTimeTracker -Game $Game -Area "Belor"
        $workQuestion = if ($Game.Hero.Class -eq "Bard") { "1. Ask where someone with presence can find honest coin" } else { "1. Ask where a capable fighter can find decent work" }
        Write-ColorLine $workQuestion "White"
        Write-ColorLine "2. Ask what has the watch worried" "White"
        Write-ColorLine "3. Ask which part of the city feels wrong" "White"
        Write-ColorLine "4. Thank him and move on" "White"
        Write-ColorLine "0. Back to streets" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Resolve-BelorChoice -Game $Game -Choice "1")
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Get-BelorWatchTalk -Game $Game)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Get-BelorDistrictRumorTalk -Game $Game)
                Write-ColorLine ""
            }
            "4" {
                Write-Scene (Resolve-BelorChoice -Game $Game -Choice "2")
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

function Start-TownStreetScene {
    param(
        $Game,
        [string]$ReturnLabel = "Back to town"
    )

    $showIntro = $true
    $heroName = Get-HeroTownName -Hero $Game.Hero

    while ($true) {
        Write-SectionTitle -Text "City Streets" -Color "Cyan"
        Write-TownTimeTracker -Game $Game -Area "Streets"

        if ($showIntro -and -not $Game.Town.StreetFlags["StreetSceneVisited"]) {
            if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
                if ($Game.Hero.Class -eq "Bard") {
                    Write-Scene "$heroName moves through narrow lanes under lantern glow, where voices drop lower, shutters sit half-closed, and every rumor sounds a little more deliberate."
                    Write-Scene "Night turns the streets into a different kind of stage. Gratitude, fear, and opportunity all speak softer, but none of them speak less."
                }
                else {
                    Write-Scene "$heroName moves through narrow lanes under lantern glow, where doors are shut, conversations turn quiet, and the city feels alert in a harder way than it does by day."
                    Write-Scene "Some faces still want to thank him. Others only watch, as if night itself might decide what kind of trouble comes next."
                }
            }
            elseif ($Game.Hero.Class -eq "Bard") {
                Write-Scene "$heroName moves through narrow lanes lit by lanterns, where relieved citizens speak the name in hushed half-whispers and curious tavern retellings."
                Write-Scene "Some want to thank him. Others want to warn him. A few are already trying to pull him toward the next kind of trouble, certain he can talk his way into rooms they cannot reach."
            }
            else {
                Write-Scene "$heroName moves through narrow lanes lit by lanterns, where relieved citizens speak the name in hushed half-whispers."
                Write-Scene "Some want to thank him. Others want to warn him. A few are already trying to pull him toward the next kind of trouble."
            }
            $Game.Town.StreetFlags["StreetSceneVisited"] = $true
        }
        elseif ($showIntro) {
            if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
                if ($Game.Hero.Class -eq "Bard") {
                    Write-Scene "At night the streets read $heroName differently. Familiar faces still recognize him, but now they measure whether he looks like a witness, a rumor-carrier, or the answer to some private problem."
                }
                else {
                    Write-Scene "At night the streets read $heroName differently. The city watches him less like a passerby and more like someone who might actually matter before dawn."
                }
            }
            elseif ($Game.Hero.Class -eq "Bard") {
                if ([int]$Game.Town.PerformanceCountTotal -ge 6) {
                    Write-Scene "The streets know $heroName a little better now. Familiar faces still watch for him, and more than one passerby recognizes the city's working performer before the next whisper even starts."
                }
                else {
                    Write-Scene "The streets know $heroName a little better now. Familiar faces still watch for him, each hoping to be remembered when the city's whispers need carrying somewhere useful."
                }
            }
            else {
                Write-Scene "The streets know $heroName a little better now. Familiar faces still watch for him, each hoping to be remembered for the right reason."
            }
        }

        $showIntro = $false

        Write-ColorLine ""
        Write-ColorLine $(if ((Get-TownTimeOfDay -Game $Game) -eq "Night") { "Who do you seek out under the lamps?" } else { "Who do you want to speak with?" }) "Cyan"
        if (Test-TownStreetContactAvailableAtCurrentTime -Game $Game -ContactId "WidowElira") {
            Write-ColorLine "1. Speak with Widow Elira" "White"
        }
        else {
            Write-ColorLine "1. Widow Elira has gone inside for the night" "DarkGray"
        }
        if (Test-TownStreetContactAvailableAtCurrentTime -Game $Game -ContactId "Hadrik") {
            Write-ColorLine "2. Speak with Hadrik the smith's apprentice" "White"
        }
        else {
            Write-ColorLine "2. Hadrik has gone back to the forge" "DarkGray"
        }
        Write-ColorLine "3. Speak with Watchman Belor" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. $ReturnLabel" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                if (-not (Test-TownStreetContactAvailableAtCurrentTime -Game $Game -ContactId "WidowElira")) {
                    Write-Scene (Get-TownStreetContactUnavailableText -Game $Game -ContactId "WidowElira")
                    Write-ColorLine ""
                }
                else {
                    Start-WidowEliraConversation -Game $Game
                }
            }
            "2" {
                if (-not (Test-TownStreetContactAvailableAtCurrentTime -Game $Game -ContactId "Hadrik")) {
                    Write-Scene (Get-TownStreetContactUnavailableText -Game $Game -ContactId "Hadrik")
                    Write-ColorLine ""
                }
                else {
                    Start-HadrikConversation -Game $Game
                }
            }
            "3" {
                Start-BelorConversation -Game $Game
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $Game.Hero.HP
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


