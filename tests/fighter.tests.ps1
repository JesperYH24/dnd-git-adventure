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

function Test-FighterTourneyLossStillTracksRecord {
    $game = Initialize-Game -Class "Fighter"

    $result = Resolve-JoustingArenaSquireSpar -Game $game -Roll 5

    Assert-Equal -Actual $result.Success -Expected $false -Message "A poor sparring roll should fail."
    Assert-Equal -Actual $game.Town.Jousting.SquireLosses -Expected 1 -Message "Failed sparring should track squire losses."
    Assert-Equal -Actual $game.Town.Jousting.PatronAttention -Expected 0 -Message "A poor loss should not build patron attention."
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
Test-FighterTourneyLossStillTracksRecord
Test-MountedJoustingRequiresHorseAndTourneyArmor
Test-ClassSelectionCanChooseFighter

Write-Host "Fighter tests passed." -ForegroundColor Green
