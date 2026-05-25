. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-TestRollStub {
    param([scriptblock]$Body)

    $global:RollDiceOverride = $Body
}

function Test-RingTrainingUnlocksUnarmedBonus {
    $game = Initialize-Game
    $before = Get-HeroUnarmedProfile -Hero $game.Hero

    $partial = Grant-RingTraining -Hero $game.Hero -Wins 6
    $training = Grant-RingTraining -Hero $game.Hero -Wins 4
    $after = Get-HeroUnarmedProfile -Hero $game.Hero

    Assert-Equal -Actual $partial.Unlocked -Expected $false -Message "Six ring wins should still be too few to unlock unarmed training."
    Assert-Equal -Actual $training.Unlocked -Expected $true -Message "Ten total ring wins should unlock the first unarmed training tier."
    Assert-Equal -Actual $after.TotalAttackBonus -Expected ($before.TotalAttackBonus + 1) -Message "Unarmed training should raise hit chance by 1."
    Assert-Equal -Actual $after.DamageBonus -Expected ($before.DamageBonus + 1) -Message "Unarmed training should raise bare-hand damage by 1."
}

function Test-RingReputationTracksSeparateProgress {
    $hero = Get-Hero

    $first = Add-HeroRingReputation -Hero $hero -Amount (Get-RingReputationReward -Wins 2)
    $second = Add-HeroRingReputation -Hero $hero -Amount (Get-RingReputationReward -Wins 3)

    Assert-Equal -Actual $first.Added -Expected 5 -Message "Two wins should add the two-win reputation reward."
    Assert-Equal -Actual $second.Total -Expected 14 -Message "Ring reputation should accumulate separately from ring wins."
    Assert-Equal -Actual $hero.RingWinsTotal -Expected 0 -Message "Reputation awards should not change total win count."
    Assert-Equal -Actual (Get-RingReputationTitle -Hero $hero) -Expected "Heard in the Pit" -Message "Reputation should resolve to a public ring title."
}

function Test-UnarmedRingTitleProgression {
    $hero = Get-Hero

    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Unproven Hands" -Message "Fresh heroes should start with an unproven unarmed title."

    $hero.RingWinsTotal = 1
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Proven Hands" -Message "A first win should move the hero out of the unproven title."

    $hero.RingWinsTotal = 5
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Crowd Fighter" -Message "Several ring wins should earn a crowd-facing unarmed title."

    $hero.RingWinsTotal = 10
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Bare-Knuckle Regular" -Message "Champion-ready fighters should have a stronger unarmed title."

    $hero.UnarmedTrainingLevel = 2
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Pit-Fighter" -Message "Second-tier unarmed training should award the Pit-Fighter title."
}

function Test-UnarmedRingTitleUsesChampionAndMonsterHooks {
    $hero = Get-Hero
    $hero.RingWinsTotal = 10

    Complete-RingChampionNight -Hero $hero | Out-Null
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $hero) -Expected "Pit Champion" -Message "Champion Night should override lower unarmed titles."

    $prospect = Get-Hero
    $prospect.Level = 4
    $prospect.RingReputation = 50
    Assert-Equal -Actual (Get-HeroUnarmedRingTitle -Hero $prospect) -Expected "Beast-Hand Prospect" -Message "Level 4 high-reputation fighters should foreshadow monster-challenge titles."
}

function Test-RingFightStyleSummaryRecognizesQuickFinish {
    $summary = Get-RingFightStyleSummary -ActionCounts @{ P = 2; G = 0; B = 0; F = 0 } -Rounds 2 -HeroWon $true

    Assert-Equal -Actual $summary.Key -Expected "QuickFinish" -Message "Fast punch-heavy wins should count as quick finishes."
    Assert-Equal -Actual $summary.ReputationBonus -Expected 2 -Message "Quick finishes should be worth extra crowd reputation."
}

function Test-RingFightStyleSummaryRecognizesTechnicalWin {
    $summary = Get-RingFightStyleSummary -ActionCounts @{ P = 0; G = 0; B = 2; F = 2 } -Rounds 4 -HeroWon $true

    Assert-Equal -Actual $summary.Key -Expected "Technical" -Message "Block and focus-heavy wins should count as technical crowd taste."
}

function Test-HeroRingStyleResultTracksCrowdTaste {
    $hero = Get-Hero
    $summary = Get-RingFightStyleSummary -ActionCounts @{ P = 0; G = 3; B = 0; F = 0 } -Rounds 3 -HeroWon $true
    $result = Add-HeroRingStyleResult -Hero $hero -StyleSummary $summary

    Assert-Equal -Actual $result.Style -Expected "Grappler" -Message "Grapple-heavy wins should be recorded as grappler style."
    Assert-Equal -Actual $hero.RingStyleCounts["Grappler"] -Expected 1 -Message "Hero ring style counts should persist the crowd taste."
    Assert-Equal -Actual (Get-HeroDominantRingStyle -Hero $hero) -Expected "Grappler" -Message "Dominant style should read back from style counts."
    Assert-Equal -Actual $hero.RingReputation -Expected 1 -Message "Style result should add its small crowd reputation bonus."
}

function Test-RingMasterRespectsPhysicalProwess {
    $barbarian = Get-Hero
    $rogueLikeHero = Get-Hero
    $rogueLikeHero.Class = "Rogue"
    $rogueLikeHero.STR = 10
    $rogueLikeHero.DEX = 16
    $rogueLikeHero.CON = 12

    $barbarianGreeting = Get-RingMasterGreeting -Hero $barbarian
    $rogueGreeting = Get-RingMasterGreeting -Hero $rogueLikeHero

    Assert-True -Condition ($barbarianGreeting -like "*Real shoulders, real lungs, real scars*") -Message "The ring master should admire strong and hardy heroes."
    Assert-True -Condition ($rogueGreeting -like "*Fast feet survive longer*") -Message "The ring master should notice quick fighters differently."
}

function Test-RingChampionUnlocksHarderCircuit {
    $hero = Get-Hero
    $hero.RingWinsTotal = 10

    $greeting = Get-RingMasterGreeting -Hero $hero
    $opponents = Get-RingOpponents -Hero $hero

    Assert-True -Condition ($greeting -like "*Champion's back*") -Message "The ring master should acknowledge a ten-win champion."
    Assert-Equal -Actual $opponents.Count -Expected 4 -Message "Champion status should unlock a longer ring circuit."
}

function Test-RingChampionNightReadinessUsesTenWins {
    $hero = Get-Hero
    $hero.RingWinsTotal = 9

    Assert-Equal -Actual (Test-HeroReadyForRingChampionNight -Hero $hero) -Expected $false -Message "Champion Night should stay locked before ten ring wins."

    $hero.RingWinsTotal = 10
    Assert-Equal -Actual (Test-HeroReadyForRingChampionNight -Hero $hero) -Expected $true -Message "Champion Night should unlock at ten ring wins."

    Complete-RingChampionNight -Hero $hero | Out-Null
    Assert-Equal -Actual (Test-HeroReadyForRingChampionNight -Hero $hero) -Expected $false -Message "Champion Night should not stay ready after the title has been won."
    Assert-Equal -Actual $hero.RingChampionNightWon -Expected $true -Message "Champion Night completion should set the persistent title flag."
}

function Test-RingVeteranCircuitUnlocksAfterFifteenWins {
    $hero = Get-Hero
    $hero.RingWinsTotal = 15

    $pitTalk = Get-RingMasterPitTalk -Hero $hero
    $opponents = Get-RingOpponents -Hero $hero

    Assert-True -Condition ($pitTalk -like "*fifteen wins*") -Message "The ring master should acknowledge the deeper post-champion tier."
    Assert-Equal -Actual $opponents.Count -Expected 5 -Message "Fifteen total ring wins should unlock the extended veteran circuit."
}

function Test-RingMonsterChallengesUnlockAtLevelFour {
    $hero = Get-Hero
    $hero.Level = 3

    $lockedTalk = Get-RingMonsterChallengeTalk -Hero $hero
    $locked = Test-HeroReadyForRingMonsterChallenges -Hero $hero

    $hero.Level = 4
    $unlockedTalk = Get-RingMonsterChallengeTalk -Hero $hero
    $unlocked = Test-HeroReadyForRingMonsterChallenges -Hero $hero

    Assert-Equal -Actual $locked -Expected $false -Message "Monster challenges should stay locked before level 4."
    Assert-True -Condition ($lockedTalk -like "*level four*") -Message "Locked monster challenge talk should explain the level 4 gate."
    Assert-Equal -Actual $unlocked -Expected $true -Message "Monster challenges should unlock as a ring conversation at level 4."
    Assert-True -Condition ($unlockedTalk -like "*outer contracts*") -Message "Unlocked monster challenge talk should point toward future outer contracts."
}

function Test-RingMonsterChallengePreviewRequiresLevelFour {
    $hero = Get-Hero
    $hero.Level = 3

    $lockedPreview = @(Get-RingMonsterChallengePreview -Hero $hero)

    $hero.Level = 4
    $unlockedPreview = @(Get-RingMonsterChallengePreview -Hero $hero)

    Assert-Equal -Actual $lockedPreview.Count -Expected 0 -Message "Monster challenge preview should stay hidden before level 4."
    Assert-Equal -Actual $unlockedPreview.Count -Expected 5 -Message "Level 4 should reveal the preview monster contract ladder."
    Assert-Equal -Actual $unlockedPreview[0].Name -Expected "Wall-Scraper Trial" -Message "The first preview contract should be the proof bout."
}

function Test-RingMonsterChallengePreviewReflectsReputationAndChampionTitle {
    $hero = Get-Hero
    $hero.Level = 4

    $baselinePreview = @(Get-RingMonsterChallengePreview -Hero $hero)

    $hero.RingReputation = 25
    $hero.RingWinsTotal = 10
    Complete-RingChampionNight -Hero $hero | Out-Null
    $advancedPreview = @(Get-RingMonsterChallengePreview -Hero $hero)

    Assert-Equal -Actual $baselinePreview[1].Readiness -Expected "Needs stronger ring reputation" -Message "The grapple contract should ask for stronger reputation at first."
    Assert-Equal -Actual $advancedPreview[1].Readiness -Expected "Ready when monster zone opens" -Message "Stronger ring reputation should mark the grapple contract ready for the future zone."
    Assert-Equal -Actual $advancedPreview[2].Readiness -Expected "Champion preview" -Message "Champion Night should improve the named monster preview readiness."
    Assert-True -Condition ($advancedPreview[2].RewardPreview -like "*Pit Champion*") -Message "Named monster rewards should reference the hero's current unarmed title."
}

function Test-RingMonsterContractsStayBarbarianOnly {
    $bard = Initialize-Game -Class "Bard"
    $fighter = Initialize-Game -Class "Fighter"
    $barbarian = Initialize-Game -Class "Barbarian"

    $bard.Hero.Level = 4
    $fighter.Hero.Level = 4
    $barbarian.Hero.Level = 4

    Assert-Equal -Actual (Test-HeroReadyForRingMonsterChallenges -Hero $bard.Hero) -Expected $false -Message "Bard should be able to use the base ring but not Dorr's monster contracts."
    Assert-Equal -Actual (Test-HeroReadyForRingMonsterChallenges -Hero $fighter.Hero) -Expected $false -Message "Fighter should be able to use the base ring but not Dorr's monster contracts."
    Assert-Equal -Actual (Test-HeroReadyForRingMonsterChallenges -Hero $barbarian.Hero) -Expected $true -Message "Barbarian should keep the monster-contract ring path at level 4."
    Assert-Equal -Actual @(Get-RingMonsterChallengePreview -Hero $bard.Hero).Count -Expected 0 -Message "Bard should not see the monster contract ladder."
    Assert-Equal -Actual @(Get-RingMonsterChallengePreview -Hero $fighter.Hero).Count -Expected 0 -Message "Fighter should not see the monster contract ladder."
}

function Test-FighterCanDiscussMonsterProofWithDorrWithoutContracts {
    $fighter = Initialize-Game -Class "Fighter"
    $barbarian = Initialize-Game -Class "Barbarian"

    $fighter.Hero.Level = 4
    $barbarian.Hero.Level = 4

    $fighterTalk = Get-RingMonsterChallengeTalk -Hero $fighter.Hero -Game $fighter

    Assert-Equal -Actual (Test-HeroCanDiscussMonsterZoneWithDorr -Game $fighter) -Expected $true -Message "Level 4 Fighter should be able to ask Dorr about wall proof."
    Assert-Equal -Actual (Test-HeroCanDiscussMonsterZoneWithDorr -Game $barbarian) -Expected $true -Message "Level 4 Barbarian should still be able to access Dorr's contract talk."
    Assert-Equal -Actual (Test-HeroReadyForRingMonsterChallenges -Hero $fighter.Hero) -Expected $false -Message "Fighter discussion should not unlock monster contracts."
    Assert-True -Condition ($fighterTalk -like "*patrol sense*" -and $fighterTalk -like "*tourney talk*") -Message "Fighter Dorr talk should frame wall proof through patrol and tourney value."
}

function Test-FighterCanReportMonsterProofToDorr {
    $game = Initialize-Game -Class "Fighter"
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null

    $canDiscuss = Test-HeroCanDiscussMonsterZoneWithDorr -Game $game
    Start-RingMonsterChallengeMenu -Game $game
    $contracts = @(Get-AvailableRingMonsterChallengeContracts -Game $game)

    Assert-Equal -Actual $canDiscuss -Expected $true -Message "Unreported proof should make Dorr's monster-zone conversation available to Fighter."
    Assert-Equal -Actual @($game.Town.MonsterZone.ReportedCreaturesToDorr.Keys).Count -Expected 1 -Message "Fighter should be able to report defeated monster proof to Dorr."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 57 -Message "Fighter Dorr reports should still pay the wall-bounty purse."
    Assert-Equal -Actual $contracts.Count -Expected 0 -Message "Reporting as Fighter should not create bookable monster contracts."
}

function Test-RingMonsterContractsRequireReportedZoneDefeat {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    $availableBeforeReport = @(Get-AvailableRingMonsterChallengeContracts -Game $game)
    $report = Report-MonsterZoneDiscoveriesToDorr -Game $game
    $availableAfterReport = @(Get-AvailableRingMonsterChallengeContracts -Game $game)

    Assert-Equal -Actual $availableBeforeReport.Count -Expected 0 -Message "Beating a monster should not unlock Dorr contracts until the hero reports it."
    Assert-Equal -Actual @($report.NewlyReported).Count -Expected 1 -Message "Reporting to Dorr should record the newly defeated creature."
    Assert-Equal -Actual $availableAfterReport[0].Id -Expected "wall_scraper_trial" -Message "A reported wall scout should unlock the Wall-Scraper Trial."
}

function Test-RingMonsterReportsPayBountyAndSupplyFavor {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1
    $marketPotion = Get-MarketOffers -Game $game | Where-Object { $_.Id -eq "market_healing_potion" } | Select-Object -First 1
    $packGoat = Get-StableOffers -Game $game | Where-Object { $_.Id -eq "stable_pack_goat" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    $report = Report-MonsterZoneDiscoveriesToDorr -Game $game
    $repeat = Report-MonsterZoneDiscoveriesToDorr -Game $game

    Assert-Equal -Actual $report.TotalBountyCopper -Expected 57 -Message "A reported kobold wall scout trail should pay a small wall-bounty purse."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 57 -Message "Reporting monster proof should add bounty coin to the hero."
    Assert-Equal -Actual $report.NewlyReported[0]["BountyCopper"] -Expected 57 -Message "The reported trail should remember its bounty payout."
    Assert-Equal -Actual $report.SupplyFavorUnlocked -Expected $true -Message "The first monster-zone report should unlock a town supply favor."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $marketPotion) -Expected 50 -Message "Supply favor should discount basic market healing."
    Assert-Equal -Actual (Get-TownOfferPrice -Game $game -Offer $packGoat) -Expected 220 -Message "Supply favor should discount the starter pack animal for oddity hauling."
    Assert-Equal -Actual $repeat.TotalBountyCopper -Expected 0 -Message "Already reported trails should not pay bounty twice."
    Assert-Equal -Actual $repeat.SupplyFavorUnlocked -Expected $false -Message "Supply favor should only unlock once."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 57 -Message "Repeat reports should not add more bounty coin."
}

function Test-RingMonsterContractsKeepExtraGates {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "razor_boar" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null

    $contract = Get-RingMonsterChallengeContracts | Where-Object { $_.Id -eq "mire_tusk_clinch" } | Select-Object -First 1
    $blocked = Get-RingMonsterContractReadiness -Game $game -Contract $contract

    $game.Hero.RingReputation = 25
    $ready = Get-RingMonsterContractReadiness -Game $game -Contract $contract

    Assert-Equal -Actual $blocked.CanTake -Expected $false -Message "Mire-Tusk should still require reputation after the matching creature is reported."
    Assert-True -Condition ($blocked.Readiness -like "*ring reputation 25*") -Message "Blocked readiness should name the reputation gate."
    Assert-Equal -Actual $ready.CanTake -Expected $true -Message "Mire-Tusk should unlock once the monster report and reputation gate are both satisfied."
}

function Test-RingMonsterContractsIncludeHigherZoneThreats {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $ash = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "ash_horn_drakelet" } | Select-Object -First 1
    $gate = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "gate_sunder_brute" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $ash | Out-Null
    Add-MonsterZoneCreatureDefeat -Game $game -Creature $gate | Out-Null
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null

    $ashContract = Get-RingMonsterChallengeContracts | Where-Object { $_.Id -eq "ash_horn_lockdown" } | Select-Object -First 1
    $gateContract = Get-RingMonsterChallengeContracts | Where-Object { $_.Id -eq "gate_sunder_night" } | Select-Object -First 1
    $blockedAsh = Get-RingMonsterContractReadiness -Game $game -Contract $ashContract

    $game.Hero.RingReputation = 55
    $game.Hero.RingWinsTotal = 10
    Complete-RingChampionNight -Hero $game.Hero | Out-Null
    $readyAsh = Get-RingMonsterContractReadiness -Game $game -Contract $ashContract
    $readyGate = Get-RingMonsterContractReadiness -Game $game -Contract $gateContract

    Assert-True -Condition ($blockedAsh.Readiness -like "*ring reputation 35*" -and $blockedAsh.Readiness -like "*Pit Champion*") -Message "Ash-Horn should require both reputation and champion status after the trail is reported."
    Assert-Equal -Actual $readyAsh.CanTake -Expected $true -Message "Ash-Horn should become bookable once its higher ring gates are met."
    Assert-Equal -Actual $readyGate.CanTake -Expected $true -Message "Gate-Sunder should become bookable once the level 6 trail and higher ring gates are met."
    Assert-Equal -Actual $gateContract.RewardXP -Expected 1150 -Message "The level 6 monster contract should carry a larger XP reward."
}

function Test-RingMonsterContractWinPaysAndLocksContract {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null

    $contract = Get-RingMonsterChallengeContracts | Where-Object { $_.Id -eq "wall_scraper_trial" } | Select-Object -First 1
    $booking = Book-RingMonsterChallengeContract -Game $game -Contract $contract
    $blockedEarly = Resolve-RingMonsterChallengeContract -Game $game -Contract $contract -ForceWin $true

    $game.Town.DayNumber = $booking.ReadyDay
    $xpBeforeContract = [int]$game.Hero.XP
    $result = Resolve-RingMonsterChallengeContract -Game $game -Contract $contract -ForceWin $true
    $repeatReadiness = Get-RingMonsterContractReadiness -Game $game -Contract $contract

    Assert-Equal -Actual $booking.ReadyDay -Expected 3 -Message "The Wall-Scraper capture crew should need two days from day one."
    Assert-Equal -Actual $blockedEarly.Success -Expected $false -Message "Booked monster contracts should not be fightable until the capture crew returns."
    Assert-Equal -Actual $result.Won -Expected $true -Message "Forced test win should resolve the monster contract as won."
    Assert-Equal -Actual $result.ReputationAdded -Expected 8 -Message "The Wall-Scraper Trial should award monster-challenge ring reputation."
    Assert-Equal -Actual $result.RewardXP -Expected 420 -Message "The Wall-Scraper Trial should award its one-time monster-zone contract XP."
    Assert-Equal -Actual $game.Hero.XP -Expected ($xpBeforeContract + 420) -Message "Winning a monster contract should add contract XP to the hero."
    Assert-Equal -Actual $game.Town.MonsterZone.CompletedRingMonsterContracts["wall_scraper_trial"] -Expected $true -Message "Completed monster contracts should be locked in monster-zone state."
    Assert-Equal -Actual $game.Town.MonsterZone.PendingRingMonsterContracts.ContainsKey("wall_scraper_trial") -Expected $false -Message "Completed monster contracts should leave the pending capture board."
    Assert-True -Condition ($repeatReadiness.Readiness -like "*already completed*") -Message "Completed monster contracts should not be immediately repeatable."
}

function Test-RingMonsterContractBookingRemovesAvailableUntilReady {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null

    $contract = Get-AvailableRingMonsterChallengeContracts -Game $game | Select-Object -First 1
    $booking = Book-RingMonsterChallengeContract -Game $game -Contract $contract
    $availableAfterBooking = @(Get-AvailableRingMonsterChallengeContracts -Game $game)
    $readyBeforeReturn = @(Get-ReadyRingMonsterChallengeContracts -Game $game)

    $game.Town.DayNumber = $booking.ReadyDay
    $readyAfterReturn = @(Get-ReadyRingMonsterChallengeContracts -Game $game)

    Assert-Equal -Actual $booking.Success -Expected $true -Message "Dorr should be able to book a reported matching monster contract."
    Assert-Equal -Actual $availableAfterBooking.Count -Expected 0 -Message "Booked monster contracts should leave the new-contract list while the capture crew is out."
    Assert-Equal -Actual $readyBeforeReturn.Count -Expected 0 -Message "Booked monster contracts should not be ready before their return day."
    Assert-Equal -Actual $readyAfterReturn[0].Id -Expected "wall_scraper_trial" -Message "Booked contracts should become ready when the capture crew return day arrives."
}

function Test-RingMonsterContractBoardShowsProofAndBookableContracts {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    $beforeReport = Get-RingMonsterContractBoardState -Game $game
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null
    $afterReport = Get-RingMonsterContractBoardState -Game $game

    Assert-Equal -Actual @($beforeReport.UnreportedProof).Count -Expected 1 -Message "Dorr's board should show defeated monster proof before it is reported."
    Assert-Equal -Actual $beforeReport.UnreportedProof[0].BountyCopper -Expected 57 -Message "Unreported proof should preview its wall-bounty payout."
    Assert-Equal -Actual @($beforeReport.BookableContracts).Count -Expected 0 -Message "Unreported proof should not appear as a bookable contract yet."
    Assert-Equal -Actual @($afterReport.UnreportedProof).Count -Expected 0 -Message "Reported proof should leave the unreported board section."
    Assert-Equal -Actual $afterReport.BookableContracts[0].Contract.Id -Expected "wall_scraper_trial" -Message "Reported wall proof should make Wall-Scraper bookable on the board."
}

function Test-RingMonsterContractBoardTracksPendingReadyAndCompleted {
    $game = Initialize-Game
    $game.Hero.Level = 4
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "kobold_wall_scout" } | Select-Object -First 1

    Add-MonsterZoneCreatureDefeat -Game $game -Creature $creature | Out-Null
    Report-MonsterZoneDiscoveriesToDorr -Game $game | Out-Null
    $contract = Get-AvailableRingMonsterChallengeContracts -Game $game | Select-Object -First 1
    $booking = Book-RingMonsterChallengeContract -Game $game -Contract $contract
    $pendingBoard = Get-RingMonsterContractBoardState -Game $game

    $game.Town.DayNumber = $booking.ReadyDay
    $readyBoard = Get-RingMonsterContractBoardState -Game $game
    Resolve-RingMonsterChallengeContract -Game $game -Contract $contract -ForceWin $true | Out-Null
    $completedBoard = Get-RingMonsterContractBoardState -Game $game

    Assert-Equal -Actual $pendingBoard.PendingContracts[0].Contract.Id -Expected "wall_scraper_trial" -Message "Booked contracts should appear under pending capture crews."
    Assert-Equal -Actual $pendingBoard.PendingContracts[0].DaysRemaining -Expected 2 -Message "Pending board entries should show days remaining."
    Assert-Equal -Actual $readyBoard.ReadyContracts[0].Contract.Id -Expected "wall_scraper_trial" -Message "Returned capture crews should move contracts to ready."
    Assert-Equal -Actual $completedBoard.CompletedContracts[0].Contract.Id -Expected "wall_scraper_trial" -Message "Won monster contracts should move to completed."
    Assert-Equal -Actual @($completedBoard.ReadyContracts).Count -Expected 0 -Message "Completed contracts should leave the ready section."
}

function Test-SecondRingTrainingTierUnlocksAtTwentyWins {
    $hero = Get-Hero
    $first = Grant-RingTraining -Hero $hero -Wins 10
    $second = Grant-RingTraining -Hero $hero -Wins 10
    $profile = Get-HeroUnarmedProfile -Hero $hero

    Assert-Equal -Actual $first.Unlocked -Expected $true -Message "Ten wins should still unlock the first pit-fighter tier."
    Assert-Equal -Actual $second.Unlocked -Expected $true -Message "Twenty total ring wins should unlock the second pit-fighter tier."
    Assert-Equal -Actual $hero.UnarmedTrainingLevel -Expected 2 -Message "Twenty ring wins should raise unarmed training to tier 2."
    Assert-Equal -Actual $profile.DamageBonus -Expected 4 -Message "Tier 2 unarmed training should give Borzig +2 damage on top of his base modifier."
}

function Test-UnarmedProfileIgnoresWeaponAttackBonus {
    $hero = Get-Hero
    $steelAxe = New-WeaponItem -Name "Steel Great Axe" -Value 0 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 13 -SlotCost 2
    $hero.Inventory += $steelAxe

    foreach ($item in $hero.Inventory) {
        if ($item.Type -eq "Weapon") {
            $item.Equipped = $false
        }
    }

    $steelAxe.Equipped = $true

    $unarmed = Get-HeroUnarmedProfile -Hero $hero

    Assert-Equal -Actual $unarmed.TotalAttackBonus -Expected 4 -Message "Bare-handed attacks should use proficiency and ability, not weapon attack bonuses."
}

function Test-OpponentCritUsesMaxDiePlusRolledDie {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = 20
    $opponent = [PSCustomObject]@{
        Name = "Test Bruiser"
        Definite = "Test Bruiser"
        ArmorClass = 12
        HP = 10
        AttackBonus = 2
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 2
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(20)
    $script:rollQueue.Enqueue(3)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    Invoke-OpponentBrawlAttack -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $heroHP -Expected 12 -Message "Opponent crits should deal max die + rolled die + modifier."
}

function Test-HeroRingPunchCriticalFailDealsMishapDamage {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 10
    $heroTurnEnded = $false
    $opponent = [PSCustomObject]@{
        Name = "Test Bruiser"
        Definite = "Test Bruiser"
        ArmorClass = 12
        HP = 10
        AttackBonus = 2
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 2
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(1)
    $script:rollQueue.Enqueue(3)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    Invoke-HeroBrawlAttack -Hero $hero -Opponent $opponent -OpponentHP ([ref]$opponentHP) -HeroHP ([ref]$heroHP) -HeroTurnEnded ([ref]$heroTurnEnded)

    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 3) -Message "A ring punch critical fail should deal mishap damage to the hero."
    Assert-Equal -Actual $opponentHP -Expected 10 -Message "A ring punch critical fail should not damage the opponent."
    Assert-Equal -Actual $heroTurnEnded -Expected $true -Message "A ring punch critical fail should end the hero's exchange attempt."
}

function Test-HeroRingGrappleCriticalFailDealsMishapDamage {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 10
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 10
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 4
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(1)
    $script:rollQueue.Enqueue(12)
    $script:rollQueue.Enqueue(2)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    $result = Resolve-BrawlGrappleAttempt -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Block"

    Assert-Equal -Actual $result -Expected "HeroCriticalFail" -Message "A ring grapple critical fail should end the hero's grapple attempt."
    Assert-Equal -Actual $heroHP -Expected ($hero.HP - 2) -Message "A ring grapple critical fail should deal mishap damage to the hero."
    Assert-Equal -Actual $opponentHP -Expected 10 -Message "A ring grapple critical fail should not damage the opponent."
    Assert-Equal -Actual $opponentOffBalance -Expected $false -Message "A failed critical grapple should not off-balance the opponent."
}

function Test-GrappleHeavyOpponentCanChooseGrapple {
    $opponent = [PSCustomObject]@{
        GrappleChance = 45
        FocusChance = 5
        BlockChance = 5
    }

    Set-TestRollStub {
        param([int]$Sides)
        return 10
    }

    $choice = Get-OpponentBrawlAction -Opponent $opponent

    Assert-Equal -Actual $choice -Expected "G" -Message "A grapple-heavy opponent should sometimes choose a grapple."
}

function Test-RingOpponentIntroReflectsRivalryRecord {
    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Dockhand Vero"
        Intro = "Base intro."
    }

    $firstIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent
    Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $true | Out-Null
    $secondIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent
    Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $false | Out-Null
    $thirdIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent

    Assert-Equal -Actual $firstIntro -Expected "Base intro." -Message "A fresh opponent should use the baseline intro."
    Assert-True -Condition ($secondIntro -like "*already beaten 1 time(s)*") -Message "An opponent Borzig has beaten should remember that loss."
    Assert-True -Condition ($thirdIntro -like "*unfinished business*") -Message "An even rivalry should change the intro tone."
}

function Test-NamedRingRivalIntroAddsPersonalArcText {
    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Street Bruiser Nella"
        Intro = "Base intro."
    }

    Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $true | Out-Null
    $intro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent

    Assert-True -Condition ($intro -like "*Nella keeps circling*") -Message "Named rivals should add opponent-specific rivalry intro text."
    Assert-True -Condition ($intro -like "*already beaten 1 time(s)*") -Message "Named rival intro should keep the generic rivalry record context."
}

function Test-NamedRingRivalOutcomeAddsPersonalArcText {
    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Dockhand Vero"
    }
    $record = Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $false
    $outcome = Get-NamedRingRivalOutcomeText -Hero $hero -Opponent $opponent -Record $record -HeroWon $false

    Assert-True -Condition ($outcome -like "*Everyone ends up down here*") -Message "Named rival outcomes should add opponent-specific post-fight text."
    Assert-True -Condition ($outcome -like "*0-1*") -Message "Named rival outcomes should include the updated rivalry score."
}

function Test-RingOpponentIntroResolvesActiveHero {
    $hero = Get-Hero -Class "Bard"
    $opponent = [PSCustomObject]@{
        Name = "Sella Quickstep"
        Intro = "Sella measures Borzig before the first step."
    }

    $intro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent

    Assert-True -Condition ($intro -like "*Gariand*") -Message "Ring opponent intros should resolve legacy hero text to the active hero."
    Assert-True -Condition ($intro -notlike "*Borzig*") -Message "Ring opponent intros should not leak Borzig when another hero is active."
}

function Test-PunchVsGrappleUsesPunchBonus {
    Set-TestOutputStubs

    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 1
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 2
        GrappleChance = 100
        FocusChance = 0
        BlockChance = 0
        Intro = "Test intro."
    }

    function global:Read-Host {
        param([string]$Prompt)
        return "P"
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(10)
    $script:rollQueue.Enqueue(10)

    Set-TestRollStub {
        param([int]$Sides)

        if ($script:rollQueue.Count -gt 0) {
            return $script:rollQueue.Dequeue()
        }

        return 10
    }

    $won = Start-BrawlLoop -Hero $hero -Opponent $opponent -Title "Test Bout"

    Assert-Equal -Actual $won -Expected $true -Message "Punch versus Grapple should include the punch bonus strongly enough to win this tied roll test."
}

function Test-BlockedGrappleDoesNotReverseIntoCounterGrapple {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 10
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 10
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 4
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(8)
    $script:rollQueue.Enqueue(18)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    $result = Resolve-BrawlGrappleAttempt -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $false -DefenderAction "Block"

    Assert-Equal -Actual $result -Expected "Defender" -Message "A defended grapple should be blocked when the non-grappler wins the contest."
    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "Blocking a grapple should not make the defender take reverse grapple damage."
    Assert-Equal -Actual $opponentHP -Expected 10 -Message "Blocking a grapple should not deal automatic counter-grapple damage."
    Assert-Equal -Actual $heroOffBalance -Expected $false -Message "Blocking a grapple should not leave the defender off balance."
    Assert-Equal -Actual $opponentOffBalance -Expected $false -Message "Blocking a grapple should not reverse the grapple onto the initiator."
}

function Test-GrappleDamageUsesRolledDamage {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 20
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 20
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 4
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(18)
    $script:rollQueue.Enqueue(8)
    $script:rollQueue.Enqueue(3)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    $result = Resolve-BrawlGrappleAttempt -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Block"

    Assert-Equal -Actual $result -Expected "Initiator" -Message "The hero grapple should still land in the controlled test."
    Assert-Equal -Actual $opponentHP -Expected 15 -Message "Hero grapple damage should use a rolled d4 plus grapple bonus, not a fixed flat value."
}

function Test-OffBalanceFallsBackToSimpleActions {
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "G") -Expected "P" -Message "Off-balance fighters should not be allowed to grapple again immediately."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "F") -Expected "P" -Message "Off-balance fighters should not be allowed to focus immediately."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "P") -Expected "P" -Message "Off-balance fighters should still be able to punch."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "B") -Expected "B" -Message "Off-balance fighters should still be able to block."
}

function Test-FightingRingOptionOneStartsTournament {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Hero.CurrencyCopper = 200
    $script:BrawlStarted = $false
    $script:RingChoices = [System.Collections.Generic.Queue[string]]::new()
    $script:RingChoices.Enqueue("1")
    $script:RingChoices.Enqueue("1")

    function global:Read-Host {
        param([string]$Prompt)
        if ($script:RingChoices.Count -gt 0) {
            return $script:RingChoices.Dequeue()
        }

        return "0"
    }

    function Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        $script:BrawlStarted = $true
        return $false
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $script:BrawlStarted -Expected $true -Message "Choosing option 1 in the fighting ring should actually start the tournament."
    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $true -Message "Starting the ring should consume today's tournament attempt."
}

function Test-RingWagerPayoutHandlesCrowdBet {
    $wager = Get-RingWagerOptions | Where-Object { $_.Id -eq "crowd" } | Select-Object -First 1
    $payout = Resolve-RingWagerPayout -Wager $wager -Wins 2 -MaxRounds 3 -BaseRewardCopper 220

    Assert-Equal -Actual $payout.PayoutCopper -Expected 370 -Message "Crowd bet should add its bonus when the hero wins enough rounds."
    Assert-Equal -Actual $payout.BonusCopper -Expected 150 -Message "Crowd bet bonus should be tracked separately."
}

function Test-RingWagerPayoutHandlesDoubleOrNothingFailure {
    $wager = Get-RingWagerOptions | Where-Object { $_.Id -eq "double" } | Select-Object -First 1
    $payout = Resolve-RingWagerPayout -Wager $wager -Wins 1 -MaxRounds 3 -BaseRewardCopper 100

    Assert-Equal -Actual $payout.PayoutCopper -Expected 0 -Message "Double-or-nothing should erase the purse when the hero falls short."
    Assert-Equal -Actual $payout.LostBasePurse -Expected $true -Message "Double-or-nothing failure should report that the earned purse was lost."
}

function Test-RingRumorPrioritizesHalewickAftershock {
    $game = Initialize-Game
    $game.Town.StoryFlags["LordHalewickEscaped"] = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    $rumor = Get-RingRumor -Game $game -Wins 1

    Assert-True -Condition ($rumor -like "*Halewick*") -Message "Ring rumors should prioritize the Halewick aftershock when that story flag is set."
}

function Test-RingRumorPointsToMonsterContractsAtLevelFour {
    $game = Initialize-Game
    $game.Hero.Level = 4

    $rumor = Get-RingRumor -Game $game -Wins 1

    Assert-True -Condition ($rumor -like "*outer-road contracts*") -Message "Level 4 ring rumors should point toward future monster-zone contracts."
}

function Test-RingRumorRequiresAWin {
    $game = Initialize-Game

    $rumor = Get-RingRumor -Game $game -Wins 0

    Assert-Equal -Actual $rumor -Expected $null -Message "Ring rumors should not fire when the hero wins no rounds."
}

function Test-FightingRingAwardsReputationForWins {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Hero.CurrencyCopper = 200

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    function Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        return $true
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $game.Hero.RingWinsTotal -Expected 3 -Message "A fresh ring tournament should still grant normal ring wins."
    Assert-Equal -Actual $game.Hero.RingReputation -Expected 9 -Message "Winning three fresh rounds should grant the three-win reputation reward."
}

function Test-FightingRingCrowdBetPaysBonus {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Hero.CurrencyCopper = 200
    $script:RingChoices = [System.Collections.Generic.Queue[string]]::new()
    $script:RingChoices.Enqueue("1")
    $script:RingChoices.Enqueue("2")

    function global:Read-Host {
        param([string]$Prompt)
        return $script:RingChoices.Dequeue()
    }

    function Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        return $true
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 550 -Message "Crowd bet should charge its stake and add the bonus purse after enough wins."
}

function Test-FightingRingDoubleOrNothingCanLosePurse {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Hero.CurrencyCopper = 300
    $script:RingChoices = [System.Collections.Generic.Queue[string]]::new()
    $script:RingChoices.Enqueue("1")
    $script:RingChoices.Enqueue("3")
    $script:BoutResults = [System.Collections.Generic.Queue[bool]]::new()
    $script:BoutResults.Enqueue($true)
    $script:BoutResults.Enqueue($false)

    function global:Read-Host {
        param([string]$Prompt)
        return $script:RingChoices.Dequeue()
    }

    function Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        return $script:BoutResults.Dequeue()
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 100 -Message "Double-or-nothing should keep the entry and stake and erase the prize when the card is not cleared."
    Assert-Equal -Actual $game.Hero.RingWinsTotal -Expected 1 -Message "A lost double-or-nothing purse should not erase the actual bout win."
}

function Test-FightingRingChampionNightAwardsTitleAndReputation {
    $game = Initialize-Game
    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $game.Hero.CurrencyCopper = 200
    $game.Hero.RingWinsTotal = 10
    $script:ChampionNightTitle = $null

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    function Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        $script:ChampionNightTitle = $Title
        return $true
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $script:ChampionNightTitle -Expected "Champion Night: Title Bout" -Message "Champion Night should replace the normal tournament with a title bout."
    Assert-Equal -Actual $game.Hero.RingChampionNightWon -Expected $true -Message "Winning Champion Night should persist the title flag."
    Assert-Equal -Actual $game.Hero.RingReputation -Expected 14 -Message "Champion Night should grant its bonus plus the one-win reputation reward."
    Assert-Equal -Actual $game.Hero.RingWinsTotal -Expected 11 -Message "Champion Night should still count the won bout as a ring win."
}

Test-RingTrainingUnlocksUnarmedBonus
Test-RingReputationTracksSeparateProgress
Test-UnarmedRingTitleProgression
Test-UnarmedRingTitleUsesChampionAndMonsterHooks
Test-RingFightStyleSummaryRecognizesQuickFinish
Test-RingFightStyleSummaryRecognizesTechnicalWin
Test-HeroRingStyleResultTracksCrowdTaste
Test-RingMasterRespectsPhysicalProwess
Test-RingChampionUnlocksHarderCircuit
Test-RingChampionNightReadinessUsesTenWins
Test-RingVeteranCircuitUnlocksAfterFifteenWins
Test-RingMonsterChallengesUnlockAtLevelFour
Test-RingMonsterChallengePreviewRequiresLevelFour
Test-RingMonsterChallengePreviewReflectsReputationAndChampionTitle
Test-RingMonsterContractsStayBarbarianOnly
Test-FighterCanDiscussMonsterProofWithDorrWithoutContracts
Test-FighterCanReportMonsterProofToDorr
Test-RingMonsterContractsRequireReportedZoneDefeat
Test-RingMonsterReportsPayBountyAndSupplyFavor
Test-RingMonsterContractsKeepExtraGates
Test-RingMonsterContractsIncludeHigherZoneThreats
Test-RingMonsterContractWinPaysAndLocksContract
Test-RingMonsterContractBookingRemovesAvailableUntilReady
Test-RingMonsterContractBoardShowsProofAndBookableContracts
Test-RingMonsterContractBoardTracksPendingReadyAndCompleted
Test-SecondRingTrainingTierUnlocksAtTwentyWins
Test-UnarmedProfileIgnoresWeaponAttackBonus
Test-OpponentCritUsesMaxDiePlusRolledDie
Test-HeroRingPunchCriticalFailDealsMishapDamage
Test-HeroRingGrappleCriticalFailDealsMishapDamage
Test-GrappleHeavyOpponentCanChooseGrapple
Test-RingOpponentIntroReflectsRivalryRecord
Test-NamedRingRivalIntroAddsPersonalArcText
Test-NamedRingRivalOutcomeAddsPersonalArcText
Test-RingOpponentIntroResolvesActiveHero
Test-PunchVsGrappleUsesPunchBonus
Test-BlockedGrappleDoesNotReverseIntoCounterGrapple
Test-GrappleDamageUsesRolledDamage
Test-OffBalanceFallsBackToSimpleActions
Test-FightingRingOptionOneStartsTournament
Test-RingWagerPayoutHandlesCrowdBet
Test-RingWagerPayoutHandlesDoubleOrNothingFailure
Test-RingRumorPrioritizesHalewickAftershock
Test-RingRumorPointsToMonsterContractsAtLevelFour
Test-RingRumorRequiresAWin
Test-FightingRingAwardsReputationForWins
Test-FightingRingCrowdBetPaysBonus
Test-FightingRingDoubleOrNothingCanLosePurse
Test-FightingRingChampionNightAwardsTitleAndReputation

Write-Host "Ring tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
if (Test-Path Function:\global:Read-Host) {
    Remove-Item Function:\global:Read-Host -ErrorAction SilentlyContinue
}
if (Test-Path Function:\global:Start-BrawlLoop) {
    Remove-Item Function:\global:Start-BrawlLoop -ErrorAction SilentlyContinue
}
if (Test-Path Function:\Start-BrawlLoop) {
    Remove-Item Function:\Start-BrawlLoop -ErrorAction SilentlyContinue
}
