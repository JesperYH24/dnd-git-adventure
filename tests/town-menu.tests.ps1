. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-TownMainMenuUsesSubmenus {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    Set-TestReadHostSequence -Values @("2", "0", "3", "0", "5", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "EndGame" -Message "The town menu should still exit normally after entering and leaving its core submenus."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 7 -Message "The town main menu should route through shops, work, and character submenus without extra prompts."
}

function Test-TownHeroHudShowsNameHpAndCoin {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.CurrencyCopper = 234

    $hud = Get-TownHeroHudText -Game $game -HeroHP 7

    Assert-True -Condition ($hud -like "*Gariand*") -Message "The compact town HUD should always show the current hero name."
    Assert-True -Condition ($hud -like "*Bard L1*") -Message "The compact town HUD should show class and level without opening the status submenu."
    Assert-True -Condition ($hud -like "*HP 7/$($game.Hero.HP)*") -Message "The compact town HUD should show current and max HP when current HP is provided."
    Assert-True -Condition ($hud -like "*AC*") -Message "The compact town HUD should show armor class without opening the status submenu."
    Assert-True -Condition ($hud -like "*XP*") -Message "The compact town HUD should show XP progress without opening the status submenu."
    Assert-True -Condition ($hud -like "*Coin*2 GP*3 SP*4 CP*") -Message "The compact town HUD should show the hero's current coin."
}

function Test-TownHeroHudFlagsLevelUpReady {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.XP = Get-XPThresholdForLevel -Level 2

    $hud = Get-TownHeroHudText -Game $game -HeroHP $game.Hero.HP

    Assert-True -Condition ($hud -like "*Level up ready*") -Message "The compact town HUD should flag when the hero can level up."
}

function Test-TownHeroResourceHudShowsBardResources {
    $game = Initialize-Game -Class "Bard"
    Prepare-HeroBardicInspiration -Hero $game.Hero | Out-Null
    Use-HeroSpellSlot -Hero $game.Hero -SpellLevel 1 | Out-Null

    $hud = Get-TownHeroResourceHudText -Game $game -HeroHP $game.Hero.HP

    Assert-True -Condition ($hud -like "*Story Ready*") -Message "The resource HUD should show whether the daily story quest is available."
    Assert-True -Condition ($hud -like "*Work Ready*") -Message "The resource HUD should show whether the day job is available."
    Assert-True -Condition ($hud -like "*BI*/*d6*") -Message "The resource HUD should show Bardic Inspiration dice."
    Assert-True -Condition ($hud -like "*DC*") -Message "The resource HUD should show spell save DC for a bard."
    Assert-True -Condition ($hud -like "*L1 1/2*") -Message "The resource HUD should show remaining level 1 spell slots."
    Assert-True -Condition ($hud -like "*Perform 0/3 today*") -Message "The resource HUD should show today's performance count for a bard."
}

function Test-TownHeroResourceHudShowsMartialResources {
    $barbarianGame = Initialize-Game -Class "Barbarian"
    Start-HeroRage -Hero $barbarianGame.Hero | Out-Null
    $barbarianHud = Get-TownHeroResourceHudText -Game $barbarianGame -HeroHP $barbarianGame.Hero.HP

    $fighterGame = Initialize-Game -Class "Fighter"
    $fighterGame.Hero.Level = 2
    Restore-HeroSecondWind -Hero $fighterGame.Hero | Out-Null
    $fighterHud = Get-TownHeroResourceHudText -Game $fighterGame -HeroHP $fighterGame.Hero.HP

    Assert-True -Condition ($barbarianHud -like "*Rage 1/2 active*") -Message "The resource HUD should show barbarian rage uses and active state."
    Assert-True -Condition ($fighterHud -like "*Second Wind 1/1*") -Message "The resource HUD should show fighter Second Wind uses."
    Assert-True -Condition ($fighterHud -like "*Action Surge 1/1*") -Message "The resource HUD should show fighter Action Surge once it is unlocked."
}

function Test-HeroSkillTreeRowsShowProficiencyAndExpertise {
    $hero = Get-Hero -Class "Bard"
    $hero.Level = 3

    $rows = @(Get-HeroSkillTreeRows -Hero $hero)
    $performance = $rows | Where-Object { $_.Name -eq "Performance" } | Select-Object -First 1
    $persuasion = $rows | Where-Object { $_.Name -eq "Persuasion" } | Select-Object -First 1
    $athletics = $rows | Where-Object { $_.Name -eq "Athletics" } | Select-Object -First 1
    $deception = $rows | Where-Object { $_.Name -eq "Deception" } | Select-Object -First 1

    Assert-Equal -Actual $rows.Count -Expected 18 -Message "The skill tree submenu should list every DnD skill."
    Assert-Equal -Actual $performance.Marker -Expected "E" -Message "Bard Performance should be marked as expertise at level 3."
    Assert-Equal -Actual $performance.State -Expected "Expertise" -Message "Bard Performance should label expertise clearly."
    Assert-Equal -Actual $persuasion.Marker -Expected "P" -Message "Bard Persuasion should be marked as proficient."
    Assert-Equal -Actual $persuasion.State -Expected "Proficient" -Message "Bard Persuasion should label proficiency clearly."
    Assert-Equal -Actual $athletics.Marker -Expected "-" -Message "Untrained skills should be marked as untrained."
    Assert-Equal -Actual $deception.Marker -Expected "-" -Message "Bard CHA proficiency should not make untrained CHA skills appear proficient."
}

function Test-TownCharacterMenuCanOpenSkillTree {
    $game = Initialize-Game -Class "Bard"
    $heroHP = $game.Hero.HP
    Set-TestReadHostSequence -Values @("4", "0")

    Start-TownCharacterMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $script:ReadHostIndex -Expected 2 -Message "The character menu should open the skill tree and return without extra prompts."
}

function Test-BardCanCastInvisibilityFromQuestPreparation {
    $game = Initialize-Game -Class "Bard"
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 3
    Restore-HeroSpellSlots -Hero $game.Hero | Out-Null
    $heroHP = $game.Hero.HP
    $quest = Find-TownQuest -Game $game -QuestId "guard_night_watch"
    Set-TestReadHostSequence -Values @("6", "4")

    Start-TownQuestPreparationMenu -Game $game -HeroHP ([ref]$heroHP) -Quest $quest

    Assert-Equal -Actual $game.Hero.ActiveBuff.Type -Expected "Invisibility" -Message "Quest preparation should let a level 3 bard cast Invisibility before danger."
    Assert-Equal -Actual $game.Hero.CurrentSpellSlots.Level2 -Expected 1 -Message "Preparing Invisibility should spend one level 2 spell slot."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 2 -Message "The preparation menu should accept invisibility then back out."
}

function Test-TownLocationIntroShortensAfterRepeatVisits {
    $game = Initialize-Game
    $key = Get-TownFlavorVisitKey -Prefix "Vendor" -Name "Market"

    $first = Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro."
    $second = Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro."
    $third = Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro."

    Assert-Equal -Actual $first -Expected "Long market intro." -Message "The first visit to a location should show full flavor."
    Assert-Equal -Actual $second -Expected "Short market intro." -Message "The second visit should show a short reminder instead of the full scene."
    Assert-Equal -Actual $third -Expected "" -Message "Frequent repeat visits should suppress the intro entirely."
}

function Test-TownLocationIntroResetsAfterRest {
    $game = Initialize-Game
    $key = Get-TownFlavorVisitKey -Prefix "Vendor" -Name "Market"

    Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro." | Out-Null
    Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro." | Out-Null
    Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro." | Out-Null
    $game.Town.InnFlags["InnkeeperIntroIndex_bent_nail"] = 2
    $game.Town.InnFlags["InnAmbientIndex_bent_nail"] = 2
    $game.Town.InnFlags["InnVisitSeen_bent_nail"] = $true
    $game.Town.InnFlags["BentNailShadyRumor"] = $true

    Advance-TownToNextDay -Game $game -StartingTimeOfDay "Day"

    $afterRest = Get-TownLocationIntroText -Game $game -Key $key -FullText "Long market intro." -RepeatText "Short market intro."

    Assert-Equal -Actual $afterRest -Expected "Long market intro." -Message "A rest should reset transient location flavor so full intro text can return."
    Assert-Equal -Actual $game.Town.InnFlags.ContainsKey("InnkeeperIntroIndex_bent_nail") -Expected $false -Message "Innkeeper intro rotation should reset after rest."
    Assert-Equal -Actual $game.Town.InnFlags.ContainsKey("InnAmbientIndex_bent_nail") -Expected $false -Message "Inn ambient rotation should reset after rest."
    Assert-Equal -Actual $game.Town.InnFlags.ContainsKey("InnVisitSeen_bent_nail") -Expected $false -Message "Inn visit flavor should reset after rest."
    Assert-Equal -Actual $game.Town.InnFlags["BentNailShadyRumor"] -Expected $true -Message "Resetting flavor should not erase real inn progress flags."
}

function Test-DocksDistrictUnlocksAfterLadyVeyraReveal {
    $game = Initialize-Game

    Assert-Equal -Actual (Test-DocksDistrictUnlocked -Game $game) -Expected $false -Message "The docks district should stay locked before Lady Veyra is revealed."
    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $false -Message "The docks should not be open from the town menu before the docks story chain is solved."
    Assert-Equal -Actual (Get-TownQuestSourceDisplayTitle -Source "Quest Giver" -Game $game) -Expected "Quest Giver" -Message "The private quest source should keep its anonymous title before Lady Veyra is revealed."

    $game.Town.StoryFlags["BenefactorRevealed"] = $true

    Assert-Equal -Actual (Test-DocksDistrictUnlocked -Game $game) -Expected $true -Message "The docks district should unlock once Lady Veyra's identity becomes part of the story."
    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $false -Message "The Veyra reveal should unlock the docks lead, not the open town district."
    Assert-Equal -Actual (Get-TownQuestSourceDisplayTitle -Source "Quest Giver" -Game $game) -Expected "High Ledger Office" -Message "After the reveal, the private quest source should be reframed around Lady Veyra's office."
}

function Test-DocksDistrictFirstVisitDiscoversOddityShop {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopDiscovered -Game $game) -Expected $true -Message "The first docks visit should discover Auntie Brindle's shop before other dock leads expand."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 1 -Message "The docks district menu should allow the player to back out cleanly after the first discovery."
}

function Test-DocksDistrictRequiresOddityShopBeforeTallyShack {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("2", "0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopDiscovered -Game $game) -Expected $true -Message "Entering the docks should still discover Auntie Brindle first."
    Assert-Equal -Actual (Test-DocksOddityShopVisited -Game $game) -Expected $false -Message "Trying to skip ahead should not count as visiting the oddity shop."
    Assert-Equal -Actual (Test-DocksTallyShackDiscovered -Game $game) -Expected $false -Message "The tide-ledger shack should stay locked until Auntie Brindle has been visited."
}

function Test-DocksDistrictOddityShopUnlocksTallyShackLead {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    Set-TestReadHostSequence -Values @("1", "0", "2", "0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksOddityShopVisited -Game $game) -Expected $true -Message "Visiting Auntie Brindle should mark the first docks step complete."
    Assert-Equal -Actual (Test-DocksTallyShackDiscovered -Game $game) -Expected $true -Message "Asking Auntie about the clue should unlock the tide-ledger shack."
}

function Test-DocksDistrictOpensFromTownAfterBlackContractChain {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["DocksOddityShopDiscovered"] = $true
    $game.Town.StoryFlags["DocksOddityShopVisited"] = $true
    $game.Town.StoryFlags["DocksTallyShackDiscovered"] = $true
    $game.Town.StoryFlags["NamedVeyraContractBroker"] = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    Set-TestReadHostSequence -Values @("6", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual (Test-DocksDistrictOpenToTown -Game $game) -Expected $true -Message "Completing the first docks chain should open the docks as a town district."
    Assert-Equal -Actual ([bool]$game.Town.StoryFlags["HigherPatronSuspected"]) -Expected $false -Message "Opening the docks should not require discovering the higher patron yet."
    Assert-Equal -Actual $result -Expected "EndGame" -Message "The player should be able to visit the open docks district from town and return."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 3 -Message "The town menu should route into the opened docks district without extra prompts."
}

function Test-DocksOpenLeadsComeFromVeyraContact {
    $game = Initialize-Game
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["DocksOddityShopDiscovered"] = $true
    $game.Town.StoryFlags["DocksOddityShopVisited"] = $true
    $game.Town.StoryFlags["DocksTallyShackDiscovered"] = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true

    $progressText = Get-DocksDistrictProgressText -Game $game
    $introText = Get-TownQuestSourceIntroText -Source "Docks" -DefaultIntroText "unused" -Game $game

    Assert-True -Condition ($progressText -like "*Mira Kest*") -Message "Open Docks progress text should name Lady Veyra's dock contact."
    Assert-True -Condition ($introText -like "*Mira Kest*") -Message "Docks quest-source text should present later leads through Lady Veyra's dock contact."
}

function Test-DocksProgressCallsOutMonsterZoneOddityHaul {
    $game = Initialize-Game
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "scale_touched_mastiff" } | Select-Object -First 1

    Add-MonsterZoneOddity -Game $game -Creature $creature | Out-Null
    $progressText = Get-DocksDistrictProgressText -Game $game

    Assert-True -Condition ($progressText -like "*Auntie Brindle*" -and $progressText -like "*monster-zone oddity*") -Message "Docks progress should point carried monster-zone oddities toward Auntie Brindle."
    Assert-True -Condition ($progressText -like "*Veyra*wall ledger*") -Message "Docks progress should tie draconic oddities back to Veyra's city ledger."
}

function Test-DocksCanCashOutMonsterZoneOddities {
    $game = Initialize-Game
    $game.Town.Mounts.MonsterOddityCapacity = 2
    $first = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "wall_wolf" } | Select-Object -First 1
    $second = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "scale_touched_mastiff" } | Select-Object -First 1
    $startingCopper = [int]$game.Hero.CurrencyCopper

    Add-MonsterZoneOddity -Game $game -Creature $first | Out-Null
    Add-MonsterZoneOddity -Game $game -Creature $second | Out-Null
    $sale = Resolve-DocksMonsterOdditySale -Game $game

    Assert-Equal -Actual $sale.Success -Expected $true -Message "The docks should accept carried monster-zone oddities as a city payout."
    Assert-Equal -Actual $sale.Count -Expected 2 -Message "The docks sale should include the whole carried oddity haul."
    Assert-Equal -Actual $sale.TotalCopper -Expected 135 -Message "The docks payout should use the carried oddity values."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected ($startingCopper + 135) -Message "Selling monster-zone oddities should add coin to the hero."
    Assert-Equal -Actual @($game.Town.MonsterZone.Oddities).Count -Expected 0 -Message "Selling the haul should clear carried monster-zone oddities."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksMonsterOdditiesDelivered"] -Expected $true -Message "The city should remember that monster-zone oddities reached the docks."
    Assert-Equal -Actual $game.Town.StoryFlags["DocksDraconicOddityNoted"] -Expected $true -Message "Draconic monster-zone salvage should leave a Veyra ledger note."
}

function Test-DocksMenuCanDeliverMonsterZoneOddities {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $creature = Get-MonsterZoneCreatures | Where-Object { $_.id -eq "razor_boar" } | Select-Object -First 1
    Add-MonsterZoneOddity -Game $game -Creature $creature | Out-Null
    Set-TestReadHostSequence -Values @("7", "0")

    Start-DocksDistrictMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual @($game.Town.MonsterZone.Oddities).Count -Expected 0 -Message "The docks menu should let the player deliver carried monster-zone oddities."
    Assert-Equal -Actual $game.Hero.CurrencyCopper -Expected 55 -Message "Delivering the razor boar oddity should pay its value."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 2 -Message "The docks delivery path should consume the delivery choice and the exit choice."
}

function Test-PostCivicVaultTownTextReactsToHalewickEscape {
    $game = Initialize-Game
    $game.Town.ChapterTwoComplete = $true
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $game.Town.StoryFlags["HigherPatronSuspected"] = $true
    $game.Town.StoryFlags["LordHalewickEscaped"] = $true

    $docksProgress = Get-DocksDistrictProgressText -Game $game
    $ledgerIntro = Get-TownQuestSourceIntroText -Source "Quest Giver" -DefaultIntroText "unused" -Game $game
    $docksIntro = Get-TownQuestSourceIntroText -Source "Docks" -DefaultIntroText "unused" -Game $game
    $guardIntro = Get-TownQuestSourceIntroText -Source "Guard Station" -DefaultIntroText "unused" -Game $game
    $aftermathReminder = Get-PostCivicVaultAftermathReminderText -Game $game

    Assert-True -Condition ($docksProgress -like "*Halewick*escaped*") -Message "Docks progress should react once Halewick has escaped after the Civic Vault."
    Assert-True -Condition ($ledgerIntro -like "*High Ledger*Halewick*") -Message "The High Ledger intro should acknowledge the post-Civic-Vault alarm state."
    Assert-True -Condition ($docksIntro -like "*Halewick*dragon*escape route*") -Message "The Docks intro should turn dragon panic into a new lead direction."
    Assert-True -Condition ($guardIntro -like "*Civic Keep witnesses*" -and $guardIntro -like "*draconic*") -Message "The Guard Station intro should react to the public Civic Keep witnesses before wall rumors start."
    Assert-True -Condition ($aftermathReminder -like "*Aftermath:*" -and $aftermathReminder -like "*Rest*") -Message "The town menu should give a clear post-Civic-Vault next step before wall rumors start."
}

function Test-PostCivicVaultAftermathReminderClearsAfterWallRumors {
    $game = Initialize-Game
    $game.Town.StoryFlags["LordHalewickEscaped"] = $true

    $beforeRumors = Get-PostCivicVaultAftermathReminderText -Game $game
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    $afterRumors = Get-PostCivicVaultAftermathReminderText -Game $game

    Assert-True -Condition ($beforeRumors -like "*Halewick*escaped*") -Message "Post-Civic-Vault reminder should appear before wall rumors start."
    Assert-Equal -Actual $afterRumors -Expected "" -Message "Post-Civic-Vault reminder should clear once wall rumors take over the next step."
}

function Test-TownNextStepReminderPrioritizesLevelUpRest {
    $game = Initialize-Game
    $game.Hero.Level = 3
    $game.Hero.LevelCap = 4
    $game.Hero.XP = 2700
    $game.Town.StoryFlags["DocksCharterScribeExposed"] = $true

    $reminder = Get-TownNextStepReminderText -Game $game

    Assert-True -Condition ($reminder -like "*Rest at an inn*" -and $reminder -like "*level-up*") -Message "Town next-step reminder should prioritize pending level-up rests."
}

function Test-TownNextStepReminderTracksDocksStoryBeats {
    $game = Initialize-Game
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $veyrasLead = Get-TownNextStepReminderText -Game $game

    $game.Town.StoryFlags["DocksFirstChainComplete"] = $true
    $miraLead = Get-TownNextStepReminderText -Game $game

    $game.Town.StoryFlags["DocksOrganizationProfiled"] = $true
    $scribeLead = Get-TownNextStepReminderText -Game $game

    Assert-True -Condition ($veyrasLead -like "*Docks*" -and $veyrasLead -like "*Auntie Brindle*") -Message "After Veyra reveal, next-step reminder should point to Auntie Brindle."
    Assert-True -Condition ($miraLead -like "*Mira Kest*" -and $miraLead -like "*organization*") -Message "After the first Docks chain, next-step reminder should point to Mira's organization leads."
    Assert-True -Condition ($scribeLead -like "*charter scribe*") -Message "After profiling the Docks organization, next-step reminder should point to the charter scribe."
}

function Test-TownNextStepReminderYieldsToMonsterZone {
    $game = Initialize-Game
    $game.Town.StoryFlags["BenefactorRevealed"] = $true
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true

    $reminder = Get-TownNextStepReminderText -Game $game

    Assert-Equal -Actual $reminder -Expected "" -Message "Generic town next-step reminder should clear once monster-zone guidance is active."
}

function Test-TownRelationshipHintSurfacesBardInnPayoff {
    $game = Initialize-Game -Class "Bard"
    $game.Town.InnFlags["SilverKettlePrivateInvite"] = $true

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Silver Kettle private rooms*" -and $hint -like "*night performances*") -Message "Town relationship hint should point Bards toward the Silver Kettle private performance payoff."
}

function Test-TownRelationshipHintSurfacesFighterPatronPayoff {
    $game = Initialize-Game -Class "Fighter"
    $game.Town.Relationships["TourneyPatrons"] = "Introduced"

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Silver Kettle patrons*" -and $hint -like "*tourney ground*" -and $hint -like "*backing*") -Message "Town relationship hint should point Fighters from inn patrons toward tourney backing."
}

function Test-TownRelationshipHintSurfacesBarbarianInnPayoff {
    $game = Initialize-Game -Class "Barbarian"
    $game.Town.Relationships["LanternMercenaries"] = "Warm"

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Lantern Rest mercenaries*" -and $hint -like "*travel steel*") -Message "Town relationship hint should point Barbarians from Lantern Rest standing toward practical gear leads."
}

function Test-TownRelationshipHintSurfacesBardStreetPayoff {
    $game = Initialize-Game -Class "Bard"
    $game.Town.StreetFlags["BelorSquarePermit"] = $true

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Belor*" -and $hint -like "*market performance*" -and $hint -like "*pays better*") -Message "Town relationship hint should surface Belor's bard market-performance permit."
}

function Test-TownRelationshipHintSurfacesFighterStreetPayoff {
    $game = Initialize-Game -Class "Fighter"
    $game.Town.StreetFlags["BelorTourneyStanding"] = $true

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Belor*" -and $hint -like "*formal watch respect*" -and $hint -like "*armorer*") -Message "Town relationship hint should surface Belor's fighter armorer favors."
}

function Test-TownRelationshipHintSurfacesBarbarianStreetPayoff {
    $game = Initialize-Game -Class "Barbarian"
    $game.Town.StreetFlags["BelorWatchFavor"] = $true

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Belor trusts*" -and $hint -like "*apothecary*" -and $hint -like "*healing supply*") -Message "Town relationship hint should surface Belor's barbarian healing supply favor."
}

function Test-TownRelationshipHintSurfacesActiveSilverKettlePayoutBonus {
    $game = Initialize-Game
    $game.Town.InnFlags["SilverKettleEconomicInsight"] = $true
    $game.Town.QuestPayoutBonusCopper = 20

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Silver Kettle contract talk*" -and $hint -like "*next city payout*") -Message "Town relationship hint should surface Silver Kettle economic insight while its payout bonus remains active."
}

function Test-TownRelationshipHintSkipsSpentSilverKettlePayoutBonus {
    $game = Initialize-Game
    $game.Town.InnFlags["SilverKettleEconomicInsight"] = $true
    $game.Town.QuestPayoutBonusCopper = 0

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-Equal -Actual $hint -Expected "" -Message "Town relationship hint should stop pointing at a Silver Kettle payout once that bonus has been spent."
}

function Test-TownRelationshipHintSurfacesBentNailFallback {
    $game = Initialize-Game -Class "Fighter"
    $game.Town.Relationships["BentNailRoom"] = "Grudging"

    $hint = Get-TownRelationshipHintText -Game $game

    Assert-True -Condition ($hint -like "*Bent Nail*" -and $hint -like "*under-table leads*") -Message "Town relationship hint should still surface a Bent Nail relationship when no class-specific higher payoff is active."
}

function Test-TownAmbienceHintsAtPalaceRepairsAfterHalewickEscape {
    $game = Initialize-Game

    Assert-Equal -Actual (Get-TownAmbientText -Game $game) -Expected "" -Message "Town ambience should stay quiet before the palace aftermath is known."

    $game.Town.StoryFlags["LordHalewickEscaped"] = $true
    $dayText = Get-TownAmbientText -Game $game

    Assert-True -Condition ($dayText -like "*Civic Keep*") -Message "Day ambience should anchor the repair sounds at the Civic Keep."
    Assert-True -Condition ($dayText -like "*hammers*" -and $dayText -like "*repair*") -Message "Day ambience should hint at palace repairs through sound."

    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $nightText = Get-TownAmbientText -Game $game

    Assert-True -Condition ($nightText -like "*hammer*" -and $nightText -like "*palace*") -Message "Night ambience should keep the palace repair sounds present in town."
    Assert-True -Condition ($nightText -like "*guard*" -or $nightText -like "*lanterns*") -Message "Night ambience should make the repairs feel watched and uneasy."
}

function Test-TownAmbienceAddsWallMonsterRumorsAfterInnRest {
    $game = Initialize-Game
    $game.Town.StoryFlags["LordHalewickEscaped"] = $true
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true

    $dayText = Get-TownAmbientText -Game $game

    Assert-True -Condition ($dayText -like "*Civic Keep*" -and $dayText -like "*walls*") -Message "Post-rest ambience should keep palace repairs while adding outer-wall rumors."
    Assert-True -Condition ($dayText -like "*creatures*" -or $dayText -like "*gate guards*") -Message "Post-rest ambience should foreshadow creatures beyond the city."

    Set-TownTimeOfDay -Game $game -TimeOfDay "Night"
    $nightText = Get-TownAmbientText -Game $game

    Assert-True -Condition ($nightText -like "*outer wall*" -and $nightText -like "*hungry shapes*") -Message "Night ambience should carry the wall-monster rumor after it starts."
}

function Test-TownMenuCanEnterUnlockedMonsterZone {
    $game = Initialize-Game
    $heroHP = $game.Hero.HP
    $game.Town.MustChooseFirstInn = $false
    $game.Town.ChapterOneComplete = $true
    $game.Town.StoryFlags["MonsterWallRumorsStarted"] = $true
    Set-TestReadHostSequence -Values @("7", "0", "0")

    $result = Start-TownMenu -Game $game -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $result -Expected "EndGame" -Message "The town menu should route into the unlocked monster zone and return cleanly."
    Assert-Equal -Actual $script:ReadHostIndex -Expected 3 -Message "Monster zone entry should consume only the expected prompts when the player backs out."
}

Test-TownMainMenuUsesSubmenus
Test-TownHeroHudShowsNameHpAndCoin
Test-TownHeroHudFlagsLevelUpReady
Test-TownHeroResourceHudShowsBardResources
Test-TownHeroResourceHudShowsMartialResources
Test-HeroSkillTreeRowsShowProficiencyAndExpertise
Test-TownCharacterMenuCanOpenSkillTree
Test-BardCanCastInvisibilityFromQuestPreparation
Test-TownLocationIntroShortensAfterRepeatVisits
Test-TownLocationIntroResetsAfterRest
Test-DocksDistrictUnlocksAfterLadyVeyraReveal
Test-DocksDistrictFirstVisitDiscoversOddityShop
Test-DocksDistrictRequiresOddityShopBeforeTallyShack
Test-DocksDistrictOddityShopUnlocksTallyShackLead
Test-DocksDistrictOpensFromTownAfterBlackContractChain
Test-DocksOpenLeadsComeFromVeyraContact
Test-DocksProgressCallsOutMonsterZoneOddityHaul
Test-DocksCanCashOutMonsterZoneOddities
Test-DocksMenuCanDeliverMonsterZoneOddities
Test-PostCivicVaultTownTextReactsToHalewickEscape
Test-PostCivicVaultAftermathReminderClearsAfterWallRumors
Test-TownNextStepReminderPrioritizesLevelUpRest
Test-TownNextStepReminderTracksDocksStoryBeats
Test-TownNextStepReminderYieldsToMonsterZone
Test-TownRelationshipHintSurfacesBardInnPayoff
Test-TownRelationshipHintSurfacesFighterPatronPayoff
Test-TownRelationshipHintSurfacesBarbarianInnPayoff
Test-TownRelationshipHintSurfacesBardStreetPayoff
Test-TownRelationshipHintSurfacesFighterStreetPayoff
Test-TownRelationshipHintSurfacesBarbarianStreetPayoff
Test-TownRelationshipHintSurfacesActiveSilverKettlePayoutBonus
Test-TownRelationshipHintSkipsSpentSilverKettlePayoutBonus
Test-TownRelationshipHintSurfacesBentNailFallback
Test-TownAmbienceHintsAtPalaceRepairsAfterHalewickEscape
Test-TownAmbienceAddsWallMonsterRumorsAfterInnRest
Test-TownMenuCanEnterUnlockedMonsterZone

Write-Host "Town menu tests passed." -ForegroundColor Green
