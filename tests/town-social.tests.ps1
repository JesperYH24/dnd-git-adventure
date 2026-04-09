. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-StreetChoicesAreRemembered {
    $game = Initialize-Game

    $first = Resolve-HadrikChoice -Game $game -Choice "2"
    $second = Resolve-HadrikChoice -Game $game -Choice "1"

    Assert-True -Condition ($first -like "*Your loss*") -Message "The first declined smith conversation should store the refusal."
    Assert-True -Condition ($second -like "*Already told you*") -Message "The second smith conversation should not grant a late discount."
    Assert-True -Condition (-not [bool]$game.Town.StreetFlags["SmithyDiscountUnlocked"]) -Message "Declining the first time should permanently forfeit the smith discount."
}

function Test-TownQuestCanBeAcceptedOnce {
    $game = Initialize-Game

    $first = Accept-TownQuest -Game $game -QuestId "guard_night_watch"
    $second = Accept-TownQuest -Game $game -QuestId "guard_night_watch"
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"

    Assert-Equal -Actual $first.Success -Expected $true -Message "A new town quest should be accepted the first time."
    Assert-Equal -Actual $second.Success -Expected $false -Message "The same town quest should not be accepted twice."
    Assert-Equal -Actual $quest.Accepted -Expected $true -Message "Accepted quests should stay marked in the quest log."
}

function Test-BentNailShadyInfoIsRemembered {
    $game = Initialize-Game

    Resolve-BentNailEveningChoice -Game $game -Choice "1"
    $relationshipBefore = $game.Town.Relationships["UnderstreetBroker"]
    Resolve-BentNailEveningChoice -Game $game -Choice "1" | Out-Null

    Assert-Equal -Actual $game.Town.InnFlags["BentNailBrokerInfo"] -Expected $true -Message "Bent Nail shady information should set a persistent inn flag."
    Assert-Equal -Actual $game.Town.Relationships["UnderstreetBroker"] -Expected $relationshipBefore -Message "Repeated Bent Nail rumor fishing should not unlock extra broker progress."
}

function Test-SilverKettleEconomicInfoSetsFutureHook {
    $game = Initialize-Game

    Resolve-SilverKettleEveningChoice -Game $game -Choice "1"

    Assert-Equal -Actual $game.Town.InnFlags["SilverKettleEconomicInsight"] -Expected $true -Message "Silver Kettle economic information should set a persistent inn flag."
    Assert-Equal -Actual $game.Town.QuestPayoutBonusCopper -Expected 20 -Message "Silver Kettle information should prime a future quest payout bonus."
}

function Test-InnkeeperGreetingChangesWithHeroStyle {
    $barbarian = Get-Hero
    $bard = Get-Hero
    $bard.Class = "Bard"
    $bard.CHA = 16
    $silverKettle = Get-TownInns | Where-Object { $_.Id -eq "silver_kettle" } | Select-Object -First 1

    $barbarianGreeting = Get-InnKeeperGreeting -Inn $silverKettle -Hero $barbarian
    $bardGreeting = Get-InnKeeperGreeting -Inn $silverKettle -Hero $bard

    Assert-True -Condition ($barbarianGreeting -like "*wolf invited into a ballroom*") -Message "Silver Kettle should greet a barbarian with a rougher tone."
    Assert-True -Condition ($bardGreeting -like "*understands the value of presentation*") -Message "Silver Kettle should greet a bard more warmly."
}

function Test-InnkeeperSmallTalkChangesAfterFirstAsk {
    $game = Initialize-Game
    $game.Town.ActiveInn = Get-TownInns | Where-Object { $_.Id -eq "bent_nail" } | Select-Object -First 1

    $first = Get-InnkeeperHouseTalk -Game $game
    $second = Get-InnkeeperHouseTalk -Game $game

    Assert-True -Condition ($first -like "*roof leaks slower than the patrons bleed*") -Message "Innkeepers should have a fuller first-time house explanation."
    Assert-True -Condition ($second -like "*still standing*") -Message "Innkeepers should have a shorter repeat answer after the first ask."
}

function Test-StreetNpcFlavorTalkIsRemembered {
    $game = Initialize-Game

    $first = Get-BelorWatchTalk -Game $game
    $second = Get-BelorWatchTalk -Game $game

    Assert-True -Condition ($first -like "*walls keep danger out*") -Message "Belor should have a fuller first warning about the watch."
    Assert-True -Condition ($second -like "*Too many small problems*") -Message "Belor should shift to a shorter repeat warning on later talks."
}

function Test-StreetNpcExtraFlavorTalksExist {
    $game = Initialize-Game

    $widow = Get-WidowEliraDistrictTalk -Game $game
    $hadrik = Get-HadrikCityTalk -Game $game
    $belor = Get-BelorDistrictRumorTalk -Game $game

    Assert-True -Condition ($widow -like "*city is upright*" -or $widow -like "*breathing easier*") -Message "Widow Elira should have an extra district-focused conversation path."
    Assert-True -Condition ($hadrik -like "*money comes from*") -Message "Hadrik should have extra city-business flavor dialogue."
    Assert-True -Condition ($belor -like "*river quarter*") -Message "Belor should have an extra district rumor conversation path."
}

function Test-RingMasterHasExtendedConversationHooks {
    $hero = Get-Hero
    $pitTalk = Get-RingMasterPitTalk -Hero $hero
    $opponentTalk = Get-RingMasterOpponentTalk -Hero $hero

    Assert-True -Condition ($pitTalk -like "*pit teaches quick*") -Message "Ringmaster Dorr should be able to talk about the pit itself."
    Assert-True -Condition ($opponentTalk -like "*Some swing wild*") -Message "Ringmaster Dorr should be able to hint at opponent styles."
}

function Test-LevelThreeNpcToneChangesAfterUnderstreet {
    $hero = Get-Hero
    $hero.Level = 3

    $widow = Get-WidowEliraIntro -Hero $hero
    $hadrik = Get-HadrikIntro -Hero $hero
    $belor = Get-BelorIntro -Hero $hero

    Assert-True -Condition ($widow -like "*went under the city*") -Message "Widow Elira should acknowledge Borzig's undercity victory once he reaches level 3."
    Assert-True -Condition ($hadrik -like "*broke the smugglers' den*") -Message "Hadrik should react to Borzig's city-level reputation at level 3."
    Assert-True -Condition ($belor -like "*won't be small*") -Message "Belor should frame later work differently once Borzig has proven himself."
}

Test-StreetChoicesAreRemembered
Test-TownQuestCanBeAcceptedOnce
Test-BentNailShadyInfoIsRemembered
Test-SilverKettleEconomicInfoSetsFutureHook
Test-InnkeeperGreetingChangesWithHeroStyle
Test-InnkeeperSmallTalkChangesAfterFirstAsk
Test-StreetNpcFlavorTalkIsRemembered
Test-StreetNpcExtraFlavorTalksExist
Test-RingMasterHasExtendedConversationHooks
Test-LevelThreeNpcToneChangesAfterUnderstreet

Write-Host "Town social tests passed." -ForegroundColor Green
