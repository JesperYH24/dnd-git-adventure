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

    Assert-Equal -Actual $game.Town.InnFlags["BentNailShadyRumor"] -Expected $true -Message "Bent Nail rumor fishing should set an early persistent inn flag."
    Assert-Equal -Actual $game.Town.InnFlags["BentNailBrokerInfo"] -Expected $null -Message "Tier 1 Bent Nail conversations should not unlock the deeper broker lead yet."
    Assert-Equal -Actual $game.Town.Relationships["UnderstreetBroker"] -Expected $relationshipBefore -Message "Repeated Bent Nail rumor fishing should not unlock extra broker progress."
}

function Test-SilverKettleEconomicInfoSetsFutureHook {
    $game = Initialize-Game

    Resolve-SilverKettleEveningChoice -Game $game -Choice "1"

    Assert-Equal -Actual $game.Town.InnFlags["SilverKettleEconomicInsight"] -Expected $true -Message "Silver Kettle economic information should set a persistent inn flag."
    Assert-Equal -Actual $game.Town.QuestPayoutBonusCopper -Expected 20 -Message "Silver Kettle information should prime a future quest payout bonus."
}

function Test-LanternRestMerchantsFavorBardToolsForBards {
    $game = Initialize-Game -Class "Bard"

    Resolve-LanternRestEveningChoice -Game $game -Choice "1"
    $stageLuteOffer = (Get-InstrumentShopOffers -Game $game) | Where-Object { $_.Id -eq "instrument_shop_stage_lute" } | Select-Object -First 1

    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $stageLuteOffer) -Expected 200 -Message "Lantern Rest merchants should steer a bard toward the dedicated instrument shop instead of an axe discount."
    Assert-Equal -Actual $game.Town.Relationships["LanternAudience"] -Expected "Warm" -Message "Lantern Rest should recognize the bard as a good fit for the room."
}

function Test-SilverKettleUpperTablesAdvanceBardSocialStanding {
    $game = Initialize-Game -Class "Bard"

    Resolve-SilverKettleEveningChoice -Game $game -Choice "2"

    Assert-Equal -Actual $game.Town.InnFlags["SilverKettlePatronFavor"] -Expected $true -Message "A bard's Silver Kettle introduction should still grant patron favor."
    Assert-Equal -Actual $game.Town.InnFlags["SilverKettlePrivateInvite"] -Expected $true -Message "A bard's upper-table introduction should be able to unlock a private invitation even before a full performance."
    Assert-Equal -Actual $game.Town.Relationships["MerchantPatron"] -Expected "Favorable" -Message "A bard's Silver Kettle introduction should improve upper-table standing."
}

function Test-BardQuestSourceTextReflectsSocialAllianceRole {
    $game = Initialize-Game -Class "Bard"
    $game.Town.StoryFlags["ConfirmedUndergroundRoute"] = $true
    $game.Town.StoryFlags["SecuredLedgerEvidence"] = $true
    $game.Town.StoryFlags["BentNailBrokerConfirmed"] = $true

    $guardText = Get-ChapterTwoAllianceStatusText -Source "Guard Station" -Game $game
    $clerkText = Get-ChapterTwoAllianceStatusText -Source "Quest Giver" -Game $game
    $repeatClerkText = Get-TownQuestSourceIntroText -Source "Quest Giver" -DefaultIntroText "unused" -Game $game

    Assert-True -Condition ($guardText -like "*Gariand*") -Message "Guard Station alliance text should acknowledge the bard as the one carrying information between rooms."
    Assert-True -Condition ($clerkText -like "*Gariand*") -Message "Quest giver alliance text should acknowledge the bard's connective role in the investigation."
    Assert-True -Condition ($repeatClerkText -like "*polished performer*" -or $repeatClerkText -like "*Gariand*") -Message "Repeat clerk intros should stop reading like they only fit a heavy bruiser."
}

function Test-BardTownShopsUseDifferentIntroTone {
    $game = Initialize-Game -Class "Bard"

    $marketText = Get-TownShopIntroText -Shop "Market" -Hero $game.Hero
    $smithyText = Get-TownShopIntroText -Shop "Smithy" -Hero $game.Hero
    $apothecaryText = Get-TownShopIntroText -Shop "Apothecary" -Hero $game.Hero
    $instrumentText = Get-TownShopIntroText -Shop "Instrument Shop" -Hero $game.Hero
    $armorerText = Get-TownShopIntroText -Shop "Armorer" -Hero $game.Hero

    Assert-True -Condition ($marketText -like "*Gariand*" -or $marketText -like "*strings*") -Message "Market intro should speak to the bard as more than a weapon buyer."
    Assert-True -Condition ($smithyText -like "*light armor*" -or $smithyText -like "*quick-handed performer*") -Message "Smithy intro should recognize the bard's lighter kit needs."
    Assert-True -Condition ($apothecaryText -like "*performer*" -or $apothecaryText -like "*steady nerves*") -Message "Apothecary intro should feel more bard-aware than simple battle-tonic flavor."
    Assert-True -Condition ($instrumentText -like "*Gariand*" -or $instrumentText -like "*measured first by ear*") -Message "Instrument shop intro should treat the bard like a real performer walking into a specialist's room."
    Assert-True -Condition ($armorerText -like "*performer*" -or $armorerText -like "*mobility*") -Message "Armorer intro should still frame armor through the bard's movement and presentation."
}

function Test-BarbarianSpecialtyShopToneFitsBorzig {
    $game = Initialize-Game -Class "Barbarian"

    $instrumentText = Get-TownShopIntroText -Shop "Instrument Shop" -Hero $game.Hero
    $armorerText = Get-TownShopIntroText -Shop "Armorer" -Hero $game.Hero

    Assert-True -Condition ($instrumentText -like "*Borzig*" -or $instrumentText -like "*carry a lute by the neck*") -Message "Instrument shop intro should treat Borzig like an outsider in a room built for performers."
    Assert-True -Condition ($armorerText -like "*Borzig*" -or $armorerText -like "*worth fitting properly*") -Message "Armorer intro should read Borzig as a serious customer for heavier field gear."
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

function Test-StreetNpcIntrosRecognizeBardAsGariand {
    $bard = Get-Hero -Class "Bard"

    $widowIntro = Get-WidowEliraIntro -Hero $bard
    $hadrikIntro = Get-HadrikIntro -Hero $bard
    $belorIntro = Get-BelorIntro -Hero $bard

    Assert-True -Condition ($widowIntro -like "*Gariand*") -Message "Widow Elira should address the bard by his own name."
    Assert-True -Condition ($hadrikIntro -like "*Gariand*" -and $hadrikIntro -like "*forge's usual customer*") -Message "Hadrik should frame the bard as an unusual but valid customer."
    Assert-True -Condition ($belorIntro -like "*Gariand*" -and $belorIntro -like "*truth before steel*") -Message "Belor should recognize the bard as useful before a fight starts."
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

function Test-BarbarianStreetTalkUsesBorzigsPhysicalRole {
    $game = Initialize-Game -Class "Barbarian"

    $hadrik = Get-HadrikCityTalk -Game $game
    $belor = Get-BelorWatchTalk -Game $game

    Assert-True -Condition ($hadrik -like "*Borzig*" -or $hadrik -like "*built like him*") -Message "Hadrik's city talk should frame Borzig as part of the city's practical demand for hard fighters."
    Assert-True -Condition ($belor -like "*broad enough*" -or $belor -like "*refuses to move*" -or $belor -like "*hard people*") -Message "Belor's watch talk should recognize Borzig as the kind of body the line depends on."
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

function Test-HadrikCommentsOnWornStartingAndCaveGear {
    $hero = Get-Hero

    $intro = Get-HadrikIntro -Hero $hero
    $forgeTalk = Get-HadrikForgeTalk -Game (Initialize-Game)

    Assert-True -Condition ($intro -like "*better steel*" -or $intro -like "*rust than craft*") -Message "Hadrik should comment on Borzig's worn starting gear."
    Assert-True -Condition ($forgeTalk -like "*cave*" -or $forgeTalk -like "*dead men's leftovers*") -Message "Hadrik should frame tutorial loot as low-quality salvage."
}

function Test-HadrikRewardsDifferentClassesDifferently {
    $barbarianGame = Initialize-Game
    $bardGame = Initialize-Game -Class "Bard"

    $barbarianResult = Resolve-HadrikChoice -Game $barbarianGame -Choice "1"
    $bardResult = Resolve-HadrikChoice -Game $bardGame -Choice "1"

    $greataxeOffer = (Get-SmithyOffers -Game $barbarianGame) | Where-Object { $_.Id -eq "smithy_greataxe" } | Select-Object -First 1
    $rapierOffer = (Get-SmithyOffers -Game $bardGame) | Where-Object { $_.Id -eq "smithy_rapier" } | Select-Object -First 1
    $stageLuteOffer = (Get-InstrumentShopOffers -Game $bardGame) | Where-Object { $_.Id -eq "instrument_shop_stage_lute" } | Select-Object -First 1

    Assert-True -Condition ([bool]$barbarianGame.Town.StreetFlags["SmithyDiscountUnlocked"]) -Message "Barbarians should still get Hadrik's smithy weapon discount."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $barbarianGame -Offer $greataxeOffer) -Expected 200 -Message "Hadrik's barbarian discount should lower the Steel Great Axe price."
    Assert-True -Condition ($barbarianResult -like "*Steel Great Axe*") -Message "Hadrik should still point martial heroes toward the great axe."

    Assert-True -Condition ([bool]$bardGame.Town.StreetFlags["HadrikRapierDiscountUnlocked"]) -Message "Bards should get Hadrik's rapier recommendation instead of a heavy axe pitch."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $bardGame -Offer $rapierOffer) -Expected 140 -Message "Hadrik's bard recommendation should lower the Rapier price."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $bardGame -Offer $stageLuteOffer) -Expected 220 -Message "Hadrik should not interfere with the Lantern Rest instrument-shop discount path."
    Assert-True -Condition (-not [bool]$bardGame.Town.StreetFlags["SmithyDiscountUnlocked"]) -Message "Bards should not spend their one-time Hadrik reward on an axe discount they are unlikely to use."
    Assert-True -Condition ($bardResult -like "*Rapier*") -Message "Hadrik should name the rapier lead clearly for a bard."
}

function Test-BelorCanHelpBardPerformanceInsteadOfJustPointingToTheWatch {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 4 }

    $withoutPermit = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $withoutPermit -TimeOfDay "Night"
    $beforePermit = Resolve-BardPerformance -Game $withoutPermit -VenueId "market_square"

    $withPermit = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $withPermit -TimeOfDay "Night"
    Resolve-BelorChoice -Game $withPermit -Choice "1" | Out-Null
    $afterPermit = Resolve-BardPerformance -Game $withPermit -VenueId "market_square"

    Assert-Equal -Actual $beforePermit.Outcome -Expected "Poor" -Message "Without Belor's help, a middling square performance should still come up short."
    Assert-Equal -Actual $afterPermit.Outcome -Expected "Good" -Message "Belor's square permit should make the market more workable for a bard."
    Assert-Equal -Actual $withPermit.Town.StreetFlags["BelorSquarePermit"] -Expected $true -Message "Belor should record the bard's market permit."
    Assert-True -Condition ($afterPermit.RewardCopper -gt $beforePermit.RewardCopper) -Message "Belor's permit should improve the bard's practical market payout, not just the flavor text."
}

function Test-BelorCanHelpBarbarianPrepareForGuardWork {
    $game = Initialize-Game -Class "Barbarian"

    $result = Resolve-BelorChoice -Game $game -Choice "1"
    $healingOffer = (Get-ApothecaryOffers -Game $game) | Where-Object { $_.Id -eq "apothecary_healing_potion" } | Select-Object -First 1
    $greaterOffer = (Get-ApothecaryOffers -Game $game) | Where-Object { $_.Id -eq "apothecary_greater_healing_potion" } | Select-Object -First 1

    Assert-Equal -Actual $game.Town.StreetFlags["BelorWatchFavor"] -Expected $true -Message "Belor should be able to give a barbarian a concrete watch favor, not just directions."
    Assert-Equal -Actual $game.Town.Relationships["Belor"] -Expected "Trusting" -Message "Belor should trust a barbarian he is willing to back for ugly work."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $healingOffer) -Expected 45 -Message "Belor's watch favor should make basic healing cheaper for a barbarian."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $greaterOffer) -Expected 160 -Message "Belor's watch favor should also help with stronger healing supplies."
    Assert-True -Condition ($result -like "*healing supplies*") -Message "Belor should explain the barbarian reward as practical preparation, not social polish."
}

function Test-LanternRestMerchantsFavorBarbarianTravelSteel {
    $game = Initialize-Game -Class "Barbarian"

    Resolve-LanternRestEveningChoice -Game $game -Choice "1"
    $handaxeOffer = (Get-MarketOffers -Game $game) | Where-Object { $_.Id -eq "market_handaxe" } | Select-Object -First 1

    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $handaxeOffer) -Expected 120 -Message "Lantern Rest should still steer a barbarian toward practical close-quarters steel."
    Assert-Equal -Actual $game.Town.Relationships["LanternMercenaries"] -Expected "Warm" -Message "Lantern Rest should give a barbarian some standing with the room's mercenary crowd."
}

function Test-SilverKettleContractTalkCanSupportBarbarianRecovery {
    $game = Initialize-Game -Class "Barbarian"

    Resolve-SilverKettleEveningChoice -Game $game -Choice "1"
    $greaterOffer = (Get-ApothecaryOffers -Game $game) | Where-Object { $_.Id -eq "apothecary_greater_healing_potion" } | Select-Object -First 1

    Assert-Equal -Actual $game.Town.InnFlags["SilverKettleEconomicInsight"] -Expected $true -Message "Silver Kettle contract talk should still set the persistent economic insight flag for a barbarian."
    Assert-Equal -Actual $game.Town.QuestPayoutBonusCopper -Expected 20 -Message "Silver Kettle contract talk should keep the future quest payout bonus for a barbarian."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $greaterOffer) -Expected 150 -Message "Silver Kettle patrons should also help a barbarian afford stronger recovery supplies."
}

function Test-BardCanEarnCoinByPerformingInMarketSquare {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $beforeXP = $game.Hero.XP

    $result = Resolve-BardPerformance -Game $game -VenueId "market_square"

    Assert-Equal -Actual $result.Success -Expected $true -Message "A bard should be able to perform for coin in the market square."
    Assert-True -Condition ($result.RewardCopper -gt 0) -Message "A successful square performance should pay coin."
    Assert-Equal -Actual $game.Town.PerformanceCountToday -Expected 1 -Message "A performance should count against the bard's own daily performance limit."
    Assert-Equal -Actual $game.Hero.XP -Expected $beforeXP -Message "Street performances should not grant XP."
}

function Test-BardCannotPerformTwiceAtSameVenueInOneDay {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    Resolve-BardPerformance -Game $game -VenueId "market_square" | Out-Null
    $beforeCopper = $game.Hero.CurrencyCopper
    $secondResult = Resolve-BardPerformance -Game $game -VenueId "market_square"

    Assert-Equal -Actual $secondResult.Success -Expected $false -Message "A bard should not be able to repeat the same venue on the same day."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected $beforeCopper -Message "A blocked repeat venue should not pay extra coin."
}

function Test-BardCanPerformAtDifferentVenuesOnSameDay {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    $first = Resolve-BardPerformance -Game $game -VenueId "market_square"
    $second = Resolve-BardPerformance -Game $game -VenueId "lantern_rest_stage"

    Assert-Equal -Actual $first.Success -Expected $true -Message "The first venue should pay normally."
    Assert-Equal -Actual $second.Success -Expected $true -Message "A bard should be able to take a second performance at a different venue on the same day."
    Assert-Equal -Actual $game.Town.PerformanceCountToday -Expected 2 -Message "Different venues should count toward the separate three-performance cap."
}

function Test-BardHasThreePerformanceSlotsPerDay {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    Resolve-BardPerformance -Game $game -VenueId "market_square" | Out-Null
    Resolve-BardPerformance -Game $game -VenueId "lantern_rest_stage" | Out-Null
    Resolve-BardPerformance -Game $game -VenueId "bent_nail_stage" | Out-Null
    $beforeCopper = $game.Hero.CurrencyCopper
    $fourth = Resolve-BardPerformance -Game $game -VenueId "silver_kettle_stage"

    Assert-Equal -Actual $game.Town.PerformanceCountToday -Expected 3 -Message "The bard should cap at three performances in one day."
    Assert-Equal -Actual $fourth.Success -Expected $false -Message "A fourth paid performance should be blocked until tomorrow."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected $beforeCopper -Message "A blocked fourth performance should not pay extra coin."
}

function Test-SilverKettlePerformanceCanEarnPatronFavor {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 18 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"

    $result = Resolve-BardPerformance -Game $game -VenueId "silver_kettle_stage"

    Assert-Equal -Actual $result.Outcome -Expected "Great" -Message "A strong Silver Kettle performance should count as a great success."
    Assert-Equal -Actual $game.Town.InnFlags["SilverKettlePatronFavor"] -Expected $true -Message "A standout Silver Kettle performance should be able to win patron favor."
    Assert-Equal -Actual $game.Town.InnFlags["SilverKettlePrivateInvite"] -Expected $true -Message "A standout Silver Kettle performance should unlock private patron venue invitations."
    Assert-Equal -Actual $game.Town.Relationships["MerchantPatron"] -Expected "Favorable" -Message "A great salon performance should improve the bard's standing with wealthy patrons."
}

function Test-PrivateSalonPerformanceRequiresInvite {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 12 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $beforeCopper = $game.Hero.CurrencyCopper

    $result = Resolve-BardPerformance -Game $game -VenueId "private_patron_salons"

    Assert-Equal -Actual $result.Success -Expected $false -Message "Private salons should stay locked before the bard earns an invitation."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected $beforeCopper -Message "A locked private salon should not pay out."
}

function Test-PrivateSalonPerformancePaysAfterInvite {
    function global:Read-Host {
        param([string]$Prompt)
        return "2"
    }

    $global:RollDiceOverride = { param([int]$Sides) return 18 }

    $game = Initialize-Game -Class "Bard"
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Town.InnFlags["SilverKettlePrivateInvite"] = $true

    $result = Resolve-BardPerformance -Game $game -VenueId "private_patron_salons"

    Assert-Equal -Actual $result.Success -Expected $true -Message "Private salons should become playable after the bard earns an invitation."
    Assert-True -Condition ($result.RewardCopper -ge 40) -Message "Private salon performances should pay meaningfully better than open street work."
}

Test-StreetChoicesAreRemembered
Test-TownQuestCanBeAcceptedOnce
Test-BentNailShadyInfoIsRemembered
Test-SilverKettleEconomicInfoSetsFutureHook
Test-LanternRestMerchantsFavorBardToolsForBards
Test-SilverKettleUpperTablesAdvanceBardSocialStanding
Test-BardQuestSourceTextReflectsSocialAllianceRole
Test-BardTownShopsUseDifferentIntroTone
Test-BarbarianSpecialtyShopToneFitsBorzig
Test-InnkeeperGreetingChangesWithHeroStyle
Test-StreetNpcIntrosRecognizeBardAsGariand
Test-InnkeeperSmallTalkChangesAfterFirstAsk
Test-StreetNpcFlavorTalkIsRemembered
Test-StreetNpcExtraFlavorTalksExist
Test-RingMasterHasExtendedConversationHooks
Test-LevelThreeNpcToneChangesAfterUnderstreet
Test-HadrikCommentsOnWornStartingAndCaveGear
Test-HadrikRewardsDifferentClassesDifferently
Test-BelorCanHelpBardPerformanceInsteadOfJustPointingToTheWatch
Test-BardCanEarnCoinByPerformingInMarketSquare
Test-BardCannotPerformTwiceAtSameVenueInOneDay
Test-BardCanPerformAtDifferentVenuesOnSameDay
Test-BardHasThreePerformanceSlotsPerDay
Test-SilverKettlePerformanceCanEarnPatronFavor
Test-PrivateSalonPerformanceRequiresInvite
Test-PrivateSalonPerformancePaysAfterInvite

$global:RollDiceOverride = $null

Write-Host "Town social tests passed." -ForegroundColor Green
