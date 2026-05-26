# Town is split into focused scripts so city progression stays readable as it grows.
. "$PSScriptRoot\\town-shops.ps1"
. "$PSScriptRoot\\town-npcs.ps1"
. "$PSScriptRoot\\town-ring.ps1"
. "$PSScriptRoot\\town-inns.ps1"

function Get-TownSourceVisitKey {
    param([string]$Source)

    return ("QuestSourceVisited_" + ($Source -replace "[^A-Za-z0-9]", ""))
}

function Get-TownFlavorVisitKey {
    param(
        [string]$Prefix,
        [string]$Name
    )

    return ("FlavorVisit_$Prefix" + "_" + ($Name -replace "[^A-Za-z0-9]", ""))
}

function Get-TownLocationIntroText {
    param(
        $Game,
        [string]$Key,
        [string]$FullText,
        [string]$RepeatText = "",
        [int]$RepeatLimit = 1
    )

    if ([string]::IsNullOrWhiteSpace($FullText)) {
        return ""
    }

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.StreetFlags -or [string]::IsNullOrWhiteSpace($Key)) {
        return $FullText
    }

    $currentVisits = if ($null -ne $Game.Town.StreetFlags[$Key]) { [int]$Game.Town.StreetFlags[$Key] } else { 0 }
    $Game.Town.StreetFlags[$Key] = $currentVisits + 1

    if ($currentVisits -eq 0) {
        return $FullText
    }

    if ($currentVisits -le $RepeatLimit -and -not [string]::IsNullOrWhiteSpace($RepeatText)) {
        return $RepeatText
    }

    return ""
}

function Write-TownLocationIntro {
    param(
        $Game,
        [string]$Key,
        [string]$FullText,
        [string]$RepeatText = "",
        [int]$RepeatLimit = 1
    )

    $introText = Get-TownLocationIntroText -Game $Game -Key $Key -FullText $FullText -RepeatText $RepeatText -RepeatLimit $RepeatLimit

    if (-not [string]::IsNullOrWhiteSpace($introText)) {
        Write-Scene $introText
    }
}

function Get-TownVendorRepeatIntroText {
    param([string]$Title)

    switch ($Title) {
        "Market" { return "The market trader is still at the counter, hands already near the goods instead of the greeting." }
        "Smithy" { return "The smith glances up from the workbench, ready to talk steel without another speech." }
        "Apothecary" { return "The apothecary looks up from the bottles and waits for the practical part." }
        "Instrument Shop" { return "The instrument maker lets the room settle back into quiet wood, strings, and prices." }
        "Armorer" { return "The armorer keeps the measuring cord close and waits to see what needs fitting." }
        "Stable Yard" { return "The stable yard has already made its smells, prices, and animals plain enough." }
        default { return "The counter is familiar now, and the business can start without ceremony." }
    }
}

function Get-TownQuestSourceRepeatIntroText {
    param(
        [string]$Source,
        $Game
    )

    $title = Get-TownQuestSourceDisplayTitle -Source $Source -Game $Game

    switch ($Source) {
        "Quest Board" { return "The board is still here: names, coin, and trouble waiting in shorter lines than the first look." }
        "Guard Station" { return "The watch desk has already said its piece. The open assignments matter more than the room now." }
        "Quest Giver" { return "$title is ready to get back to the work itself." }
        "Docks" { return "The dock leads remain on the table, wet-edged and dangerous enough without repeating the whole quarter." }
        default { return "The work source is familiar now; the listed jobs matter more than another introduction." }
    }
}

function Get-TownNpcRepeatIntroText {
    param(
        [string]$NpcId,
        $Game
    )

    $heroName = if ($null -ne $Game -and $null -ne $Game.Hero) { [string]$Game.Hero.Name } else { "the hero" }

    switch ($NpcId) {
        "WidowElira" { return "Elira recognizes $heroName's return and skips the careful doorstep pause." }
        "Hadrik" { return "Hadrik is already near the forge rail, ready to talk without warming the coals twice." }
        "Belor" { return "Belor gives $heroName a short nod, already past greetings and into watchman's attention." }
        default { return "The familiar face gives $heroName room to get to the point." }
    }
}

function Get-DocksContactName {
    return "Mira Kest"
}

function Get-TownAmbientText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return ""
    }

    if (-not [bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
        return ""
    }

    if ([bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"]) {
        if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
            return "Even after dark, dull hammer taps carry from the Civic Keep while watch bells answer from the outer wall. People speak lower now, trading rumors of hungry shapes testing the roads beyond the gates."
        }

        return "From the Civic Keep, hammers and block-and-tackle creak over the rooftops. Beneath the repair noise, gate guards trade uneasy reports of creatures growing bold beyond the city walls."
    }

    if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
        return "Even after dark, dull hammer taps carry from the Civic Keep. Somewhere above the palace courts, repairs continue under guard and covered lanterns."
    }

    return "From the Civic Keep, hammers and block-and-tackle creak over the rooftops. Palace masons repair stone no one in the street is ready to name out loud."
}

function Get-PostCivicVaultAftermathReminderText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or -not [bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
        return ""
    }

    if ([bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"]) {
        return ""
    }

    $innText = if ($null -ne $Game.Town.ActiveInn -and -not [string]::IsNullOrWhiteSpace([string]$Game.Town.ActiveInn.Name)) {
        "Rest at $($Game.Town.ActiveInn.Name)"
    }
    else {
        "Find an inn and rest"
    }

    return "Aftermath: Halewick has been exposed and escaped. $innText so the city can gather witness reports and reveal what fear reaches the gates next."
}

function Get-TownNextStepReminderText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Hero) {
        return ""
    }

    if (Test-MonsterZoneUnlocked -Game $Game) {
        return ""
    }

    if ((Get-HeroAvailableLevelUps -Hero $Game.Hero) -gt 0) {
        return "Next step: Rest at an inn to take the pending level-up before the next major danger."
    }

    if ([bool]$Game.Town.StoryQuestDoneToday) {
        return "Next step: Rest for the night before taking another real story lead."
    }

    if ([bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
        return ""
    }

    if ([bool]$Game.Town.StoryFlags["HigherPatronSuspected"]) {
        return "Next step: Meet Mira Kest in the Docks and follow the higher-city proof toward the Civic Vault."
    }

    if ([bool]$Game.Town.StoryFlags["DocksCharterScribeExposed"]) {
        return "Next step: Rest at an inn, then return to Mira Kest for the higher-city paper trail."
    }

    if ([bool]$Game.Town.StoryFlags["DocksOrganizationProfiled"]) {
        return "Next step: Keep working Mira Kest's Docks leads until the charter scribe can be exposed."
    }

    if ([bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]) {
        return "Next step: Visit Mira Kest in the Docks for the organization leads behind Lady Veyra's contract."
    }

    if ([bool]$Game.Town.StoryFlags["NamedVeyraContractBroker"]) {
        return "Next step: Return to the Docks and press Warehouse Row or the old knife berth."
    }

    if ([bool]$Game.Town.StoryFlags["BenefactorRevealed"]) {
        return "Next step: Follow Lady Veyra's lead to the Docks and start with Auntie Brindle's salvage shop."
    }

    if ([bool]$Game.Town.StoryFlags["UnderstreetComplexCleared"]) {
        return "Next step: Visit the High Ledger office. The city's hidden patron is ready to become a real lead."
    }

    return ""
}

function Get-TownRelationshipHintText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Hero) {
        return ""
    }

    $heroName = [string]$Game.Hero.Name

    if ($Game.Hero.Class -eq "Bard") {
        if ([bool]$Game.Town.InnFlags["SilverKettlePrivateInvite"]) {
            return "Relationship: Silver Kettle private rooms are open to $heroName; night performances can earn better patron coin."
        }

        if ([string]$Game.Town.Relationships["LanternAudience"] -eq "Warm") {
            return "Relationship: Lantern Rest has a warm audience for $heroName, and the instrument shop has a Stage Lute lead."
        }

        if ([bool]$Game.Town.StreetFlags["BelorSquarePermit"]) {
            return "Relationship: Belor cleared $heroName for market performance space; public square work pays better with the watch looking on."
        }

        if ([bool]$Game.Town.StreetFlags["HadrikRapierDiscountUnlocked"]) {
            return "Relationship: Hadrik has a Slim Forge Rapier lead waiting at the smithy for $heroName."
        }
    }
    elseif ($Game.Hero.Class -eq "Fighter") {
        if ($null -ne $Game.Town.Relationships["TourneyPatrons"]) {
            return "Relationship: Silver Kettle patrons have noticed $heroName; the tourney ground can turn that attention into backing."
        }

        if ([string]$Game.Town.Relationships["LanternTourneyTalk"] -eq "Warm") {
            return "Relationship: Lantern Rest tourney talk is warm, and the armorer has a Heater Shield lead."
        }

        if ([bool]$Game.Town.StreetFlags["BelorTourneyStanding"]) {
            return "Relationship: Belor has given $heroName formal watch respect; the armorer has knightly shield and mail favors ready."
        }

        if ([bool]$Game.Town.StreetFlags["HadrikKnightlyLongswordDiscountUnlocked"]) {
            return "Relationship: Hadrik has a Knightly Longsword lead waiting at the smithy for $heroName."
        }
    }
    elseif ($Game.Hero.Class -eq "Barbarian") {
        if ([string]$Game.Town.Relationships["LanternMercenaries"] -eq "Warm") {
            return "Relationship: Lantern Rest mercenaries respect $heroName, and the market has practical travel steel leads."
        }

        if ([bool]$Game.Town.InnFlags["SilverKettleEconomicInsight"] -and [int]$Game.Town.QuestPayoutBonusCopper -gt 0) {
            return "Relationship: Silver Kettle contract talk can improve $heroName's next city payout and recovery supply path."
        }

        if ([bool]$Game.Town.StreetFlags["BelorWatchFavor"]) {
            return "Relationship: Belor trusts $heroName for ugly watch work; the apothecary has healing supply favors ready."
        }

        if ([bool]$Game.Town.StreetFlags["SmithyDiscountUnlocked"]) {
            return "Relationship: Hadrik has a Steel Great Axe lead waiting at the smithy for $heroName."
        }
    }

    if (-not [string]::IsNullOrWhiteSpace([string]$Game.Town.Relationships["BentNailRoom"])) {
        return "Relationship: The Bent Nail knows $heroName now; under-table leads may open there as the story deepens."
    }

    if ([bool]$Game.Town.InnFlags["SilverKettleEconomicInsight"] -and [int]$Game.Town.QuestPayoutBonusCopper -gt 0) {
        return "Relationship: Silver Kettle contract talk can improve the next city payout."
    }

    return ""
}

function Test-DocksDistrictUnlocked {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    return [bool]$Game.Town.StoryFlags["DocksUnlocked"] -or [bool]$Game.Town.StoryFlags["BenefactorRevealed"]
}

function Test-DocksDistrictOpenToTown {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    if ([bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]) {
        return $true
    }

    $quest = Find-TownQuest -Game $Game -QuestId "docks_black_contract"
    return ($null -ne $quest -and [bool]$quest.Completed)
}

function Test-DocksOddityShopDiscovered {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    return [bool]$Game.Town.StoryFlags["DocksOddityShopDiscovered"]
}

function Test-DocksOddityShopVisited {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    return [bool]$Game.Town.StoryFlags["DocksOddityShopVisited"]
}

function Test-DocksTallyShackDiscovered {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $false
    }

    return [bool]$Game.Town.StoryFlags["DocksTallyShackDiscovered"]
}

function Get-DocksDistrictProgressText {
    param($Game)

    $docksContactName = Get-DocksContactName
    $monsterOddityHaul = Get-DocksMonsterOddityHaul -Game $Game

    if ($monsterOddityHaul.Count -gt 0) {
        return "Docks Salvage: Auntie Brindle can turn $($monsterOddityHaul.Count) monster-zone oddity bundle(s) into coin, and $docksContactName can keep anything draconic tied to Veyra's wall ledger."
    }

    if ([bool]$Game.Town.StoryFlags["DocksDraconicOddityNoted"]) {
        return "Docks Ledger: $docksContactName has a draconic oddity note from Auntie Brindle's table, tying monster-zone salvage back toward Lady Veyra's wall records."
    }

    if ([bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
        return "Docks Aftershock: $docksContactName says every tide-runner has heard the bells. Halewick was exposed in the Civic Keep, became something draconic, and escaped into the city's frightened sky."
    }

    if (-not (Test-DocksOddityShopDiscovered -Game $Game)) {
        return "Docks Discovery: the first useful doorway is still hidden among the salvage stalls."
    }

    if (-not (Test-DocksOddityShopVisited -Game $Game)) {
        return "Docks Discovery: Auntie Brindle's impossible shop is the first place worth understanding."
    }

    if (-not (Test-DocksTallyShackDiscovered -Game $Game)) {
        return "Docks Lead: Auntie Brindle knows which bit of discarded black wax matters, if {hero} asks the right way."
    }

    if ([bool]$Game.Town.StoryFlags["HigherPatronSuspected"]) {
        return "Docks Lead: $docksContactName has enough shell-charter proof to say the order against Lady Veyra came from higher city hands."
    }

    if ([bool]$Game.Town.StoryFlags["DocksCharterScribeExposed"]) {
        return "Docks Breakthrough: $docksContactName has the charter scribe's dirty paper trail. Rest before the next larger move."
    }

    if ([bool]$Game.Town.StoryFlags["DocksOrganizationProfiled"]) {
        return "Docks Lead: $docksContactName has sorted the organization into freight, debt, secrets, and blades. The charter scribe is the next loose thread."
    }

    if ([bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]) {
        return "Docks Open: $docksContactName, Lady Veyra's dock contact, can now turn each ugly dockside clue into deeper leads."
    }

    if ([bool]$Game.Town.StoryFlags["NamedVeyraContractBroker"]) {
        return "Docks Lead: Warehouse Row has given up the broker's name. The old knife berth is the next place to press."
    }

    return "Docks Lead: the tide-ledger shack is open now. Follow the black wax mark from salvage to paperwork."
}

function Show-DocksOddityShopDiscovery {
    param($Game)

    if (Test-DocksOddityShopDiscovered -Game $Game) {
        return
    }

    $Game.Town.StoryFlags["DocksOddityShopDiscovered"] = $true
    Write-SectionTitle -Text "A Door Made of Other Doors" -Color "Yellow"
    Write-TownTimeTracker -Game $Game -Area "Docks" -HeroHP $Game.Hero.HP
    Write-Scene "The first place the docks reveal is not a tavern, a pier office, or a smugglers' den. It is a crooked little shop wedged under a stair, built from mismatched doors and hung with bottle glass that clicks in the river wind."
    Write-Scene "A wild-haired old woman in a patched shawl leans out through a curtain of beads, holding what might be a rat skull, a fishing lure, or both."
    Write-Scene "'People throw away the best parts,' she says. 'Monster teeth. Bent buckles. Old bones. Bottle stoppers. Shameful little trinkets. Bring them to Auntie Brindle before some clean-handed fool sweeps them into the river.'"
    Write-EmphasisLine -Text "New Docks Discovery: Auntie Brindle's Rag-and-Bone Teapot buys odd junk and unwanted salvage for better coin than respectable shops." -Color "Yellow"
    Write-ColorLine ""
}

function Open-DocksOddityShop {
    param($Game)

    Show-DocksOddityShopDiscovery -Game $Game
    $Game.Town.StoryFlags["DocksOddityShopVisited"] = $true
    Open-TownSellMenu -Game $Game -Hero $Game.Hero -BuyerType "DocksideOddities" -ExitLabel "Back to the docks"
}

function Get-DocksMonsterOddityHaul {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return [PSCustomObject]@{
            Count = 0
            TotalValue = 0
            Names = @()
            HasDraconicOddity = $false
        }
    }

    Initialize-MonsterZoneState -Game $Game

    $oddities = @($Game.Town.MonsterZone.Oddities)
    $totalValue = 0
    $names = @()
    $hasDraconicOddity = $false

    foreach ($oddity in $oddities) {
        $name = [string]$oddity.Name
        $value = if ($null -ne $oddity.Value) { [int]$oddity.Value } else { 0 }
        $totalValue += $value

        if (-not [string]::IsNullOrWhiteSpace($name)) {
            $names += $name
        }

        if ($name -like "*Scale*" -or $name -like "*Ash-Horn*" -or $name -like "*Gate-Bone*") {
            $hasDraconicOddity = $true
        }
    }

    return [PSCustomObject]@{
        Count = $oddities.Count
        TotalValue = $totalValue
        Names = $names
        HasDraconicOddity = $hasDraconicOddity
    }
}

function Resolve-DocksMonsterOdditySale {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Hero) {
        return [PSCustomObject]@{
            Success = $false
            Count = 0
            TotalCopper = 0
            Message = "There is no monster oddity haul to settle."
        }
    }

    Initialize-MonsterZoneState -Game $Game
    $haul = Get-DocksMonsterOddityHaul -Game $Game

    if ($haul.Count -le 0) {
        return [PSCustomObject]@{
            Success = $false
            Count = 0
            TotalCopper = 0
            Message = "Auntie Brindle pats an empty crate. 'Bring me something with teeth, dear, then we will talk coin.'"
        }
    }

    $totalCopper = [Math]::Max(1, [int]$haul.TotalValue)
    Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $totalCopper | Out-Null

    $Game.Town.MonsterZone.Oddities = @()
    $Game.Town.StoryFlags["DocksMonsterOdditiesDelivered"] = $true
    $Game.Town.Relationships["AuntieBrindle"] = "Monster Oddity Buyer"

    if ($null -eq $Game.Town.StreetFlags["DocksMonsterOddityDeliveries"]) {
        $Game.Town.StreetFlags["DocksMonsterOddityDeliveries"] = 0
    }

    if ($null -eq $Game.Town.StreetFlags["DocksMonsterOddityCopperTotal"]) {
        $Game.Town.StreetFlags["DocksMonsterOddityCopperTotal"] = 0
    }

    $Game.Town.StreetFlags["DocksMonsterOddityDeliveries"] = [int]$Game.Town.StreetFlags["DocksMonsterOddityDeliveries"] + 1
    $Game.Town.StreetFlags["DocksMonsterOddityCopperTotal"] = [int]$Game.Town.StreetFlags["DocksMonsterOddityCopperTotal"] + $totalCopper

    if ($haul.HasDraconicOddity) {
        $Game.Town.StoryFlags["DocksDraconicOddityNoted"] = $true
    }

    $sampleText = if (@($haul.Names).Count -gt 0) { @($haul.Names)[0] } else { "monster salvage" }
    $draconicText = if ($haul.HasDraconicOddity) { " Mira Kest asks for a note in Veyra's ledger before the crate leaves the table." } else { "" }

    return [PSCustomObject]@{
        Success = $true
        Count = [int]$haul.Count
        TotalCopper = $totalCopper
        Names = @($haul.Names)
        HasDraconicOddity = [bool]$haul.HasDraconicOddity
        Message = "Auntie Brindle sorts $($haul.Count) monster oddity bundle(s), starting with $sampleText, and pays $(Convert-CopperToCurrencyText -Copper $totalCopper).$draconicText"
    }
}

function Discover-DocksTallyShack {
    param($Game)

    if (-not (Test-DocksOddityShopVisited -Game $Game)) {
        Write-Scene "The black-contract trail keeps slipping away until {hero} has taken a proper look at Auntie Brindle's shelves. In the docks, even rubbish has witnesses."
        Write-ColorLine ""
        return
    }

    if (Test-DocksTallyShackDiscovered -Game $Game) {
        Write-Scene "Auntie Brindle has already pointed {hero} toward the tide-ledger shack and its too-careful wharf boss."
        Write-ColorLine ""
        return
    }

    $Game.Town.StoryFlags["DocksTallyShackDiscovered"] = $true
    Write-SectionTitle -Text "The Wax in the Rubbish" -Color "Yellow"
    Write-TownTimeTracker -Game $Game -Area "Docks" -HeroHP $Game.Hero.HP
    Write-Scene "Auntie Brindle plucks a black wax fleck from a tray of broken seals, fish hooks, and things with too many tiny teeth."
    Write-Scene "'This was not thrown away by accident,' she says, suddenly less mad than she looked a breath ago. 'Tide-ledger wax. Wharf boss wax. Men use it when cargo needs to look boring.'"
    Write-Scene "She points with a knitting needle toward a damp tally shack beyond the salvage stairs. 'Start there. Then the docks will show you the next ugly little room.'"
    Write-EmphasisLine -Text "New Docks Area: the Tide-Ledger Shack is now open as the next step in Lady Veyra's contract trail." -Color "Yellow"
    Write-ColorLine ""
}

function Show-DocksAreaScene {
    param(
        $Game,
        [string]$Area
    )

    Write-SectionTitle -Text $Area -Color "Yellow"
    Write-TownTimeTracker -Game $Game -Area "Docks" -HeroHP $Game.Hero.HP

    switch ($Area) {
        "Tide-Ledger Shack" {
            Write-Scene "The tide-ledger shack sweats ink and river damp. Clerks pretend to count ordinary freight while runners linger just long enough to hear which names are dangerous today."
            Write-Scene "A black wax tray sits cleaner than the desk around it. Someone has started hiding the interesting records better since Marris Vane fell."
        }
        "Warehouse Row" {
            Write-Scene "Warehouse Row is a canyon of rope, tarps, stacked crates, and men who stop talking when the wrong boots hit the boards."
            Write-Scene "By day it smells of pitch and wet canvas. By night every locked door feels like it is listening."
        }
        "Old Knife Berth" {
            Write-Scene "The old knife berth is quieter than it should be. Nets hang like curtains, gulls pick at the pilings, and every shadow looks recently rented."
            Write-Scene "Marris Vane's people are gone, but the berth still remembers how contracts changed hands here."
        }
        default {
            Write-Scene "The Rag-and-Bone Teapot clatters softly under the salvage stairs. Auntie Brindle's blue bottle-lamps make even rubbish look like evidence waiting for the right question."
        }
    }

    Write-ColorLine ""
}

function Start-DocksDistrictMenu {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$ReturnLabel = "Back to seek work"
    )

    Show-DocksOddityShopDiscovery -Game $Game

    while ($true) {
        Write-SectionTitle -Text "Docks" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Docks" -HeroHP $HeroHP.Value
        Write-Scene (Get-ClassAwareTownText -Hero $Game.Hero `
            -BarbarianText "The docks do not open all at once for Borzig. They show one useful crack at a time: a junk shop first, then whispers, then doors with heavier locks." `
            -BardText "The docks do not open all at once for Gariand. They reveal themselves like a crooked song: one odd shop, one useful name, one dangerous refrain at a time.")
        Write-EmphasisLine -Text (Get-DocksDistrictProgressText -Game $Game) -Color "Yellow"
        $isOpenDistrict = Test-DocksDistrictOpenToTown -Game $Game
        Write-ColorLine ""
        Write-ColorLine "1. Visit Auntie Brindle's Rag-and-Bone Teapot" "White"
        if ($isOpenDistrict) {
            Write-ColorLine "2. Revisit the Tide-Ledger Shack" "White"
            Write-ColorLine "3. Walk Warehouse Row" "White"
            Write-ColorLine "4. Check the Old Knife Berth" "White"
            Write-ColorLine "5. Meet Mira Kest for Lady Veyra's dock leads" "White"
        }
        else {
            if (Test-DocksTallyShackDiscovered -Game $Game) {
                Write-ColorLine "2. Follow the black wax mark to the Tide-Ledger Shack" "White"
            }
            elseif (Test-DocksOddityShopVisited -Game $Game) {
                Write-ColorLine "2. Ask Auntie Brindle about the black wax clue" "White"
            }
            else {
                Write-ColorLine "2. Follow Lady Veyra's black-contract lead (start with Auntie Brindle first)" "DarkGray"
            }
            if ([bool]$Game.Town.StoryFlags["NamedVeyraContractBroker"]) {
                Write-ColorLine "3. Recheck Warehouse Row and the broker's old berth" "White"
            }
        }
        if ([bool]$Game.Town.StoryFlags["HigherPatronSuspected"]) {
            Write-ColorLine "6. Study the shell-charter trail above the docks" "White"
        }
        $monsterOddityHaul = Get-DocksMonsterOddityHaul -Game $Game
        if ($monsterOddityHaul.Count -gt 0) {
            Write-ColorLine "7. Deliver monster-zone oddities to Auntie Brindle" "White"
        }
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. $ReturnLabel" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Open-DocksOddityShop -Game $Game
            }
            "2" {
                if ($isOpenDistrict) {
                    Show-DocksAreaScene -Game $Game -Area "Tide-Ledger Shack"
                    continue
                }

                if (-not (Test-DocksTallyShackDiscovered -Game $Game)) {
                    Discover-DocksTallyShack -Game $Game
                    continue
                }

                Show-TownQuestSource -Title "Docks" -IntroText "Beyond Auntie Brindle's impossible shelves, wet planks, shouted cargo counts, and paid dockside silence make the river quarter feel like its own city. If someone hired a knife against Lady Veyra, the tide may have carried the name here." -Source "Docks" -Game $Game -HeroHP $HeroHP
            }
            "3" {
                if ($isOpenDistrict) {
                    Show-DocksAreaScene -Game $Game -Area "Warehouse Row"
                    continue
                }

                if (-not [bool]$Game.Town.StoryFlags["NamedVeyraContractBroker"]) {
                    Write-ColorLine "Warehouse Row has not opened up yet." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Write-Scene "Warehouse Row is louder now that Marris Vane's name is loose. Every shut door feels like it knows which clerk paid too much for silence."
                Write-ColorLine ""
            }
            "4" {
                if ($isOpenDistrict) {
                    Show-DocksAreaScene -Game $Game -Area "Old Knife Berth"
                    continue
                }

                Write-ColorLine "The shell-charter trail has not opened yet." "DarkYellow"
                Write-ColorLine ""
            }
            "5" {
                if (-not $isOpenDistrict) {
                    Write-ColorLine "The docks are not open enough for that lead yet." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Show-TownQuestSource -Title "Mira Kest's Dock Leads" -IntroText "Mira Kest waits where rope shadow hides Lady Veyra's seal inside a ledger strap. Now that the river quarter is open, she can turn smaller sounds into work: who gets credit, who pays debt, who receives protection, and who never has to touch the knife they bought." -Source "Docks" -Game $Game -HeroHP $HeroHP
            }
            "6" {
                if (-not [bool]$Game.Town.StoryFlags["HigherPatronSuspected"]) {
                    Write-ColorLine "The trail has not climbed above the docks yet." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Write-Scene "The shell-charter marks point away from rope, tar, and warehouse ledgers toward cleaner hands higher in the city."
                Write-ColorLine ""
            }
            "7" {
                $sale = Resolve-DocksMonsterOdditySale -Game $Game
                Write-Scene $sale.Message
                Write-ColorLine ""
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
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

function Get-ClassAwareTownText {
    param(
        $Hero,
        [string]$BarbarianText,
        [string]$BardText,
        [string]$FighterText = ""
    )

    $selectedText = $BarbarianText

    if ($null -ne $Hero -and $Hero.Class -eq "Bard" -and -not [string]::IsNullOrWhiteSpace($BardText)) {
        $selectedText = $BardText
    }
    elseif ($null -ne $Hero -and $Hero.Class -eq "Fighter" -and -not [string]::IsNullOrWhiteSpace($FighterText)) {
        $selectedText = $FighterText
    }

    if ($null -ne $Hero -and $null -ne $Hero.PSObject.Properties["Name"] -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Name)) {
        $selectedText = $selectedText.Replace("Borzig", [string]$Hero.Name).Replace("Gariand", [string]$Hero.Name)
    }

    return (Resolve-HeroNarrativeText -Text $selectedText -Hero $Hero)
}

function Get-TownShopIntroText {
    param(
        [string]$Shop,
        $Hero,
        $Game = $null
    )

    $isNight = $null -ne $Game -and (Get-TownTimeOfDay -Game $Game) -eq "Night"

    switch ($Shop) {
        "Market" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "Most of the market has shuttered for the night. A few stubborn traders still work by lantern light, selling travel gear and necessities to anyone desperate enough to pay after dusk." `
                    -BardText "Most of the market has gone dark, but a few lantern-lit stalls still linger for late coin, hurried repairs, and performers who know night crowds buy differently than day ones." `
                    -FighterText "Most of the market has shuttered for the night, but a few lantern-lit traders still recognize Lubert Stryer as the sort of armed customer who buys rope, polish, and practical kit before a formal morning.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Canvas stalls crowd the square. Traders wave Borzig over with travel gear, blades, and battered adventuring stock. More than one set of eyes lingers on the weathered state of Borzig's older kit." `
                -BardText "Canvas stalls crowd the square. Traders call Gariand over with travel gear, strings, ribbons, lamp oil, and opportunistic smiles. The market reads him as the sort of traveler who can turn polish and timing into coin if his kit is worthy of the room." `
                -FighterText "Canvas stalls crowd the square. Traders point Lubert Stryer toward oilcloth, straps, whetstones, and the sort of careful kit that makes a shield arm look reliable before anyone sees it tested.")
        }
        "Smithy" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "The forge burns lower at night, but not cold. Steel still glows in the coals while the smith works the kind of late orders that never wait for morning." `
                    -BardText "The forge runs on lower light now, all banked coals and sharp reflections. Even at night, the smith's eye still goes first to buckles, light armor, and gear that has to survive hard use without looking clumsy." `
                    -FighterText "The forge burns lower at night, but Lubert Stryer can still see the better longswords kept away from the common rack. The smith talks less like a trader and more like a man measuring a future knight.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Heat and sparks pour from the forge while the smith sizes Borzig up like a problem that can be solved with steel. The look he gives Borzig's older weaponry suggests he has already judged it rough, serviceable, and overdue for replacement." `
                -BardText "Heat and sparks pour from the forge while the smith judges Gariand with a craftsman's patience. Even here the eye goes first to buckles, light armor, and anything that might keep a quick-handed performer alive without ruining his poise." `
                -FighterText "Heat and sparks pour from the forge while the smith looks Lubert Stryer over like a man already picturing a better blade. Shortsword and round shield will do for a first road, but the longsword rack keeps catching the eye.")
        }
        "Apothecary" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "The apothecary keeps a quieter night counter for travelers, watchmen, and anyone trying to look less injured than they are. The room smells stronger of tonic, clove, and clean linen after dark." `
                    -BardText "The apothecary speaks softer at night, serving bruised guards, late travelers, and performers trying to keep a long evening from showing too clearly on the face." `
                    -FighterText "The apothecary keeps a quieter night counter for travelers, watchmen, and duelists who know discipline still needs clean bandages by morning.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Glass vials glimmer behind the counter as the apothecary speaks in a low voice about wounds, nerves, and battle tonic. Even here, Borzig's cave-worn gear draws a faintly disapproving glance whenever old blood and rust get too close to the glass." `
                -BardText "Glass vials glimmer behind the counter as the apothecary speaks softly about calm hands, clear breath, steady nerves, and keeping a performer on his feet after a hard night. Gariand's road-worn kit earns a measured glance, but less judgment than practical advice." `
                -FighterText "Glass vials glimmer behind the counter as the apothecary speaks about bruises, clean stitching, and steady hands. Lubert Stryer's mail earns the practical look usually saved for people expected to stand upright after impact.")
        }
        "Instrument Shop" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "The instrument shop is half-closed for the night, but warm workshop light still spills across polished wood and hanging strings. Someone here clearly trusts evening repairs more than morning promises." `
                    -BardText "The instrument maker works by lamplight now, listening to wood and strings in the hush after the city's louder rooms have filled. It feels less like a shop and more like a backstage confession." `
                    -FighterText "The instrument shop is half-closed for the night, but the old marching drums and courtly horns still catch Lubert Stryer's eye like reminders that public courage often needs a sound to march behind.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "The instrument maker's walls are hung with lutes, fiddles, reeds, and half-finished bodies of polished wood. Borzig gets a wary craftsman's look, the sort usually reserved for men who might carry a lute by the neck instead of the case." `
                -BardText "The instrument maker's walls are hung with lutes, fiddles, reeds, and half-finished bodies of polished wood. Gariand is measured first by ear, then by posture, then by the condition of the instrument already at his side." `
                -FighterText "The instrument maker's walls are hung with lutes, horns, and old marching drums. Lubert Stryer is not the usual customer, but the shopkeeper still understands that banners, ballads, and battlefield rhythm all make reputations travel.")
        }
        "Armorer" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "The armorer keeps late hours for people expecting trouble before dawn. Leather, mail, and oiled straps hang heavy in the lamplight, all of it meant for work rather than display." `
                    -BardText "At night the armorer feels more private, all lamplight on buckles, rivets, and fitted coats. The room has the calm patience of someone who knows last-minute protection sells best after dark." `
                    -FighterText "The armorer's hall is half-shadowed, but the mail and shields still catch the lamplight. Lubert Stryer can feel the room selling not just protection, but station.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "Leather, chain, buckles, and heavy stitched coats line the armorer's walls. The room smells of oil, wool, and old campaigns, and Borzig is judged like someone who might finally be worth fitting properly." `
                -BardText "Leather, chain, buckles, and fitted coats line the armorer's walls. Even here the eye goes toward mobility, silhouette, and whether Gariand wants protection that still lets him move like a performer instead of a tower shield." `
                -FighterText "Mail, shields, fitted straps, and heavier coats line the armorer's walls. Lubert Stryer's round shield earns a nod, but the squire mail is clearly what the room wants him to become.")
        }
        "Stable" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Hero `
                    -BarbarianText "The stable yard is mostly dark now. A few lanterns burn over straw, tack hooks, and sleepy animals, but no sensible dealer writes fresh bills of sale after midnight." `
                    -BardText "The stable yard has gone quiet except for hooves shifting in straw and a groom humming under his breath. Daylight is better for judging animals, prices, and lies." `
                    -FighterText "The stable yard is quiet enough that Lubert Stryer can hear leather creak from the tourney tack. No dealer wants to sell a future jousting horse under bad lantern light.")
            }

            return (Get-ClassAwareTownText -Hero $Hero `
                -BarbarianText "The stable yard smells of hay, leather, warm animal breath, and road mud. Pack goats, donkeys, mules, and riding horses wait under the eye of a dealer who knows the monster roads will need carriers as much as courage." `
                -BardText "The stable yard is all bridles, bargaining, and animals with more opinions than most tavern audiences. Pack animals promise a practical future: odd monster bits hauled home for the docks instead of left in the dirt." `
                -FighterText "The stable yard has pack animals for hard roads, but Lubert Stryer's eye keeps finding the riding horses. A proper mount is not knighthood yet, but it is one of the doors.")
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
    $tier = Get-CurrentStoryQuestTier -Game $Game
    $openingLeadsComplete = Test-OpeningGuardAndPatronLeadsComplete -Game $Game

    switch ($Source) {
        "Guard Station" {
            if ($tier -eq 1 -and -not $openingLeadsComplete -and -not $hasClerkLead -and -not $hasBrokerLead) {
                return "The watch is chasing patrol breaks, sealed grates, and movement under the streets. Halden's people do not yet have the clerk's storehouse ledgers, so this still looks like a guard problem rather than half of a shared investigation."
            }

            if ($hasClerkLead -and $hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch is no longer working blind. Halden's people are comparing patrol reports against the clerk's ledger trail and the river-quarter whispers Borzig keeps bringing in." `
                    -BardText "The watch is no longer working blind. Halden's people are comparing patrol reports against the clerk's ledger trail and the river-quarter whispers Gariand has been carrying between rooms that normally never speak to one another." `
                    -FighterText "The watch is no longer working blind. Halden's people are comparing patrol reports against the clerk's ledger trail and the river-quarter whispers Lubert Stryer keeps turning into orderly proof.")
            }

            if ($hasClerkLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch hall feels tighter now. Someone inside has started taking the merchant clerk's paper trail seriously, even if no one says so loudly." `
                    -BardText "The watch hall feels tighter now. Someone inside has started taking the merchant clerk's paper trail seriously, and Gariand can hear how carefully the guards choose their words around it." `
                    -FighterText "The watch hall feels tighter now. Someone inside has started taking the merchant clerk's paper trail seriously, and Lubert Stryer can see which reports are becoming orders.")
            }

            if ($hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The guards pretend they are only following patrol work, but Borzig can tell the river-quarter whispers have reached this hall already." `
                    -BardText "The guards pretend they are only following patrol work, but Gariand can tell the river-quarter whispers have reached this hall already. Even here, the city's rumor-song is changing key." `
                    -FighterText "The guards pretend they are only following patrol work, but Lubert Stryer can tell the river-quarter whispers have reached the watch desk and started looking like a route map.")
            }
        }
        "Quest Giver" {
            if ($tier -eq 1 -and -not $openingLeadsComplete -and -not $hasGuardLead -and -not $hasBrokerLead) {
                return "The patron's clerk is following missing stock, locked doors, and careful merchant paperwork. He has not seen enough of the watch's tunnel trouble yet, so the storehouse lead still reads like private merchant damage instead of the other half of the same case."
            }

            if ($hasGuardLead -and $hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk no longer treats this like a private merchant problem. His books, the watch's tunnel reports, and the Bent Nail whispers are all starting to describe the same hidden network." `
                    -BardText "The clerk no longer treats this like a private merchant problem. His books, the watch's tunnel reports, and the Bent Nail whispers Gariand keeps drawing together are all starting to describe the same hidden network." `
                    -FighterText "The clerk no longer treats this like a private merchant problem. His books, the watch's tunnel reports, and the Bent Nail whispers are becoming the sort of civic case Lubert Stryer can carry without looking like hired muscle.")
            }

            if ($hasGuardLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk keeps one eye on his papers and one on the watch. Whatever Borzig brought back from the patrols has made these ledgers feel more dangerous." `
                    -BardText "The clerk keeps one eye on his papers and one on the watch. Whatever Gariand has coaxed out of patrol routes and tense conversations has made these ledgers feel more dangerous." `
                    -FighterText "The clerk keeps one eye on his papers and one on the watch. Whatever Lubert Stryer brought back from patrol routes has made these ledgers read less like commerce and more like duty.")
            }

            if ($hasBrokerLead) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The clerk speaks like a careful man who has realized his ledgers are brushing up against the same river-quarter names Borzig hears in rougher rooms." `
                    -BardText "The clerk speaks like a careful man who has realized his ledgers are brushing up against the same river-quarter names Gariand hears in rougher rooms and better salons alike." `
                    -FighterText "The clerk speaks like a careful man who has realized his ledgers are brushing up against the same river-quarter names Lubert Stryer has started treating like formal charges.")
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

function Get-TownQuestSourceDisplayTitle {
    param(
        [string]$Source,
        $Game
    )

    if ($Source -eq "Quest Giver" -and
        $null -ne $Game -and
        $null -ne $Game.Town -and
        [bool]$Game.Town.StoryFlags["BenefactorRevealed"]) {
        return "High Ledger Office"
    }

    return $Source
}

function Show-PostUnderstreetHook {
    param($Game)

    if (-not $Game.Town.ChapterTwoComplete -or $Game.Town.ChapterThreeHookSeen) {
        return
    }

    $heroName = $Game.Hero.Name

    Write-SectionTitle -Text "Aftermath" -Color "Green"
    Write-Scene "Word spreads faster than $heroName expected. By dawn, half the city knows the hidden route under the ward has been broken open."
    Write-Scene "Captain Halden sends quiet thanks. Merchants start asking what else was hidden below. The wrong people are suddenly too silent."
    Write-Scene "And in more than one district, $heroName hears the same uneasy thought repeated in different words: if the understreet was only one branch, what larger hand planted it here?"
    Write-EmphasisLine -Text "New Chapter Hook: $heroName's victory under the city has exposed a wider network still worth hunting." -Color "Yellow"
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
    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"
    $docksContactName = Get-DocksContactName

    if ($isNight -and -not $isRepeatVisit) {
        switch ($Source) {
            "Quest Board" {
                $Game.Town.StreetFlags[$visitKey] = $true
                return "Pinned notices stir in the lantern-draft, half public work and half quiet desperation. By night, even the ordinary jobs look like they might lead somewhere sharper."
            }
            "Guard Station" {
                $Game.Town.StreetFlags[$visitKey] = $true
                return "Lanterns burn low over the watch desks while runners, tired guards, and half-finished reports keep the hall alive. This is the city's harder face, the one it shows after dark."
            }
            "Quest Giver" {
                $Game.Town.StreetFlags[$visitKey] = $true
                return "The patron's clerk keeps the ledgers close and his voice lower than usual. Night work in this office feels less like posting jobs and more like choosing who can be trusted with quiet damage."
            }
            "Docks" {
                $Game.Town.StreetFlags[$visitKey] = $true
                return "Lanterns sway over wet pilings and tar-black water while $docksContactName waits with Lady Veyra's quiet seal tucked out of sight. The air tastes of salt, rope, and the kind of paid silence Veyra needs broken."
            }
        }
    }

    if ($Game.Town.ChapterTwoComplete) {
        switch ($Source) {
            "Quest Board" {
                if ($isNight) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "Fresh notices rustle under lantern light now that Borzig's name carries more weight. Night jobs, private coin, and uglier requests seem to surface after dark." `
                        -BardText "Fresh notices rustle under lantern light now that Gariand's name carries more weight. By night, the board reads less like public work and more like whispered opportunities pinned in plain sight." `
                        -FighterText "Fresh notices rustle under lantern light now that Lubert Stryer's name carries more weight. By night, even small jobs read like chances to prove discipline where the city can see it.")
                }

                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "Fresh notices have started appearing now that Borzig's name carries more weight. Some want coin-work. Some want the man who broke the understreet to look into worse things." `
                    -BardText "Fresh notices have started appearing now that Gariand's name carries more weight. Some want coin-work. Some want the man who sang his way through closed rooms and walked back out of the understreet to look into worse things." `
                    -FighterText "Fresh notices have started appearing now that Lubert Stryer's name carries more weight. Some want coin-work. Some want disciplined steel that can make civic trouble look orderly again.")
            }
            "Guard Station" {
                if ([bool]$Game.Town.StoryFlags["MonsterWallRumorsStarted"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The watch hall has a new board beside the old patrol ledgers: outer-gate scratches, missing road markers, and wall-watch reports from guards who no longer laugh at monster stories. Borzig's work beyond the wall can turn that fear into proof." `
                        -BardText "The watch hall has a new board beside the old patrol ledgers: outer-gate scratches, witness fragments, and wall-watch reports that sound too similar to be coincidence. Gariand's work beyond the wall can turn fear into a story precise enough to act on." `
                        -FighterText "The watch hall has a new board beside the old patrol ledgers: outer-gate scratches, weak sightlines, and wall-watch reports from guards trying to hold a line they cannot fully see. Lubert Stryer's work beyond the wall can turn those reports into a defensible pattern.")
                }

                if ([bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The watch hall is crowded with Civic Keep witnesses, repair orders, and guards angry enough to stop whispering. Halewick was exposed in public, became something draconic, and escaped over stone the watch was sworn to hold." `
                        -BardText "The watch hall is crowded with Civic Keep witnesses, repair orders, and guards trying to make one official truth out of a dozen terrified versions. Halewick was exposed in public, became something draconic, and escaped over a city that still has to name what it saw." `
                        -FighterText "The watch hall is crowded with Civic Keep witnesses, repair orders, and sightline sketches. Halewick was exposed in public, became something draconic, and escaped through a defense failure no disciplined guard can ignore.")
                }

                if ($isNight) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The watch hall runs sharper at night. Runners come faster, tired guards speak lower, and the jobs left on the table feel closer to real trouble." `
                        -BardText "The watch hall runs sharper at night. Orders move in clipped voices, lanterns burn low over the desks, and even the guards who distrust polish know Gariand belongs where the city's after-dark truth starts surfacing.")
                }

                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The watch hall changes tone when Borzig enters now. Some guards step aside out of respect, and the harder jobs are no longer hidden from him." `
                    -BardText "The watch hall changes tone when Gariand enters now. Some guards still distrust a polished tongue, but none of them mistake him for a lightweight anymore, and the harder jobs are no longer hidden from him.")
            }
            "Quest Giver" {
                if ([bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "Lady Veyra's High Ledger office feels like the still point inside a city-wide alarm. Clerks sort witness names, sealed proof, and Halewick's vanished flight path while Borzig's part in the exposure is no longer deniable." `
                        -BardText "Lady Veyra's High Ledger office feels like the still point inside a city-wide alarm. Clerks sort witness names, sealed proof, and Halewick's vanished flight path while Gariand can hear a terrified city trying to decide which version of the truth survives." `
                        -FighterText "Lady Veyra's High Ledger office feels like the still point inside a city-wide alarm. Clerks sort witness names, sealed proof, and Halewick's vanished flight path while Lubert Stryer can feel every noble eye measuring who held discipline when the court broke.")
                }

                if ([bool]$Game.Town.StoryFlags["BenefactorRevealed"]) {
                    if ($isNight) {
                        return (Get-ClassAwareTownText -Hero $Game.Hero `
                            -BarbarianText "The clerk's office now wears Lady Veyra's hidden seal openly after dark. Every whispered job feels tied to council ledgers, dangerous debts, and enemies who learned Borzig is hard to remove." `
                            -BardText "The clerk's office now wears Lady Veyra's hidden seal openly after dark. Every whispered job sounds like a verse from a higher, colder song: council ledgers, dangerous debts, and enemies who learned Gariand is hard to silence.")
                    }

                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The Quest Giver is no longer just a seal and a careful clerk. Lady Veyra of the High Ledger has a name in Borzig's story now, and her office feels like a door into the city's upper machinery." `
                        -BardText "The Quest Giver is no longer just a seal and a careful clerk. Lady Veyra of the High Ledger has a name in Gariand's story now, and her office feels like a stage door into the city's upper machinery.")
                }

                if ($isNight) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The patron's clerk looks more guarded at night, as if every ledger opened after dusk carries extra risk. The work offered now feels quieter, more deliberate, and less deniable." `
                        -BardText "The patron's clerk looks more guarded at night, counting doors, voices, and witnesses before he says much. The work offered after dusk feels meant for someone who can move carefully between trust and leverage.")
                }

                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The patron's clerk has stopped treating Borzig like hired muscle. Now the work is more careful, more valuable, and rarely clean." `
                    -BardText "The patron's clerk has stopped treating Gariand like charming decoration. Now the work is more careful, more valuable, and offered with the uneasy respect reserved for someone who can move between ledgers, guard posts, and whispered rooms.")
            }
            "Docks" {
                if ([bool]$Game.Town.StoryFlags["LordHalewickEscaped"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The docks have become a rumor engine. Crews swear they saw Halewick's small dragon shape over the Civic Keep, and $docksContactName is already turning frightened sailor-talk into possible escape routes." `
                        -BardText "The docks have become a rumor engine. Every crew has a different song for Halewick's small dragon shape over the Civic Keep, and $docksContactName is already listening for the verse that names his escape route." `
                        -FighterText "The docks have become a rumor engine. Crews swear they saw Halewick's small dragon shape over the Civic Keep, and $docksContactName is sorting sailor panic into routes, witnesses, and defensible pursuit lines.")
                }

                if ([bool]$Game.Town.StoryFlags["DocksOrganizationProfiled"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "$docksContactName has helped Borzig see the machine under the docks: false freight, debt hooks, blackmail books, and knives waiting behind paperwork." `
                        -BardText "$docksContactName has helped Gariand hear the ugly chords under the docks: false freight, debt hooks, blackmail books, and knives waiting behind paperwork.")
                }

                if ([bool]$Game.Town.StoryFlags["DocksFirstChainComplete"]) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The docks are open to Borzig now, but $docksContactName gives the danger a shape. Auntie Brindle watches the salvage stairs, Warehouse Row keeps its doors heavy, and each new lead comes through Veyra's dock contact." `
                        -BardText "The docks are open to Gariand now, but $docksContactName gives the danger a rhythm. Auntie Brindle watches the salvage stairs, Warehouse Row keeps its doors heavy, and each new lead comes through Veyra's dock contact.")
                }

                if ($isNight) {
                    return (Get-ClassAwareTownText -Hero $Game.Hero `
                        -BarbarianText "The docks wake into their truer life after dark. Lantern crews, smugglers, brokers, and hired knives all move under the same ropes, and Borzig has come looking for whoever carried Lady Veyra's death warrant down here." `
                        -BardText "The docks wake into their truer life after dark. Lantern crews, smugglers, brokers, and paid silence all share the same tide, and Gariand has come looking for whoever turned Lady Veyra's murder into dockside business.")
                }

                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "By daylight the docks look almost honest: cargo cranes, shouting crews, and ledgers gone damp with spray. But after Lady Veyra's reveal, Borzig knows this is where contracts, cargo, and fear touch the same rope." `
                    -BardText "By daylight the docks look almost honest: shouted tallies, wet ledgers, and crews pretending not to notice who pays for quiet. After Lady Veyra's reveal, Gariand can hear how much of the city's hidden music starts here.")
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
        "Quest Board" {
            if ($isNight) {
                return "The board looks different by lantern light. Public notices remain, but the jobs that stand out after dark are the ones ordinary folk do not want overheard."
            }

            return "The board looks thinner now, but there is still work on it for anyone willing to take the coin."
        }
        "Guard Station" {
            if ($isNight) {
                return "The watch hall has shifted into its night rhythm. Hard jobs are passed quietly from one tired hand to the next, and nobody wastes words they do not need."
            }

            return "The watch hall is busier than it looks. Hard jobs are passed quietly from one tired hand to the next."
        }
        "Quest Giver" {
            if ($isNight) {
                return (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "The patron's clerk recognizes Borzig now and keeps his night work short, private, and expensive." `
                    -BardText "The patron's clerk recognizes Gariand now and slips into a lower, tighter tone fit for work discussed after dark.")
            }

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

    $showIntro = $true

    while ($true) {
        $quests = @(Get-TownQuestList -Game $Game -Source $Source)
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area $Title -HeroHP $HeroHP.Value
        if ($showIntro) {
            Write-TownLocationIntro `
                -Game $Game `
                -Key (Get-TownFlavorVisitKey -Prefix "QuestSource" -Name $Source) `
                -FullText (Get-TownQuestSourceIntroText -Source $Source -DefaultIntroText $IntroText -Game $Game) `
                -RepeatText (Get-TownQuestSourceRepeatIntroText -Source $Source -Game $Game)
            $showIntro = $false
        }
        Write-ColorLine ""

        $tierStatus = if ($Source -eq "Docks") { Get-DocksTierProgressStatus -Game $Game } else { Get-StoryTierProgressStatus -Game $Game }
        Write-EmphasisLine -Text $tierStatus.StatusText -Color "Yellow"
        Write-ColorLine ""

        if ($Game.Town.StoryQuestDoneToday) {
            Write-EmphasisLine -Text "$($Game.Hero.Name) has already pushed the main story forward today. Another story quest must wait until tomorrow." -Color "DarkYellow"
        }

        if ($Game.Town.DayJobDoneToday) {
            Write-EmphasisLine -Text "$($Game.Hero.Name) has already taken one paid side job today." -Color "DarkYellow"
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
            $tierText = Get-TownQuestTierSuffix -Quest $quest
            $dayJobText = if ($quest.QuestType -eq "DayJob") { " | Step $(Get-DayJobStep -Quest $quest) | Level $(Get-DayJobRequiredHeroLevel -Quest $quest)+" } else { "" }
            $timeText = Get-TownQuestRequiredTimeOfDay -Quest $quest
            Write-ColorLine "   Type: $($quest.QuestType)$tierText$dayJobText" "DarkGray"
            if (-not [string]::IsNullOrWhiteSpace($timeText)) {
                Write-ColorLine "   Time: $timeText" "DarkGray"
            }
            Write-ColorLine "   $($quest.Description)" "DarkGray"
            Write-ColorLine "   Reward: $(Get-QuestRewardText -Quest $quest -Game $Game)" "DarkGray"
        }

        Write-ColorLine ""
        Write-ColorLine "0. Back to seek work" "DarkGray"
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

function Wait-For-Nightfall {
    param($Game)

    if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
        Write-Scene "Night already hangs over the city."
        Write-ColorLine ""
        return
    }

    Set-TownTimeOfDay -Game $Game -TimeOfDay "Night"
    Write-Scene "$($Game.Hero.Name) lets the bright edge of the day burn down into lantern light, shuttered stalls, and the slower dangers that only wake after dusk."
    Write-ColorLine ""
}

function Test-TownActionAvailableAtCurrentTime {
    param(
        $Game,
        [string]$Action
    )

    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

    switch ($Action) {
        "Market" { return -not $isNight }
        "Smithy" { return -not $isNight }
        "Armorer" { return -not $isNight }
        "Stable" { return -not $isNight }
        "Ring" { return $isNight }
        "Performance" { return $isNight }
        default { return $true }
    }
}

function Get-TownActionUnavailableText {
    param(
        $Game,
        [string]$Action
    )

    switch ($Action) {
        "Market" { return "Most of the market has shuttered for the night. The real trade there will have to wait for morning." }
        "Smithy" { return "Rurik's main forge business is done for the night. Serious smithing waits for daylight." }
        "Armorer" { return "The armorer has closed up for the night, leaving only measured lamplight behind the shutters." }
        "Stable" { return "The stable yard has settled for the night. Buying animals waits for daylight, when teeth, legs, tack, and temper can be judged properly." }
        "Ring" { return "The fighting ring does not truly wake until after dark, when the wagers start moving faster than the greetings." }
        "Performance" { return "$($Game.Hero.Name) can work a room for coin, but this city pays best for performances once the evening crowd has gathered." }
        default { return "That part of the city is not moving at this hour." }
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
        Write-TownTimeTracker -Game $Game -Area "Quest Preparation" -HeroHP $HeroHP.Value
        Write-Scene (Get-ClassAwareTownText -Hero $Game.Hero `
            -BarbarianText "$($Quest.Name) waits when Borzig is ready. He can make final adjustments before stepping out." `
            -BardText "$($Quest.Name) waits when Gariand is ready. He can make final adjustments, steady his nerves, and choose how he wants to carry himself before stepping out.")
        Write-ColorLine "Quest: $($Quest.Name)" "White"
        Write-ColorLine "Objective: $($Quest.Objective)" "DarkGray"
        Write-ColorLine "Reward: $(Get-QuestRewardText -Quest $Quest -Game $Game)" "DarkGray"
        Write-ColorLine ""
        Write-ColorLine "1. Start the quest now" "White"
        Write-ColorLine "2. Check inventory and gear" "White"
        Write-ColorLine "3. Check quest log" "White"
        Write-ColorLine "4. Back to town without starting" "White"
        if ($Game.Hero.Class -eq "Bard") {
            $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Game.Hero
            $instrumentName = if ($null -ne $bardicStatus.Instrument) { $bardicStatus.Instrument.Name } else { "your instrument" }
            $invisibilityCheck = Test-HeroCanCastSpell -Hero $Game.Hero -SpellName "Invisibility"
            Write-ColorLine "5. Prepare bardic inspiration with $instrumentName" "White"
            Write-ColorLine "   Current: $($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides)" "DarkGray"
            if ($invisibilityCheck.CanCast) {
                $invisibilityStatus = if ((Get-HeroInvisibilityStealthBonus -Hero $Game.Hero) -gt 0) { "active" } else { "L2 slots $($Game.Hero.CurrentSpellSlots.Level2)/$($Game.Hero.MaxSpellSlots.Level2)" }
                Write-ColorLine "6. Cast Invisibility before danger" "White"
                Write-ColorLine "   Current: $invisibilityStatus" "DarkGray"
            }
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
            "6" {
                if ($Game.Hero.Class -eq "Bard") {
                    $invisibility = Invoke-HeroInvisibility -Hero $Game.Hero
                    Write-Scene $invisibility.Message
                    if ($invisibility.Success) {
                        Write-Action "Invisibility: +$(Get-HeroInvisibilityStealthBonus -Hero $Game.Hero) to Stealth checks. Level 2 slots left: $($invisibility.SlotsRemaining)." "Yellow"
                    }
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

function Get-HeroPublicPerformanceVenue {
    param(
        $Game,
        [string]$VenueId
    )

    $venue = Get-BardPerformanceVenue -VenueId $VenueId

    if ($null -eq $venue -or $null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -eq "Bard") {
        return $venue
    }

    if ($VenueId -ne "market_square") {
        return $null
    }

    switch ($Game.Hero.Class) {
        "Barbarian" {
            return [PSCustomObject]@{
                Id = "market_square"
                Name = "Market Square"
                CheckDC = 12
                IntroText = "The market gives {hero} a wary circle as {he} stamps a hard rhythm into the stones: a stylized war-call of breath, chest, heel, and glare that turns strength into spectacle."
                PoorRewardCopper = 4
                GoodRewardCopper = 10
                GreatRewardCopper = 18
                SuccessText = "The haka-like display catches the square by surprise. A few workers laugh in delight, others clap the rhythm back, and the hat gains honest coin."
                GreatSuccessText = "The whole square falls into the beat. By the final shout, the crowd answers like it has been dared into courage, and the purse comes back heavier than anyone expected."
                FailureText = "The rhythm lands too hard for the market's mood. People give {hero} room, a little coin, and the careful respect owed to someone best not mocked."
            }
        }
        "Fighter" {
            return [PSCustomObject]@{
                Id = "market_square"
                Name = "Market Square"
                CheckDC = 12
                IntroText = "{hero} chooses no tavern stage and no noble room, only the open square. The song is an old war-ballad: low, plain, and melancholy enough to make even busy people remember that history had names."
                PoorRewardCopper = 4
                GoodRewardCopper = 10
                GreatRewardCopper = 18
                SuccessText = "The ballad holds a small crowd in place. Veterans lower their eyes, apprentices stop pretending not to listen, and the coins come softly rather than loudly."
                GreatSuccessText = "The square goes quiet around the old tragedy. When the last line fades, the applause is restrained but real, and the purse fills with the respect of people who understood enough."
                FailureText = "The ballad is too heavy for the market's hurry. A few listeners leave coin out of courtesy, but the square moves on before the sorrow can take root."
            }
        }
    }

    return $null
}

function Start-BardPerformanceCheck {
    param(
        $Game,
        $Venue,
        [int]$CheckDC = 0,
        [string]$Ability = "CHA",
        [string]$CheckTag = "Performance"
    )

    if ($CheckDC -le 0) {
        $CheckDC = [int]$Venue.CheckDC
    }

    $checkProfile = Get-HeroAbilityCheckModifier -Hero $Game.Hero -Ability $Ability -CheckTag $CheckTag
    $instrument = Get-HeroInstrument -Hero $Game.Hero
    $instrumentBonus = if ($null -ne $instrument -and $null -ne $instrument.PSObject.Properties["InspirationBonus"]) { [int]$instrument.InspirationBonus } else { 0 }
    $roll = Roll-Dice -Sides 20
    $bardicBonus = 0

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

    $total = $roll + $checkProfile.TotalModifier + $instrumentBonus + $bardicBonus

    Write-Scene (Resolve-HeroNarrativeText -Text $Venue.IntroText -Hero $Game.Hero)
    $performanceBreakdown = "d20 roll $roll $(Format-AbilityModifier -Modifier $checkProfile.AbilityModifier) + $($checkProfile.ClassBonus) proficiency"

    if ($instrumentBonus -gt 0) {
        $performanceBreakdown += " + $instrumentBonus instrument"
    }

    if ($bardicBonus -gt 0) {
        $performanceBreakdown += " + $bardicBonus inspiration"
    }

    Write-Action "$($Game.Hero.Name) performs: $performanceBreakdown = $total" "Cyan"
    Write-ColorLine ""

    return $total
}

function New-BardPerformanceVenueRecord {
    return @{
        Plays = 0
        Poor = 0
        Good = 0
        Great = 0
        EarningsCopper = 0
        LastOutcome = ""
        LastRewardCopper = 0
    }
}

function Get-BardPerformanceVenueRecord {
    param(
        $Game,
        [string]$VenueId
    )

    if ($null -eq $Game.Town.PerformanceHistory) {
        $Game.Town.PerformanceHistory = @{}
    }

    if ($null -eq $Game.Town.PerformanceHistory[$VenueId]) {
        $Game.Town.PerformanceHistory[$VenueId] = New-BardPerformanceVenueRecord
    }

    $record = $Game.Town.PerformanceHistory[$VenueId]

    foreach ($entry in @(
        @{ Key = "Plays"; Value = 0 },
        @{ Key = "Poor"; Value = 0 },
        @{ Key = "Good"; Value = 0 },
        @{ Key = "Great"; Value = 0 },
        @{ Key = "EarningsCopper"; Value = 0 },
        @{ Key = "LastOutcome"; Value = "" },
        @{ Key = "LastRewardCopper"; Value = 0 }
    )) {
        if ($record -is [hashtable]) {
            if (-not $record.ContainsKey($entry.Key)) {
                $record[$entry.Key] = $entry.Value
            }
        }
        elseif ($null -eq $record.PSObject.Properties[$entry.Key]) {
            $record | Add-Member -NotePropertyName $entry.Key -NotePropertyValue $entry.Value
        }
    }

    return $record
}

function Get-BardPerformanceRecordValue {
    param(
        $Record,
        [string]$Key
    )

    if ($null -eq $Record) {
        return $null
    }

    if ($Record -is [hashtable]) {
        return $Record[$Key]
    }

    if ($null -ne $Record.PSObject.Properties[$Key]) {
        return $Record.$Key
    }

    return $null
}

function Set-BardPerformanceRecordValue {
    param(
        $Record,
        [string]$Key,
        $Value
    )

    if ($Record -is [hashtable]) {
        $Record[$Key] = $Value
        return
    }

    if ($null -eq $Record.PSObject.Properties[$Key]) {
        $Record | Add-Member -NotePropertyName $Key -NotePropertyValue $Value
        return
    }

    $Record.$Key = $Value
}

function Get-BardPerformanceAudienceFamiliarity {
    param($Record)

    $plays = [int](Get-BardPerformanceRecordValue -Record $Record -Key "Plays")
    $poor = [int](Get-BardPerformanceRecordValue -Record $Record -Key "Poor")
    $good = [int](Get-BardPerformanceRecordValue -Record $Record -Key "Good")
    $great = [int](Get-BardPerformanceRecordValue -Record $Record -Key "Great")

    if ($plays -le 0) {
        return "Unknown"
    }

    if ($great -ge 2 -or ($plays -ge 5 -and ($good + $great) -ge 4)) {
        return "Favorite"
    }

    if ($poor -ge 2 -and $great -le 0) {
        return "Shaky"
    }

    if ($plays -ge 2 -or ($good + $great) -ge 1) {
        return "Known"
    }

    return "Tried"
}

function Get-BardPerformanceOutcomeMemoryText {
    param(
        $Game,
        $Venue,
        $Record,
        [string]$Outcome
    )

    $familiarity = Get-BardPerformanceAudienceFamiliarity -Record $Record
    $lastOutcome = [string](Get-BardPerformanceRecordValue -Record $Record -Key "LastOutcome")

    switch ($familiarity) {
        "Unknown" {
            if ($Outcome -eq "Great") {
                return "$($Venue.Name) did not know what to expect from $($Game.Hero.Name). Now it does."
            }

            return ""
        }
        "Shaky" {
            if ($Outcome -eq "Great") {
                return "The room came in ready to doubt him after rougher sets, which makes the turnaround land harder. By the end, the old jokes sound badly out of date."
            }

            if ($Outcome -eq "Good") {
                return "The audience gives $($Game.Hero.Name) cautious credit. They remember the weaker nights, but this one steadies his name."
            }

            return "A few listeners exchange the kind of look that says they have heard this miss before. The coin still comes, but the room keeps its distance."
        }
        "Known" {
            if ($Outcome -eq "Great") {
                return "People who already knew the songs start singing early, and the new listeners follow because the room has clearly decided he belongs here."
            }

            if ($Outcome -eq "Good") {
                return "The familiar faces carry the set through its thinner moments. $($Game.Hero.Name) has enough goodwill here that a good night feels comfortably earned."
            }

            return "The regulars notice the stumble, but they do not turn on him. Familiarity softens the miss, even if the hat comes back lighter."
        }
        "Favorite" {
            if ($Outcome -eq "Great") {
                return "This is the reaction reserved for a favorite: applause arriving before the last note, voices calling for another song, and coin offered like thanks instead of payment."
            }

            if ($Outcome -eq "Good") {
                return "Even a merely good set lands warmly here. The audience knows his better nights and treats this one as part of the same story."
            }

            return "The room hears the off night and forgives more than it should. A favorite can disappoint people without becoming a stranger."
        }
        default {
            if ($lastOutcome -eq "Poor" -and $Outcome -ne "Poor") {
                return "After the last shaky set, this one sounds like a recovery."
            }

            return ""
        }
    }
}

function Update-BardPerformanceVenueRecord {
    param(
        $Game,
        [string]$VenueId,
        [string]$Outcome,
        [int]$RewardCopper
    )

    $record = Get-BardPerformanceVenueRecord -Game $Game -VenueId $VenueId
    Set-BardPerformanceRecordValue -Record $record -Key "Plays" -Value ([int](Get-BardPerformanceRecordValue -Record $record -Key "Plays") + 1)
    Set-BardPerformanceRecordValue -Record $record -Key $Outcome -Value ([int](Get-BardPerformanceRecordValue -Record $record -Key $Outcome) + 1)
    Set-BardPerformanceRecordValue -Record $record -Key "EarningsCopper" -Value ([int](Get-BardPerformanceRecordValue -Record $record -Key "EarningsCopper") + $RewardCopper)
    Set-BardPerformanceRecordValue -Record $record -Key "LastOutcome" -Value $Outcome
    Set-BardPerformanceRecordValue -Record $record -Key "LastRewardCopper" -Value $RewardCopper

    return $record
}

function Get-BardPerformancePatronBonusCopper {
    param(
        $Game,
        [string]$VenueId,
        [string]$Outcome
    )

    if ($null -eq $Game -or $null -eq $Game.Town -or $Outcome -eq "Poor") {
        return 0
    }

    switch ($VenueId) {
        "silver_kettle_stage" {
            if ([bool]$Game.Town.InnFlags["SilverKettleArtistWelcome"] -or [string]$Game.Town.Relationships["MerchantPatron"] -eq "Favorable") {
                return 30
            }
        }
        "private_patron_salons" {
            if ([bool]$Game.Town.InnFlags["SilverKettlePrivateInvite"]) {
                return 50
            }
        }
    }

    return 0
}

function Get-BardPerformanceRecognitionText {
    param(
        $Game,
        $Venue
    )

    $performanceCountTotal = [int]$Game.Town.PerformanceCountTotal
    $record = Get-BardPerformanceVenueRecord -Game $Game -VenueId $Venue.Id
    $familiarity = Get-BardPerformanceAudienceFamiliarity -Record $record

    if ($familiarity -eq "Favorite") {
        switch ($Venue.Id) {
            "market_square" { return "The market spots $($Game.Hero.Name) before he has finished setting up. A few children run for better places, and traders make room for the song because they already know it will hold a crowd." }
            "lantern_rest_stage" { return "The Lantern Rest welcomes $($Game.Hero.Name) like a returning warmth. Travelers turn from their cups before the first chord because this room knows his music can change the shape of a night." }
            "silver_kettle_stage" { return "Silver Kettle patrons pretend restraint, but their attention is already arranged around $($Game.Hero.Name). Here, being expected is almost as valuable as being applauded." }
            "bent_nail_stage" { return "The Bent Nail greets $($Game.Hero.Name) with table-knocks and crooked grins. The regulars know the songs, and more importantly, they know he can survive the room." }
            "private_patron_salons" { return "The private salon receives $($Game.Hero.Name) as a known pleasure now. Conversation lowers before he asks for silence." }
        }
    }

    if ($familiarity -eq "Shaky") {
        return "$($Venue.Name) remembers the rougher sets too. Curiosity gathers, but it is guarded, waiting to see which version of $($Game.Hero.Name) has walked in tonight."
    }

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

    if ($Game.Hero.Class -ne "Bard" -and $VenueId -ne "market_square") {
        return [PSCustomObject]@{
            Success = $false
            Message = "Only bards can perform in inn rooms or private salons."
        }
    }

    if ((Get-TownTimeOfDay -Game $Game) -ne "Night") {
        Write-Scene "$($Game.Hero.Name) can earn coin with a room and a song, but the city does not really pay attention until the evening crowd gathers."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Performance venue not live yet."
        }
    }

    if ($Game.Town.PerformanceCountToday -ge 3) {
        Write-Scene "$($Game.Hero.Name) has already played three paying sets today. His voice, hands, and audience luck will have to wait for tomorrow."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Performance limit reached."
        }
    }

    $venue = Get-HeroPublicPerformanceVenue -Game $Game -VenueId $VenueId

    if ($null -eq $venue) {
        return [PSCustomObject]@{
            Success = $false
            Message = "Performance venue unavailable."
        }
    }

    if (-not [string]::IsNullOrWhiteSpace($VenueId) -and [bool]$Game.Town.PerformanceVenuesToday[$VenueId]) {
        Write-Scene "$($venue.Name) has already had $($Game.Hero.Name)'s set today. If he wants more coin before nightfall, he needs a different room."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Venue already used today."
        }
    }

    if ($Game.Hero.Class -ne "Bard" -and $VenueId -ne "market_square") {
        Write-Scene "$($Game.Hero.Name) can test the public market crowd, but inn stages and private rooms are bard work."
        Write-ColorLine ""
        return [PSCustomObject]@{
            Success = $false
            Message = "Only bards can perform in inn rooms or private salons."
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

    $venueRecordBefore = Get-BardPerformanceVenueRecord -Game $Game -VenueId $VenueId
    $performanceAbility = if ($Game.Hero.Class -eq "Barbarian" -and $VenueId -eq "market_square") { "STR" } else { "CHA" }
    $total = Start-BardPerformanceCheck -Game $Game -Venue $venue -CheckDC $effectiveCheckDC -Ability $performanceAbility -CheckTag "Performance"
    $rewardCopper = 0
    $outcome = "Poor"

    if ($total -ge ($effectiveCheckDC + 5)) {
        $rewardCopper = [int]$venue.GreatRewardCopper
        $outcome = "Great"
        Write-Scene (Resolve-HeroNarrativeText -Text $venue.GreatSuccessText -Hero $Game.Hero)
    }
    elseif ($total -ge $effectiveCheckDC) {
        $rewardCopper = [int]$venue.GoodRewardCopper
        $outcome = "Good"
        Write-Scene (Resolve-HeroNarrativeText -Text $venue.SuccessText -Hero $Game.Hero)
    }
    else {
        $rewardCopper = [int]$venue.PoorRewardCopper
        Write-Scene (Resolve-HeroNarrativeText -Text $venue.FailureText -Hero $Game.Hero)
    }

    $memoryText = Get-BardPerformanceOutcomeMemoryText -Game $Game -Venue $venue -Record $venueRecordBefore -Outcome $outcome

    if (-not [string]::IsNullOrWhiteSpace($memoryText)) {
        Write-Scene $memoryText
    }

    if ($permitRewardCopper -gt 0 -and $outcome -ne "Poor") {
        $rewardCopper += $permitRewardCopper
        Write-EmphasisLine -Text "Belor's market permit keeps the wardens off the set and the tip hat fuller." -Color "Yellow"
    }

    $patronBonusCopper = Get-BardPerformancePatronBonusCopper -Game $Game -VenueId $VenueId -Outcome $outcome
    if ($patronBonusCopper -gt 0) {
        $rewardCopper += $patronBonusCopper
        Write-EmphasisLine -Text "Patron attention turns the set into paid upper-room work instead of loose tips." -Color "Yellow"
    }

    Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper | Out-Null
    $Game.Town.PerformanceCountToday = [int]$Game.Town.PerformanceCountToday + 1
    $Game.Town.PerformanceCountTotal = [int]$Game.Town.PerformanceCountTotal + 1
    $Game.Town.PerformanceVenuesToday[$VenueId] = $true
    $updatedRecord = Update-BardPerformanceVenueRecord -Game $Game -VenueId $VenueId -Outcome $outcome -RewardCopper $rewardCopper

    if ($VenueId -eq "market_square" -and $outcome -ne "Poor") {
        $Game.Town.Relationships["SquareAudience"] = if ($outcome -eq "Great") { "Delighted" } else { "Warm" }
    }

    if ($Game.Hero.Class -eq "Bard" -and $VenueId -eq "silver_kettle_stage" -and $outcome -eq "Great" -and -not $Game.Town.InnFlags["SilverKettlePatronFavor"]) {
        $Game.Town.InnFlags["SilverKettlePatronFavor"] = $true
        $Game.Town.Relationships["MerchantPatron"] = "Favorable"
        Write-EmphasisLine -Text "A patron remembers the set and starts asking after $($Game.Hero.Name) by name." -Color "Yellow"
    }

    if ($Game.Hero.Class -eq "Bard" -and $VenueId -eq "silver_kettle_stage" -and $outcome -eq "Great") {
        $Game.Town.InnFlags["SilverKettlePrivateInvite"] = $true
    }

    Write-EmphasisLine -Text "$($Game.Hero.Name) earns $(Convert-CopperToCurrencyText -Copper $rewardCopper) from the performance." -Color "Yellow"
    Write-ColorLine ""

    return [PSCustomObject]@{
        Success = $true
        Outcome = $outcome
        RewardCopper = $rewardCopper
        CheckTotal = $total
        VenueRecord = $updatedRecord
    }
}

function Start-BardPerformanceMenu {
    param($Game)

    if ((Get-TownTimeOfDay -Game $Game) -ne "Night") {
        Write-Scene "$($Game.Hero.Name) can work the city's rooms for coin, but the real audiences do not gather until nightfall."
        Write-ColorLine ""
        return
    }

    while ($true) {
        Write-SectionTitle -Text "Find an Audience" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Performance" -HeroHP $Game.Hero.HP
        Write-Scene "A bard can make coin in this city without lifting a blade, if the room is right and the performance lands."
        Write-EmphasisLine -Text "Performances today: $($Game.Town.PerformanceCountToday)/3" -Color "Yellow"
        Write-ColorLine "1. Perform in the market square" "White"
        Write-ColorLine "2. Book a private patron salon" "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
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

function Start-InnRoomThenVisitMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

    if ($innMenuResult -eq "EndGame") {
        return "EndGame"
    }

    if ($innMenuResult -eq "BackToInn") {
        return (Start-InnVisitMenu -Game $Game -HeroHP $HeroHP)
    }

    return $innMenuResult
}

function Start-QuestHubMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $showIntro = $true

    while ($true) {
        Write-SectionTitle -Text "Seek Work" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Seek Work" -HeroHP $HeroHP.Value
        if ($showIntro) {
            Write-TownLocationIntro `
                -Game $Game `
                -Key (Get-TownFlavorVisitKey -Prefix "Hub" -Name "SeekWork") `
                -FullText (Get-ClassAwareTownText -Hero $Game.Hero `
                    -BarbarianText "Borzig can ask for work from official hands, desperate citizens, or merchants with private problems." `
                    -BardText "Gariand can ask for work from official hands, desperate citizens, or merchants with private problems. More and more often, each of them wants someone who can listen as well as act." `
                    -FighterText "Lubert Stryer can ask for work from official hands, patrons, and anyone who understands that a shield can be a social promise as much as protection.") `
                -RepeatText "The work sources are familiar now; the open leads and tier progress tell the useful part."

            if (-not [bool]$Game.Town.StreetFlags["SeekWorkTroubleLineSeen"]) {
                Write-Scene "More and more, it feels like the same trouble is being seen from different corners of the city."
                $Game.Town.StreetFlags["SeekWorkTroubleLineSeen"] = $true
            }

            $showIntro = $false
        }
        Write-EmphasisLine -Text ((Get-StoryTierProgressStatus -Game $Game).StatusText) -Color "Yellow"
        Write-ColorLine ""
        Write-ColorLine "1. Check the quest board" "White"
        Write-ColorLine "2. Visit the guard station" "White"
        $privateWorkLabel = if ((Get-TownQuestSourceDisplayTitle -Source "Quest Giver" -Game $Game) -eq "High Ledger Office") {
            "Visit Lady Veyra's High Ledger office"
        }
        else {
            "Speak with the quest giver's clerk"
        }
        Write-ColorLine "3. $privateWorkLabel" "White"
        if ((Test-DocksDistrictUnlocked -Game $Game) -and -not (Test-DocksDistrictOpenToTown -Game $Game)) {
            Write-ColorLine "4. Follow leads down at the docks" "White"
        }
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
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
                Show-TownQuestSource -Title (Get-TownQuestSourceDisplayTitle -Source "Quest Giver" -Game $Game) -IntroText "A clerk waits beneath the old patron's seal, ready to pass along jobs too awkward or dangerous for ordinary hirelings." -Source "Quest Giver" -Game $Game -HeroHP $HeroHP
            }
            "4" {
                if (-not (Test-DocksDistrictUnlocked -Game $Game)) {
                    Write-ColorLine "There is no reason to chase dockside leads yet." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                if (Test-DocksDistrictOpenToTown -Game $Game) {
                    Write-ColorLine "The docks are open as their own district now. Visit them from the town menu." "DarkYellow"
                    Write-ColorLine ""
                    continue
                }

                Start-DocksDistrictMenu -Game $Game -HeroHP $HeroHP
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

function Open-TownShopAction {
    param(
        $Game,
        [ref]$HeroHP,
        [string]$Action
    )

    switch ($Action) {
        "Market" {
            if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Market")) {
                Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Market")
                Write-ColorLine ""
                return
            }

            Show-TownShop -Title "Market" -IntroText (Get-TownShopIntroText -Shop "Market" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-MarketOffers -Game $Game) -BuyerType "Market"
        }
        "Smithy" {
            if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Smithy")) {
                Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Smithy")
                Write-ColorLine ""
                return
            }

            Show-TownShop -Title "Smithy" -IntroText (Get-TownShopIntroText -Shop "Smithy" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-SmithyOffers -Game $Game) -BuyerType "Smithy"
        }
        "Apothecary" {
            Show-TownShop -Title "Apothecary" -IntroText (Get-TownShopIntroText -Shop "Apothecary" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-ApothecaryOffers -Game $Game) -BuyerType "Apothecary"
        }
        "InstrumentShop" {
            Show-TownShop -Title "Instrument Shop" -IntroText (Get-TownShopIntroText -Shop "Instrument Shop" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-InstrumentShopOffers -Game $Game) -BuyerType "InstrumentShop"
        }
        "Armorer" {
            if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Armorer")) {
                Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Armorer")
                Write-ColorLine ""
                return
            }

            Show-TownShop -Title "Armorer" -IntroText (Get-TownShopIntroText -Shop "Armorer" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-ArmorerOffers -Game $Game) -BuyerType "Armorer"
        }
        "Stable" {
            if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Stable")) {
                Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Stable")
                Write-ColorLine ""
                return
            }

            Show-TownStable -IntroText (Get-TownShopIntroText -Shop "Stable" -Hero $Game.Hero -Game $Game) -Game $Game -Hero $Game.Hero -Offers (Get-StableOffers -Game $Game)
        }
        "Sell" {
            Open-TownSellMenu -Game $Game -Hero $Game.Hero -BuyerType "GeneralBuyer" -ExitLabel "Back to shops"
        }
    }
}

function Start-TownShopsMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $showIntro = $true

    while ($true) {
        $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

        Write-SectionTitle -Text "Shops & Services" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Shops" -HeroHP $HeroHP.Value
        if ($showIntro) {
            Write-TownLocationIntro `
                -Game $Game `
                -Key (Get-TownFlavorVisitKey -Prefix "Hub" -Name "Shops") `
                -FullText $(if ($isNight) { "After dark, the city sells only what it can keep lit, guarded, or discreet." } else { "The city's practical business gathers around counters, stalls, workshops, and people with enough stock to solve problems for coin." }) `
                -RepeatText "The shop streets are familiar now; the useful part is which counters are open."
            $showIntro = $false
        }
        Write-ColorLine ""
        Write-ColorLine $(if ($isNight) { "1. Browse the last open stalls (market closed)" } else { "1. Browse the market" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Market") { "White" } else { "DarkGray" })
        Write-ColorLine $(if ($isNight) { "2. Visit the forge doors (smithy closed)" } else { "2. Visit the smithy" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Smithy") { "White" } else { "DarkGray" })
        Write-ColorLine $(if ($isNight) { "3. Visit the candlelit apothecary" } else { "3. Visit the apothecary" }) "White"
        Write-ColorLine $(if ($isNight) { "4. Visit the quiet instrument shop" } else { "4. Visit the instrument shop" }) "White"
        Write-ColorLine $(if ($isNight) { "5. Visit the armorer's hall (closed)" } else { "5. Visit the armorer" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Armorer") { "White" } else { "DarkGray" })
        Write-ColorLine $(if ($isNight) { "6. Visit the stable yard (closed)" } else { "6. Visit the stable yard" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Stable") { "White" } else { "DarkGray" })
        Write-ColorLine $(if ($isNight) { "7. Find a late buyer" } else { "7. Find a buyer" }) "White"
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Market" }
            "2" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Smithy" }
            "3" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Apothecary" }
            "4" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "InstrumentShop" }
            "5" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Armorer" }
            "6" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Stable" }
            "7" { Open-TownShopAction -Game $Game -HeroHP $HeroHP -Action "Sell" }
            "S" { Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value }
            "0" { return }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Start-TownWorkMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    $showIntro = $true

    while ($true) {
        $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

        Write-SectionTitle -Text "Work & Trouble" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Work" -HeroHP $HeroHP.Value
        if ($showIntro) {
            Write-TownLocationIntro `
                -Game $Game `
                -Key (Get-TownFlavorVisitKey -Prefix "Hub" -Name "Work") `
                -FullText $(if ($isNight) { "Night work has sharper edges: private jobs, ring wagers, and rooms that pay attention once lanterns are lit." } else { "Day work is easier to ask for openly: posted jobs, honest labor, and trouble that still pretends to be respectable." }) `
                -RepeatText "The work choices are familiar now; only the open doors and posted trouble need checking."
            $showIntro = $false
        }
        Write-ColorLine ""
        Write-ColorLine $(if ($isNight) { "1. Seek late work" } else { "1. Seek work" }) "White"
        Write-ColorLine $(if ($isNight) { "2. Head for the fighting ring" } else { "2. Visit the fighting ring (opens at night)" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Ring") { "White" } else { "DarkGray" })

        if ($Game.Hero.Class -eq "Bard") {
            Write-ColorLine $(if ($isNight) { "3. Find a room and perform for coin" } else { "3. Find an audience and perform for coin (best after dark)" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance") { "White" } else { "DarkGray" })
        }
        elseif ($Game.Hero.Class -eq "Fighter") {
            Write-ColorLine "3. Visit the tourney ground" "White"
            Write-ColorLine $(if ($isNight) { "4. Sing an old war-ballad in the market" } else { "4. Try a public market performance (best after dark)" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance") { "White" } else { "DarkGray" })
        }
        elseif ($Game.Hero.Class -eq "Barbarian") {
            Write-ColorLine $(if ($isNight) { "3. Lead a war-rhythm performance in the market" } else { "3. Try a public market performance (best after dark)" }) $(if (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance") { "White" } else { "DarkGray" })
        }

        Write-ColorLine "S. Status" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                Start-QuestHubMenu -Game $Game -HeroHP $HeroHP
            }
            "2" {
                if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Ring")) {
                    Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Ring")
                    Write-ColorLine ""
                }
                else {
                    Start-FightingRing -Game $Game
                }
            }
            "3" {
                if ($Game.Hero.Class -eq "Bard") {
                    if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance")) {
                        Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Performance")
                        Write-ColorLine ""
                    }
                    else {
                        Start-BardPerformanceMenu -Game $Game
                    }
                }
                elseif ($Game.Hero.Class -eq "Fighter") {
                    Start-JoustingArena -Game $Game
                }
                elseif ($Game.Hero.Class -eq "Barbarian") {
                    if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance")) {
                        Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Performance")
                        Write-ColorLine ""
                    }
                    else {
                        Resolve-BardPerformance -Game $Game -VenueId "market_square" | Out-Null
                    }
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                }
            }
            "4" {
                if ($Game.Hero.Class -eq "Fighter") {
                    if (-not (Test-TownActionAvailableAtCurrentTime -Game $Game -Action "Performance")) {
                        Write-Scene (Get-TownActionUnavailableText -Game $Game -Action "Performance")
                        Write-ColorLine ""
                    }
                    else {
                        Resolve-BardPerformance -Game $Game -VenueId "market_square" | Out-Null
                    }
                }
                else {
                    Write-ColorLine "Choose a listed option." "DarkYellow"
                    Write-ColorLine ""
                }
            }
            "S" { Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value }
            "0" { return }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}

function Start-TownInnHubMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    if ($null -ne $Game.Town.ActiveInn) {
        $innMenuResult = Start-InnVisitMenu -Game $Game -HeroHP $HeroHP

        if ($innMenuResult -eq "EndGame") {
            return "EndGame"
        }

        return "Back"
    }

    $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

    if ($innResult -eq "Stayed") {
        return (Start-InnVisitMenu -Game $Game -HeroHP $HeroHP)
    }

    return $innResult
}

function Start-TownCharacterMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-SectionTitle -Text "Hero & Records" -Color "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Hero" -HeroHP $HeroHP.Value
        Write-Scene "$($Game.Hero.Name) takes a moment away from the city's noise to check gear, notes, and next steps."
        Write-ColorLine ""
        Write-ColorLine "1. Check inventory" "White"
        Write-ColorLine "2. Check quest log" "White"
        Write-ColorLine "3. Status" "White"
        Write-ColorLine "4. Skill tree" "White"
        Write-ColorLine "5. Save adventure" "White"
        Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" { Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null }
            "2" { Start-TownQuestLogMenu -Game $Game -HeroHP $HeroHP }
            "3" { Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value }
            "4" { Show-HeroSkillTree -Hero $Game.Hero }
            "5" { Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null }
            "T" { Toggle-TextSpeed | Out-Null }
            "0" { return }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
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
        $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"

        # The first city night is mandatory so the tutorial always lands on the inn chapter ending.
        if ($Game.Town.MustChooseFirstInn -and -not $Game.Town.ChapterOneComplete) {
            Write-SectionTitle -Text "Night Falls" -Color "Yellow"
            Write-Scene "The city can wait until morning. $($Game.Hero.Name) needs a roof, a locked door, and one real night's sleep before the next chapter begins."
            Write-ColorLine ""

            $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

            if ($innResult -eq "Stayed") {
                $innMenuResult = Start-InnRoomThenVisitMenu -Game $Game -HeroHP $HeroHP

                if ($innMenuResult -eq "EndGame") {
                    return "EndGame"
                }
            }

            continue
        }

        Write-ColorLine ""
        Write-ColorLine "===== TOWN =====" "Yellow"
        Write-TownTimeTracker -Game $Game -Area "Town" -HeroHP $HeroHP.Value

        if (-not $Game.Town.StreetFlags["TownMenuVisited"]) {
            Write-Scene "Stone streets spread out before $($Game.Hero.Name), loud with merchants, carts, and the clatter of a city living by its own stubborn rhythm."
            Write-Scene "The city no longer feels like refuge alone. It feels like a place where the next chapter might actually begin."
            $Game.Town.StreetFlags["TownMenuVisited"] = $true
        }
        elseif ($Game.Town.ChapterTwoComplete) {
            Write-Scene "The city watches $($Game.Hero.Name) differently now, with more respect and sharper attention."
        }
        elseif ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
            Write-Scene "Lantern light and late footsteps have taken over the streets. The city is quieter now, but never truly calm."
        }
        else {
            Write-Scene "The city is awake around $($Game.Hero.Name) again, full of noise, work, and unfinished business."
        }
        $ambientText = Get-TownAmbientText -Game $Game
        if (-not [string]::IsNullOrWhiteSpace($ambientText)) {
            Write-Scene $ambientText
        }
        $aftermathReminder = Get-PostCivicVaultAftermathReminderText -Game $Game
        if (-not [string]::IsNullOrWhiteSpace($aftermathReminder)) {
            Write-EmphasisLine -Text $aftermathReminder -Color "DarkYellow"
        }
        $nextStepReminder = Get-TownNextStepReminderText -Game $Game
        if (-not [string]::IsNullOrWhiteSpace($nextStepReminder)) {
            Write-EmphasisLine -Text $nextStepReminder -Color "DarkCyan"
        }
        $relationshipHint = Get-TownRelationshipHintText -Game $Game
        if (-not [string]::IsNullOrWhiteSpace($relationshipHint)) {
            Write-EmphasisLine -Text $relationshipHint -Color "Magenta"
        }
        $monsterZoneReminder = Get-MonsterZoneTownReminderText -Game $Game
        if (-not [string]::IsNullOrWhiteSpace($monsterZoneReminder)) {
            Write-EmphasisLine -Text $monsterZoneReminder -Color "DarkCyan"
        }
        Write-ColorLine ""
        if ($isNight) {
            Write-ColorLine "How do you want to spend the night?" "Cyan"
        }
        else {
            Write-ColorLine "What do you want to do?" "Cyan"
        }
        Write-ColorLine $(if ($isNight) { "1. Walk the lantern-lit streets" } else { "1. Walk the streets" }) "White"
        Write-ColorLine "2. Shops & services" "White"
        Write-ColorLine $(if ($isNight) { "3. Work, trouble, and night coin" } else { "3. Work, trouble, and day jobs" }) "White"
        Write-ColorLine $(if ($null -ne $Game.Town.ActiveInn) { "4. Go to your inn" } else { "4. Find lodging" }) "White"
        Write-ColorLine "5. Hero, inventory, and quest log" "White"
        if (Test-DocksDistrictOpenToTown -Game $Game) {
            Write-ColorLine "6. Visit the docks district" "White"
        }
        if (Test-MonsterZoneUnlocked -Game $Game) {
            Write-ColorLine "7. Venture beyond the outer wall" "White"
        }
        Write-ColorLine "S. Status" "White"
        Write-ColorLine "G. Save adventure" "White"
        if ((Get-TownTimeOfDay -Game $Game) -eq "Day") {
            Write-ColorLine "W. Wait for nightfall" "White"
        }
        Write-TextSpeedOption
        Write-ColorLine "0. End adventure for now" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                Start-TownStreetScene -Game $Game -ReturnLabel "Back to town"
            }
            "2" {
                Start-TownShopsMenu -Game $Game -HeroHP $HeroHP
            }
            "3" {
                Start-TownWorkMenu -Game $Game -HeroHP $HeroHP
            }
            "4" {
                $innHubResult = Start-TownInnHubMenu -Game $Game -HeroHP $HeroHP

                if ($innHubResult -eq "EndGame") {
                    return "EndGame"
                }
            }
            "5" {
                Start-TownCharacterMenu -Game $Game -HeroHP $HeroHP
            }
            "6" {
                if (Test-DocksDistrictOpenToTown -Game $Game) {
                    Start-DocksDistrictMenu -Game $Game -HeroHP $HeroHP -ReturnLabel "Back to town"
                }
                else {
                    Write-ColorLine "Invalid choice. Try again." "Red"
                    Write-ColorLine ""
                }
            }
            "7" {
                if (Test-MonsterZoneUnlocked -Game $Game) {
                    $monsterZoneResult = Start-MonsterZoneMenu -Game $Game -HeroHP $HeroHP

                    if ($monsterZoneResult -eq "Defeated") {
                        Write-Scene "$($Game.Hero.Name) is dragged back to the city by a patrol that was almost too late."
                        $HeroHP.Value = [Math]::Max(1, [Math]::Floor($Game.Hero.HP / 2))
                        Set-TownTimeOfDay -Game $Game -TimeOfDay "Night"
                    }
                }
                else {
                    Write-ColorLine "Invalid choice. Try again." "Red"
                    Write-ColorLine ""
                }
            }
            "S" {
                Show-AdventureStatus -Game $Game -HeroHP $HeroHP.Value
            }
            "G" {
                Start-AdventureSaveMenu -Game $Game -HeroHP $HeroHP.Value -HeroDroppedWeapon ([bool]$Game.HeroDroppedWeapon) | Out-Null
            }
            "W" {
                Wait-For-Nightfall -Game $Game
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
