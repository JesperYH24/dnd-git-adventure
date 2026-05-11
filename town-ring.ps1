# The ring is a self-contained unarmed combat loop with its own rewards and progression hooks.
function Get-RingOpponentPool {
    return @(
        [PSCustomObject]@{
            Name = "Dockhand Vero"
            Definite = "Dockhand Vero"
            Tier = 1
            ArmorClass = 11
            HP = 10
            AttackBonus = 2
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 4
            GrappleChance = 45
            FocusChance = 5
            BlockChance = 5
            Intro = "A square-shouldered dockhand cracks his knuckles and grins through a split lip. Vero fights to drag people down, not just trade punches."
        }
        [PSCustomObject]@{
            Name = "Street Bruiser Nella"
            Definite = "Street Bruiser Nella"
            Tier = 1
            ArmorClass = 13
            HP = 7
            AttackBonus = 1
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 1
            GrappleChance = 10
            FocusChance = 15
            BlockChance = 20
            Intro = "Nella rolls her neck once and comes in light on her feet, slipping in and out before most fighters can plant for a counter."
        }
        [PSCustomObject]@{
            Name = "Coal-Fist Bren"
            Definite = "Coal-Fist Bren"
            Tier = 1
            ArmorClass = 12
            HP = 9
            AttackBonus = 2
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 2
            GrappleChance = 15
            FocusChance = 5
            BlockChance = 5
            Intro = "Bren comes in with soot still on his forearms, throwing short, ugly punches that land harder than they should."
        }
        [PSCustomObject]@{
            Name = "Pit Runner Sella"
            Definite = "Pit Runner Sella"
            Tier = 2
            ArmorClass = 14
            HP = 10
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 2
            GrappleChance = 10
            FocusChance = 20
            BlockChance = 15
            Intro = "Sella circles lightly on her feet, measuring {hero} with the patience of someone used to tiring out bigger foes."
        }
        [PSCustomObject]@{
            Name = "Gravel-Tooth Harven"
            Definite = "Gravel-Tooth Harven"
            Tier = 2
            ArmorClass = 11
            HP = 13
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 3
            GrappleBonus = 2
            GrappleChance = 10
            FocusChance = 0
            BlockChance = 0
            Intro = "Harven spits blood into the sand and beckons {hero} closer with a broken grin. He is slower than most, but every clean hit lands heavy."
        }
        [PSCustomObject]@{
            Name = "Latchhook Vessa"
            Definite = "Latchhook Vessa"
            Tier = 2
            ArmorClass = 13
            HP = 11
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 4
            GrappleChance = 35
            FocusChance = 5
            BlockChance = 10
            Intro = "Vessa prowls in close, hunting wrists and elbows with the calm patience of someone who likes winning on the ground."
        }
        [PSCustomObject]@{
            Name = "Ironjaw Marn"
            Definite = "Ironjaw Marn"
            Tier = 3
            ArmorClass = 13
            HP = 15
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 5
            GrappleChance = 30
            FocusChance = 5
            BlockChance = 10
            Intro = "Ironjaw Marn steps into the lantern light to a chorus of shouts. The crowd knows him, and that alone is warning enough."
        }
        [PSCustomObject]@{
            Name = "Silent Torh"
            Definite = "Silent Torh"
            Tier = 3
            ArmorClass = 15
            HP = 12
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 4
            GrappleChance = 20
            FocusChance = 20
            BlockChance = 20
            Intro = "Torh says nothing at all. He only plants his feet and raises his hands, which somehow feels worse."
        }
        [PSCustomObject]@{
            Name = "Stonewall Hedd"
            Definite = "Stonewall Hedd"
            Tier = 3
            ArmorClass = 16
            HP = 14
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 4
            GrappleChance = 15
            FocusChance = 10
            BlockChance = 35
            Intro = "Hedd steps forward behind a tight guard, looking less like a brawler and more like a wall that learned to punch back."
        }
        [PSCustomObject]@{
            Name = "Champion Breaker Ysold"
            Definite = "Champion Breaker Ysold"
            Tier = 4
            ArmorClass = 15
            HP = 16
            AttackBonus = 5
            DamageDiceSides = 4
            DamageBonus = 3
            GrappleBonus = 5
            GrappleChance = 30
            FocusChance = 15
            BlockChance = 15
            Intro = "Ysold steps through the ropes with the relaxed calm of someone who has ended more than one local legend."
        }
        [PSCustomObject]@{
            Name = "Quick-Knife Renn"
            Definite = "Quick-Knife Renn"
            Tier = 4
            ArmorClass = 16
            HP = 14
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 3
            GrappleChance = 10
            FocusChance = 25
            BlockChance = 20
            Intro = "Renn is unarmed tonight, but every step still looks like he learned to survive by never being where the blow lands."
        }
        [PSCustomObject]@{
            Name = "Chainbreaker Odo"
            Definite = "Chainbreaker Odo"
            Tier = 4
            ArmorClass = 15
            HP = 18
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 3
            GrappleBonus = 6
            GrappleChance = 45
            FocusChance = 5
            BlockChance = 10
            Intro = "Odo rolls his shoulders once and smiles without warmth. He fights like a man who believes every match should end in a takedown."
        }
        [PSCustomObject]@{
            Name = "Ashen Varg"
            Definite = "Ashen Varg"
            Tier = 5
            ArmorClass = 16
            HP = 19
            AttackBonus = 5
            DamageDiceSides = 4
            DamageBonus = 3
            GrappleBonus = 6
            GrappleChance = 30
            FocusChance = 20
            BlockChance = 20
            Intro = "Ashen Varg steps in without fanfare, all cold eyes and deliberate movement. He fights like someone who studies people before he hurts them."
        }
        [PSCustomObject]@{
            Name = "The Ox of Merefield"
            Definite = "The Ox of Merefield"
            Tier = 5
            ArmorClass = 15
            HP = 22
            AttackBonus = 5
            DamageDiceSides = 4
            DamageBonus = 4
            GrappleBonus = 7
            GrappleChance = 40
            FocusChance = 5
            BlockChance = 10
            Intro = "The Ox ducks through the ropes to a wall of noise. Broad-backed and patient, he looks like the sort of man who expects the ring itself to move for him."
        }
    )
}

function Get-RingOpponents {
    param($Hero)

    $pool = Get-RingOpponentPool
    $maxTier = 3
    $roundCount = 3

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"] -and [int]$Hero.RingWinsTotal -ge 15) {
        $maxTier = 5
        $roundCount = 5
    }
    elseif ($null -ne $Hero.PSObject.Properties["RingWinsTotal"] -and [int]$Hero.RingWinsTotal -ge 10) {
        $maxTier = 4
        $roundCount = 4
    }

    $eligible = @($pool | Where-Object { $_.Tier -le $maxTier } | Sort-Object { Get-Random })
    return @($eligible | Select-Object -First $roundCount)
}

function Get-RingRewardCopper {
    param([int]$Wins)

    switch ($Wins) {
        1 { return 100 }
        2 { return 220 }
        3 { return 350 }
        4 { return 520 }
        5 { return 700 }
        default { return 0 }
    }
}

function Get-RingWagerOptions {
    return @(
        [PSCustomObject]@{
            Id = "standard"
            MenuKey = "1"
            Name = "Safe purse"
            StakeCopper = 0
            Description = "Standard entry. Keep whatever purse the rounds earn."
        }
        [PSCustomObject]@{
            Id = "crowd"
            MenuKey = "2"
            Name = "Crowd bet"
            StakeCopper = 50
            Description = "Pay extra for a crowd mark. Win at least two rounds for a bonus purse."
        }
        [PSCustomObject]@{
            Id = "double"
            MenuKey = "3"
            Name = "Double-or-nothing"
            StakeCopper = 100
            Description = "Risk a heavier stake. Clear the card to double the purse; fall short and the purse is gone."
        }
    )
}

function Show-RingWagerOptions {
    param(
        [int]$EntryFeeCopper,
        [int]$MaxRounds
    )

    Write-ColorLine "Choose your purse:" "Cyan"

    foreach ($option in Get-RingWagerOptions) {
        $totalCost = $EntryFeeCopper + [int]$option.StakeCopper
        Write-ColorLine "$($option.MenuKey). $($option.Name) - total cost $(Convert-CopperToCurrencyText -Copper $totalCost)" "White"
        Write-ColorLine "   $($option.Description)" "DarkGray"
    }

    Write-ColorLine "0. Back to the rail" "DarkGray"
    Write-ColorLine ""
}

function Select-RingWager {
    param(
        [int]$EntryFeeCopper,
        [int]$MaxRounds
    )

    $options = @(Get-RingWagerOptions)

    while ($true) {
        Show-RingWagerOptions -EntryFeeCopper $EntryFeeCopper -MaxRounds $MaxRounds
        $choice = Read-Host "Choose purse"

        if ($choice -eq "0") {
            return $null
        }

        $selected = $options | Where-Object { $_.MenuKey -eq $choice } | Select-Object -First 1

        if ($null -ne $selected) {
            return $selected
        }

        Write-ColorLine "Choose one of the listed purse options." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-RingWagerPayout {
    param(
        $Wager,
        [int]$Wins,
        [int]$MaxRounds,
        [int]$BaseRewardCopper
    )

    if ($null -eq $Wager -or $Wager.Id -eq "standard") {
        return [PSCustomObject]@{
            PayoutCopper = $BaseRewardCopper
            BonusCopper = 0
            LostBasePurse = $false
            Text = "The safe purse pays exactly what the rounds earned."
        }
    }

    if ($Wager.Id -eq "crowd") {
        $bonus = if ($Wins -ge [Math]::Min(2, $MaxRounds)) { 150 } else { 0 }
        $text = if ($bonus -gt 0) {
            "The crowd bet lands. The rail pays an extra $(Convert-CopperToCurrencyText -Copper $bonus)."
        }
        else {
            "The crowd bet misses. The extra stake stays with the rail."
        }

        return [PSCustomObject]@{
            PayoutCopper = $BaseRewardCopper + $bonus
            BonusCopper = $bonus
            LostBasePurse = $false
            Text = $text
        }
    }

    if ($Wager.Id -eq "double") {
        if ($Wins -ge $MaxRounds -and $BaseRewardCopper -gt 0) {
            return [PSCustomObject]@{
                PayoutCopper = $BaseRewardCopper * 2
                BonusCopper = $BaseRewardCopper
                LostBasePurse = $false
                Text = "Double-or-nothing lands. The pit pays the purse twice over."
            }
        }

        return [PSCustomObject]@{
            PayoutCopper = 0
            BonusCopper = 0
            LostBasePurse = ($BaseRewardCopper -gt 0)
            Text = "Double-or-nothing fails. The purse is swallowed by the rail."
        }
    }

    return [PSCustomObject]@{
        PayoutCopper = $BaseRewardCopper
        BonusCopper = 0
        LostBasePurse = $false
        Text = "The purse pays out normally."
    }
}

function Get-RingRumor {
    param(
        $Game,
        [int]$Wins
    )

    if ($Wins -le 0 -or $null -eq $Game -or $null -eq $Game.Hero) {
        return $null
    }

    $storyFlags = if ($null -ne $Game.Town -and $null -ne $Game.Town.StoryFlags) { $Game.Town.StoryFlags } else { @{} }

    if ([bool]$storyFlags["LordHalewickEscaped"]) {
        return "Ring rumor: a cut man near the back rail swears two dock crews saw Halewick's smaller dragon shape cross the Civic Keep bells before turning toward the river wind."
    }

    if ([bool]$storyFlags["HigherPatronSuspected"]) {
        return "Ring rumor: a bookmaker mutters that shell-company coin has started avoiding obvious bets, as if someone above the docks is suddenly afraid of written names."
    }

    if ([bool]$storyFlags["DocksFirstChainComplete"] -or [bool]$storyFlags["DocksUnlocked"]) {
        return "Ring rumor: one of the handlers says the docks are paying rough coin for quiet men, false cargo tallies, and anyone who can keep a witness from reaching Mira Kest."
    }

    if ([int]$Game.Hero.Level -ge 4) {
        return "Ring rumor: Dorr has heard of outer-road contracts where bruisers get paid for bringing strange hides, teeth, and living proof back from beyond the walls."
    }

    if ((Get-HeroRingReputation -Hero $Game.Hero) -ge 15) {
        return "Ring rumor: a patron in a clean coat asks too many questions about whether $($Game.Hero.Name)'s name can move a crowd without Dorr's permission."
    }

    return "Ring rumor: the rail says winning in the pit travels faster than honest notices. By morning, somebody who needs muscle will know $($Game.Hero.Name)'s name."
}

function Get-HeroRingReputation {
    param($Hero)

    if ($null -eq $Hero) {
        return 0
    }

    if ($null -eq $Hero.PSObject.Properties["RingReputation"]) {
        $Hero | Add-Member -NotePropertyName RingReputation -NotePropertyValue 0
    }

    return [int]$Hero.RingReputation
}

function Get-RingReputationReward {
    param([int]$Wins)

    switch ($Wins) {
        1 { return 2 }
        2 { return 5 }
        3 { return 9 }
        4 { return 14 }
        5 { return 20 }
        default { return 0 }
    }
}

function Add-HeroRingReputation {
    param(
        $Hero,
        [int]$Amount
    )

    $current = Get-HeroRingReputation -Hero $Hero

    if ($Amount -le 0) {
        return [PSCustomObject]@{
            Added = 0
            Total = $current
        }
    }

    $Hero.RingReputation = $current + $Amount

    return [PSCustomObject]@{
        Added = $Amount
        Total = [int]$Hero.RingReputation
    }
}

function Test-HeroWonRingChampionNight {
    param($Hero)

    if ($null -eq $Hero) {
        return $false
    }

    if ($null -eq $Hero.PSObject.Properties["RingChampionNightWon"]) {
        $Hero | Add-Member -NotePropertyName RingChampionNightWon -NotePropertyValue $false
    }

    return [bool]$Hero.RingChampionNightWon
}

function Test-HeroReadyForRingChampionNight {
    param($Hero)

    if ($null -eq $Hero -or $null -eq $Hero.PSObject.Properties["RingWinsTotal"]) {
        return $false
    }

    return ([int]$Hero.RingWinsTotal -ge 10 -and -not (Test-HeroWonRingChampionNight -Hero $Hero))
}

function Get-RingChampionNightOpponent {
    $opponent = Get-RingOpponentPool | Where-Object { $_.Name -eq "Champion Breaker Ysold" } | Select-Object -First 1

    return $opponent
}

function Complete-RingChampionNight {
    param($Hero)

    if ($null -eq $Hero) {
        return $null
    }

    if ($null -eq $Hero.PSObject.Properties["RingChampionNightWon"]) {
        $Hero | Add-Member -NotePropertyName RingChampionNightWon -NotePropertyValue $false
    }

    $Hero.RingChampionNightWon = $true
    $reputationResult = Add-HeroRingReputation -Hero $Hero -Amount 12

    return [PSCustomObject]@{
        Title = "Pit Champion"
        ReputationAdded = $reputationResult.Added
        ReputationTotal = $reputationResult.Total
    }
}

function Get-DefaultRingStyleCounts {
    return @{
        QuickFinish = 0
        Technical = 0
        Grappler = 0
        Brawler = 0
    }
}

function Get-HeroRingStyleCounts {
    param($Hero)

    if ($null -eq $Hero) {
        return Get-DefaultRingStyleCounts
    }

    if ($null -eq $Hero.PSObject.Properties["RingStyleCounts"] -or $null -eq $Hero.RingStyleCounts) {
        $Hero | Add-Member -NotePropertyName RingStyleCounts -NotePropertyValue (Get-DefaultRingStyleCounts)
    }

    foreach ($key in (Get-DefaultRingStyleCounts).Keys) {
        if (-not $Hero.RingStyleCounts.ContainsKey($key)) {
            $Hero.RingStyleCounts[$key] = 0
        }
    }

    return $Hero.RingStyleCounts
}

function Get-RingFightStyleSummary {
    param(
        [hashtable]$ActionCounts,
        [int]$Rounds,
        [bool]$HeroWon
    )

    $punches = [int]$ActionCounts["P"]
    $grapples = [int]$ActionCounts["G"]
    $blocks = [int]$ActionCounts["B"]
    $focuses = [int]$ActionCounts["F"]
    $technicalActions = $blocks + $focuses
    $directActions = $punches + $grapples

    if (-not $HeroWon) {
        return [PSCustomObject]@{
            Key = "Brawler"
            Label = "Hard Lesson"
            ReputationBonus = 0
            CrowdText = "The crowd gives the loss a rough kind of respect, but no one chants a style name for it yet."
        }
    }

    if ($Rounds -le 2 -and $punches -gt 0 -and $punches -ge $grapples) {
        return [PSCustomObject]@{
            Key = "QuickFinish"
            Label = "Quick Finish"
            ReputationBonus = 2
            CrowdText = "The crowd erupts for the quick finish. Fast violence sells itself."
        }
    }

    if ($technicalActions -gt 0 -and $technicalActions -ge $directActions) {
        return [PSCustomObject]@{
            Key = "Technical"
            Label = "Technical"
            ReputationBonus = 1
            CrowdText = "The louder bettors wanted blood, but the careful watchers saw the reads, guards, and timing."
        }
    }

    if ($grapples -gt 0 -and $grapples -ge $punches) {
        return [PSCustomObject]@{
            Key = "Grappler"
            Label = "Grappler"
            ReputationBonus = 1
            CrowdText = "Half the room cheers the control. The other half boos because clean takedowns ruin their favorite kind of chaos."
        }
    }

    return [PSCustomObject]@{
        Key = "Brawler"
        Label = "Brawler"
        ReputationBonus = 1
        CrowdText = "The crowd accepts the honest brawl: enough grit, enough bruises, and enough reason to remember the name."
    }
}

function Add-HeroRingStyleResult {
    param(
        $Hero,
        $StyleSummary
    )

    $styleCounts = Get-HeroRingStyleCounts -Hero $Hero
    $styleCounts[$StyleSummary.Key] = [int]$styleCounts[$StyleSummary.Key] + 1
    $reputationResult = Add-HeroRingReputation -Hero $Hero -Amount $StyleSummary.ReputationBonus

    return [PSCustomObject]@{
        Style = $StyleSummary.Label
        Count = [int]$styleCounts[$StyleSummary.Key]
        ReputationAdded = $reputationResult.Added
        ReputationTotal = $reputationResult.Total
    }
}

function Get-HeroDominantRingStyle {
    param($Hero)

    $styleCounts = Get-HeroRingStyleCounts -Hero $Hero
    $dominant = $styleCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 1

    if ($null -eq $dominant -or [int]$dominant.Value -le 0) {
        return "None yet"
    }

    switch ($dominant.Key) {
        "QuickFinish" { return "Quick Finish" }
        "Technical" { return "Technical" }
        "Grappler" { return "Grappler" }
        "Brawler" { return "Brawler" }
        default { return "None yet" }
    }
}

function Get-RingReputationTitle {
    param($Hero)

    $reputation = Get-HeroRingReputation -Hero $Hero

    if ($reputation -ge 80) { return "Ring Legend" }
    if ($reputation -ge 50) { return "City Bruiser" }
    if ($reputation -ge 30) { return "Pit Name" }
    if ($reputation -ge 15) { return "Crowd Name" }
    if ($reputation -ge 5) { return "Heard in the Pit" }

    return "Unproven"
}

function Get-HeroUnarmedRingTitle {
    param($Hero)

    if ($null -eq $Hero) {
        return "Unproven Hands"
    }

    $wins = 0
    $trainingLevel = 0
    $level = 1
    $reputation = Get-HeroRingReputation -Hero $Hero

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"]) {
        $wins = [int]$Hero.RingWinsTotal
    }

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $trainingLevel = [int]$Hero.UnarmedTrainingLevel
    }

    if ($null -ne $Hero.PSObject.Properties["Level"]) {
        $level = [int]$Hero.Level
    }

    if (Test-HeroWonRingChampionNight -Hero $Hero) {
        return "Pit Champion"
    }

    if ($level -ge 4 -and $reputation -ge 50) {
        return "Beast-Hand Prospect"
    }

    if ($trainingLevel -ge 2) {
        return "Pit-Fighter"
    }

    if ($trainingLevel -ge 1 -or $wins -ge 10) {
        return "Bare-Knuckle Regular"
    }

    if ($wins -ge 5 -or $reputation -ge 15) {
        return "Crowd Fighter"
    }

    if ($wins -gt 0 -or $reputation -gt 0) {
        return "Proven Hands"
    }

    return "Unproven Hands"
}

function Get-RingMasterPitTalk {
    param($Hero)

    $wins = 0

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"]) {
        $wins = [int]$Hero.RingWinsTotal
    }

    if ($wins -ge 10) {
        if ($Hero.RingWinsTotal -ge 15) {
            return "Dorr's grin turns savage. 'Champion? That's old news. Once you push past fifteen wins, you stop getting tested by hopefuls. You start getting hunted by professionals.'"
        }

        return "Ringmaster Dorr leans both arms on the rail. 'Champions don't just fight opponents. They fight expectations, bettors, and every fool who wants a piece of a name.'"
    }

    if ($wins -ge 5) {
        return "Dorr jerks his chin toward the sand. 'The pit changes once people recognize you. New blood gets tested. Known blood gets hunted.'"
    }

    return "Dorr raps the rail with his knuckles. 'The pit teaches quick. Crowd loves courage, but it pays hardest for timing and nerve.'"
}

function Get-RingMasterOpponentTalk {
    param($Hero)

    $wins = 0

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"]) {
        $wins = [int]$Hero.RingWinsTotal
    }

    if ($wins -ge 10) {
        if ($Hero.RingWinsTotal -ge 15) {
            return "Dorr jerks his chin toward the back shadows. 'Now they send the specialists. Men who read grips, break rhythm, and come in with plans instead of temper.'"
        }

        return "Dorr's grin turns sharp. 'Now you get the ones who study habits, hold grudges, and come in with something to prove.'"
    }

    if ($wins -ge 5) {
        return "Dorr hooks a thumb toward the back benches. 'You won't see many easy bruisers now. Faster hands, smarter guards, meaner reads.'"
    }

    return "Dorr squints toward the waiting fighters. 'Some swing wild. Some hide behind a tight guard. Some want the floor under you more than your jaw. Watch their first step.'"
}

function Test-HeroReadyForRingMonsterChallenges {
    param($Hero)

    if ($null -eq $Hero -or $null -eq $Hero.PSObject.Properties["Level"]) {
        return $false
    }

    return ([int]$Hero.Level -ge 4)
}

function Get-RingMonsterChallengeTalk {
    param(
        $Hero,
        $Game = $null
    )

    if (-not (Test-HeroReadyForRingMonsterChallenges -Hero $Hero)) {
        return "Dorr's grin fades into a measuring look. 'Monster bouts are not tavern dares. When you have survived enough real trouble to stand at level four, we can talk about contracts beyond the wall.'"
    }

    if ($null -ne $Game) {
        Initialize-MonsterZoneState -Game $Game
        $defeatedCount = @($Game.Town.MonsterZone.DefeatedCreatures.Keys).Count
        $reportedCount = @($Game.Town.MonsterZone.ReportedCreaturesToDorr.Keys).Count

        if ($defeatedCount -le 0) {
            return "Dorr leans on the rail. 'I can sell a city crowd on bruisers, but not ghost stories. Walk beyond the wall, beat something that should have stayed outside, then come back and tell me exactly what it was.'"
        }

        if ($reportedCount -le 0) {
            return "Dorr's attention sharpens when $($Hero.Name) mentions the outer grass. 'Good. Give me the shape of it. Claws, tusks, habits. I will know which contracts can survive the telling.'"
        }
    }

    if ($Hero.RingWinsTotal -ge 10) {
        return "Dorr lowers his voice. 'Champion hands against city bruisers is one thing. Champion hands against things dragged in from beyond the wall? That is how a name turns into a warning. Bring me a real monster trail when the outer contracts open, and I will make the pit listen.'"
    }

    return "Dorr taps the rail, eyes bright with ugly possibilities. 'Level four means you have lived through enough that I can say this plainly: once the outer contracts open, I can put your bare hands against things with claws, hides, and prices on their heads. Win those, and the city will not just pay you. It will talk about you.'"
}

function Get-RingMonsterChallengeContracts {
    return @(
        [PSCustomObject]@{
            Id = "wall_scraper_trial"
            Name = "Wall-Scraper Trial"
            Type = "Proof Bout"
            SourceCreatureIds = @("kobold_wall_scout", "wall_wolf")
            RequiredReputation = 0
            RequiresChampionNight = $false
            Hook = "A clawed wall-scavenger or scout that learns city patrol routes."
            Rule = "Dorr only signs it after the hero has beaten a matching creature beyond the wall and reported the trail."
            RewardPreview = "+ring reputation, bounty coin, Beast-Hand notice"
            RewardCopper = 180
            ReputationReward = 8
            Opponent = [PSCustomObject]@{
                Name = "The Wall-Scraper"
                Definite = "The Wall-Scraper"
                ArmorClass = 13
                HP = 14
                AttackBonus = 3
                DamageDiceSides = 4
                DamageBonus = 2
                GrappleBonus = 3
                GrappleChance = 25
                FocusChance = 10
                BlockChance = 10
                Intro = "A roped, clawed thing snaps at the sand while Dorr's handlers back away fast. The crowd goes quiet in a way city fighters never earn."
            }
        },
        [PSCustomObject]@{
            Id = "mire_tusk_clinch"
            Name = "Mire-Tusk Clinch"
            Type = "Grapple Contract"
            SourceCreatureIds = @("razor_boar")
            RequiredReputation = 25
            RequiresChampionNight = $false
            Hook = "A low marsh brute with a price on its tusks and a habit of breaking nets."
            Rule = "Unarmed takedown; weapons spoil the ring story even if they save skin."
            RewardPreview = "+larger reputation, tusk bounty, grappler crowd title"
            RewardCopper = 260
            ReputationReward = 12
            Opponent = [PSCustomObject]@{
                Name = "Mire-Tusk"
                Definite = "Mire-Tusk"
                ArmorClass = 12
                HP = 18
                AttackBonus = 3
                DamageDiceSides = 6
                DamageBonus = 2
                GrappleBonus = 5
                GrappleChance = 40
                FocusChance = 5
                BlockChance = 5
                Intro = "Mire-Tusk hammers the boards with its hooves, too low and too heavy for any clean prize-fighter stance. This is not a bout. It is weather with teeth."
            }
        },
        [PSCustomObject]@{
            Id = "lantern_eater_exhibition"
            Name = "Lantern-Eater Exhibition"
            Type = "Named Monster"
            SourceCreatureIds = @("grave_hungry_thing", "scale_touched_mastiff")
            RequiredReputation = 0
            RequiresChampionNight = $true
            Hook = "Something pale or scale-touched that stalks road lanterns and leaves glass bitten clean."
            Rule = "Dorr needs both a champion name and a reported outer-wall monster trail before he books it."
            RewardPreview = "+major reputation, monster rumor, possible title beyond Pit Champion"
            RewardCopper = 400
            ReputationReward = 18
            Opponent = [PSCustomObject]@{
                Name = "The Lantern-Eater"
                Definite = "The Lantern-Eater"
                ArmorClass = 14
                HP = 22
                AttackBonus = 4
                DamageDiceSides = 6
                DamageBonus = 3
                GrappleBonus = 4
                GrappleChance = 25
                FocusChance = 15
                BlockChance = 15
                Intro = "The lanterns around the pit burn low when the creature is led in. Even Dorr stops smiling until the ropes are checked twice."
            }
        }
    )
}

function Test-RingMonsterContractCompleted {
    param(
        $Game,
        $Contract
    )

    if ($null -eq $Game -or $null -eq $Contract) {
        return $false
    }

    Initialize-MonsterZoneState -Game $Game
    return [bool]$Game.Town.MonsterZone.CompletedRingMonsterContracts[[string]$Contract.Id]
}

function Test-RingMonsterContractHasReportedCreature {
    param(
        $Game,
        $Contract
    )

    if ($null -eq $Game -or $null -eq $Contract) {
        return $false
    }

    Initialize-MonsterZoneState -Game $Game

    foreach ($creatureId in @($Contract.SourceCreatureIds)) {
        if ([bool]$Game.Town.MonsterZone.ReportedCreaturesToDorr[[string]$creatureId]) {
            return $true
        }
    }

    return $false
}

function Get-RingMonsterContractReadiness {
    param(
        $Game,
        $Contract
    )

    $missing = @()

    if ($null -eq $Game -or $null -eq $Contract) {
        return [PSCustomObject]@{ CanTake = $false; Missing = @("no game state"); Readiness = "Unavailable" }
    }

    Initialize-MonsterZoneState -Game $Game

    if (-not (Test-HeroReadyForRingMonsterChallenges -Hero $Game.Hero)) {
        $missing += "level 4"
    }

    if (Test-RingMonsterContractCompleted -Game $Game -Contract $Contract) {
        $missing += "already completed"
    }

    if (-not (Test-RingMonsterContractHasReportedCreature -Game $Game -Contract $Contract)) {
        $missing += "reported matching monster"
    }

    if ([int]$Contract.RequiredReputation -gt (Get-HeroRingReputation -Hero $Game.Hero)) {
        $missing += "ring reputation $($Contract.RequiredReputation)"
    }

    if ([bool]$Contract.RequiresChampionNight -and -not (Test-HeroWonRingChampionNight -Hero $Game.Hero)) {
        $missing += "Pit Champion title"
    }

    if ($missing.Count -gt 0) {
        return [PSCustomObject]@{
            CanTake = $false
            Missing = $missing
            Readiness = "Needs: $($missing -join ', ')"
        }
    }

    return [PSCustomObject]@{
        CanTake = $true
        Missing = @()
        Readiness = "Ready"
    }
}

function Report-MonsterZoneDiscoveriesToDorr {
    param($Game)

    Initialize-MonsterZoneState -Game $Game

    $newReports = @()

    foreach ($creatureId in @($Game.Town.MonsterZone.DefeatedCreatures.Keys)) {
        if (-not [bool]$Game.Town.MonsterZone.ReportedCreaturesToDorr[[string]$creatureId]) {
            $record = $Game.Town.MonsterZone.DefeatedCreatures[$creatureId]
            $Game.Town.MonsterZone.ReportedCreaturesToDorr[[string]$creatureId] = @{
                Id = [string]$creatureId
                Name = [string]$record["Name"]
                Count = [int]$record["Count"]
                ReportedDay = if ($null -ne $Game.Town.DayNumber) { [int]$Game.Town.DayNumber } else { 1 }
            }
            $newReports += $Game.Town.MonsterZone.ReportedCreaturesToDorr[[string]$creatureId]
        }
    }

    return [PSCustomObject]@{
        NewlyReported = $newReports
        AvailableContracts = @(Get-AvailableRingMonsterChallengeContracts -Game $Game)
    }
}

function Get-AvailableRingMonsterChallengeContracts {
    param($Game)

    $available = @()

    foreach ($contract in @(Get-RingMonsterChallengeContracts)) {
        $readiness = Get-RingMonsterContractReadiness -Game $Game -Contract $contract

        if ($readiness.CanTake) {
            $available += $contract
        }
    }

    return $available
}

function Get-RingMonsterChallengePreview {
    param(
        $Hero,
        $Game = $null
    )

    if (-not (Test-HeroReadyForRingMonsterChallenges -Hero $Hero)) {
        return @()
    }

    $title = Get-HeroUnarmedRingTitle -Hero $Hero
    $reputation = Get-HeroRingReputation -Hero $Hero
    $wonChampionNight = Test-HeroWonRingChampionNight -Hero $Hero

    $contracts = @(Get-RingMonsterChallengeContracts)

    if ($null -eq $Game) {
        $contracts[0] | Add-Member -NotePropertyName Readiness -NotePropertyValue "Level 4" -Force
        $contracts[1] | Add-Member -NotePropertyName Readiness -NotePropertyValue $(if ($reputation -ge 25) { "Ready when monster zone opens" } else { "Needs stronger ring reputation" }) -Force
        $contracts[2] | Add-Member -NotePropertyName Readiness -NotePropertyValue $(if ($wonChampionNight) { "Champion preview" } else { "Champion Night recommended" }) -Force
        $contracts[2].RewardPreview = "+major reputation, monster rumor, possible title beyond $title"

        return $contracts
    }

    foreach ($contract in $contracts) {
        $readiness = Get-RingMonsterContractReadiness -Game $Game -Contract $contract
        $contract | Add-Member -NotePropertyName Readiness -NotePropertyValue $readiness.Readiness -Force
    }

    return $contracts
}

function Show-RingMonsterChallengePreview {
    param(
        $Hero,
        $Game = $null
    )

    $contracts = @(Get-RingMonsterChallengePreview -Hero $Hero -Game $Game)

    if ($contracts.Count -eq 0) {
        return
    }

    Write-SectionTitle -Text "Monster Challenge Preview" -Color "DarkYellow"
    Write-Scene "Dorr lays the outer contracts on the rail. The names only become real when $($Hero.Name) has beaten the right thing beyond the wall and told Dorr how it fights."

    foreach ($contract in $contracts) {
        Write-EmphasisLine -Text "$($contract.Name) - $($contract.Type)" -Color "Yellow"
        Write-ColorLine "Readiness: $($contract.Readiness)" "DarkYellow"
        Write-ColorLine "Hook: $($contract.Hook)" "Gray"
        Write-ColorLine "Rule: $($contract.Rule)" "Gray"
        Write-ColorLine "Reward preview: $($contract.RewardPreview)" "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-RingMonsterChallengeContract {
    param(
        $Game,
        $Contract,
        [Nullable[bool]]$ForceWin = $null
    )

    $readiness = Get-RingMonsterContractReadiness -Game $Game -Contract $Contract

    if (-not $readiness.CanTake) {
        Write-Scene "Dorr taps the contract and shakes his head. 'Not this one yet. $($readiness.Readiness).'"
        return [PSCustomObject]@{
            Success = $false
            Won = $false
            Contract = $Contract
            Reason = $readiness.Readiness
        }
    }

    Write-SectionTitle -Text $Contract.Name -Color "Red"
    Write-Scene "Dorr signs the contract board in chalk. 'No blades. No grandstanding. You already proved this thing can bleed. Now prove the city can watch you make it yield.'"

    $Game.Hero.RingVisits += 1
    $Game.Town.Ring.Visits += 1
    $Game.Town.Ring.FoughtToday = $true

    $wonBout = if ($null -ne $ForceWin) { [bool]$ForceWin } else { Start-BrawlLoop -Hero $Game.Hero -Opponent $Contract.Opponent -Title $Contract.Name -TrackRivalry $false }

    if (-not $wonBout) {
        Write-Scene "Dorr pulls the contract slate down. 'Story is not dead. It is just uglier now. Heal first.'"
        return [PSCustomObject]@{
            Success = $true
            Won = $false
            Contract = $Contract
            ReputationAdded = 0
            RewardCopper = 0
        }
    }

    $Game.Town.MonsterZone.CompletedRingMonsterContracts[[string]$Contract.Id] = $true
    Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount ([int]$Contract.RewardCopper) | Out-Null
    $reputation = Add-HeroRingReputation -Hero $Game.Hero -Amount ([int]$Contract.ReputationReward)

    Write-EmphasisLine -Text "$($Game.Hero.Name) wins $($Contract.Name). Dorr pays $(Convert-CopperToCurrencyText -Copper ([int]$Contract.RewardCopper)) and lets the crowd chew on the story." -Color "Yellow"
    Write-EmphasisLine -Text "Monster challenge reputation: +$($reputation.Added)." -Color "Yellow"

    return [PSCustomObject]@{
        Success = $true
        Won = $true
        Contract = $Contract
        ReputationAdded = [int]$reputation.Added
        RewardCopper = [int]$Contract.RewardCopper
    }
}

function Start-RingMonsterChallengeMenu {
    param($Game)

    Write-Scene (Get-RingMonsterChallengeTalk -Hero $Game.Hero -Game $Game)

    if (-not (Test-HeroReadyForRingMonsterChallenges -Hero $Game.Hero)) {
        Write-ColorLine ""
        return
    }

    $report = Report-MonsterZoneDiscoveriesToDorr -Game $Game

    if (@($report.NewlyReported).Count -gt 0) {
        $names = @($report.NewlyReported | ForEach-Object { $_["Name"] }) -join ", "
        Write-Scene "Dorr listens to the report and marks the board: $names."
    }
    elseif (@($Game.Town.MonsterZone.DefeatedCreatures.Keys).Count -gt 0) {
        Write-Scene "Dorr has already written down every monster trail $($Game.Hero.Name) has brought him so far."
    }

    Show-RingMonsterChallengePreview -Hero $Game.Hero -Game $Game

    $available = @(Get-AvailableRingMonsterChallengeContracts -Game $Game)

    if ($available.Count -le 0) {
        Write-Scene "No monster contract is ready to take tonight."
        Write-ColorLine ""
        return
    }

    Write-ColorLine "Ready contracts:" "Yellow"
    for ($i = 0; $i -lt $available.Count; $i++) {
        Write-ColorLine "$($i + 1). $($available[$i].Name)" "White"
    }
    Write-ColorLine "0. Back to the pit" "DarkGray"
    $choice = Read-Host "Choose"

    if ($choice -eq "0") {
        return
    }

    $selectedIndex = 0

    if ([int]::TryParse($choice, [ref]$selectedIndex) -and $selectedIndex -ge 1 -and $selectedIndex -le $available.Count) {
        Resolve-RingMonsterChallengeContract -Game $Game -Contract $available[$selectedIndex - 1] | Out-Null
        return
    }

    Write-ColorLine "Choose a listed contract." "DarkYellow"
    Write-ColorLine ""
}

function Get-HeroRingRivalryRecord {
    param(
        $Hero,
        [string]$OpponentName
    )

    if ($null -eq $Hero.PSObject.Properties["RingRivalries"]) {
        $Hero | Add-Member -NotePropertyName RingRivalries -NotePropertyValue @{}
    }

    if ($null -eq $Hero.RingRivalries[$OpponentName]) {
        $Hero.RingRivalries[$OpponentName] = [PSCustomObject]@{
            HeroWins = 0
            OpponentWins = 0
        }
    }

    return $Hero.RingRivalries[$OpponentName]
}

function Update-HeroRingRivalryRecord {
    param(
        $Hero,
        $Opponent,
        [bool]$HeroWon
    )

    $record = Get-HeroRingRivalryRecord -Hero $Hero -OpponentName $Opponent.Name

    if ($HeroWon) {
        $record.HeroWins += 1
    }
    else {
        $record.OpponentWins += 1
    }

    return $record
}

function Get-NamedRingRivalIntroText {
    param(
        $Hero,
        $Opponent,
        $Record
    )

    if ($null -eq $Record -or ([int]$Record.HeroWins + [int]$Record.OpponentWins) -eq 0) {
        return $null
    }

    $score = "$($Record.HeroWins)-$($Record.OpponentWins)"

    switch ($Opponent.Name) {
        "Dockhand Vero" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Vero has wrapped his wrists tighter than last time. The grudge is practical now: he keeps testing grips in the air, hunting the answer to the hold that failed him before."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Vero smiles like a man who remembers exactly how the sand felt under $($Hero.Name). He does not need the crowd to believe in him. He already has proof."
            }

            return "Vero rolls his shoulders and nods at the score between them: $score. The crowd leans in because this one has stopped being random matchmaking."
        }
        "Street Bruiser Nella" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Nella keeps circling before the bell, eyes narrowed in study. Losing to $($Hero.Name) has made her quieter, quicker, and less interested in applause."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Nella bounces lightly on her heels, wearing past wins like good footwork: easy, balanced, and annoying to everyone who came hoping to see her humbled."
            }

            return "Nella gives $($Hero.Name) a brief salute. Their record sits even at $score, and she looks pleased that the pit has noticed."
        }
        "Champion Breaker Ysold" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Ysold enters with no smile at all. Beating a breaker once makes a story; doing it again would make $($Hero.Name) a problem she has to solve in public."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Ysold lets the crowd say her name for her. She has already cracked $($Hero.Name)'s rhythm once, and every bettor near the ropes remembers it."
            }

            return "Ysold studies $($Hero.Name) across the ropes, the score even at $score. The pit goes quieter for this kind of unfinished business."
        }
        default {
            return $null
        }
    }
}

function Get-NamedRingRivalOutcomeText {
    param(
        $Hero,
        $Opponent,
        $Record,
        [bool]$HeroWon
    )

    $score = "$($Record.HeroWins)-$($Record.OpponentWins)"

    switch ($Opponent.Name) {
        "Dockhand Vero" {
            if ($HeroWon) {
                return "Vero slaps the sand once before standing. 'Fine,' he mutters. 'Next time I take the legs first.' Their record is now $score."
            }

            return "Vero hauls himself up with a grin and points two fingers at the floor. 'Told you. Everyone ends up down here.' Their record is now $score."
        }
        "Street Bruiser Nella" {
            if ($HeroWon) {
                return "Nella exhales a laugh despite herself. 'Good read,' she says, already replaying the exchange in her head. Their record is now $score."
            }

            return "Nella steps away before the crowd can grab too much of the moment. 'Too slow on the turn,' she calls back. Their record is now $score."
        }
        "Champion Breaker Ysold" {
            if ($HeroWon) {
                return "Ysold gives $($Hero.Name) one hard nod. From her, it lands louder than praise. Their record is now $score."
            }

            return "Ysold leaves the ropes calm and unsentimental. 'Champion talk is cheap after the bell,' she says. Their record is now $score."
        }
        default {
            return $null
        }
    }
}

function Get-RingOpponentIntro {
    param(
        $Hero,
        $Opponent
    )

    $intro = Resolve-HeroNarrativeText -Text $Opponent.Intro -Hero $Hero
    $record = Get-HeroRingRivalryRecord -Hero $Hero -OpponentName $Opponent.Name

    if ($record.HeroWins -eq 0 -and $record.OpponentWins -eq 0) {
        return $intro
    }

    $namedRivalText = Get-NamedRingRivalIntroText -Hero $Hero -Opponent $Opponent -Record $record

    if (-not [string]::IsNullOrWhiteSpace($namedRivalText)) {
        $intro = "$intro `n$namedRivalText"
    }

    if ($record.HeroWins -gt 0 -and $record.OpponentWins -eq 0) {
        return "$intro `n$($Opponent.Name) does not hide the fact that $($Hero.Name) has already beaten $([int]$record.HeroWins) time(s), and the crowd can feel the grudge."
    }

    if ($record.OpponentWins -gt 0 -and $record.HeroWins -eq 0) {
        return "$intro `n$($Opponent.Name) carries the easy confidence of someone who has already put $($Hero.Name) on the canvas $([int]$record.OpponentWins) time(s)."
    }

    if ($record.HeroWins -eq $record.OpponentWins) {
        return "$intro `nTheir record stands even at $($record.HeroWins)-$($record.OpponentWins), and the pit treats it like unfinished business."
    }

    if ($record.HeroWins -gt $record.OpponentWins) {
        return "$intro `n$($Hero.Name) leads their rivalry $($record.HeroWins)-$($record.OpponentWins), which leaves $($Opponent.Name) tense, proud, and eager to change that."
    }

    return "$intro `n$($Opponent.Name) leads their rivalry $($record.OpponentWins)-$($record.HeroWins), and steps in like someone expecting history to repeat."
}

function Grant-RingTraining {
    param(
        $Hero,
        [int]$Wins
    )

    $Hero.RingWinsTotal += $Wins
    $unlocked = $false

    if ($Hero.UnarmedTrainingLevel -lt 1 -and $Hero.RingWinsTotal -ge 10) {
        $Hero.UnarmedTrainingLevel = 1
        $unlocked = $true
    }
    elseif ($Hero.UnarmedTrainingLevel -lt 2 -and $Hero.RingWinsTotal -ge 20) {
        $Hero.UnarmedTrainingLevel = 2
        $unlocked = $true
    }

    return [PSCustomObject]@{
        Unlocked = $unlocked
        TotalWins = $Hero.RingWinsTotal
    }
}

function Invoke-HeroBrawlAttack {
    param(
        $Hero,
        $Opponent,
        [ref]$OpponentHP,
        [int]$AttackBonusModifier = 0,
        [int]$TargetArmorBonus = 0,
        [string]$TargetAction = "Punch",
        $HeroHP = $null,
        $HeroTurnEnded = $null
    )

    $profile = Get-HeroUnarmedProfile -Hero $Hero
    $roll = Roll-Dice -Sides 20
    $total = $roll + $profile.TotalAttackBonus + $AttackBonusModifier
    $bonusText = ""
    $targetArmorClass = $Opponent.ArmorClass + $TargetArmorBonus

    if ($AttackBonusModifier -gt 0) {
        $bonusText = " (+$AttackBonusModifier focus)"
    }

    if ($TargetArmorBonus -gt 0) {
        $bonusText += " against guarded AC"
    }

    Write-Action "$($Hero.Name) steps in with a hard punch." "Cyan"

    if ($roll -eq 20) {
        $extraRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $profile.DamageMax + $extraRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) lands a brutal hook that rocks $($Opponent.Definite)." "Yellow"
    }
    elseif ($roll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Opponent -HeroHP $HeroHP -HeroTurnEnded $HeroTurnEnded
    }
    elseif ($total -ge $targetArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $damageRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "$($Hero.Name) lands cleanly and drives $($Opponent.Definite) back." "Yellow"
    }
    else {
        Write-Action "$($Opponent.Definite) slips the shot." "DarkGray"
    }

    if ($OpponentHP.Value -lt 0) {
        $OpponentHP.Value = 0
    }

    Write-ColorLine ""
}

function Invoke-OpponentBrawlAttack {
    param(
        $Hero,
        $Opponent,
        [ref]$HeroHP,
        [int]$BlockArmorBonus = 0,
        [int]$AttackBonusModifier = 0,
        [string]$TargetAction = "Punch"
    )

    # Ring bouts use the hero's current defensive gear baseline, with Block temporarily raising it.
    $heroArmorClass = (Get-HeroArmorClass -Hero $Hero) + $BlockArmorBonus
    $roll = Roll-Dice -Sides 20
    $total = $roll + $Opponent.AttackBonus + $AttackBonusModifier
    $blockText = ""

    if ($BlockArmorBonus -gt 0) {
        $blockText = " (including +$BlockArmorBonus block)"
    }

    if ($AttackBonusModifier -gt 0) {
        $blockText += " (+$AttackBonusModifier focus)"
    }

    Write-Action "$($Opponent.Definite) surges forward behind a swinging punch." "DarkCyan"

    if ($roll -eq 20) {
        $secondDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $Opponent.DamageDiceSides + $secondDamage + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Opponent.Definite) crashes through $($Hero.Name)'s guard with a huge hit." "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Opponent.Definite) slips and loses the angle." "DarkGray"
    }
    elseif ($total -ge $heroArmorClass) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $damageRoll + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "$($Opponent.Definite) clips $($Hero.Name) with a solid shot." "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) slips clear." "DarkGray"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
    }

    Write-ColorLine ""
}

function Resolve-OpponentBrawlGrapple {
    param(
        $Hero,
        $Opponent,
        [ref]$HeroHP,
        [ref]$HeroOffBalance
    )

    $heroAbility = Get-HeroBrawlAbility -Hero $Hero
    $heroModifier = Get-HeroAbilityModifier -Hero $Hero -Ability $heroAbility
    $trainingBonus = 0

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $trainingBonus = [int]$Hero.UnarmedTrainingLevel
    }

    $opponentGrappleBonus = [int]$Opponent.GrappleBonus
    $heroRoll = Roll-Dice -Sides 20
    $opponentRoll = Roll-Dice -Sides 20
    $heroTotal = $heroRoll + $heroModifier + $trainingBonus
    $opponentTotal = $opponentRoll + $opponentGrappleBonus

    Write-Action "$($Opponent.Definite) dives in for a takedown and $($Hero.Name) braces hard against it." "DarkCyan"

    if ($opponentRoll -eq 20 -or ($heroRoll -ne 20 -and $opponentTotal -ge $heroTotal)) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $controlDamage = [Math]::Max(1, $damageRoll + $Opponent.DamageBonus)
        $HeroHP.Value -= $controlDamage
        $HeroOffBalance.Value = $true
        Write-Action "$($Opponent.Definite) drags $($Hero.Name) down into the sand and leaves $($Hero.GenderPronouns.Objective) scrambling up." "Yellow"

        if ($HeroHP.Value -lt 0) {
            $HeroHP.Value = 0
        }

        Write-ColorLine ""
        return $true
    }

    Write-Action "$($Hero.Name) fights free before the hold can settle." "DarkGray"
    Write-ColorLine ""
    return $false
}

function Get-OpponentBrawlAction {
    param($Opponent)

    $roll = Roll-Dice -Sides 100
    $grappleChance = [int]$Opponent.GrappleChance
    $focusChance = [int]$Opponent.FocusChance
    $blockChance = [int]$Opponent.BlockChance

    if ($roll -le $grappleChance) {
        return "G"
    }

    if ($roll -le ($grappleChance + $focusChance)) {
        return "F"
    }

    if ($roll -le ($grappleChance + $focusChance + $blockChance)) {
        return "B"
    }

    return "P"
}

function Get-BrawlActionLabel {
    param([string]$Action)

    switch ($Action) {
        "P" { return "Punch" }
        "B" { return "Block" }
        "F" { return "Focus" }
        "G" { return "Grapple" }
        "R" { return "Recover" }
        default { return "Recover" }
    }
}

function Get-OffBalanceBrawlAction {
    param([string]$Action)

    if ($Action -in @("B", "P")) {
        return $Action
    }

    return "P"
}

function Resolve-BrawlGrappleContest {
    param(
        $Hero,
        $Opponent,
        [ref]$HeroHP,
        [ref]$OpponentHP,
        [ref]$HeroOffBalance,
        [ref]$OpponentOffBalance,
        [bool]$HeroUsesModifier = $true,
        [bool]$OpponentUsesModifier = $true,
        [int]$HeroFlatBonus = 0,
        [int]$OpponentFlatBonus = 0,
        [int]$HeroDamageBonus = 0,
        [int]$OpponentDamageBonus = 0,
        [string]$HeroActionLabel = "Grapple",
        [string]$OpponentActionLabel = "Grapple"
    )

    $heroAbility = Get-HeroBrawlAbility -Hero $Hero
    $heroModifier = 0
    $trainingBonus = 0

    if ($HeroUsesModifier) {
        $heroModifier = Get-HeroAbilityModifier -Hero $Hero -Ability $heroAbility

        if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
            $trainingBonus = [int]$Hero.UnarmedTrainingLevel
        }
    }

    $opponentModifier = 0

    if ($OpponentUsesModifier) {
        $opponentModifier = [int]$Opponent.GrappleBonus
    }

    $heroRoll = Roll-Dice -Sides 20
    $opponentRoll = Roll-Dice -Sides 20
    $heroTotal = $heroRoll + $heroModifier + $trainingBonus + $HeroFlatBonus
    $opponentTotal = $opponentRoll + $opponentModifier + $OpponentFlatBonus
    $heroBonusText = if ($HeroFlatBonus -gt 0) { " (+$HeroFlatBonus)" } elseif ($HeroFlatBonus -lt 0) { " ($HeroFlatBonus)" } else { "" }
    $opponentBonusText = if ($OpponentFlatBonus -gt 0) { " (+$OpponentFlatBonus)" } elseif ($OpponentFlatBonus -lt 0) { " ($OpponentFlatBonus)" } else { "" }

    Write-Action "$($Hero.Name) commits to ${HeroActionLabel}: d20 roll $heroRoll, total $heroTotal$heroBonusText" "Cyan"
    Write-Action "$($Opponent.Definite) answers with ${OpponentActionLabel}: d20 roll $opponentRoll, total $opponentTotal$opponentBonusText" "DarkCyan"

    if ($heroRoll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Opponent -HeroHP $HeroHP
        Write-ColorLine ""
        return "HeroCriticalFail"
    }

    if ($heroRoll -eq 20 -or ($opponentRoll -ne 20 -and $heroTotal -gt $opponentTotal)) {
        $damageRoll = Roll-Dice -Sides 4
        $controlDamage = [Math]::Max(1, $damageRoll + [Math]::Max(0, $heroModifier) + $trainingBonus + $HeroDamageBonus)
        $OpponentHP.Value -= $controlDamage

        if ($OpponentHP.Value -lt 0) {
            $OpponentHP.Value = 0
        }

        $OpponentOffBalance.Value = $true
        Write-Action "$($Hero.Name) wins the clinch for $controlDamage damage! ($damageRoll + $([Math]::Max(0, $heroModifier) + $trainingBonus + $HeroDamageBonus)) $($Opponent.Definite) is left off balance for the next round." "Yellow"
        Write-ColorLine ""
        return "Hero"
    }

    if ($opponentRoll -eq 20 -or $opponentTotal -gt $heroTotal) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $controlDamage = [Math]::Max(1, $damageRoll + [Math]::Max(0, $opponentModifier) + $OpponentDamageBonus)
        $HeroHP.Value -= $controlDamage

        if ($HeroHP.Value -lt 0) {
            $HeroHP.Value = 0
        }

        $HeroOffBalance.Value = $true
        Write-Action "$($Opponent.Definite) wins the clinch for $controlDamage damage! ($damageRoll + $([Math]::Max(0, $opponentModifier) + $OpponentDamageBonus)) $($Hero.Name) is left off balance for the next round." "Yellow"
        Write-ColorLine ""
        return "Opponent"
    }

    Write-Action "Neither fighter secures the hold cleanly." "DarkGray"
    Write-ColorLine ""
    return "Tie"
}

function Resolve-BrawlGrappleAttempt {
    param(
        $Hero,
        $Opponent,
        [ref]$HeroHP,
        [ref]$OpponentHP,
        [ref]$HeroOffBalance,
        [ref]$OpponentOffBalance,
        [ref]$HeroFocusAttackBonus,
        [ref]$OpponentFocusAttackBonus,
        [bool]$HeroInitiates,
        [string]$DefenderAction = "Recover"
    )

    $heroProfile = Get-HeroUnarmedProfile -Hero $Hero
    $heroGrappleBonus = Get-HeroAbilityModifier -Hero $Hero -Ability (Get-HeroBrawlAbility -Hero $Hero)

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $heroGrappleBonus += [int]$Hero.UnarmedTrainingLevel
    }

    $initiatorName = if ($HeroInitiates) { $Hero.Name } else { $Opponent.Definite }
    $defenderName = if ($HeroInitiates) { $Opponent.Definite } else { $Hero.Name }
    $initiatorActionLabel = "Grapple"
    $defenderActionLabel = $DefenderAction

    $initiatorRoll = Roll-Dice -Sides 20
    $initiatorBonus = if ($HeroInitiates) { $heroGrappleBonus } else { [int]$Opponent.GrappleBonus }
    $initiatorTotal = $initiatorRoll + $initiatorBonus

    $defenderRoll = Roll-Dice -Sides 20
    $defenderBonus = 0

    switch ($DefenderAction) {
        "Punch" {
            $defenderBonus = if ($HeroInitiates) { [int]$Opponent.AttackBonus } else { [int]$heroProfile.TotalAttackBonus }
        }
        "Block" { $defenderBonus = 0 }
        "Focus" { $defenderBonus = 0 }
        "Recover" { $defenderBonus = 0 }
    }

    $defenderTotal = $defenderRoll + $defenderBonus
    $defenderBonusText = if ($defenderBonus -gt 0) { " (+$defenderBonus)" } else { "" }

    Write-Action "$initiatorName shoots in for a clinch while $defenderName answers on instinct." "Cyan"

    if ($HeroInitiates -and $initiatorRoll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Opponent -HeroHP $HeroHP
        Write-ColorLine ""
        return "HeroCriticalFail"
    }

    if (-not $HeroInitiates -and $defenderRoll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Opponent -HeroHP $HeroHP
        Write-ColorLine ""
        return "HeroCriticalFail"
    }

    if ($initiatorRoll -eq 20 -or ($defenderRoll -ne 20 -and $initiatorTotal -gt $defenderTotal)) {
        if ($HeroInitiates) {
            $damageRoll = Roll-Dice -Sides 4
            $controlDamage = [Math]::Max(1, $damageRoll + [Math]::Max(0, $heroGrappleBonus))
            $OpponentHP.Value -= $controlDamage

            if ($OpponentHP.Value -lt 0) {
                $OpponentHP.Value = 0
            }

            $OpponentOffBalance.Value = $true
            Write-Action "$($Hero.Name) muscles the clinch through and leaves $($Opponent.Definite) stumbling into the next exchange." "Yellow"
        }
        else {
            $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
            $controlDamage = [Math]::Max(1, $damageRoll + [Math]::Max(0, [int]$Opponent.GrappleBonus))
            $HeroHP.Value -= $controlDamage

            if ($HeroHP.Value -lt 0) {
                $HeroHP.Value = 0
            }

            $HeroOffBalance.Value = $true
            Write-Action "$($Opponent.Definite) forces the clinch through and leaves $($Hero.Name) off balance for the next exchange." "Yellow"
        }

        Write-ColorLine ""
        return "Initiator"
    }

    Write-Action "$defenderName slips the takedown before it can settle." "DarkGray"

    switch ($DefenderAction) {
        "Punch" {
            if ($HeroInitiates) {
                Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP $HeroHP -AttackBonusModifier $OpponentFocusAttackBonus.Value -TargetAction "Grapple"
                $OpponentFocusAttackBonus.Value = 0
            }
            else {
                Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP $OpponentHP -AttackBonusModifier $HeroFocusAttackBonus.Value -TargetAction "Grapple" -HeroHP $HeroHP
                $HeroFocusAttackBonus.Value = 0
            }
        }
        "Focus" {
            if ($HeroInitiates) {
                $OpponentFocusAttackBonus.Value = 2
                Write-Action "$($Opponent.Definite) turns the scramble into a better read on the fight." "Yellow"
                Write-ColorLine ""
            }
            else {
                $HeroFocusAttackBonus.Value = 2
                Write-Action "$($Hero.Name) turns the scramble into a better read on the fight." "Yellow"
                Write-ColorLine ""
            }
        }
        "Block" {
            Write-Scene "$defenderName keeps the guard disciplined and gives up nothing else."
            Write-ColorLine ""
        }
        "Recover" {
            Write-Scene "$defenderName escapes cleanly and resets their footing."
            Write-ColorLine ""
        }
    }

    return "Defender"
}

function Start-BrawlLoop {
    param(
        $Hero,
        $Opponent,
        [string]$Title = "Brawl",
        [bool]$TrackRivalry = $false
    )

    $heroBrawlHP = $Hero.HP
    $opponentHP = $Opponent.HP
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroActionCounts = @{ P = 0; G = 0; B = 0; F = 0 }
    $rounds = 0

    Write-SectionTitle -Text $Title -Color "Yellow"
    Write-Scene (Get-RingOpponentIntro -Hero $Hero -Opponent $Opponent)
    Write-ColorLine ""

    while ($heroBrawlHP -gt 0 -and $opponentHP -gt 0) {
        Write-ColorLine "$($Hero.Name): $heroBrawlHP HP | $($Opponent.Name): $opponentHP HP" "Green"
        Write-ColorLine "P. Throw hands" "White"
        Write-ColorLine "G. Go for a takedown" "White"
        Write-ColorLine "B. Cover up" "White"
        Write-ColorLine "F. Read the next move" "White"
        Write-ColorLine "C. Concede" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        if ($choice -eq "C") {
            Write-Scene "$($Hero.Name) raises a hand and backs out before the beating gets worse."
            return $false
        }

        if ($choice -notin @("P", "G", "B", "F")) {
            Write-ColorLine "Choose P, G, B, F or C." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $opponentChoice = Get-OpponentBrawlAction -Opponent $Opponent
        $heroChoice = $choice
        $heroAdjusted = $false

        if ($heroOffBalance) {
            $heroChoice = Get-OffBalanceBrawlAction -Action $choice
            $heroAdjusted = $heroChoice -ne $choice

            if ($heroAdjusted) {
                Write-Scene "$($Hero.Name) is still recovering and cannot commit fully this round."
            }
        }

        $opponentDisplayChoice = $opponentChoice
        $opponentAdjusted = $false

        if ($opponentOffBalance) {
            $opponentDisplayChoice = Get-OffBalanceBrawlAction -Action $opponentChoice
            $opponentAdjusted = $opponentDisplayChoice -ne $opponentChoice

            if ($opponentAdjusted) {
                Write-Scene "$($Opponent.Definite) is still scrambling for footing and settles for something simpler."
            }
        }

        $heroOffBalance = $false
        $opponentOffBalance = $false
        $heroActionCounts[$heroChoice] = [int]$heroActionCounts[$heroChoice] + 1
        $rounds += 1

        switch ("$heroChoice/$opponentDisplayChoice") {
                "P/P" {
                    $heroTurnEnded = $false
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetAction "Punch" -HeroHP ([ref]$heroBrawlHP) -HeroTurnEnded ([ref]$heroTurnEnded)
                    $heroFocusAttackBonus = 0

                    if ($opponentHP -gt 0 -and -not $heroTurnEnded) {
                        Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Punch"
                        $opponentFocusAttackBonus = 0
                    }
                }
                "P/B" {
                    $heroTurnEnded = $false
                    Write-Scene "$($Opponent.Definite) reads the swing and shells up in time."
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetArmorBonus 2 -TargetAction "Block" -HeroHP ([ref]$heroBrawlHP) -HeroTurnEnded ([ref]$heroTurnEnded)
                    $heroFocusAttackBonus = 0
                }
                "B/P" {
                    Write-Scene "$($Hero.Name) braces behind a tight guard."
                    Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -BlockArmorBonus 2 -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Block"
                    $opponentFocusAttackBonus = 0
                }
                "P/F" {
                    $heroTurnEnded = $false
                    Write-Scene "$($Opponent.Definite) hesitates for a read and gives $($Hero.Name) the cleaner opening."
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetAction "Focus" -HeroHP ([ref]$heroBrawlHP) -HeroTurnEnded ([ref]$heroTurnEnded)
                    $heroFocusAttackBonus = 0

                    if ($opponentHP -gt 0 -and -not $heroTurnEnded) {
                        $opponentFocusAttackBonus = 2
                        Write-Action "$($Opponent.Definite) still comes away with a sharper read for the next exchange." "Yellow"
                        Write-ColorLine ""
                    }
                }
                "F/P" {
                    Write-Scene "$($Hero.Name) waits for the read a moment too long and gives up the cleaner opening."
                    Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Focus"
                    $opponentFocusAttackBonus = 0

                    if ($heroBrawlHP -gt 0) {
                        $heroFocusAttackBonus = 2
                        Write-Action "$($Hero.Name) still comes away with a sharper read for the next exchange." "Yellow"
                        Write-ColorLine ""
                    }
                }
                "B/B" {
                    Write-Scene "Both fighters stay disciplined, circle, and make the crowd wait for the next real opening."
                    Write-ColorLine ""
                }
                "F/F" {
                    $heroFocusAttackBonus = 2
                    $opponentFocusAttackBonus = 2
                    Write-Scene "Both fighters slow the pace, study each other, and build toward a sharper next exchange."
                    Write-ColorLine ""
                }
                "F/B" {
                    $heroFocusAttackBonus = 2
                    Write-Scene "$($Hero.Name) uses the guarded lull to get a better read."
                    Write-Action "$($Hero.Name) is set up better for the next clean strike." "Yellow"
                    Write-ColorLine ""
                }
                "B/F" {
                    $opponentFocusAttackBonus = 2
                    Write-Scene "$($Opponent.Definite) uses the guarded lull to get a better read."
                    Write-Action "$($Opponent.Definite) is set up better for the next clean strike." "Yellow"
                    Write-ColorLine ""
                }
                "G/G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroActionLabel "Grapple" -OpponentActionLabel "Grapple" | Out-Null
                }
                "G/B" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Block" | Out-Null
                }
                "B/G" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $false -DefenderAction "Block" | Out-Null
                }
                "G/F" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Focus" | Out-Null
                }
                "F/G" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $false -DefenderAction "Focus" | Out-Null
                }
                "G/P" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Punch" | Out-Null
                }
                "P/G" {
                    Resolve-BrawlGrappleAttempt -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $false -DefenderAction "Punch" | Out-Null
                }
        }

        if ($opponentHP -le 0) {
            Write-Scene "$($Opponent.Name) drops to one knee and yields the fight."
            $styleSummary = Get-RingFightStyleSummary -ActionCounts $heroActionCounts -Rounds $rounds -HeroWon $true
            $styleResult = Add-HeroRingStyleResult -Hero $Hero -StyleSummary $styleSummary
            Write-Scene $styleSummary.CrowdText

            if ($styleResult.ReputationAdded -gt 0) {
                Write-EmphasisLine -Text "Crowd taste: $($styleResult.Style) (+$($styleResult.ReputationAdded) ring reputation)." -Color "Yellow"
            }
            else {
                Write-ColorLine "Crowd taste: $($styleResult.Style)" "DarkYellow"
            }

            if ($TrackRivalry) {
                $updatedRecord = Update-HeroRingRivalryRecord -Hero $Hero -Opponent $Opponent -HeroWon $true
                $rivalOutcome = Get-NamedRingRivalOutcomeText -Hero $Hero -Opponent $Opponent -Record $updatedRecord -HeroWon $true

                if (-not [string]::IsNullOrWhiteSpace($rivalOutcome)) {
                    Write-Scene $rivalOutcome
                }
            }

            return $true
        }

        if ($heroBrawlHP -le 0) {
            Write-Scene "$($Hero.Name) is forced down and the referee calls the bout."
            $styleSummary = Get-RingFightStyleSummary -ActionCounts $heroActionCounts -Rounds $rounds -HeroWon $false
            $styleResult = Add-HeroRingStyleResult -Hero $Hero -StyleSummary $styleSummary
            Write-Scene $styleSummary.CrowdText
            Write-ColorLine "Crowd taste: $($styleResult.Style)" "DarkYellow"

            if ($TrackRivalry) {
                $updatedRecord = Update-HeroRingRivalryRecord -Hero $Hero -Opponent $Opponent -HeroWon $false
                $rivalOutcome = Get-NamedRingRivalOutcomeText -Hero $Hero -Opponent $Opponent -Record $updatedRecord -HeroWon $false

                if (-not [string]::IsNullOrWhiteSpace($rivalOutcome)) {
                    Write-Scene $rivalOutcome
                }
            }

            return $false
        }
    }

    return $false
}

function Start-FightingRing {
    param($Game)

    if ((Get-TownTimeOfDay -Game $Game) -ne "Night") {
        Write-SectionTitle -Text "Fighting Ring" -Color "Yellow"
        Write-Scene "The pit is still being readied for the night crowd. Canvas, chalk, wagers, and bad decisions all gather properly only after dark."
        Write-ColorLine ""
        return
    }

    $entryFee = 100
    $trainingGoal = 10
    Write-SectionTitle -Text "Fighting Ring" -Color "Yellow"
    Write-TownTimeTracker -Game $Game -Area "Ring"
    Write-Scene "In a sunken pit behind heavy canvas, wagers trade hands faster than greetings and every bruise is worth an opinion."
    Write-Scene "Weapons stay out. Pride stays in. Coin changes hands either way."
    Write-Scene "Each exchange happens fast: pick a style, commit to it, and see who controls the moment."
    Write-Scene (Get-RingMasterGreeting -Hero $Game.Hero)

    $championNightReady = Test-HeroReadyForRingChampionNight -Hero $Game.Hero

    if ($championNightReady) {
        Write-Scene "Tonight, Dorr has cleared the usual ladder. The boards are packed, the odds are ugly, and Champion Breaker Ysold is waiting for a title bout."
    }

    Write-ColorLine "Entry Fee: $(Convert-CopperToCurrencyText -Copper $entryFee)" "DarkYellow"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
    Write-ColorLine "Ring Reputation: $(Get-HeroRingReputation -Hero $Game.Hero) ($(Get-RingReputationTitle -Hero $Game.Hero))" "DarkYellow"
    Write-ColorLine "Unarmed Title: $(Get-HeroUnarmedRingTitle -Hero $Game.Hero)" "DarkYellow"
    Write-ColorLine "Crowd Taste: $(Get-HeroDominantRingStyle -Hero $Game.Hero)" "DarkYellow"
    if (Test-HeroWonRingChampionNight -Hero $Game.Hero) {
        Write-ColorLine "Ring Title: Pit Champion" "DarkYellow"
    }
    elseif ($championNightReady) {
        Write-ColorLine "Champion Night: Ready" "DarkYellow"
    }

    if ($Game.Hero.RingWinsTotal -ge 10) {
        Write-ColorLine "Ring Standing: Champion" "DarkYellow"
    }
    elseif ($Game.Hero.RingWinsTotal -gt 0) {
        Write-ColorLine "Ring Standing: Known Contender ($($Game.Hero.RingWinsTotal) total wins)" "DarkYellow"
    }
    else {
        Write-ColorLine "Ring Standing: New Blood" "DarkYellow"
    }
    if ($Game.Hero.UnarmedTrainingLevel -gt 0) {
        Write-ColorLine "Pit-Fighter Basics: Tier $($Game.Hero.UnarmedTrainingLevel)" "DarkYellow"
    }
    else {
        $progressWins = [Math]::Min($Game.Hero.RingWinsTotal, $trainingGoal)
        Write-ColorLine "Pit-Fighter Basics progress: $progressWins/$trainingGoal wins" "DarkYellow"
    }
    Write-ColorLine ""
    Write-ColorLine "1. Enter the ring" "White"
    Write-ColorLine "2. Ask Dorr about the pit" "White"
    Write-ColorLine "3. Ask Dorr what sort of challengers are waiting" "White"
    Write-ColorLine "4. Ask about monster challenges" $(if (Test-HeroReadyForRingMonsterChallenges -Hero $Game.Hero) { "White" } else { "DarkGray" })
    Write-ColorLine "0. Back to town" "DarkGray"
    Write-ColorLine ""

    if ($Game.Town.WorkedForRoomToday) {
        Write-Scene "Ringmaster Dorr snorts when $($Game.Hero.Name) approaches. 'You smell like inn-work and sleep loss. Come back after a real night off.'"
        Write-ColorLine ""
        return
    }

    if ($Game.Town.Ring.FoughtToday) {
        Write-Scene "The ring master shakes his head. 'One tournament per day. Come back after you've had a real night's sleep.'"
        Write-ColorLine ""
        return
    }

    $enterRing = $false

    while ($true) {
        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $enterRing = $true
                break
            }
            "2" {
                Write-Scene (Get-RingMasterPitTalk -Hero $Game.Hero)
                Write-ColorLine ""
            }
            "3" {
                Write-Scene (Get-RingMasterOpponentTalk -Hero $Game.Hero)
                Write-ColorLine ""
            }
            "4" {
                Start-RingMonsterChallengeMenu -Game $Game
                Write-ColorLine ""

                if ($Game.Town.Ring.FoughtToday) {
                    return
                }
            }
            "0" {
                return
            }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }

        if ($enterRing) {
            break
        }
    }

    $maxRounds = if ($championNightReady) { 1 } else {
        $previewOpponents = @(Get-RingOpponents -Hero $Game.Hero)
        $previewOpponents.Count
    }
    $selectedWager = Select-RingWager -EntryFeeCopper $entryFee -MaxRounds $maxRounds

    if ($null -eq $selectedWager) {
        return
    }

    $totalEntryCost = $entryFee + [int]$selectedWager.StakeCopper
    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $totalEntryCost

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) does not have enough coin to register that purse."
        Write-ColorLine ""
        return
    }

    Write-Scene "$($Game.Hero.Name) registers the $($selectedWager.Name) for $(Convert-CopperToCurrencyText -Copper $totalEntryCost)."

    $Game.Hero.RingVisits += 1
    $Game.Town.Ring.Visits += 1
    $Game.Town.Ring.FoughtToday = $true

    $wins = 0
    $ringOpponents = if ($championNightReady) {
        @(Get-RingChampionNightOpponent)
    }
    else {
        $previewOpponents
    }

    foreach ($opponent in $ringOpponents) {
        $roundTitle = if ($championNightReady) { "Champion Night: Title Bout" } else { "Ring Round $($wins + 1)" }
        $wonBout = Start-BrawlLoop -Hero $Game.Hero -Opponent $opponent -Title $roundTitle -TrackRivalry $true

        if (-not $wonBout) {
            break
        }

        $wins += 1
        Write-Scene "The crowd roars as $($Game.Hero.Name) survives another round."
        Write-ColorLine ""
    }

    if ($championNightReady -and $wins -gt 0) {
        $championResult = Complete-RingChampionNight -Hero $Game.Hero
        Write-SectionTitle -Text "Champion Night Won" -Color "Green"
        Write-EmphasisLine -Text "$($Game.Hero.Name) leaves the ropes as $($championResult.Title). Dorr makes the crowd say it twice." -Color "Green"
        Write-EmphasisLine -Text "Champion Night reputation bonus: +$($championResult.ReputationAdded)." -Color "Yellow"
    }

    $baseRewardCopper = Get-RingRewardCopper -Wins $wins
    $wagerPayout = Resolve-RingWagerPayout -Wager $selectedWager -Wins $wins -MaxRounds $ringOpponents.Count -BaseRewardCopper $baseRewardCopper
    $rewardCopper = [int]$wagerPayout.PayoutCopper

    if ($rewardCopper -gt 0) {
        Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper | Out-Null
        Write-EmphasisLine -Text "$($Game.Hero.Name) leaves the pit with $(Convert-CopperToCurrencyText -Copper $rewardCopper) in prize money." -Color "Yellow"
    }
    else {
        Write-Scene "$($Game.Hero.Name) leaves the ring with bruises, noise in $($Game.Hero.GenderPronouns.Possessive) ears, and no prize money."
    }

    Write-Scene $wagerPayout.Text

    if ($wins -gt 0) {
        $ringRumor = Get-RingRumor -Game $Game -Wins $wins

        if (-not [string]::IsNullOrWhiteSpace($ringRumor)) {
            Write-Scene $ringRumor
        }

        $reputationResult = Add-HeroRingReputation -Hero $Game.Hero -Amount (Get-RingReputationReward -Wins $wins)
        Write-EmphasisLine -Text "Ring reputation grows by $($reputationResult.Added). Dorr now calls $($Game.Hero.Name) '$((Get-RingReputationTitle -Hero $Game.Hero))' when the crowd is listening." -Color "Yellow"

        $trainingResult = Grant-RingTraining -Hero $Game.Hero -Wins $wins

        if ($trainingResult.Unlocked) {
            Write-SectionTitle -Text "Skill Gained" -Color "Green"
            if ($Game.Hero.UnarmedTrainingLevel -eq 1) {
                Write-EmphasisLine -Text "Pit-Fighter Basics unlocked: $($Game.Hero.Name) gains +1 to hit and +1 damage with bare hands." -Color "Green"
            }
            else {
                Write-EmphasisLine -Text "Pit-Fighter Basics deepens: $($Game.Hero.Name) now gains +2 to hit and +2 damage with bare hands." -Color "Green"
            }
        }
    }

    Write-ColorLine ""
}


