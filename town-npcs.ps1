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

function Get-InnKeeperGreeting {
    param(
        $Inn,
        $Hero,
        [bool]$RepeatVisit = $false
    )

    $persona = Get-HeroTownPersona -Hero $Hero

    switch ($Inn.Id) {
        "bent_nail" {
            if ($RepeatVisit) {
                return "Marta jerks her chin toward the bar. 'Room's still yours if the coin keeps showing up and the trouble stays manageable.'"
            }

            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Marta squints up at Borzig's shoulders and grunts. 'You look like the kind who breaks furniture instead of rules. Pay first and keep the trouble pointed away from my bar.'"
            }

            if ($persona.IsBardLike -or $persona.IsCharming) {
                return "Marta gives Borzig a narrow look. 'Pretty words do not buy a bed here. Coin does. If you've got both, keep the words short and the purse visible.'"
            }

            if ($persona.IsKnightLike) {
                return "Marta eyes Borzig's posture like it belongs in a cleaner room. 'You'll not fix this place by standing straighter, soldier. Pay, sleep, and mind your temper.'"
            }

            return $Inn.KeeperText
        }
        "lantern_rest" {
            if ($RepeatVisit) {
                return "Oren gives Borzig an easy nod. 'Back again. Same room, same clean sheets, same promise that this place stays calmer than most.'"
            }

            if ($persona.IsBardLike -or $persona.IsCharming) {
                return "Oren's smile comes easier as he sizes Borzig up. 'A good room, a better meal, and company willing to listen if you speak like you mean it. That is what the Lantern Rest is for.'"
            }

            if ($persona.IsKnightLike) {
                return "Oren dips his head with almost formal respect. 'Discipline is welcome here, and so is coin. You'll find both the sheets and the service in proper order.'"
            }

            if ($persona.IsBarbarian -or $persona.IsStrong) {
                return "Oren measures Borzig with a practiced host's calm. 'We've had caravan guards rougher than you and merchants softer. Leave both at the door and we'll get along well enough.'"
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
                return "Madam Seraphine studies Borzig like a wolf invited into a ballroom. 'Strength has its uses, darling, but under my roof it will wear boots clean enough not to offend the carpets.'"
            }

            return $Inn.KeeperText
        }
        default {
            return $Inn.KeeperText
        }
    }
}

function Get-WidowEliraIntro {
    param($Hero)

    $persona = Get-HeroTownPersona -Hero $Hero

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Widow Elira reaches for Borzig's hand with watery eyes. 'The city said you carried yourself gently, and now I see why. Your warning brought my son home before sunset.'"
    }

    if ($persona.IsKnightLike) {
        return "Widow Elira bows her head before speaking. 'You carry yourself like someone who still believes duty matters. Your warning brought my son home before sunset.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Widow Elira grips Borzig's wrist with surprising strength. 'I feared a hard man would bring only hard news, but your warning brought my son home before sunset.'"
    }

    return "Widow Elira grips Borzig's wrist with surprising strength. 'My son was on the road when the dragon panic started. Your warning brought him home before sunset.'"
}

function Get-HadrikIntro {
    param($Hero)

    $persona = Get-HeroTownPersona -Hero $Hero

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Hadrik wipes soot from his brow and grins at Borzig's build. 'Master Rurik respects shoulders like those. Anyone who walks back from a dragon's shadow alive is worth arming properly.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Hadrik wipes soot from his brow and gives Borzig a curious look. 'You do not look like the forge's usual customer, but anyone who comes back from a dragon's shadow deserves a fair word with Rurik.'"
    }

    if ($persona.IsKnightLike) {
        return "Hadrik straightens a little before speaking. 'Master Rurik says a disciplined arm is worth twice the steel in it. Walk in there like that and he'll treat you seriously.'"
    }

    return "Hadrik wipes soot from his brow and jerks a thumb toward the smithy. 'Master Rurik respects anyone who walks back from a dragon's shadow alive.'"
}

function Get-BelorIntro {
    param($Hero)

    $persona = Get-HeroTownPersona -Hero $Hero

    if ($persona.IsKnightLike) {
        return "Watchman Belor gives Borzig the kind of look guards save for people they might one day salute. 'If the cave held one ancient thing, do not assume it held only one.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Watchman Belor studies Borzig a moment longer than most guards bother to. 'You speak well enough to be listened to. Use that well if the cave's trouble spreads further.'"
    }

    if ($persona.IsBarbarian -or $persona.IsStrong) {
        return "Watchman Belor watches the gate with tired eyes. 'You look like the sort they send where words fail. If the cave held one ancient thing, do not assume it held only one.'"
    }

    return "Watchman Belor watches the gate with tired eyes. 'If the cave held one ancient thing, do not assume it held only one.'"
}

function Get-RingMasterGreeting {
    param($Hero)

    $persona = Get-HeroTownPersona -Hero $Hero
    $ringWins = 0

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"]) {
        $ringWins = [int]$Hero.RingWinsTotal
    }

    if ($ringWins -ge 10) {
        return "Ringmaster Dorr slaps the rail hard enough to wake the whole pit. 'Champion's back. Good. The easy money cleared out weeks ago, so now the real challengers come looking for your name.'"
    }

    if ($ringWins -ge 5) {
        return "Ringmaster Dorr gives Borzig a harder look than before, half measuring and half approving. 'The crowd knows you now. That means the next lot will come in sharper.'"
    }

    if ($ringWins -gt 0) {
        return "Ringmaster Dorr points at Borzig with two thick fingers. 'You're not new anymore. The pit remembers faces that win.'"
    }

    if ($persona.IsStrong -and $persona.IsTough) {
        return "Ringmaster Dorr looks Borzig over and bares his teeth in approval. 'Good. Real shoulders, real lungs, real scars. The crowd knows what to do with that.'"
    }

    if ($persona.IsQuick) {
        return "Ringmaster Dorr watches Borzig's footwork before he says a word. 'Fast feet survive longer than loud mouths in my pit. Keep them moving and the crowd might remember you.'"
    }

    if ($persona.IsBardLike -or $persona.IsCharming) {
        return "Ringmaster Dorr snorts at first, then catches the way Borzig holds the room. 'If you can fight half as well as you carry yourself, the bettors will love you.'"
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

function Get-WidowEliraFamilyTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["WidowFamilyTalk"]) {
        $Game.Town.StreetFlags["WidowFamilyTalk"] = $true
        return "Elira's face softens. 'My boy drives grain in from the outer farms. One rumor about the cave and half the district thought the road was cursed. Your warning got him home before the panic got worse.'"
    }

    return "Elira smiles more easily now. 'He's still home, still complaining about city bread, and still alive. I call that a good week.'"
}

function Get-WidowEliraDistrictTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["WidowDistrictTalk"]) {
        $Game.Town.StreetFlags["WidowDistrictTalk"] = $true
        return "Elira glances down the lane before she answers. 'People here act brave in daylight, but every loud sound after dusk still sends shutters closing. The city is upright, not calm.'"
    }

    return "Elira lowers her voice. 'The district is breathing easier than it was, but not easy. Not yet.'"
}

function Get-HadrikForgeTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["HadrikForgeTalk"]) {
        $Game.Town.StreetFlags["HadrikForgeTalk"] = $true
        return "Hadrik jerks a thumb toward the sparks. 'Rurik says a blade tells you what kind of fool bought it. Fancy steel for nobles, practical steel for survivors, and heavy steel for people who solve things the hard way.'"
    }

    return "Hadrik grins through the soot. 'Forge is the same as ever. Too hot, too loud, and somehow still not finished by dusk.'"
}

function Get-HadrikCityTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["HadrikCityTalk"]) {
        $Game.Town.StreetFlags["HadrikCityTalk"] = $true
        return "Hadrik lowers his voice and leans on the doorframe. 'Funny thing about the city: the rich buy polished blades, but the real money comes from the folk who know they'll need steel before the week is out.'"
    }

    return "Hadrik scratches soot from his jaw. 'City still wants steel. City always wants steel. Means the forge sleeps last.'"
}

function Get-BelorWatchTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["BelorWatchTalk"]) {
        $Game.Town.StreetFlags["BelorWatchTalk"] = $true
        return "Belor keeps his eyes on the gate as he talks. 'People think walls keep danger out. Truth is, walls only help if tired men on watch still know what to look for.'"
    }

    return "Belor's mouth tightens. 'Too many small problems in a city turn into one large one if nobody stays awake long enough to connect them.'"
}

function Get-BelorDistrictRumorTalk {
    param($Game)

    if (-not $Game.Town.StreetFlags["BelorDistrictRumorTalk"]) {
        $Game.Town.StreetFlags["BelorDistrictRumorTalk"] = $true
        return "Belor keeps his tone flat. 'Outer lanes are jumpy, river quarter is lying about something, and half the city still thinks the trouble lives outside the walls. It doesn't.'"
    }

    return "Belor exhales through his nose. 'Same rumors, sharper edges. That usually means some of them are true.'"
}

function Start-WidowEliraConversation {
    param($Game)

    while ($true) {
        Write-Scene (Get-WidowEliraIntro -Hero $Game.Hero)
        Write-ColorLine "1. Ask after her family" "White"
        Write-ColorLine "2. Ask how the district is holding up" "White"
        Write-ColorLine "3. Tell her no thanks are needed" "White"
        Write-ColorLine "4. Accept her gratitude with respect" "White"
        Write-ColorLine "0. Back" "DarkGray"
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

    while ($true) {
        Write-Scene (Get-HadrikIntro -Hero $Game.Hero)
        Write-ColorLine "1. Ask about the forge and its steel" "White"
        Write-ColorLine "2. Ask how business in the city has changed" "White"
        Write-ColorLine "3. Ask if the forge has anything worth carrying into the wilds" "White"
        Write-ColorLine "4. Shrug him off and keep walking" "White"
        Write-ColorLine "0. Back" "DarkGray"
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

    while ($true) {
        Write-Scene (Get-BelorIntro -Hero $Game.Hero)
        Write-ColorLine "1. Ask where a capable fighter can find decent work" "White"
        Write-ColorLine "2. Ask what has the watch worried" "White"
        Write-ColorLine "3. Ask which part of the city feels wrong" "White"
        Write-ColorLine "4. Thank him and move on" "White"
        Write-ColorLine "0. Back" "DarkGray"
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
    param($Game)

    while ($true) {
        Write-SectionTitle -Text "City Streets" -Color "Cyan"

        if (-not $Game.Town.StreetFlags["StreetSceneVisited"]) {
            Write-Scene "Borzig moves through narrow lanes lit by lanterns, where relieved citizens speak his name in hushed half-whispers."
            Write-Scene "Some want to thank him. Others want to warn him. A few are already trying to pull him toward the next kind of trouble."
            $Game.Town.StreetFlags["StreetSceneVisited"] = $true
        }
        else {
            Write-Scene "The streets know Borzig a little better now. Familiar faces still watch for him, each hoping to be remembered for the right reason."
        }

        Write-ColorLine ""
        Write-ColorLine "1. Speak with Widow Elira" "White"
        Write-ColorLine "2. Speak with Hadrik the smith's apprentice" "White"
        Write-ColorLine "3. Speak with Watchman Belor" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Start-WidowEliraConversation -Game $Game
            }
            "2" {
                Start-HadrikConversation -Game $Game
            }
            "3" {
                Start-BelorConversation -Game $Game
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


