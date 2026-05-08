. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-FighterStartsWithKnightlyKit {
    $hero = Get-Hero -Class "Fighter"

    Assert-Equal -Actual $hero.Name -Expected "Lubert Stryer" -Message "Fighter should use the knight-leaning hero identity."
    Assert-Equal -Actual $hero.Class -Expected "Fighter" -Message "Fighter class should initialize correctly."
    Assert-Equal -Actual $hero.HitDie -Expected 10 -Message "Fighter should use a d10 hit die."
    Assert-Equal -Actual $hero.CON -Expected 15 -Message "Fighter should lean on CON for durability."
    Assert-Equal -Actual (Get-HeroMaxHP -Hero $hero) -Expected 12 -Message "Fighter max HP should include CON modifier."
    Assert-Equal -Actual $hero.FightingStyle -Expected "Defense" -Message "Fighter should start with the Defense fighting style."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 19 -Message "Fighter starter chain mail, shield, and Defense style should stack."
    Assert-Equal -Actual $hero.CurrentSecondWind -Expected 1 -Message "Fighter should start with one Second Wind use."
    Assert-True -Condition (@($hero.Inventory | Where-Object { $_.Name -eq "Shortsword" -and $_.Equipped }).Count -eq 1) -Message "Fighter should start with an equipped shortsword."
    Assert-True -Condition (@($hero.Inventory | Where-Object { $_.Name -eq "Simple Round Shield" -and $_.Equipped }).Count -eq 1) -Message "Fighter should start with an equipped round shield."
    Assert-True -Condition (@($hero.Inventory | Where-Object { $_.Name -eq "Chain Mail" -and $_.Equipped }).Count -eq 1) -Message "Fighter should start with equipped chain mail."
}

function Test-FighterUsesConAsPrimaryProgressionStat {
    $hero = Get-Hero -Class "Fighter"

    Assert-Equal -Actual (Get-HeroPrimaryAbilityForASI -Hero $hero) -Expected "CON" -Message "Fighter should default ASI guidance toward CON."
    Assert-True -Condition ($hero.CheckProficiencies -contains "CON") -Message "Fighter should be proficient with CON checks."
    Assert-True -Condition ($hero.CheckProficiencies -contains "STR") -Message "Fighter should be proficient with STR checks."
}

function Test-ShieldUsesSeparateEquipSlot {
    $hero = Get-Hero -Class "Fighter"
    $newShield = New-ShieldItem -Name "Heater Shield" -Value 240 -ArmorBonus 2 -SlotCost 2
    $hero.Inventory += $newShield

    $result = Set-EquippedItem -Hero $hero -Item $newShield

    Assert-True -Condition $result.Success -Message "Equipping a shield should succeed."
    Assert-Equal -Actual (@($hero.Inventory | Where-Object { $_.Type -eq "Shield" -and $_.Equipped }).Count) -Expected 1 -Message "Only one shield should be equipped."
    Assert-True -Condition (@($hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped }).Count -eq 1) -Message "Equipping a shield should not unequip armor."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 19 -Message "Shield should keep stacking with chain mail and Defense after shield swaps."
}

function Test-FighterDefenseRequiresArmor {
    $hero = Get-Hero -Class "Fighter"
    $armor = $hero.Inventory | Where-Object { $_.Type -eq "Armor" -and $_.Equipped } | Select-Object -First 1
    $armor.Equipped = $false

    Assert-Equal -Actual (Test-HeroFightingStyleDefenseActive -Hero $hero) -Expected $false -Message "Defense should only be active while Fighter wears armor."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 12 -Message "Defense should not add AC without equipped armor."
}

function Test-FighterSecondWindHealsAndRestores {
    $hero = Get-Hero -Class "Fighter"
    $heroHP = 4
    $global:RollDiceOverride = { param([int]$Sides) return 6 }

    $result = Use-HeroSecondWind -Hero $hero -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result.Success -Expected $true -Message "Second Wind should be usable by Fighter."
    Assert-Equal -Actual $result.Healed -Expected 7 -Message "Second Wind should heal 1d10 + Fighter level."
    Assert-Equal -Actual $heroHP -Expected 11 -Message "Second Wind should update hero HP."
    Assert-Equal -Actual $hero.CurrentSecondWind -Expected 0 -Message "Second Wind should spend its use."

    $rest = Restore-HeroSecondWind -Hero $hero
    Assert-Equal -Actual $rest.Success -Expected $true -Message "Second Wind should restore on rest."
    Assert-Equal -Actual $hero.CurrentSecondWind -Expected 1 -Message "Second Wind should restore to max uses."
    $global:RollDiceOverride = $null
}

function Test-FighterShopOffersPointTowardKnightProgression {
    $game = Initialize-Game -Class "Fighter"
    $smithyOffers = @(Get-SmithyOffers -Game $game)
    $armorerOffers = @(Get-ArmorerOffers -Game $game)

    Assert-True -Condition (@($smithyOffers | Where-Object { $_.Id -eq "smithy_knightly_longsword" }).Count -eq 1) -Message "Smithy should offer Fighter a knightly longsword."
    Assert-True -Condition (@($armorerOffers | Where-Object { $_.Id -eq "armorer_squire_mail" }).Count -eq 1) -Message "Armorer should offer Fighter squire mail."
    Assert-True -Condition (@($armorerOffers | Where-Object { $_.Id -eq "armorer_heater_shield" }).Count -eq 1) -Message "Armorer should offer shields."
    Assert-Equal -Actual (New-TownItemFromOfferId -OfferId "armorer_heater_shield").Type -Expected "Shield" -Message "Shield offers should create shield items."

    $game.Hero.Level = 4
    $levelFourArmorerOffers = @(Get-ArmorerOffers -Game $game)
    Assert-True -Condition (@($levelFourArmorerOffers | Where-Object { $_.Id -eq "armorer_splint_armor" }).Count -eq 1) -Message "Level 4 Fighter should see splint armor as a tourney goal."
    Assert-True -Condition (@($levelFourArmorerOffers | Where-Object { $_.Id -eq "armorer_plate_armor" }).Count -eq 1) -Message "Level 4 Fighter should see plate armor as a tourney goal."
    Assert-Equal -Actual (New-TownItemFromOfferId -OfferId "armorer_splint_armor").Name -Expected "Splint Armor" -Message "Splint offer should create splint armor."
    Assert-Equal -Actual (New-TownItemFromOfferId -OfferId "armorer_plate_armor").Name -Expected "Plate Armor" -Message "Plate offer should create plate armor."
}

function Test-FighterJoustingArenaPreviewAndSquireSpar {
    $game = Initialize-Game -Class "Fighter"

    $preview = Get-JoustingArenaPreviewText -Game $game
    $result = Resolve-JoustingArenaSquireSpar -Game $game -Roll 15

    Assert-True -Condition ($preview -like "*Mounted jousting waits*") -Message "Jousting preview should foreshadow horse-gated mounted play."
    Assert-True -Condition $result.Success -Message "A strong squire spar roll should succeed."
    Assert-Equal -Actual $game.Town.Jousting.SquireWins -Expected 1 -Message "Successful sparring should track squire wins."
    Assert-Equal -Actual $game.Town.Jousting.PatronAttention -Expected 2 -Message "Successful sparring should build patron attention."
    Assert-Equal -Actual $game.Town.Relationships["TourneyGround"] -Expected "Noticed" -Message "Successful sparring should mark tourney ground recognition."
}

function Test-FighterTourneyPatronAttentionUnlocks {
    $game = Initialize-Game -Class "Fighter"

    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    $result = Resolve-JoustingArenaSquireSpar -Game $game -Roll 15
    $status = Get-HeroJoustingStatus -Game $game
    $patronText = Get-JoustingPatronAttentionText -Game $game

    Assert-Equal -Actual $result.MilestoneUnlocked -Expected $true -Message "Third clean squire win should cross the first patron milestone."
    Assert-Equal -Actual $game.Town.Jousting.PatronAttention -Expected 6 -Message "Three clean squire wins should reach patron attention threshold."
    Assert-Equal -Actual $game.Town.Relationships["TourneyPatrons"] -Expected "Watching" -Message "Patrons should start watching after enough attention."
    Assert-Equal -Actual $game.Town.StreetFlags["TourneyPatronAttentionUnlocked"] -Expected $true -Message "Patron attention milestone should set a story flag."
    Assert-Equal -Actual $status.Title -Expected "Patron-Noticed Aspirant" -Message "Fighter standing should reflect patron notice."
    Assert-True -Condition ($patronText -like "*writing {hero}'s name*") -Message "Patron text should reflect upper rail attention."
}

function Test-FighterArmoredDuelUsesWeaponAndArmor {
    $game = Initialize-Game -Class "Fighter"

    $result = Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "shield_squire" -HeroRolls @(14, 14) -OpponentRolls @(8, 8)
    $status = Get-HeroJoustingStatus -Game $game

    Assert-Equal -Actual $result.Success -Expected $true -Message "A Fighter should be able to win an armored duel with weapon attacks and armor discipline."
    Assert-Equal -Actual $result.Opponent -Expected "Sirren Vale" -Message "The requested duel opponent should be used."
    Assert-Equal -Actual $result.Technique -Expected "Measured Guard" -Message "Measured Guard should be the default defensive duel technique."
    Assert-Equal -Actual $game.Town.Jousting.DuelWins -Expected 1 -Message "Armored duel wins should track separately from light squire sparring."
    Assert-Equal -Actual $status.DuelWins -Expected 1 -Message "Jousting status should expose armored duel wins."
    Assert-True -Condition ($result.IntroText -like "*Sirren Vale*") -Message "Armored duel results should include a named opponent intro."
    Assert-True -Condition ($result.RivalOutcomeText -like "*Sirren*") -Message "Armored duel results should include named rivalry outcome text."
    Assert-True -Condition ($result.ExchangeLog[0] -like "*Shortsword*" -or $result.Message -like "*Shortsword*") -Message "Duel output should be grounded in the equipped weapon."
}

function Test-FighterArmoredDuelCanLoseOnPoints {
    $game = Initialize-Game -Class "Fighter"

    $result = Resolve-TourneyGroundDuel -Game $game -Technique "Committed" -OpponentId "maul_aspirant" -HeroRolls @(3, 3) -OpponentRolls @(18, 18)

    Assert-Equal -Actual $result.Success -Expected $false -Message "Armored duels should be losable on points."
    Assert-Equal -Actual $game.Town.Jousting.DuelLosses -Expected 1 -Message "Armored duel losses should be tracked."
    Assert-Equal -Actual $result.Technique -Expected "Committed Strike" -Message "Committed Strike should be a supported risky duel technique."
    Assert-Equal -Actual $game.Hero.TourneyDuelRivalries["Maudren Pike"].OpponentWins -Expected 1 -Message "Named duel losses should update that rival's record."
}

function Test-FighterTourneyDuelRivalryChangesRematchText {
    $game = Initialize-Game -Class "Fighter"

    $first = Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "ledger_knight" -HeroRolls @(14, 14) -OpponentRolls @(8, 8)
    $second = Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "ledger_knight" -HeroRolls @(14, 14) -OpponentRolls @(8, 8)
    $record = Get-HeroTourneyDuelRivalryRecord -Hero $game.Hero -OpponentName "Elian Voss"

    Assert-Equal -Actual $first.Success -Expected $true -Message "The first named rival duel should resolve normally."
    Assert-Equal -Actual $record.HeroWins -Expected 2 -Message "Repeated wins should persist against the same named rival."
    Assert-Equal -Actual $record.OpponentWins -Expected 0 -Message "Opponent losses should not increment opponent wins."
    Assert-True -Condition ($second.IntroText -like "*Elian*" -and ($second.IntroText -like "*family shield*" -or $second.IntroText -like "*public loss*" -or $second.IntroText -like "*pattern*")) -Message "A rematch intro should react to the existing named rival record."
    Assert-True -Condition ($second.RivalOutcomeText -like "*record is 2-0*" -or $second.RivalOutcomeText -like "*2-0*") -Message "Named rival outcome text should include the updated duel record."
}

function Test-FighterShieldBashUnlocksAfterArmoredDuelWins {
    $game = Initialize-Game -Class "Fighter"

    $blocked = Resolve-TourneyGroundDuel -Game $game -Technique "ShieldBash" -OpponentId "shield_squire" -HeroRolls @(14, 14) -OpponentRolls @(8, 8)
    Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "shield_squire" -HeroRolls @(14, 14) -OpponentRolls @(8, 8) | Out-Null
    Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "shield_squire" -HeroRolls @(14, 14) -OpponentRolls @(8, 8) | Out-Null
    $unlockingWin = Resolve-TourneyGroundDuel -Game $game -Technique "Measured" -OpponentId "shield_squire" -HeroRolls @(14, 14) -OpponentRolls @(8, 8)
    $bashWin = Resolve-TourneyGroundDuel -Game $game -Technique "ShieldBash" -OpponentId "shield_squire" -HeroRolls @(12, 12) -OpponentRolls @(8, 8)

    Assert-Equal -Actual $blocked.Success -Expected $false -Message "Shield Bash should be locked before enough armored duel wins."
    Assert-Equal -Actual $blocked.Blocked -Expected $true -Message "Locked Shield Bash should return a blocked result."
    Assert-Equal -Actual $unlockingWin.ShieldBashUnlocked -Expected $true -Message "The third armored duel win with a shield should unlock Shield Bash."
    Assert-Equal -Actual $game.Town.StreetFlags["ShieldBashUnlocked"] -Expected $true -Message "Shield Bash unlock should set a persistent story flag."
    Assert-Equal -Actual $bashWin.Success -Expected $true -Message "Unlocked Shield Bash should be usable in later armored duels."
    Assert-Equal -Actual $bashWin.Technique -Expected "Shield Bash" -Message "The result should report the Shield Bash technique."
}

function Test-FighterPatronPresentationRequiresNoticeAndSurcoat {
    $game = Initialize-Game -Class "Fighter"

    $tooEarly = Resolve-JoustingPatronPresentation -Game $game
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    $withoutSurcoat = Resolve-JoustingPatronPresentation -Game $game

    Assert-Equal -Actual $tooEarly.Success -Expected $false -Message "Presentation should wait until the rail has enough patron attention."
    Assert-Equal -Actual $withoutSurcoat.Success -Expected $false -Message "Presentation should require heraldic colors after patron notice."
    Assert-Equal -Actual $withoutSurcoat.MissingSurcoat -Expected $true -Message "A noticed Fighter without a surcoat should get a clear missing-surcoat result."
    Assert-True -Condition ($withoutSurcoat.Message -like "*Heraldic Surcoat*") -Message "The blocked presentation should point to the Heraldic Surcoat."
}

function Test-FighterHeraldicPresentationBuildsPatronBacking {
    $game = Initialize-Game -Class "Fighter"
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    Resolve-JoustingArenaSquireSpar -Game $game -Roll 15 | Out-Null
    $game.Hero.Inventory += (New-TownItemFromOfferId -OfferId "armorer_heraldic_surcoat")

    $result = Resolve-JoustingPatronPresentation -Game $game
    $status = Get-HeroJoustingStatus -Game $game

    Assert-Equal -Actual $result.Success -Expected $true -Message "A noticed Fighter with heraldic colors should be able to present to the rail."
    Assert-Equal -Actual $game.Town.Jousting.PresentationMade -Expected $true -Message "Presentation should persist on the jousting state."
    Assert-Equal -Actual $game.Town.Relationships["TourneyPatrons"] -Expected "Backing" -Message "Presentation should upgrade patron relationship from watching to backing."
    Assert-Equal -Actual $game.Town.StreetFlags["TourneyPresentationAccepted"] -Expected $true -Message "Presentation should set a story flag for later NPC/content hooks."
    Assert-Equal -Actual $status.Title -Expected "Patron-Backed Aspirant" -Message "Presentation should improve Lubert's tourney standing title."
    Assert-Equal -Actual $status.HasHeraldicSurcoat -Expected $true -Message "Jousting status should report whether Lubert has heraldic colors."

    $game.Hero.Level = 4
    $splintOffer = (Get-ArmorerOffers -Game $game) | Where-Object { $_.Id -eq "armorer_splint_armor" } | Select-Object -First 1
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $splintOffer) -Expected 1650 -Message "Patron backing should make future splint armor easier to afford."
}

function Test-FighterTourneyLossStillTracksRecord {
    $game = Initialize-Game -Class "Fighter"

    $result = Resolve-JoustingArenaSquireSpar -Game $game -Roll 5

    Assert-Equal -Actual $result.Success -Expected $false -Message "A poor sparring roll should fail."
    Assert-Equal -Actual $game.Town.Jousting.SquireLosses -Expected 1 -Message "Failed sparring should track squire losses."
    Assert-Equal -Actual $game.Town.Jousting.PatronAttention -Expected 0 -Message "A poor loss should not build patron attention."
}

function Test-FighterQuestAcceptanceUsesKnightlyTone {
    $guardGame = Initialize-Game -Class "Fighter"
    $patronGame = Initialize-Game -Class "Fighter"

    $guardResult = Accept-TownQuest -Game $guardGame -QuestId "guard_night_watch"
    $patronResult = Accept-TownQuest -Game $patronGame -QuestId "patron_storehouse_rats"

    Assert-Equal -Actual $guardResult.Success -Expected $true -Message "Fighter should be able to accept guard station work."
    Assert-True -Condition ($guardResult.Message -like "*shield discipline*" -and $guardResult.Message -like "*reliable arms*") -Message "Guard Station acceptance should recognize Fighter's formal martial identity."
    Assert-Equal -Actual $patronResult.Success -Expected $true -Message "Fighter should be able to accept quest giver work."
    Assert-True -Condition ($patronResult.Message -like "*future knight*" -or $patronResult.Message -like "*reputation*") -Message "Quest Giver acceptance should frame Fighter through knightly reputation."
}

function Test-MountedJoustingRequiresHorseAndTourneyArmor {
    $game = Initialize-Game -Class "Fighter"
    $initialRequirements = Get-MountedJoustingRequirements -Game $game

    Assert-Equal -Actual $initialRequirements.CanEnter -Expected $false -Message "Mounted jousting should start locked."
    Assert-True -Condition ($initialRequirements.Missing -contains "horse") -Message "Mounted jousting should require a horse."
    Assert-True -Condition ($initialRequirements.Missing -contains "splint or plate armor") -Message "Mounted jousting should require splint or plate armor."

    $game.Town.Jousting.HasHorse = $true
    $horseOnlyRequirements = Get-MountedJoustingRequirements -Game $game
    $horseOnlyPreview = Get-JoustingArenaPreviewText -Game $game

    Assert-Equal -Actual $horseOnlyRequirements.CanEnter -Expected $false -Message "A horse alone should not unlock mounted jousting."
    Assert-True -Condition ($horseOnlyPreview -like "*Splint or plate armor is required*") -Message "Preview should explain that horse alone is not enough."

    $plate = New-ArmorItem -Name "Plate Armor" -Value 4500 -ArmorBonus 8 -AddsDexModifier $false -SlotCost 5
    $game.Hero.Inventory += $plate
    Set-EquippedItem -Hero $game.Hero -Item $plate | Out-Null
    $readyRequirements = Get-MountedJoustingRequirements -Game $game

    Assert-Equal -Actual $readyRequirements.CanEnter -Expected $true -Message "Mounted jousting should be ready with horse and plate armor."
    Assert-Equal -Actual (Get-HeroJoustingStatus -Game $game).Title -Expected "Mounted Prospect" -Message "Horse and tourney armor should mark the Fighter as a mounted prospect."
}

function Test-ClassSelectionCanChooseFighter {
    function global:Read-Host { param([string]$Prompt) return "3" }

    $selectedClass = Start-ClassSelection

    Assert-Equal -Actual $selectedClass -Expected "Fighter" -Message "Class selection should allow Fighter."
    Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
}

Test-FighterStartsWithKnightlyKit
Test-FighterUsesConAsPrimaryProgressionStat
Test-ShieldUsesSeparateEquipSlot
Test-FighterDefenseRequiresArmor
Test-FighterSecondWindHealsAndRestores
Test-FighterShopOffersPointTowardKnightProgression
Test-FighterJoustingArenaPreviewAndSquireSpar
Test-FighterTourneyPatronAttentionUnlocks
Test-FighterArmoredDuelUsesWeaponAndArmor
Test-FighterArmoredDuelCanLoseOnPoints
Test-FighterTourneyDuelRivalryChangesRematchText
Test-FighterShieldBashUnlocksAfterArmoredDuelWins
Test-FighterPatronPresentationRequiresNoticeAndSurcoat
Test-FighterHeraldicPresentationBuildsPatronBacking
Test-FighterTourneyLossStillTracksRecord
Test-FighterQuestAcceptanceUsesKnightlyTone
Test-MountedJoustingRequiresHorseAndTourneyArmor
Test-ClassSelectionCanChooseFighter

Write-Host "Fighter tests passed." -ForegroundColor Green
