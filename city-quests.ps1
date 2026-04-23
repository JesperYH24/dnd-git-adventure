# Chapter quests live outside the generic town menu code so each quest can grow into its own small adventure.

function Get-NightWatchReliefEnemy {
    return [PSCustomObject]@{
        name = "tunnel runner"
        article = "A"
        definite = "The Tunnel Runner"
        combatantType = "Opponent"
        hp = 12
        xp = 0
        armorClass = 11
        attackBonus = 2
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 6
        damageBonus = 1
        damageMin = 2
        damageMax = 7
        isBoss = $false
    }
}

function Get-StorehouseTroubleEnemy {
    return [PSCustomObject]@{
        name = "storehouse cutthroat"
        article = "A"
        definite = "The Storehouse Cutthroat"
        combatantType = "Opponent"
        hp = 14
        xp = 0
        armorClass = 12
        attackBonus = 3
        initiativeBonus = 1
        damageDiceCount = 1
        damageDiceSides = 6
        damageBonus = 2
        damageMin = 3
        damageMax = 8
        isBoss = $false
    }
}

function Get-BrokenSealPatrolEnemy {
    return [PSCustomObject]@{
        name = "understreet enforcer"
        article = "An"
        definite = "The Understreet Enforcer"
        combatantType = "Opponent"
        hp = 16
        xp = 0
        armorClass = 13
        attackBonus = 4
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 2
        damageMin = 3
        damageMax = 10
        isBoss = $false
    }
}

function New-UnderstreetQuestRoom {
    param(
        [string]$Id,
        [string]$Name,
        [string]$Description,
        [hashtable]$Exits,
        [string]$EncounterFactory = "",
        [string]$EncounterTitle = "",
        [string]$EncounterIntro = "",
        [bool]$BossRoom = $false,
        [bool]$CanShortRest = $false
    )

    $room = New-Room -Id $Id -Name $Name -Description $Description -Exits $Exits -BossRoom $BossRoom
    $room | Add-Member -NotePropertyName EncounterFactory -NotePropertyValue $EncounterFactory
    $room | Add-Member -NotePropertyName EncounterTitle -NotePropertyValue $EncounterTitle
    $room | Add-Member -NotePropertyName EncounterIntro -NotePropertyValue $EncounterIntro
    $room | Add-Member -NotePropertyName Secured -NotePropertyValue $false
    $room | Add-Member -NotePropertyName ShortRestTaken -NotePropertyValue $false
    $room | Add-Member -NotePropertyName RestHintShown -NotePropertyValue $false
    $room | Add-Member -NotePropertyName CanShortRest -NotePropertyValue $CanShortRest
    $room | Add-Member -NotePropertyName SearchHintText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName SearchPromptText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName SearchSuccessText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName SearchFailureText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName SearchDC -NotePropertyValue 0
    $room | Add-Member -NotePropertyName SearchResolved -NotePropertyValue $false
    $room | Add-Member -NotePropertyName HiddenLoot -NotePropertyValue @()
    $room | Add-Member -NotePropertyName SearchRewardFlag -NotePropertyValue ""
    $room | Add-Member -NotePropertyName SearchRewardText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName LockedCacheName -NotePropertyValue ""
    $room | Add-Member -NotePropertyName LockedCacheHintText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName LockedCacheOpened -NotePropertyValue $false
    $room | Add-Member -NotePropertyName LockedCacheForceDC -NotePropertyValue 0
    $room | Add-Member -NotePropertyName LockedCachePickDC -NotePropertyValue 0
    $room | Add-Member -NotePropertyName LockedCacheKeyFlag -NotePropertyValue ""
    $room | Add-Member -NotePropertyName LockedCacheLoot -NotePropertyValue @()
    $room | Add-Member -NotePropertyName LockedCacheOpenText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName LockedCacheFailText -NotePropertyValue ""
    $room | Add-Member -NotePropertyName EncounterRewardFlag -NotePropertyValue ""
    $room | Add-Member -NotePropertyName EncounterRewardText -NotePropertyValue ""
    return $room
}

function Format-UnderstreetHeroText {
    param(
        [string]$Text,
        $Hero
    )

    return (Resolve-HeroNarrativeText -Text $Text -Hero $Hero)
}

function Get-UnderstreetFinalClassText {
    param(
        $Hero,
        [string]$Key
    )

    $isBard = $null -ne $Hero -and $Hero.Class -eq "Bard"
    $name = if ($null -ne $Hero -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Name)) { [string]$Hero.Name } else { "the hero" }

    switch ($Key) {
        "NeedAccepted" {
            if ($isBard) { return "$name needs to take the final understreet assignment before the watch will trust his read on the room, the route, and the lies holding both together." }
            return "$name needs to take the final understreet assignment before the watch will commit men and steel."
        }
        "NeedEvidence" {
            if ($isBard) { return "$name still lacks enough hard evidence to turn rumor, ledgers, and whispers into a watch-sanctioned strike beneath the city." }
            return "$name still lacks enough hard evidence to force the watch into the understreet complex."
        }
        "BriefingClues" {
            if ($isBard) { return "Captain Halden spreads $name's gathered clues across a scarred planning table: broken seals, courier marks, ledger scraps, broker whispers, and the careful social pressure that made the city's hidden pattern sing in tune." }
            return "Captain Halden spreads $name's gathered clues across a scarred planning table: broken seals, courier marks, ledger scraps, and broker whispers that all point below the same streets."
        }
        "BriefingPrep" {
            if ($isBard) { return "The watch begins its quiet preparations while $name studies tunnel sketches like a hostile score: sealed descent, contraband hall, record chamber, and command vault, each one waiting for the wrong note." }
            return "The watch begins its quiet preparations while $name looks over tunnel sketches showing a sealed descent, a contraband hall, and the command vault at the heart of the route."
        }
        "ApproachWatch" {
            if ($isBard) { return "$name descends beside two watch veterans, reading their silences as carefully as the tunnel turns while black runoff splashes underfoot." }
            return "$name descends beside two watch veterans, boots splashing into black runoff beneath the district."
        }
        "ApproachBroker" {
            if ($isBard) { return "$name takes the broker's lower route, carrying a half-truth, a quiet smile, and enough confidence to enter before the smugglers know which story they are trapped inside." }
            return "$name takes the broker's route instead, entering through a mean little cut beneath old river stairs before the smugglers can shift their guard."
        }
        "ApproachStudyAction" {
            if ($isBard) { return "$name studies the sketched route and gathered clues like competing verses, looking for the refrain that reveals where Serik's command vault must be." }
            return "$name studies the sketched route and the gathered clues one last time before committing to the descent."
        }
        "ApproachStudySuccess" {
            if ($isBard) { return "The pattern resolves in $name's head: route, motive, witness, and hiding place all falling into one clean progression. He leads the descent like he already knows where the silence will break." }
            return "The route finally clicks into place in $name's head. He leads the descent like he has already walked it once in the dark."
        }
        "ApproachStudyFail" {
            if ($isBard) { return "$name catches enough of the pattern to move. It is not a perfect read, but it is enough to step into the dark without letting the room set the tempo." }
            return "$name gets enough from the map to move. It is not elegant, but it is enough to start the descent with purpose."
        }
        "MoveRoomByRoom" {
            if ($isBard) { return "$name will have to move room by room, reading threats, records, and frightened men before the whole hidden arrangement can collapse cleanly." }
            return "$name will have to move room by room if he wants to break it cleanly."
        }
        "Victory" {
            if ($isBard) { return "Whatever comes next for the city will grow out of this ruin, because $name has turned whispers, ledgers, and the final blade in the dark into proof no one can sing away." }
            return "Whatever comes next for the city will grow out of this ruin, because $name has broken the hidden structure that held the whole scheme together."
        }
        default {
            return ""
        }
    }
}

function Get-UnderstreetComplexRooms {
    $rooms = @{
        sealed_descent = (New-UnderstreetQuestRoom -Id "sealed_descent" -Name "Sealed Descent" -Description "Broken stone stairs fall away beneath the ward. Damp mortar and old guard sigils mark the last point where the city still pretended these routes were closed. Fresh scrape marks suggest heavy crates were dragged east in a hurry." -Exits @{ east = "contraband_hall" })
        contraband_hall = (New-UnderstreetQuestRoom -Id "contraband_hall" -Name "Contraband Hall" -Description "False crates line the passage in crooked ranks. Cheap lamp oil, stamped cloth, and sealed packets have all been staged here for quick movement above. One stack leans at an angle that looks too deliberate to be accidental." -Exits @{ west = "sealed_descent"; south = "cistern_refuge"; east = "tally_crossing"; north = "sentry_turn" } -EncounterFactory "Get-UnderstreetLookoutEnemy" -EncounterTitle "Contraband Hall" -EncounterIntro "A hard-eyed lookout lunges out from behind a wall of false cargo, trying to buy the complex enough time to bury its evidence.")
        cistern_refuge = (New-UnderstreetQuestRoom -Id "cistern_refuge" -Name "Cistern Refuge" -Description "An old maintenance alcove opens beside a stagnant cistern. The space is cramped, but the stone lip and rusted grating make it defensible if {hero} takes the time to secure it. Someone once hid here long enough to scratch warning marks into the lime." -Exits @{ north = "contraband_hall" } -CanShortRest $true)
        sentry_turn = (New-UnderstreetQuestRoom -Id "sentry_turn" -Name "Sentry Turn" -Description "A bent corner widens just enough for a sentry post. A stool, a lantern hook, and a strip of chalked wall codes tell {hero} this turn was meant to watch three approaches at once." -Exits @{ south = "contraband_hall"; east = "flooded_switchback"; north = "collapsed_barracks" } -EncounterFactory "Get-UnderstreetSentryEnemy" -EncounterTitle "Sentry Turn" -EncounterIntro "A sentry with a hooked knife kicks the stool aside and comes at {hero} before he can read the wall codes.")
        collapsed_barracks = (New-UnderstreetQuestRoom -Id "collapsed_barracks" -Name "Collapsed Barracks" -Description "Half the ceiling has given up here, crushing rotten bunks and leaving a crescent of dry ground near the back wall. A faded gambling rhyme and a cracked footlocker make the dead-end feel less abandoned than it should." -Exits @{ south = "sentry_turn" } -CanShortRest $true)
        tally_crossing = (New-UnderstreetQuestRoom -Id "tally_crossing" -Name "Tally Crossing" -Description "Three passages knot together around a waist-high counting table scarred by blades and ink. Every path looks used, but not equally often. The south passage smells of sump water while the east smells of lampblack and old paper." -Exits @{ west = "contraband_hall"; north = "flooded_switchback"; east = "record_chamber"; south = "sump_gallery" })
        flooded_switchback = (New-UnderstreetQuestRoom -Id "flooded_switchback" -Name "Flooded Switchback" -Description "The tunnel kinks twice around a flooded trench where dark water moves just fast enough to hide its depth. Bootprints crowd one ledge, and claw-marks score the stone near the bend." -Exits @{ west = "sentry_turn"; south = "tally_crossing"; east = "old_armory" } -EncounterFactory "Get-UnderstreetHoundEnemy" -EncounterTitle "Flooded Switchback" -EncounterIntro "A chain-scarred tunnel hound splashes up from the trench edge while its handler drives it toward {hero} with a curse.")
        sump_gallery = (New-UnderstreetQuestRoom -Id "sump_gallery" -Name "Sump Gallery" -Description "The floor dips into a long wet gallery lined with runoff channels and rusted hooks. Someone has been using the dripping noise to hide whispered conversations. One section of wall bears a cleaner rectangle where something once hung." -Exits @{ north = "tally_crossing"; east = "whisper_cells" })
        whisper_cells = (New-UnderstreetQuestRoom -Id "whisper_cells" -Name "Whisper Cells" -Description "A row of cramped holding cells sits behind warped bars. Most doors hang open, but one remains shut beside a niche where candles were burned down to wax claws. The place feels important in the way forgotten cruelty always does." -Exits @{ west = "sump_gallery" })
        old_armory = (New-UnderstreetQuestRoom -Id "old_armory" -Name "Old Armory" -Description "Weapon racks stand stripped or bent, but a reinforced locker still clings to the wall under a rusted watch crest. The floor shows recent traffic. If the smugglers kept anything worth saving, it may be in here." -Exits @{ west = "flooded_switchback"; south = "record_chamber"; north = "smugglers_lockup" } -EncounterFactory "Get-UnderstreetArmoryWardenEnemy" -EncounterTitle "Old Armory" -EncounterIntro "An armored warden tears a pry-bar off the wall and charges before {hero} can test the locker.")
        smugglers_lockup = (New-UnderstreetQuestRoom -Id "smugglers_lockup" -Name "Smugglers' Lockup" -Description "The lockup is a dead-end cage of chain, old manacles, and confiscated satchels. A key ring is missing from the board, but a single hook still bears fresh scratches and a scrap of red cloth." -Exits @{ south = "old_armory" } -EncounterFactory "Get-UnderstreetGaolerEnemy" -EncounterTitle "Smugglers' Lockup" -EncounterIntro "The lockup's gaoler steps out from the shadows with chain wrapped around one forearm and a cudgel in the other hand.")
        record_chamber = (New-UnderstreetQuestRoom -Id "record_chamber" -Name "Record Chamber" -Description "Shelves of coded tallies and damp ledgers fill a long narrow room. The understreet network kept its memory here, hidden in dust and oilskin. Some shelves stand too far from the wall, as if the room was searched in a panic." -Exits @{ west = "tally_crossing"; north = "old_armory"; east = "command_vault" } -EncounterFactory "Get-UnderstreetRecordKeeperEnemy" -EncounterTitle "Record Chamber" -EncounterIntro "A ledger-keeper slams shut a hidden folio, grabs a hooked blade, and throws himself between {hero} and the chamber's evidence.")
        command_vault = (New-UnderstreetQuestRoom -Id "command_vault" -Name "Command Vault" -Description "The deepest chamber is half office, half bunker. Route maps, coin ledgers, and sealed orders cover a heavy table beneath a pair of guttering lanterns. A locked war chest sits open just enough to prove Serik was ready to run." -Exits @{ west = "record_chamber" } -EncounterFactory "Get-UnderstreetCaptainEnemy" -EncounterTitle "Command Vault" -EncounterIntro "Captain Serik steps into the lantern glow with a heavy blade, a command ledger under one arm, and the cold expression of a man who thought the city would never reach him down here." -BossRoom $true)
    }

    $rooms["contraband_hall"].SearchHintText = "The slanted cargo stack looks wrong. There may be something worth searching if {hero} slows down."
    $rooms["contraband_hall"].SearchPromptText = "Search the false cargo stacks for hidden spoils or route notes."
    $rooms["contraband_hall"].SearchSuccessText = "{hero} shifts the false crates and finds a smuggler's drop pocket: a healing draught, loose coin, and a chalk map marking the hall as a transfer point."
    $rooms["contraband_hall"].SearchFailureText = "{hero} checks the stacks, but the best hiding place was already skimmed clean before he spots it."
    $rooms["contraband_hall"].SearchDC = 11
    $rooms["contraband_hall"].HiddenLoot += (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1)
    $rooms["contraband_hall"].HiddenLoot += (New-CurrencyItem -Denomination "SP" -Amount 8)

    $rooms["collapsed_barracks"].SearchHintText = "The cracked footlocker and gambling rhyme make this dead-end feel like it still holds a private stash."
    $rooms["collapsed_barracks"].SearchPromptText = "Search the collapsed bunks and broken footlocker for anything the sentries hid here."
    $rooms["collapsed_barracks"].SearchSuccessText = "{hero} pries open the crushed locker and finds a field note, a tucked-away potion, and a line about 'the red rag on the lockup board'."
    $rooms["collapsed_barracks"].SearchFailureText = "{hero} turns the dead-end over, but the best hiding place stays buried under splintered bunks and stone."
    $rooms["collapsed_barracks"].SearchDC = 12
    $rooms["collapsed_barracks"].HiddenLoot += (New-ConsumableItem -Name "Healing Potion" -Value 60 -HealAmount 8 -SlotCost 1)
    $rooms["collapsed_barracks"].SearchRewardText = "Lore: the barracks note suggests the missing armory key was hung near the lockup under a strip of red cloth."

    $rooms["sump_gallery"].SearchHintText = "The clean patch on the wall and the sound-cover of the runoff both suggest someone hid things here."
    $rooms["sump_gallery"].SearchPromptText = "Search the runoff hooks and wall seams for anything hidden behind the noise."
    $rooms["sump_gallery"].SearchSuccessText = "{hero} finds a wax-wrapped packet tucked into the wall seam: route ciphers, a little coin, and another hint that Serik kept backup exits ready."
    $rooms["sump_gallery"].SearchFailureText = "{hero} checks the dripping wall, but the hiding place stays just out of reach."
    $rooms["sump_gallery"].SearchDC = 12
    $rooms["sump_gallery"].HiddenLoot += (New-CurrencyItem -Denomination "SP" -Amount 12)
    $rooms["sump_gallery"].SearchRewardText = "Lore: the ciphers describe fallback routes and emergency fires meant to erase the record chamber in minutes."

    $rooms["whisper_cells"].SearchHintText = "The burned candle niche and the shut cell door make this dead-end feel like it was used for more than storage."
    $rooms["whisper_cells"].SearchPromptText = "Search the cells and candle niche for overlooked evidence or hidden belongings."
    $rooms["whisper_cells"].SearchSuccessText = "Under a loose stone in the candle niche, {hero} finds a narrow iron key wrapped in red cloth and a note recording prisoner names that never reached the watch."
    $rooms["whisper_cells"].SearchFailureText = "{hero} searches the cells, but the walls keep their best secret."
    $rooms["whisper_cells"].SearchDC = 12
    $rooms["whisper_cells"].SearchRewardFlag = "UnderstreetArmoryKey"
    $rooms["whisper_cells"].SearchRewardText = "{hero} recovers a red-wrapped key that should fit the old armory locker."

    $rooms["old_armory"].LockedCacheName = "reinforced armory locker"
    $rooms["old_armory"].LockedCacheHintText = "The reinforced locker is still intact. It could be forced with brute strength, picked carefully, or opened cleanly with the right key."
    $rooms["old_armory"].LockedCacheForceDC = 15
    $rooms["old_armory"].LockedCachePickDC = 13
    $rooms["old_armory"].LockedCacheKeyFlag = "UnderstreetArmoryKey"
    $rooms["old_armory"].LockedCacheOpenText = "The locker finally gives way with a metal crack. Inside are preserved supplies and one piece of gear the smugglers clearly kept for themselves."
    $rooms["old_armory"].LockedCacheFailText = "The locker holds. {hero} will need a better touch, more force, or the proper key."
    $rooms["old_armory"].LockedCacheLoot += (New-ConsumableItem -Name "Greater Healing Potion" -Value 180 -HealAmount 12 -SlotCost 1)
    $rooms["old_armory"].LockedCacheLoot += (New-ArmorItem -Name "Braced Leather Vest" -Value 220 -ArmorBonus 1 -SlotCost 2)

    $rooms["smugglers_lockup"].EncounterRewardText = "The gaoler drops a ring of cell keys and a pouch of emergency silver, but the armory hook beside the red cloth is already empty."
    $rooms["smugglers_lockup"].Loot += (New-CurrencyItem -Denomination "SP" -Amount 10)

    $rooms["record_chamber"].SearchHintText = "The shelves that stand away from the wall look recently disturbed. If anything else was hidden here, it may still be nearby."
    $rooms["record_chamber"].SearchPromptText = "Search the displaced shelves and hidden folios for overlooked evidence."
    $rooms["record_chamber"].SearchSuccessText = "{hero} finds a reserve folio behind the shifted shelf along with a sealed tonic and one more ledger ribbon tying Serik's orders to the city above."
    $rooms["record_chamber"].SearchFailureText = "{hero} checks the shelves, but the best-hidden folio stays buried in dust and panic."
    $rooms["record_chamber"].SearchDC = 13
    $rooms["record_chamber"].HiddenLoot += (New-ConsumableItem -Name "Greater Healing Potion" -Value 180 -HealAmount 12 -SlotCost 1)
    $rooms["record_chamber"].SearchRewardText = "Lore: the reserve folio confirms the understreet was only one branch of a larger smuggling network."

    return $rooms
}

function Get-UnderstreetLookoutEnemy {
    return [PSCustomObject]@{
        name = "understreet lookout"
        article = "An"
        definite = "The Understreet Lookout"
        combatantType = "Opponent"
        hp = 18
        xp = 0
        armorClass = 13
        attackBonus = 4
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 2
        damageMin = 3
        damageMax = 10
        isBoss = $false
    }
}

function Get-UnderstreetRecordKeeperEnemy {
    return [PSCustomObject]@{
        name = "ledger-keeper"
        article = "A"
        definite = "The Ledger-Keeper"
        combatantType = "Opponent"
        hp = 19
        xp = 0
        armorClass = 14
        attackBonus = 5
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 3
        damageMin = 4
        damageMax = 11
        isBoss = $false
    }
}

function Get-UnderstreetSentryEnemy {
    return [PSCustomObject]@{
        name = "understreet sentry"
        article = "An"
        definite = "The Understreet Sentry"
        combatantType = "Opponent"
        hp = 19
        xp = 0
        armorClass = 13
        attackBonus = 4
        initiativeBonus = 3
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 2
        damageMin = 3
        damageMax = 10
        isBoss = $false
    }
}

function Get-UnderstreetHoundEnemy {
    return [PSCustomObject]@{
        name = "tunnel hound"
        article = "A"
        definite = "The Tunnel Hound"
        combatantType = "Opponent"
        hp = 20
        xp = 0
        armorClass = 14
        attackBonus = 5
        initiativeBonus = 3
        damageDiceCount = 1
        damageDiceSides = 8
        damageBonus = 3
        damageMin = 4
        damageMax = 11
        isBoss = $false
    }
}

function Get-UnderstreetArmoryWardenEnemy {
    return [PSCustomObject]@{
        name = "armory warden"
        article = "An"
        definite = "The Armory Warden"
        combatantType = "Opponent"
        hp = 22
        xp = 0
        armorClass = 14
        attackBonus = 5
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 10
        damageBonus = 2
        damageMin = 3
        damageMax = 12
        isBoss = $false
    }
}

function Get-UnderstreetGaolerEnemy {
    return [PSCustomObject]@{
        name = "understreet gaoler"
        article = "An"
        definite = "The Understreet Gaoler"
        combatantType = "Opponent"
        hp = 21
        xp = 0
        armorClass = 14
        attackBonus = 5
        initiativeBonus = 2
        damageDiceCount = 1
        damageDiceSides = 10
        damageBonus = 3
        damageMin = 4
        damageMax = 13
        isBoss = $false
    }
}

function Get-UnderstreetCaptainEnemy {
    return [PSCustomObject]@{
        name = "Captain Serik"
        article = ""
        definite = "Captain Serik"
        combatantType = "Opponent"
        hp = 30
        xp = 0
        armorClass = 15
        attackBonus = 6
        initiativeBonus = 3
        damageDiceCount = 1
        damageDiceSides = 10
        damageBonus = 4
        damageMin = 5
        damageMax = 14
        isBoss = $true
    }
}

function Invoke-StoryCombat {
    param(
        $Game,
        [ref]$HeroHP,
        $Monster,
        [string]$Title,
        [string]$IntroText
    )

    # Test hook so city quest coverage can drive story outcomes without dropping into the full combat input loop.
    if ($null -ne $global:StoryCombatOverride) {
        return (& $global:StoryCombatOverride $Game $HeroHP $Monster $Title $IntroText)
    }

    $monsterHP = $Monster.hp
    $monsterOffBalance = $false
    $heroStarts = $false
    $monsterStarts = $false
    $encounterFled = $false

    Write-SectionTitle -Text $Title -Color "Red"
    Write-Scene (Format-UnderstreetHeroText -Text $IntroText -Hero $Game.Hero)
    Write-Scene "$($Monster.article) $($Monster.name) steps out to stop $($Game.Hero.Name)."
    Write-ColorLine ""

    Start-DetectionPhase `
        -Hero $Game.Hero `
        -Monster $Monster `
        -HeroStarts ([ref]$heroStarts) `
        -MonsterStarts ([ref]$monsterStarts)

    Start-CombatLoop `
        -Hero $Game.Hero `
        -Monster $Monster `
        -HeroHP $HeroHP `
        -MonsterHP ([ref]$monsterHP) `
        -HeroDroppedWeapon ([ref]$Game.HeroDroppedWeapon) `
        -MonsterOffBalance ([ref]$monsterOffBalance) `
        -EncounterFled ([ref]$encounterFled) `
        -HeroStarts $heroStarts

    if ($monsterHP -le 0) {
        Write-Scene "$($Monster.definite) drops and the fight is finished."
        Write-ColorLine ""
    }

    return [PSCustomObject]@{
        Won = ($monsterHP -le 0)
        Defeated = ($HeroHP.Value -le 0)
        Fled = $encounterFled
    }
}

function Get-TownDoctorRecoveryCostCopper {
    return 60
}

function Resolve-TownQuestDefeatRecovery {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -ne $quest) {
        Fail-TownQuest -Game $Game -QuestId $QuestId | Out-Null
    }

    $doctorCost = Get-TownDoctorRecoveryCostCopper
    $activeInn = $Game.Town.ActiveInn
    $canUseInn = $null -ne $activeInn -and [int]$Game.Hero.CurrencyCopper -ge [int]$activeInn.PriceCopper

    Write-SectionTitle -Text "Defeat" -Color "Red"
    Write-Scene "$($Game.Hero.Name) does not die in the street. Someone drags him out of the wreck of the job before the city can swallow him whole."

    if ($null -ne $quest) {
        Write-EmphasisLine -Text "$($quest.Name) is marked as failed." -Color "DarkYellow"
    }

    Write-ColorLine ""

    while ($true) {
        Write-ColorLine "How should $($Game.Hero.Name) recover?" "Cyan"
        Write-ColorLine "1. Town doctor - $(Convert-CopperToCurrencyText -Copper $doctorCost) and stay on the same day" "White"

        if ($null -ne $activeInn) {
            if ($canUseInn) {
                Write-ColorLine "2. Back to $($activeInn.Name) - pay for the night, take a long rest, and wake on the next day" "White"
            }
            else {
                Write-ColorLine "2. Back to $($activeInn.Name) - not enough coin for another night" "DarkGray"
            }
        }

        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $doctorPayment = Spend-HeroCurrency -Hero $Game.Hero -Copper $doctorCost

                if ($doctorPayment.Success) {
                    Clear-HeroBuff -Hero $Game.Hero
                    $HeroHP.Value = $Game.Hero.HP
                    $Game.HeroDroppedWeapon = $false
                    Write-Scene "The town doctor takes the coin, resets broken breath and split skin, and has $($Game.Hero.Name) back on his feet before the day is truly lost."
                    Write-Scene "$($Game.Hero.Name) keeps the same day, but the failed job is gone."
                    Write-ColorLine ""
                    return "Doctor"
                }

                if ($null -eq $activeInn) {
                    Clear-HeroBuff -Hero $Game.Hero
                    $HeroHP.Value = 1
                    $Game.HeroDroppedWeapon = $false
                    Write-Scene "Without the full fee, the doctor only binds the worst of it and turns $($Game.Hero.Name) back into the city with 1 HP and a warning not to waste a second rescue."
                    Write-ColorLine ""
                    return "DoctorStabilized"
                }

                Write-ColorLine "There is not enough coin left for the doctor." "DarkYellow"
                Write-ColorLine ""
            }
            "2" {
                if (-not $canUseInn) {
                    Write-ColorLine "That recovery path is not available right now." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Clear-HeroBuff -Hero $Game.Hero
                $Game.HeroDroppedWeapon = $false
                Resolve-BookedInnNightRest -Game $Game -HeroHP $HeroHP | Out-Null
                Write-Scene "$($Game.Hero.Name) loses the rest of the day, but wakes behind a locked door with the city reset for morning."
                Write-ColorLine ""
                return "Inn"
            }
            default {
                Write-ColorLine "Choose one of the listed recovery options." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Start-NonCombatQuestCheck {
    param(
        $Hero,
        [string]$Ability,
        [int]$DC,
        [string]$ActionText,
        [string]$CheckTag = ""
    )

    $checkProfile = Get-HeroAbilityCheckModifier -Hero $Hero -Ability $Ability -CheckTag $CheckTag
    $roll = Roll-Dice -Sides 20
    $bardicBonus = 0
    $bonusText = ""

    if ($checkProfile.ClassBonus -gt 0) {
        $bonusText = " + $($checkProfile.ClassBonus) proficiency"
    }

    if ($Hero.Class -eq "Bard") {
        $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

        if ($null -ne $bardicStatus -and $bardicStatus.CurrentDice -gt 0) {
            Write-ColorLine "Spend bardic inspiration on this check?" "Cyan"
            Write-ColorLine "1. Yes ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
            Write-ColorLine "2. No" "White"
            Write-ColorLine ""

            while ($true) {
                $inspirationChoice = Read-Host "Choose"

                if ($inspirationChoice -eq "1") {
                    $inspiration = Use-HeroBardicInspirationDie -Hero $Hero -UseInstrumentBonus $false

                    if ($inspiration.Success) {
                        $bardicBonus = $inspiration.TotalBonus
                        $bonusText = "$bonusText + $bardicBonus inspiration"
                    }

                    break
                }

                if ($inspirationChoice -eq "2") {
                    break
                }

                Write-ColorLine "Choose 1 or 2." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }

    $total = $roll + $checkProfile.TotalModifier + $bardicBonus

    Write-Scene $ActionText
    Write-Action "$($Hero.Name) tests ${Ability}: roll $roll $(Format-AbilityModifier -Modifier $checkProfile.AbilityModifier)$bonusText = $total vs DC $DC" "Cyan"
    Write-ColorLine ""

    return ($total -ge $DC)
}

function Complete-StoryQuestAndReport {
    param(
        $Game,
        [string]$QuestId,
        [string]$CompletionText,
        [string]$ProgressText = "",
        [Nullable[int]]$RewardCopperOverride = $null,
        [Nullable[int]]$RewardXPOverride = $null,
        [string]$RewardItemNameOverride = $null,
        [string]$AdvanceOutcome = ""
    )

    $oldTier = Get-CurrentStoryQuestTier -Game $Game
    $completeParams = @{
        Game = $Game
        QuestId = $QuestId
        AdvanceOutcome = $AdvanceOutcome
    }

    if ($null -ne $RewardCopperOverride) {
        $completeParams["RewardCopperOverride"] = $RewardCopperOverride
    }

    if ($null -ne $RewardXPOverride) {
        $completeParams["RewardXPOverride"] = $RewardXPOverride
    }

    if ($null -ne $RewardItemNameOverride) {
        $completeParams["RewardItemNameOverride"] = $RewardItemNameOverride
    }

    $completionResult = Complete-TownQuest @completeParams

    if (-not $completionResult.Success) {
        return
    }

    $newTier = Get-CurrentStoryQuestTier -Game $Game

    Write-Scene $CompletionText

    if ($completionResult.RewardXP -gt 0) {
        Write-Scene "$($Game.Hero.Name) gains $($completionResult.RewardXP) XP."
    }

    if ($completionResult.RewardCopper -gt 0) {
        Write-Scene "$($Game.Hero.Name) receives $(Convert-CopperToCurrencyText -Copper $completionResult.RewardCopper)."
    }

    if ($null -ne $completionResult.RewardItem) {
        Write-Scene "$($Game.Hero.Name) also receives $($completionResult.RewardItem.Name)."
    }

    if (-not [string]::IsNullOrWhiteSpace($ProgressText)) {
        Write-EmphasisLine -Text $ProgressText -Color "Yellow"
    }

    if ($newTier -gt $oldTier) {
        switch ($newTier) {
            2 {
                Write-EmphasisLine -Text "Chapter Two Progress: Tier 1 is complete. Tier 2 story quests are now available." -Color "Yellow"
            }
            3 {
                Write-EmphasisLine -Text "Chapter Two Progress: Tier 2 is complete. Tier 3 story quests are now available." -Color "Yellow"
            }
            4 {
                Write-EmphasisLine -Text "Chapter Two Progress: Tier 3 is complete. Tier 4 story quests are now available." -Color "Yellow"
            }
        }
    }

    if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
        Write-EmphasisLine -Text "$($Game.Hero.Name) feels stronger. A level up awaits after a long rest." -Color "Yellow"
    }

    Write-ColorLine ""
}

function Resolve-UnderstreetRoomEncounter {
    param(
        $Game,
        $Room,
        [ref]$HeroHP,
        [string]$PreviousRoomId,
        [ref]$CurrentRoomId
    )

    if ($Room.EncounterResolved -or [string]::IsNullOrWhiteSpace($Room.EncounterFactory)) {
        return "None"
    }

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (& $Room.EncounterFactory) `
        -Title $Room.EncounterTitle `
        -IntroText $Room.EncounterIntro

    if ($combatResult.Defeated) {
        return "Defeated"
    }

    if ($combatResult.Fled) {
        if (-not [string]::IsNullOrWhiteSpace($PreviousRoomId)) {
            $CurrentRoomId.Value = $PreviousRoomId
        }
        else {
            $CurrentRoomId.Value = "sealed_descent"
        }

        return "Fled"
    }

    if ($combatResult.Won) {
        $Room.EncounterResolved = $true

        if (-not [string]::IsNullOrWhiteSpace($Room.EncounterRewardFlag)) {
            $Game.Town.StoryFlags[$Room.EncounterRewardFlag] = $true
        }

        if (-not [string]::IsNullOrWhiteSpace($Room.EncounterRewardText)) {
            Write-Scene $Room.EncounterRewardText
            Write-ColorLine ""
        }

        return $(if ($Room.BossRoom) { "Victory" } else { "Won" })
    }

    return "None"
}

function Show-UnderstreetRoomActions {
    param(
        $Room,
        $Hero,
        [int]$HeroHP
    )

    $exitIndex = 1
    $exitMap = @{}

    Write-ColorLine "What do you want to do?" "Cyan"

    foreach ($exit in $Room.Exits.GetEnumerator() | Sort-Object Name) {
        $destinationLabel = $exit.Value -replace "_", " "
        Write-ColorLine "$exitIndex. Go $($exit.Name) to $destinationLabel" "White"
        $exitMap["$exitIndex"] = $exit.Value
        $exitIndex++
    }

    if (-not $Room.SearchResolved -and $Room.SearchDC -gt 0) {
        Write-ColorLine "F. Search the room carefully (INT)" "White"
    }

    if (-not $Room.LockedCacheOpened -and $Room.LockedCacheLoot.Count -gt 0) {
        Write-ColorLine "C. Open $($Room.LockedCacheName)" "White"
    }

    if ($Room.CanShortRest -and -not $Room.BossRoom -and ($Room.EncounterResolved -or [string]::IsNullOrWhiteSpace($Room.EncounterFactory)) -and -not $Room.ShortRestTaken) {
        Write-ColorLine "R. Secure this room and take a short rest" "White"
    }

    Write-ColorLine "I. Open inventory" "White"
    Write-ColorLine "L. Check room loot" "White"
    Write-ColorLine "S. View status" "White"
    Write-TextSpeedOption
    Write-ColorLine "Q. Withdraw to town" "White"
    Write-ColorLine ""

    return $exitMap
}

function Show-UnderstreetRoom {
    param(
        $Room,
        $Hero = $null
    )

    Write-SectionTitle -Text $Room.Name -Color "Cyan"
    Write-Scene (Format-UnderstreetHeroText -Text $Room.Description -Hero $Hero)

    if ($Room.Loot.Count -gt 0) {
        Write-Scene "You spot useful gear or hidden spoils left in the chamber."
    }

    if (-not [string]::IsNullOrWhiteSpace($Room.SearchHintText) -and -not $Room.SearchResolved) {
        Write-EmphasisLine -Text (Format-UnderstreetHeroText -Text $Room.SearchHintText -Hero $Hero) -Color "DarkYellow"
    }

    if (-not [string]::IsNullOrWhiteSpace($Room.LockedCacheHintText) -and -not $Room.LockedCacheOpened) {
        Write-EmphasisLine -Text (Format-UnderstreetHeroText -Text $Room.LockedCacheHintText -Hero $Hero) -Color "DarkYellow"
    }

    if (-not $Room.Visited) {
        Write-Scene "The understreet air feels close and dangerous, as if the whole place is listening for one wrong step."
    }

    if ($Room.Secured) {
        Write-Scene "$($Hero.Name) has already secured this space well enough to catch his breath here."
    }

    $restHint = Get-UnderstreetRoomRestHintText -Room $Room -Hero $Hero

    if (-not [string]::IsNullOrWhiteSpace($restHint)) {
        Write-EmphasisLine -Text $restHint -Color "Yellow"
        $Room.RestHintShown = $true
    }

    Write-ColorLine ""
}

function Get-UnderstreetRoomRestHintText {
    param(
        $Room,
        $Hero = $null
    )

    $canSecureForRest = $Room.CanShortRest -and `
        -not $Room.BossRoom -and `
        -not $Room.ShortRestTaken -and `
        ($Room.EncounterResolved -or [string]::IsNullOrWhiteSpace($Room.EncounterFactory))

    if (-not $canSecureForRest) {
        return ""
    }

    if ($Room.RestHintShown) {
        return ""
    }

    $heroName = if ($null -ne $Hero -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Name)) { [string]$Hero.Name } else { "the hero" }
    return "This chamber looks defensible. $heroName can secure it and use R to take a short rest before pushing deeper."
}

function Secure-UnderstreetRoomAndRest {
    param(
        $Game,
        $Room,
        [ref]$HeroHP
    )

    if ($Room.BossRoom -or $Room.ShortRestTaken -or -not $Room.CanShortRest) {
        return
    }

    if (-not ($Room.EncounterResolved -or [string]::IsNullOrWhiteSpace($Room.EncounterFactory))) {
        Write-Scene "$($Game.Hero.Name) cannot secure the room while it is still contested."
        Write-ColorLine ""
        return
    }

    $Room.Secured = $true
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "$($Game.Hero.Name) marks the noisy stones, dead angles, and echoing approaches, then turns $($Room.Name) into a temporary refuge that can warn him before it betrays him."
    }
    else {
        Write-Scene "$($Game.Hero.Name) drags debris into place, checks the angles, and turns $($Room.Name) into a temporary strongpoint."
    }
    $restResult = Resolve-HeroShortRest -Hero $Game.Hero -HeroHP $HeroHP
    $Room.ShortRestTaken = $true

    if ($restResult.Healed -gt 0) {
        Write-Scene "$($Game.Hero.Name) catches his breath, binds his wounds, and recovers $($restResult.Healed) HP."
        Write-Scene "Short rest: d8 roll $($restResult.Roll) $(Format-AbilityModifier -Modifier $restResult.Modifier)."
    }
    else {
        Write-Scene "$($Game.Hero.Name) takes a short rest, but the pause mostly steadies the nerves rather than closing fresh wounds."
    }

    if ($restResult.ClearedBuff) {
        Write-Scene "Any active combat tonic burns out as the short rest settles in."
    }

    if ($restResult.RestoredBardicInspiration -gt 0) {
        Write-Scene "$($Game.Hero.Name) also rebuilds $($restResult.RestoredBardicInspiration) bardic inspiration die through the short rest."
    }

    Write-ColorLine ""
}

function Search-UnderstreetRoom {
    param(
        $Game,
        $Room
    )

    if ($Room.SearchResolved -or $Room.SearchDC -le 0) {
        Write-Scene "There is nothing else here that $($Game.Hero.Name) can meaningfully search for."
        Write-ColorLine ""
        return
    }

    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "INT" -DC $Room.SearchDC -ActionText (Format-UnderstreetHeroText -Text $Room.SearchPromptText -Hero $Game.Hero)
    $Room.SearchResolved = $true

    if ($success) {
        Write-Scene (Format-UnderstreetHeroText -Text $Room.SearchSuccessText -Hero $Game.Hero)

        foreach ($item in $Room.HiddenLoot) {
            $Room.Loot += $item
        }

        if (-not [string]::IsNullOrWhiteSpace($Room.SearchRewardFlag)) {
            $Game.Town.StoryFlags[$Room.SearchRewardFlag] = $true
        }

        if (-not [string]::IsNullOrWhiteSpace($Room.SearchRewardText)) {
            Write-EmphasisLine -Text (Format-UnderstreetHeroText -Text $Room.SearchRewardText -Hero $Game.Hero) -Color "Yellow"
        }
    }
    else {
        Write-Scene (Format-UnderstreetHeroText -Text $Room.SearchFailureText -Hero $Game.Hero)

        if ($Room.Id -eq "whisper_cells" -and -not [string]::IsNullOrWhiteSpace($Room.SearchRewardFlag) -and -not [bool]$Game.Town.StoryFlags[$Room.SearchRewardFlag]) {
            $Game.Town.StoryFlags[$Room.SearchRewardFlag] = $true
            Write-EmphasisLine -Text "Even without turning the cells inside out, $($Game.Hero.Name) still spots the red-wrapped key hidden in the candle niche." -Color "Yellow"
        }
    }

    $Room.HiddenLoot = @()
    Write-ColorLine ""
}

function Resolve-UnderstreetLockedCache {
    param(
        $Game,
        $Room
    )

    if ($Room.LockedCacheOpened -or $Room.LockedCacheLoot.Count -eq 0) {
        Write-Scene "There is no unopened cache here."
        Write-ColorLine ""
        return
    }

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== LOCKED CACHE =====" "Yellow"
        Write-ColorLine "1. Force it open (STR)" "White"
        Write-ColorLine "2. Work the lock carefully (DEX)" "White"

        if (-not [string]::IsNullOrWhiteSpace($Room.LockedCacheKeyFlag) -and [bool]$Game.Town.StoryFlags[$Room.LockedCacheKeyFlag]) {
            Write-ColorLine "3. Use the recovered key" "White"
        }

        Write-ColorLine "0. Back to the room" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return
        }

        $opened = $false

        switch ($choice) {
            "1" {
                $opened = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC $Room.LockedCacheForceDC -ActionText "$($Game.Hero.Name) plants his feet and tries to wrench the lock apart by force."
            }
            "2" {
                $opened = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "DEX" -DC $Room.LockedCachePickDC -ActionText "$($Game.Hero.Name) works the old mechanism by feel, trying to tease the lock open without the proper tools."
            }
            "3" {
                if (-not [string]::IsNullOrWhiteSpace($Room.LockedCacheKeyFlag) -and [bool]$Game.Town.StoryFlags[$Room.LockedCacheKeyFlag]) {
                    Write-Scene "The recovered key turns with a grudging click."
                    Write-ColorLine ""
                    $opened = $true
                }
                else {
                    Write-ColorLine "$($Game.Hero.Name) does not have the right key." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose one of the listed actions." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($opened) {
            $Room.LockedCacheOpened = $true
            Write-Scene (Format-UnderstreetHeroText -Text $Room.LockedCacheOpenText -Hero $Game.Hero)

            foreach ($item in $Room.LockedCacheLoot) {
                $Room.Loot += $item
            }

            $Room.LockedCacheLoot = @()
            Write-ColorLine ""
            return
        }

        Write-Scene (Format-UnderstreetHeroText -Text $Room.LockedCacheFailText -Hero $Game.Hero)
        Write-ColorLine ""
        return
    }
}

function Start-UnderstreetComplexExploration {
    param(
        $Game,
        [ref]$HeroHP
    )

    $rooms = Get-UnderstreetComplexRooms
    $currentRoomId = "sealed_descent"
    $previousRoomId = $null

    while ($HeroHP.Value -gt 0) {
        $room = $rooms[$currentRoomId]
        Show-UnderstreetRoom -Room $room -Hero $Game.Hero

        $encounterResult = Resolve-UnderstreetRoomEncounter `
            -Game $Game `
            -Room $room `
            -HeroHP $HeroHP `
            -PreviousRoomId $previousRoomId `
            -CurrentRoomId ([ref]$currentRoomId)

        if ($encounterResult -eq "Defeated") {
            Write-Scene "$($Game.Hero.Name) is forced out of the understreet before the command vault can be broken."
            Write-ColorLine ""
            return "Defeated"
        }

        if ($encounterResult -eq "Fled") {
            Write-Scene "$($Game.Hero.Name) gives ground and falls back through the complex before the fight can finish him."
            Write-ColorLine ""
            continue
        }

        if ($encounterResult -eq "Victory") {
            return "Victory"
        }

        $room.Visited = $true

        while ($true) {
            $exitMap = Show-UnderstreetRoomActions -Room $room -Hero $Game.Hero -HeroHP $HeroHP.Value
            $choice = (Read-Host "Choose").ToUpper()

            if ($exitMap.ContainsKey($choice)) {
                $previousRoomId = $currentRoomId
                $currentRoomId = $exitMap[$choice]
                break
            }

            switch ($choice) {
                "F" {
                    Search-UnderstreetRoom -Game $Game -Room $room
                }
                "C" {
                    Resolve-UnderstreetLockedCache -Game $Game -Room $room
                }
                "R" {
                    Secure-UnderstreetRoomAndRest -Game $Game -Room $room -HeroHP $HeroHP
                }
                "I" {
                    Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP -Room $room | Out-Null
                }
                "L" {
                    Resolve-RoomLoot -Hero $Game.Hero -Room $room
                }
                "S" {
                    $statusSnapshot = Get-HeroStatusSnapshot -Hero $Game.Hero -HeroHP $HeroHP.Value -Game $Game
                    Write-ColorLine ""
                    Write-ColorLine "Status:" "Cyan"
                    Write-HeroStatusDetails -Hero $Game.Hero -HeroHP $HeroHP.Value -Snapshot $statusSnapshot
                    Write-ColorLine ""
                }
                "T" {
                    Toggle-TextSpeed | Out-Null
                }
                "Q" {
                    Write-Scene "$($Game.Hero.Name) withdraws from the understreet to regroup in the city above."
                    Write-ColorLine ""
                    return "Withdrawn"
                }
                default {
                    Write-ColorLine "Choose one of the listed actions." "DarkYellow"
                    Write-ColorLine ""
                }
            }
        }
    }

    return "Defeated"
}

function Start-NightWatchReliefQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_night_watch"

    if ($null -eq $quest) {
        Write-Scene "The watch cannot seem to find that assignment anymore."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The watch already counts Night Watch Relief as finished."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the assignment before the watch will brief him."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Patrol the outer district with the night watch and investigate the broken tunnel seal."

    Write-SectionTitle -Text "Night Watch Relief" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "Captain Halden meets $($Game.Hero.Name) under a guttering lantern and studies him like a man still deciding how much polish to trust."
        Write-Scene "'Outer district. Broken seal. Strange movement near the old drains,' he says. 'And now merchants are whispering about missing stock on top of it. Walk the line, listen sharp, and come back with something better than rumors. If you can pull truth out of frightened people before steel has to, do it.'"
        Write-Scene "$($Game.Hero.Name) joins Watchwoman Lysa on a short patrol through shuttered alleys and damp stone lanes."
    }
    else {
        Write-Scene "Captain Halden meets {hero} under a guttering lantern and speaks without wasting a word."
        Write-Scene "'Outer district. Broken seal. Strange movement near the old drains,' he says. 'And now merchants are whispering about missing stock on top of it. Walk the line, see what scared my people, and come back with something better than rumors.'"
        Write-Scene "{hero} joins Watchwoman Lysa on a short patrol through shuttered alleys and damp stone lanes."
    }
    Write-ColorLine ""
    Write-Scene "At the edge of the district they find a smashed city seal, muddy footprints, and drag marks leading to a storm grate half-pried from the street."
    Write-Scene "Lysa crouches by the ironwork and swears under her breath. 'Someone's using the tunnels.'"
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-NightWatchReliefEnemy) `
        -Title "Outer District Ambush" `
        -IntroText "A lean runner bursts up from the broken drain with a hooked blade and tries to silence the patrol before anyone can shout."

    if ($combatResult.Defeated) {
        Write-Scene "$($Game.Hero.Name) is forced back and the patrol collapses into chaos."
        Write-ColorLine ""
        Resolve-TownQuestDefeatRecovery -Game $Game -HeroHP $HeroHP -QuestId $quest.Id | Out-Null
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The runner disappears into the drainage dark before {hero} can finish the chase."
        Write-Scene "Lysa spits into the gutter. 'We still know more than we did, but the captain won't call this settled yet.'"
        Write-ColorLine ""
        return
    }

    Write-Scene "The runner goes down hard. On the body {hero} finds a marked token, a scrap of delivery code, and a key stamped with an undercity sigil."
    Write-Scene "Lysa stares at the broken grate, then at the token in {hero}'s hand. 'That is not random theft. That's an operation.'"
    Write-ColorLine ""

    $Game.Town.StoryFlags["FoundTunnelAccess"] = $true
    $Game.Town.Relationships["NightCaptain"] = "Respectful"
    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_night_watch" -CompletionText "'Good,' Halden says when $($Game.Hero.Name) reports back. 'Now we know this city's rot goes below the streets. If the merchants are seeing the same pattern in their missing stock, this just got bigger.'" -ProgressText "Story Progress: $($Game.Hero.Name) has confirmed a real tunnel route beneath the city."
}

function Start-StorehouseTroubleQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "patron_storehouse_rats"

    if ($null -eq $quest) {
        Write-Scene "The storehouse assignment has gone missing from the clerk's stack."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the storehouse job before the clerk hands over the key."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The riverside storehouse is already cleared and paid out."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Clear the riverside storehouse and learn why marked goods are vanishing from inside locked walls."

    Write-SectionTitle -Text "Storehouse Trouble" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "The patron's clerk presses a cold iron key into $($Game.Hero.Name)'s hand and points him toward the river quarter."
        Write-Scene "'The watch keeps asking about tunnels and night movement,' the clerk mutters. 'You hear different things in better rooms than my factors do. I want to know where the goods are going, and who thinks they can hide it behind respectable paper.'"
        Write-Scene "Inside the locked storehouse $($Game.Hero.Name) finds broken crate lids, muddy bootprints, and neat stacks of goods that have already been sorted for resale."
    }
    else {
        Write-Scene "The patron's clerk presses a cold iron key into {hero}'s hand and points him toward the river quarter."
        Write-Scene "'The watch keeps asking about tunnels and night movement,' the clerk mutters. 'I want to know where the goods are going.'"
        Write-Scene "Inside the locked storehouse {hero} finds broken crate lids, muddy bootprints, and neat stacks of goods that have already been sorted for resale."
    }
    Write-Scene "Someone has been using the place as a transfer point, not just a hiding place."
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-StorehouseTroubleEnemy) `
        -Title "Riverside Storehouse" `
        -IntroText "A cutthroat steps out from behind the cargo stacks with a club in one hand and a ledger ribbon tied around the other wrist."

    if ($combatResult.Defeated) {
        Write-Scene "$($Game.Hero.Name) is driven out of the storehouse before he can secure the evidence."
        Write-ColorLine ""
        Resolve-TownQuestDefeatRecovery -Game $Game -HeroHP $HeroHP -QuestId $quest.Id | Out-Null
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The thief escapes through a side hatch, leaving {hero} with a disturbed storehouse and half a clue."
        Write-ColorLine ""
        return
    }

    Write-Scene "Among the broken crates {hero} finds false seals, rerouting marks, and a list of goods that never should have left the lawful inventory."
    Write-Scene "This is not petty theft. It is organized smuggling with handlers on both sides of the lock."
    Write-ColorLine ""

    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
    $Game.Town.Relationships["MerchantPatron"] = "Grateful"
    Complete-StoryQuestAndReport -Game $Game -QuestId "patron_storehouse_rats" -CompletionText "The clerk goes pale when $($Game.Hero.Name) returns the rerouting list. 'So that is where the missing stock went,' he mutters. 'If the watch is right about movement under the streets, then we're looking at the same beast from two sides.'" -ProgressText "Story Progress: $($Game.Hero.Name) has linked the city's thefts to a real smuggling operation."
}

function Start-MissingHerbSatchelQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "quest_board_missing_herbs"

    if ($null -eq $quest) {
        Write-Scene "The herb notice has already been torn down."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the satchel job before setting out."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The herbalist has already been repaid with the return of the satchel."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Recover the satchel from the old road and find out why the scavengers were afraid to keep it."

    Write-SectionTitle -Text "Missing Herb Satchel" -Color "Yellow"
    Write-Scene "The satchel turns up quickly enough on the old road, wedged under a splintered cart wheel beside scattered bundles of dried leaf."
    Write-Scene "A pair of hungry scavengers lurk nearby, more scared than cruel, and one of them keeps glancing at a chalk mark cut into the stones beside the road."
    Write-ColorLine ""
    Write-ColorLine "1. Intimidate the scavengers into handing everything over (STR)" "White"
    Write-ColorLine "2. Calm them down and hear what frightened them (CHA)" "White"
    Write-ColorLine "3. Search the road yourself and ignore them (WIS)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Play a calming refrain and coax the truth out gently (Performance)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Hold the road and wait the fear out until someone finally talks (CON)" "White"
    }
    Write-ColorLine ""

    $strongOutcome = $false

    $strongOutcome = $false

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "{hero} steps in close and lets brute presence do the talking."

                if ($success) {
                    Write-Scene "The scavengers surrender the satchel and blurt out that marked runners have been using the old road at night."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The scavengers bolt, leaving {hero} with the satchel but only half-heard panic about the road. He learns less than he wanted."
                    $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 12 -ActionText "{hero} forces himself to lower his voice and listen before the moment goes bad."

                if ($success) {
                    Write-Scene "The scavengers explain they found the satchel after a courier dropped it while fleeing someone from the city."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "{hero} gets the satchel back, but the scavengers never settle enough to say who they feared."
                    $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "{hero} crouches by the broken road and follows the little signs most people walk past."

                if ($success) {
                    Write-Scene "He spots the courier mark, the satchel, and a fresh heelprint pointing back toward the city."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The search is clumsy, but {hero} still recovers the satchel after turning half the roadside ditch upside down."
                    $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                }

                break
            }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) eases the tension with a low, steady refrain and lets the scavengers talk before fear hardens again." -CheckTag "Performance"

                    if ($success) {
                        Write-Scene "The scavengers calm enough to admit they saw a marked courier drop the satchel while fleeing back toward the city lanes."
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The tune softens the moment, but not enough to get a clean story before the scavengers scatter."
                        $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                    }

                    break
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 10 -ActionText "$($Game.Hero.Name) plants his feet in the road, blocks every way out, and waits until fear and exhaustion finally crack the silence."

                    if ($success) {
                        Write-Scene "Unable to slip past the iron patience in front of them, the scavengers finally admit they saw a marked courier drop the satchel while running for the city."
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                        $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "They break and run in the end, leaving the satchel behind but only fragments about a marked man and a night road."
                        $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
                    }

                    break
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    if (-not $Game.Town.StoryFlags["FoundStreetCourierMark"]) {
        $Game.Town.StoryFlags["HelpedLocalVictim"] = $true
    }

    $progressText = if ($strongOutcome) {
        "Story Progress: $($Game.Hero.Name) has found another sign that the city's trouble moves along hidden courier routes."
    }
    else {
        "Story Progress: $($Game.Hero.Name) helped the victim, but came away with only a weak trail. Stronger Tier 1 results will open the next tier faster."
    }

    $completionText = if ($strongOutcome) {
        "The herbalist clutches the satchel to her chest and thanks {hero} more than once before the relief settles in."
    }
    else {
        "The herbalist gets her satchel back, but {hero} returns with more sympathy than certainty about who dropped it there."
    }

    $rewardXP = if ($strongOutcome) { $null } else { 80 }
    $rewardCopper = if ($strongOutcome) { $null } else { 80 }
    $advanceOutcome = if ($strongOutcome) { "Strong" } else { "Weak" }

    Complete-StoryQuestAndReport -Game $Game -QuestId "quest_board_missing_herbs" -CompletionText $completionText -ProgressText $progressText -RewardCopperOverride $rewardCopper -RewardXPOverride $rewardXP -AdvanceOutcome $advanceOutcome
}

function Start-LedgerOfAshQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "patron_ledger_of_ash"

    if ($null -eq $quest) {
        Write-Scene "The ledger assignment is nowhere to be found."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the ledger job before the clerk will risk explaining it."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The ledger has already been read and the payments traced."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Trace the false payments in the ash-stained ledger and learn who profits when city goods disappear."

    Write-SectionTitle -Text "Ledger of Ash" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "The patron's clerk spreads a smoke-smudged ledger across a narrow desk and shows $($Game.Hero.Name) which entries do not add up."
        Write-Scene "Some payments are too clean. Some names repeat in different hands. Someone is paying to move goods without asking what they are."
        Write-Scene "'The watch sees doors and broken seals,' the clerk says quietly. 'I see the money that keeps those doors useful. You hear how men talk when they think wit is the same thing as safety. Use that.'"
    }
    else {
        Write-Scene "The patron's clerk spreads a smoke-smudged ledger across a narrow desk and shows {hero} which entries do not add up."
        Write-Scene "Some payments are too clean. Some names repeat in different hands. Someone is paying to move goods without asking what they are."
        Write-Scene "'The watch sees doors and broken seals,' the clerk says quietly. 'I see the money that keeps those doors useful.'"
    }
    Write-ColorLine ""
    Write-ColorLine "1. Intimidate the dock clerk named in the ledger (STR)" "White"
    Write-ColorLine "2. Study the ledger line by line (INT)" "White"
    Write-ColorLine "3. Lean on merchant contacts for help reading the pattern (CHA)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Work the room, flatter egos, and tease the hidden name loose (CHA)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Break the dockside bluff until the hidden name finally slips (CON)" "White"
    }
    Write-ColorLine ""

    $strongOutcome = $false

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "{hero} corners the named clerk in a back office and lets silence do most of the work."
                if ($success) {
                    Write-Scene "The clerk folds quickly and gives up a chain of payments tied to an under-street handler called Serik."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The clerk lies badly, but {hero} still gets enough names to prove the books were cooked."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "INT" -DC 12 -ActionText "{hero} grinds through the numbers until the lies in the ink start to stand out."
                if ($success) {
                    Write-Scene "Three fake freight lines all point back to the same middleman. The name Serik surfaces again and again."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The ledger is a mess, but {hero} still proves the irregular payments are real."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "{hero} leans on the best merchant contacts he has and trades plain truth for useful insight."
                if ($success) {
                    Write-Scene "A contact quietly points {hero} to the same under-street name hidden behind the payments: Serik."
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "Even without a clean name, {hero} confirms the payments were not normal trade."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) turns charm, gossip, and merchant vanity into a cleaner reading of who is really profiting."
                    if ($success) {
                        Write-Scene "Three people contradict each other in exactly the right way. By the time the talk settles, the name Serik sits plainly behind the false payments."
                        $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The gossip yields only half-truths, but even half-truths are enough to prove the ledger was built to hide corruption."
                        $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                    }

                    break
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 10 -ActionText "$($Game.Hero.Name) looms over the dockside liar until swagger turns to sweat and the story starts breaking in his mouth."
                    if ($success) {
                        Write-Scene "The bluff collapses in pieces. By the time the clerk stops backpedaling, Serik's name is out in the open and everyone in the room knows it."
                        $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The clerk holds the clean name back, but the panic in his answers still proves the payments were built to hide corruption."
                        $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                    }

                    break
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    $progressText = if ($strongOutcome) {
        "Story Progress: $($Game.Hero.Name) has traced the money behind the city's disappearing goods."
    }
    else {
        "Story Progress: $($Game.Hero.Name) proved the books were cooked, but did not get the clean name behind them. Another strong Tier 2 result may still be needed."
    }

    $completionText = if ($strongOutcome) {
        "The clerk takes the marked names in both hands and looks sick. 'That is enough to sink careers,' he whispers."
    }
    else {
        "The clerk reads the rough notes and pales anyway. It is enough to prove corruption, even if the hand behind it stays blurred."
    }

    $rewardXP = if ($strongOutcome) { $null } else { 110 }
    $rewardCopper = if ($strongOutcome) { $null } else { 100 }
    $advanceOutcome = if ($strongOutcome) { "Strong" } else { "Weak" }

    Complete-StoryQuestAndReport -Game $Game -QuestId "patron_ledger_of_ash" -CompletionText $completionText -ProgressText $progressText -RewardCopperOverride $rewardCopper -RewardXPOverride $rewardXP -AdvanceOutcome $advanceOutcome
}

function Start-BrokenSealPatrolQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_broken_seal"

    if ($null -eq $quest) {
        Write-Scene "The watch has no such patrol on the books."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the broken seal patrol before the watch will move."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The broken seal patrol has already been settled."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Enter the breached maintenance line, clear resistance, and confirm where the hidden route leads."

    Write-SectionTitle -Text "Broken Seal Patrol" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "Captain Halden sends $($Game.Hero.Name) with two watchmen to a maintenance hatch that should have been sealed from the inside years ago."
        Write-Scene "The lock is split, the stones are marked, and the air from below smells like wet mortar and torch smoke."
        Write-Scene "'Your merchant clerk was right about organized movement,' one watchman mutters. 'No one protects a dead tunnel like this unless coin is riding through it.'"
        Write-Scene "The other guard eyes $($Game.Hero.Name) sidelong. 'You were right too. Same names in the nice rooms and the ugly ones. Means this rot has roots.'"
    }
    else {
        Write-Scene "Captain Halden sends {hero} with two watchmen to a maintenance hatch that should have been sealed from the inside years ago."
        Write-Scene "The lock is split, the stones are marked, and the air from below smells like wet mortar and torch smoke."
        Write-Scene "'Your merchant clerk was right about organized movement,' one watchman mutters. 'No one protects a dead tunnel like this unless coin is riding through it.'"
    }
    Write-ColorLine ""

    $combatResult = Invoke-StoryCombat `
        -Game $Game `
        -HeroHP $HeroHP `
        -Monster (Get-BrokenSealPatrolEnemy) `
        -Title "Breached Maintenance Line" `
        -IntroText "A broad-shouldered enforcer rises from the tunnel dark and tries to drive the patrol back before they see how far the route goes."

    if ($combatResult.Defeated) {
        Write-Scene "{hero} is forced up and out before the patrol can secure the line."
        Write-ColorLine ""
        Resolve-TownQuestDefeatRecovery -Game $Game -HeroHP $HeroHP -QuestId $quest.Id | Out-Null
        return
    }

    if ($combatResult.Fled) {
        Write-Scene "The enforcer falls back deeper into the route, buying the smugglers time and leaving the patrol with only half the answer."
        Write-ColorLine ""
        return
    }

    Write-Scene "Past the broken seal, the patrol finds fresh lamps, dry crate grooves, and enough footprints to prove the line is being used regularly."
    Write-Scene "This is no forgotten drain. It is an artery."
    Write-ColorLine ""

    $Game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true
    $Game.Town.StoryFlags["FoundTunnelAccess"] = $true
    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_broken_seal" -CompletionText "Halden listens to the report in silence, then orders the map room opened. 'Good. Now we stop guessing and start hunting. The merchants have their ledger trail, we have the route, and both point underground.'" -ProgressText "Story Progress: $($Game.Hero.Name) has confirmed an active understreet route beneath the city."
}

function Start-NightCourierInterceptQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_night_courier"

    if ($null -eq $quest) {
        Write-Scene "The courier assignment is gone from the watch board."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the courier assignment before the watch shares the route."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The night courier has already been intercepted."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Cut off the courier route through the city lanes and recover whatever message is feeding the understreet network."

    Write-SectionTitle -Text "Night Courier Intercept" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "Belor marks three back lanes on a scrap of guard paper and taps the last one with a callused finger."
        Write-Scene "'Runner moves light, keeps to shadow, and never uses the same lane twice unless he thinks no one is watching,' Belor says. 'The clerk's books say messages are moving with the goods. Your sort notices rhythm better than most. Break his, and the route is ours.'"
    }
    else {
        Write-Scene "Belor marks three back lanes on a scrap of guard paper and taps the last one with a callused finger."
        Write-Scene "'Runner moves light, keeps to shadow, and never uses the same lane twice unless he thinks no one is watching,' Belor says. 'The clerk's books say messages are moving with the goods. Tonight we make that runner prove it.'"
    }
    Write-ColorLine ""
    Write-ColorLine "1. Set a hard ambush and block the lane with brute presence (STR)" "White"
    Write-ColorLine "2. Trail the courier quietly until he reveals the handoff point (WIS)" "White"
    Write-ColorLine "3. Step into the open and force a panicked mistake (CHA)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Draw the courier off-rhythm with a staged street performance (Performance)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Run the courier down and break the route open by sheer pursuit (CON)" "White"
    }
    Write-ColorLine "" 

    $strongOutcome = $false

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "{hero} plants himself in the narrowest part of the lane and turns surprise into a wall of muscle."

                if ($success) {
                    Write-Scene "The courier freezes for half a heartbeat too long. {hero} gets a hand on him, tears the satchel free, and sends him running empty into the dark."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.Relationships["Belor"] = "Trusting"
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The courier slips away clean. {hero} keeps only a wax strip and a guessed lane pattern, enough to prove there is a courier game but not enough to own the route."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "{hero} hangs back and follows the courier by echoes, reflections, and the moments when a runner forgets to be invisible."

                if ($success) {
                    Write-Scene "The trail leads to a hurried exchange beneath a shuttered stair. {hero} does not get the man, but he gets the route and the signal mark."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The courier senses something and breaks early. {hero} learns which mark to watch for, but not the full route."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "{hero} steps out under the lantern light and barks a challenge sharp enough to turn speed into panic."

                if ($success) {
                    Write-Scene "The courier bolts the wrong way, collides with a closed gate, and leaves his message case in {hero}'s hands."
                    $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The courier still escapes, and {hero} gets only a signal token and another glimpse of the same marked network."
                    $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                }

                break
            }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) turns the lane into cover, striking up just enough noise and rhythm to pull the courier into the wrong window." -CheckTag "Performance"

                    if ($success) {
                        Write-Scene "The courier misreads the lane, slows for the wrong doorway, and loses both message case and route advantage in one bad step."
                        $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                        $Game.Town.Relationships["Belor"] = "Trusting"
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The ploy buys a glimpse of the signal marks, but the courier still slips the net before the handoff is exposed."
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    }

                    break
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 10 -ActionText "$($Game.Hero.Name) takes the runner head-on, forcing the whole chase into a test of lungs, legs, and stubbornness."

                    if ($success) {
                        Write-Scene "The courier cannot shake him. By the time the runner stumbles, the message case, route signs, and one bad handoff point all belong to the watch."
                        $Game.Town.StoryFlags["FoundCourierRoute"] = $true
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                        $Game.Town.Relationships["Belor"] = "Trusting"
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The runner slips away at the last turn, but not before dropping a signal strip that proves the marked route is real."
                        $Game.Town.StoryFlags["FoundStreetCourierMark"] = $true
                    }

                    break
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    $progressText = if ($strongOutcome) {
        "Story Progress: $($Game.Hero.Name) has identified a real courier route feeding the understreet network."
    }
    else {
        "Story Progress: $($Game.Hero.Name) confirmed the courier marks, but the full route is still hazy. Another strong Tier 2 result may be needed."
    }

    $completionText = if ($strongOutcome) {
        "Belor studies the recovered markings in silence, then gives {hero} a curt nod. 'Good. Now we've got their streets as well as their tunnels.'"
    }
    else {
        "Belor studies the partial signs and exhales through his nose. 'Not clean enough yet,' he says, 'but it's still more than we had.'"
    }

    $rewardXP = if ($strongOutcome) { $null } else { 110 }
    $rewardCopper = if ($strongOutcome) { $null } else { 100 }
    $advanceOutcome = if ($strongOutcome) { "Strong" } else { "Weak" }

    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_night_courier" -CompletionText $completionText -ProgressText $progressText -RewardCopperOverride $rewardCopper -RewardXPOverride $rewardXP -AdvanceOutcome $advanceOutcome
}

function Start-WarehouseLedgerRecoveryQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "patron_warehouse_ledger"

    if ($null -eq $quest) {
        Write-Scene "The warehouse-ledger job has vanished before {hero} could get his hands on it."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to accept the warehouse-ledger job before the clerk risks the details."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The warehouse ledger has already been secured."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Get into the shuttered warehouse office, secure the hidden ledger, and tie the city's missing goods to a named hand."

    Write-SectionTitle -Text "Warehouse Ledger Recovery" -Color "Yellow"
    if ($Game.Hero.Class -eq "Bard") {
        Write-Scene "The patron's clerk meets $($Game.Hero.Name) in a side passage and keeps his voice low."
        Write-Scene "'There is a second ledger,' he says. 'Not the one they show inspectors. The real one. If it vanishes, so do the names that matter. And if the watch is about to move underground, I want them moving with proof in hand. You can get men talking long past the point they mean to. I need that tonight.'"
    }
    else {
        Write-Scene "The patron's clerk meets {hero} in a side passage and keeps his voice low."
        Write-Scene "'There is a second ledger,' he says. 'Not the one they show inspectors. The real one. If it vanishes, so do the names that matter. And if the watch is about to move underground, I want them moving with proof in hand.'"
    }
    Write-Scene "The warehouse office is dark, shuttered, and recently searched. Someone knew the papers were worth hiding."
    Write-ColorLine ""
    Write-ColorLine "1. Force the office lock and search fast (STR)" "White"
    Write-ColorLine "2. Piece the hiding place together from the disturbed room (WIS)" "White"
    Write-ColorLine "3. Pressure the night clerk into giving up where the ledger was moved (CHA)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Walk the clerk through a polished lie until he corrects it for you (CHA)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Tear the office apart until the real hiding place gives itself away (STR)" "White"
    }
    Write-ColorLine ""

    $strongOutcome = $false

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "{hero} forces the office before anyone can come back for the papers."

                if ($success) {
                    Write-Scene "Behind a false shelf panel {hero} finds the true warehouse ledger, complete with hidden marks and payout names."
                    $Game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The search turns rough. {hero} saves fragments and margin codes, but not the clean ledger itself."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 12 -ActionText "{hero} slows down and reads the office by what has been moved, scrubbed, or disturbed too recently."

                if ($success) {
                    Write-Scene "A dragged stool and fresh dust line lead {hero} straight to the ledger's hiding place. The names inside tie warehouse stock to the same understreet chain."
                    $Game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The room gives up only fragments. {hero} preserves enough to keep the suspicion alive, but not enough to own the case."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "{hero} corners the night clerk with the kind of flat certainty that makes lies feel expensive."

                if ($success) {
                    Write-Scene "The clerk breaks and points {hero} to the hidden compartment. The ledger inside names the warehouse route and the hand above it."
                    $Game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
                    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The clerk lies first and folds late. {hero} comes away with scraps and irregular entries, not the clean ledger he wanted."
                    $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                }

                break
            }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) feeds the clerk a polished false version of the books and waits for vanity and fear to make the man correct it."

                    if ($success) {
                        Write-Scene "The clerk snaps at the lie, then realizes too late that he has pointed straight at the hidden compartment and the real ledger inside."
                        $Game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
                        $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The clerk holds longer than expected. {hero} still comes away with scraps and accounting tells, but not the whole book."
                        $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                    }

                    break
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "$($Game.Hero.Name) turns the office upside down with such force that the room starts confessing before the clerk does."

                    if ($success) {
                        Write-Scene "A false backing cracks under the search. Behind it sits the real ledger, still hidden with the names that tie the warehouse route to Serik's chain."
                        $Game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
                        $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
                        $strongOutcome = $true
                    }
                    else {
                        Write-Scene "The office comes apart noisily, and {hero} saves only fragments, hidden marks, and enough disturbed records to prove the fraud runs deeper."
                        $Game.Town.StoryFlags["FoundEconomicIrregularity"] = $true
                    }

                    break
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    $progressText = if ($strongOutcome) {
        "Story Progress: $($Game.Hero.Name) now holds hard ledger evidence tying the city's missing goods to the understreet operation."
    }
    else {
        "Story Progress: $($Game.Hero.Name) kept the ledger trail alive, but without hard proof. Another Tier 3 quest may still be needed before the finale opens."
    }

    $completionText = if ($strongOutcome) {
        "The clerk reads the recovered pages once, swallows hard, and locks them away. 'That is enough to ruin careful men,' he says."
    }
    else {
        "The clerk studies the fragments in silence. 'Enough to keep digging,' he says at last. 'Not enough to bury them yet.'"
    }

    $rewardXP = if ($strongOutcome) { $null } else { 120 }
    $rewardCopper = if ($strongOutcome) { $null } else { 120 }
    $advanceOutcome = if ($strongOutcome) { "Strong" } else { "Weak" }

    Complete-StoryQuestAndReport -Game $Game -QuestId "patron_warehouse_ledger" -CompletionText $completionText -ProgressText $progressText -RewardCopperOverride $rewardCopper -RewardXPOverride $rewardXP -AdvanceOutcome $advanceOutcome
}

function Start-UnderstreetComplexQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "guard_understreet_complex"

    if ($null -eq $quest) {
        Write-Scene "The watch has not yet put together a final move beneath the city."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "NeedAccepted")
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "The Understreet Complex is already marked as settled."
        Write-ColorLine ""
        return
    }

    if (-not (Is-TownQuestUnlocked -Game $Game -Quest $quest)) {
        Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "NeedEvidence")
        Write-ColorLine ""
        return
    }

    if ($Game.Hero.Level -lt 3) {
        Write-Scene (Get-UnderstreetFinalEntryMessage -Hero $Game.Hero)
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Descend into the understreet complex, break the command vault, and bring the hidden network crashing down."

    Write-SectionTitle -Text "The Understreet Complex" -Color "Yellow"
    Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "BriefingClues")
    Write-Scene "'This is it,' he says. 'No more scattered errands. No more guessing. The watch has the route, the clerk has the paper trail, and the river whispers filled in the rest. We know enough to strike the complex under the ward.'"
    Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "BriefingPrep")
    Write-ColorLine ""
    Write-ColorLine "1. Descend with the watch through the broken maintenance shaft" "White"
    Write-ColorLine "2. Use the broker's lower route and go in fast" "White"
    Write-ColorLine "3. Study the route a moment longer before moving (WIS)" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $approachText = ""

        switch ($choice) {
            "1" {
                $approachText = Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "ApproachWatch"
                $Game.Town.Relationships["NightCaptain"] = "Committed"
                break
            }
            "2" {
                $approachText = Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "ApproachBroker"
                $Game.Town.Relationships["UnderstreetBroker"] = "Proven"
                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 12 -ActionText (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "ApproachStudyAction")

                if ($success) {
                    $approachText = Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "ApproachStudySuccess"
                }
                else {
                    $approachText = Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "ApproachStudyFail"
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        Write-Scene $approachText
        break
    }

    Write-ColorLine ""
    Write-Scene "Below the city, the route opens into a real complex of sealed stairs, contraband chambers, hidden records, and the command vault at its heart."
    Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "MoveRoomByRoom")
    Write-ColorLine ""

    $explorationResult = Start-UnderstreetComplexExploration -Game $Game -HeroHP $HeroHP

    if ($explorationResult -eq "Defeated") {
        Resolve-TownQuestDefeatRecovery -Game $Game -HeroHP $HeroHP -QuestId $quest.Id | Out-Null
        return
    }

    if ($explorationResult -ne "Victory") {
        return
    }

    Write-Scene "Serik falls hard across his own ledger table. The command vault is taken, the route maps are seized, and the old understreet network finally breaks open under guard hands."
    Write-Scene (Get-UnderstreetFinalClassText -Hero $Game.Hero -Key "Victory")
    $Game.Town.StoryFlags["UnderstreetComplexCleared"] = $true
    $Game.Town.StoryFlags["NamedUnderstreetLeader"] = $true
    $Game.Town.ChapterTwoComplete = $true
    $Game.Town.Relationships["NightCaptain"] = "Proven"
    Complete-StoryQuestAndReport -Game $Game -QuestId "guard_understreet_complex" -CompletionText "Captain Halden clasps $($Game.Hero.Name)'s forearm over the captured command ledgers. 'That was the heart of it,' he says. 'The city will breathe easier because you went down there.'" -ProgressText "Chapter Two Complete: $($Game.Hero.Name) has broken the understreet command network beneath the city."
}

function Start-WhispersBeneathBentNailQuest {
    param(
        $Game,
        [ref]$HeroHP
    )

    $quest = Find-TownQuest -Game $Game -QuestId "bent_nail_whispers"

    if ($null -eq $quest) {
        Write-Scene "Whatever whispers lived under the Bent Nail seem to have gone quiet."
        Write-ColorLine ""
        return
    }

    if (-not $quest.Accepted) {
        Write-Scene "{hero} needs to take the broker's lead seriously before the back room opens up."
        Write-ColorLine ""
        return
    }

    if ($quest.Completed) {
        Write-Scene "{hero} has already squeezed what truth he can from the Bent Nail's under-table whispers."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    $quest.Objective = "Lean on the Bent Nail's broker network and learn where the city's quiet cargo routes are feeding into the understreets."

    Write-SectionTitle -Text "Whispers Beneath the Bent Nail" -Color "Yellow"
    Write-Scene "Past the loud tables and dice cups, a scarred broker finally admits {hero} into the Bent Nail's back booths."
    Write-Scene "The man calls himself Brin and talks like every sentence costs him something. 'You didn't hear this from me,' he mutters. 'But plenty of folk are moving cargo that never sees a legal ledger.'"
    Write-Scene "'Funny thing,' Brin adds. 'The watch asks about tunnels, the merchants ask about missing goods, and they're both really asking about the same people.'"
    Write-ColorLine ""
    Write-ColorLine "1. Press Brin hard and demand the route names (STR)" "White"
    Write-ColorLine "2. Buy him a drink and let him talk on his own terms (CHA)" "White"
    Write-ColorLine "3. Leave the booth and shadow the next handoff yourself (WIS)" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "{hero} leans over the table and makes it clear this is the last soft chance Brin gets."

                if ($success) {
                    Write-Scene "Brin folds fast and names a smugglers' route running beneath the river stairs, along with the warning that the work is organized."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $Game.Town.Relationships["UnderstreetBroker"] = "Useful"
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "Brin gives up less than {hero} wants. {hero} leaves knowing the Bent Nail matters, but without the clean confirmation needed to lock the broker into the case."
                    $Game.Town.Relationships["UnderstreetBroker"] = "Wary"
                }

                break
            }
            "2" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "{hero} pays for the next round, lowers his tone, and lets the broker believe the conversation is still his idea."

                if ($success) {
                    Write-Scene "Brin loosens up enough to name the handlers moving cargo off-book and to admit the Bent Nail has been hearing their footsteps for weeks."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $Game.Town.Relationships["UnderstreetBroker"] = "Useful"
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The coin buys patience more than honesty. {hero} gets a smell of the route, but not the broker's clean confession."
                    $Game.Town.Relationships["UnderstreetBroker"] = "Wary"
                }

                break
            }
            "3" {
                $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "{hero} slips away from the booth, keeps to the wall, and watches who Brin speaks to once he thinks the meeting is over."

                if ($success) {
                    Write-Scene "{hero} shadows the handoff long enough to catch marked crates and a runner heading toward a hidden lower passage."
                    $Game.Town.StoryFlags["FoundSmugglingLink"] = $true
                    $Game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true
                    $strongOutcome = $true
                }
                else {
                    Write-Scene "The tail is clumsy. {hero} confirms the room is nervous for a reason, but he loses the handoff before it becomes proof."
                    $Game.Town.Relationships["UnderstreetBroker"] = "Wary"
                }

                break
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        break
    }

    $progressText = if ($strongOutcome) {
        "Story Progress: $($Game.Hero.Name) has turned Bent Nail whispers into usable understreet intelligence."
    }
    else {
        "Story Progress: $($Game.Hero.Name) came away with rumor and tension, not a clean broker confirmation. Another strong Tier 2 result may still be needed."
    }

    $completionText = if ($strongOutcome) {
        "Brin vanishes back into the Bent Nail's smoke before {hero} is even done thinking through the lead."
    }
    else {
        "Brin disappears back into the smoke with most of his certainty intact, leaving {hero} with a rumor worth respecting but not yet proving."
    }

    $rewardXP = if ($strongOutcome) { $null } else { 100 }
    $rewardCopper = if ($strongOutcome) { $null } else { 90 }
    $advanceOutcome = if ($strongOutcome) { "Strong" } else { "Weak" }

    Complete-StoryQuestAndReport -Game $Game -QuestId "bent_nail_whispers" -CompletionText $completionText -ProgressText $progressText -RewardCopperOverride $rewardCopper -RewardXPOverride $rewardXP -AdvanceOutcome $advanceOutcome
}

function Start-MissingDeliveryDayJob {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId = "dayjob_market_delivery"
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That market runner job is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text $quest.Name -Color "Yellow"
    switch ($QuestId) {
        "dayjob_market_delivery_2" {
            Write-Scene "The same runner waves {hero} over with a ledger tucked under one arm. A crate was delivered, paid for, and signed under the wrong stall, which means three merchants are now angry and one is lying."
            Write-Scene "This is still day work, but it pays better because the runner now trusts {hero} with a problem that can cost reputation as well as coin."
        }
        "dayjob_market_delivery_3" {
            Write-Scene "By now the market runners know {hero}'s face. This time the package is sealed, valuable, and expected across the square before a rival buyer realizes it moved."
            Write-Scene "The work is still honest enough, but the coin is better because everyone involved knows a known hand is worth paying for."
        }
        default {
            if ($Game.Hero.Level -ge 3) {
                Write-Scene "A market runner needs one missing crate found before the market eats the loss. With {hero} taking the job, the man sounds more hopeful than frightened."
            }
            else {
                Write-Scene "A market runner explains the problem quickly: one crate of lamp oil and cloth never reached its stall, and if it stays missing too long he eats the loss."
            }
        }
    }
    Write-Scene "{hero} only needs to get the goods moving again and avoid turning day work into a street fight."
    Write-ColorLine "1. Clear the alley by force (STR)" "White"
    Write-ColorLine "2. Haul the crate back yourself (STR)" "White"
    Write-ColorLine "3. Talk the locals into helping (CHA)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Turn the delay into a public bit and shame everyone into helping (Performance)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Shoulder the whole mess yourself and dare anyone to block the lane (CON)" "White"
    }
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "{hero} steps into the alley and makes it clear the crate is moving now." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "{hero} gets both hands under the crate and muscles the job back on schedule." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "{hero} slows the shouting, sorts out the mix-up, and gets people pulling in the same direction." }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) turns the argument into a laughing public spectacle until no one wants to be the fool still blocking the crate." -CheckTag "Performance"
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 10 -ActionText "$($Game.Hero.Name) heaves the crate up, takes the whole lane with him, and makes daring him to stop look like a poor plan."
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            if ($choice -eq "4" -and $Game.Hero.Class -eq "Bard") {
                Write-Scene "By the time the bit is over, three bystanders are already rolling the crate forward and the runner is grinning through his panic."
            }
            elseif ($choice -eq "4" -and $Game.Hero.Class -eq "Barbarian") {
                Write-Scene "By the time the shouting catches up, the crate is already moving and nobody in the lane wants to be the one foolish enough to stand in front of it."
            }
            else {
                Write-Scene "The runner gets the crate back in one piece and pays quickly before anyone changes their mind."
            }
        }
        else {
            Write-Scene "The solution is messy, but the crate still gets home in the end."
        }

        break
    }

    $completionText = switch ($QuestId) {
        "dayjob_market_delivery_2" { "The runner checks the corrected ledger twice, pays {hero}, and looks relieved that the market will be arguing about prices instead of blame by sunset." }
        "dayjob_market_delivery_3" { "The sealed package reaches the right hands. The runner pays without haggling this time, which says more than thanks would." }
        default { "The runner presses the agreed coin into {hero}'s hand and hurries back to the market before the loss becomes permanent." }
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId $QuestId -CompletionText $completionText
}

function Start-GateDutyOverflowDayJob {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId = "dayjob_gate_labor"
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That gate detail is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text $quest.Name -Color "Yellow"
    switch ($QuestId) {
        "dayjob_gate_labor_2" {
            Write-Scene "At the east gate, the problem is paper instead of freight: two merchants both claim the toll was already paid, and the line is turning ugly while clerks compare marks."
            Write-Scene "The sergeant wants {hero} to settle it cleanly before daylight traffic turns one dispute into ten."
        }
        "dayjob_gate_labor_3" {
            Write-Scene "A noble convoy has locked the gate with polished guards, proud horses, and the kind of impatience that makes ordinary drivers furious."
            Write-Scene "The sergeant offers better coin because this is less about muscle now and more about keeping status, traffic, and temper from colliding."
        }
        default {
            if ($Game.Hero.Level -ge 3) {
                Write-Scene "At the east gate, even the loudest drivers quiet a little when they realize the fighter who broke the understreet has been sent to straighten out the line."
            }
            else {
                Write-Scene "At the east gate, freight has jammed the archway and three drivers are one insult away from a riot."
            }
        }
    }
    Write-ColorLine "1. Bark the line straight with sheer force of presence (STR)" "White"
    Write-ColorLine "2. Shoulder the worst wagon clear yourself (CON)" "White"
    Write-ColorLine "3. Calm the loudest driver before it spreads (CHA)" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 11 -ActionText "{hero} steps into the middle of the jam and makes his presence the new center of the argument." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 11 -ActionText "{hero} leans in against wood and iron until the worst wagon finally shudders free." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 12 -ActionText "{hero} tries the harder route and talks the hottest temper back down before the guards have to draw batons." }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            Write-Scene "The gate sergeant nods once when the line begins moving again. That is as close to praise as the man gets."
        }
        else {
            Write-Scene "It takes longer than anyone likes, but the line clears before sunrise and no blood gets spilled."
        }

        break
    }

    $completionText = switch ($QuestId) {
        "dayjob_gate_labor_2" { "The toll dispute ends with the line moving and the sergeant's paperwork still clean. He pays {hero} like a man who hates needing help but respects useful results." }
        "dayjob_gate_labor_3" { "The noble convoy finally clears the gate without a street brawl. The sergeant counts out better coin and admits, very grudgingly, that {hero} saved the watch a long afternoon." }
        default { "The gate sergeant counts out {hero}'s pay and tells him to come back if he wants honest work again." }
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId $QuestId -CompletionText $completionText
}

function Start-DockWorkDayJob {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId = "dayjob_dock_loading"
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That dock job is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text $quest.Name -Color "Yellow"
    switch ($QuestId) {
        "dayjob_dock_loading_2" {
            Write-Scene "The dock boss spots {hero} before the shouting crews do. Two cargo marks point to the same stack, and neither side wants to admit the ledger may be wrong."
            Write-Scene "The pay is better because the job now needs a cool head as much as a strong back."
        }
        "dayjob_dock_loading_3" {
            Write-Scene "Heavy tide lifts the barge against the pilings while expensive cargo waits under tarps. The dock boss has stopped asking for volunteers and started naming people he trusts."
            Write-Scene "This shift pays well because one bad hour can cost the river crews more than a week's wages."
        }
        default {
            Write-Scene "The morning dock is all rope, wet planks, shouting crewmen, and freight that needs to move before the tide turns inconvenient."
            Write-Scene "The work is honest, heavy, and paid in cash at the end of the shift."
        }
    }

    Write-ColorLine "1. Haul the heaviest cargo yourself (STR)" "White"
    Write-ColorLine "2. Work the full shift without slowing (CON)" "White"
    Write-ColorLine "3. Organize the crews before they waste the tide (CHA)" "White"
    if ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Make the whole dock move at your pace (STR)" "White"
    }
    elseif ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Turn the work rhythm into a call-and-response chant (Performance)" "White"
    }
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "$($Game.Hero.Name) gets under the worst of the load and makes the crew believe it can move." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CON" -DC 10 -ActionText "$($Game.Hero.Name) keeps working after the easy breath is gone, one crate and one soaked plank at a time." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "$($Game.Hero.Name) cuts through the shouting and gets the crews pulling in the same order." }
            "4" {
                if ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "STR" -DC 10 -ActionText "$($Game.Hero.Name) takes the front line, sets the pace, and dares the dock to fall behind."
                }
                elseif ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) turns the crew's rhythm into a chant that keeps hands moving and tempers low." -CheckTag "Performance"
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            Write-Scene "By the end of the shift, the cargo is moving, the dock boss is less furious, and the coin is counted without argument."
        }
        else {
            Write-Scene "The shift turns ugly and slow, but enough freight moves that the dock boss still pays the agreed wage."
        }

        break
    }

    $completionText = switch ($QuestId) {
        "dayjob_dock_loading_2" { "The cargo dispute settles before fists come out. The dock boss pays {hero} and marks him down as someone worth calling when freight turns political." }
        "dayjob_dock_loading_3" { "The heavy-tide job clears just before the river makes it impossible. The dock boss pays the higher rate without pretending it was easy." }
        default { "The dock boss counts out {hero}'s pay with wet fingers and points him toward the city before the next crew tries to hire him again." }
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId $QuestId -CompletionText $completionText
}

function Start-ScribeWorkDayJob {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId = "dayjob_scribe_copy"
    )

    $quest = Find-TownQuest -Game $Game -QuestId $QuestId

    if ($null -eq $quest -or -not $quest.Accepted -or $quest.Completed) {
        Write-Scene "That scribe job is not available right now."
        Write-ColorLine ""
        return
    }

    $startResult = Start-TownQuestAttempt -Game $Game -QuestId $quest.Id

    if (-not $startResult.Success) {
        Write-Scene $startResult.Message
        Write-ColorLine ""
        return
    }

    Write-SectionTitle -Text $quest.Name -Color "Yellow"
    switch ($QuestId) {
        "dayjob_scribe_copy_2" {
            Write-Scene "The clerk remembers {hero} and slides over a stack of drafts with ink still drying. The sums do not quite match, and someone important wants the clean version fast."
            Write-Scene "This is better-paid work because a copied error can become a public embarrassment."
        }
        "dayjob_scribe_copy_3" {
            Write-Scene "The office lowers its voice for this one. A sealed abstract needs preparing, and the patron wants accuracy, discretion, and no curious questions."
            Write-Scene "The pay is high for desk work because quiet mistakes at this level become expensive."
        }
        default {
            Write-Scene "The clerk's office smells of ink, dust, and hot wax. A stack of contracts waits beside a clean copybook."
            Write-Scene "It is not glorious work, but the coin is honest and the chair is better than a wet dock plank."
        }
    }

    Write-ColorLine "1. Copy the documents with careful focus (INT)" "White"
    Write-ColorLine "2. Spot the practical mistake before it leaves the desk (WIS)" "White"
    Write-ColorLine "3. Keep the clerk calm and the work moving (CHA)" "White"
    if ($Game.Hero.Class -eq "Bard") {
        Write-ColorLine "4. Make the language cleaner without changing the meaning (Performance)" "White"
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        Write-ColorLine "4. Catch the suspicious clause by treating it like a trap (WIS)" "White"
    }
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"
        $success = $false

        switch ($choice) {
            "1" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "INT" -DC 10 -ActionText "$($Game.Hero.Name) slows down, matches each line, and refuses to let the ink hurry him into mistakes." }
            "2" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 11 -ActionText "$($Game.Hero.Name) reads the work like a problem waiting to reveal itself." }
            "3" { $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 11 -ActionText "$($Game.Hero.Name) steadies the clerk, smooths the pressure, and keeps the desk from turning frantic." }
            "4" {
                if ($Game.Hero.Class -eq "Bard") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "CHA" -DC 10 -ActionText "$($Game.Hero.Name) shapes the wording until the contract sounds cleaner, sharper, and no less binding." -CheckTag "Performance"
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    $success = Start-NonCombatQuestCheck -Hero $Game.Hero -Ability "WIS" -DC 10 -ActionText "$($Game.Hero.Name) distrusts the neatest sentence on the page and finds the clause that was hiding its teeth."
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
                continue
            }
        }

        if ($success) {
            Write-Scene "The clerk checks the finished pages, blinks at the clean work, and pays like someone who just avoided a worse afternoon."
        }
        else {
            Write-Scene "The work takes longer and earns a few corrections, but the copies are usable and the clerk honors the wage."
        }

        break
    }

    $completionText = switch ($QuestId) {
        "dayjob_scribe_copy_2" { "The corrected drafts leave the office under fresh sand and a grateful seal. The clerk pays {hero} with the air of someone who will remember reliable help." }
        "dayjob_scribe_copy_3" { "The sealed abstract is finished cleanly and tucked away before the wrong ears can notice. The clerk pays the higher rate in quiet coin." }
        default { "The clerk counts out {hero}'s copy wage and slides the finished contracts into the outgoing stack." }
    }

    Complete-StoryQuestAndReport -Game $Game -QuestId $QuestId -CompletionText $completionText
}

function Start-TownQuest {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$QuestId
    )

    switch ($QuestId) {
        "guard_night_watch" { Start-NightWatchReliefQuest -Game $Game -HeroHP $HeroHP }
        "guard_night_courier" { Start-NightCourierInterceptQuest -Game $Game -HeroHP $HeroHP }
        "guard_understreet_complex" { Start-UnderstreetComplexQuest -Game $Game -HeroHP $HeroHP }
        "patron_storehouse_rats" { Start-StorehouseTroubleQuest -Game $Game -HeroHP $HeroHP }
        "quest_board_missing_herbs" { Start-MissingHerbSatchelQuest -Game $Game -HeroHP $HeroHP }
        "patron_ledger_of_ash" { Start-LedgerOfAshQuest -Game $Game -HeroHP $HeroHP }
        "patron_warehouse_ledger" { Start-WarehouseLedgerRecoveryQuest -Game $Game -HeroHP $HeroHP }
        "guard_broken_seal" { Start-BrokenSealPatrolQuest -Game $Game -HeroHP $HeroHP }
        "bent_nail_whispers" { Start-WhispersBeneathBentNailQuest -Game $Game -HeroHP $HeroHP }
        "dayjob_market_delivery" { Start-MissingDeliveryDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_market_delivery_2" { Start-MissingDeliveryDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_market_delivery_3" { Start-MissingDeliveryDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_gate_labor" { Start-GateDutyOverflowDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_gate_labor_2" { Start-GateDutyOverflowDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_gate_labor_3" { Start-GateDutyOverflowDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_dock_loading" { Start-DockWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_dock_loading_2" { Start-DockWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_dock_loading_3" { Start-DockWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_scribe_copy" { Start-ScribeWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_scribe_copy_2" { Start-ScribeWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        "dayjob_scribe_copy_3" { Start-ScribeWorkDayJob -Game $Game -HeroHP $HeroHP -QuestId $QuestId }
        default {
            Write-Scene "That quest is not playable yet."
            Write-ColorLine ""
        }
    }
}
