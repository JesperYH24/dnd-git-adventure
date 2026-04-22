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
            Intro = "Sella circles lightly on her feet, measuring Borzig with the patience of someone used to tiring out bigger foes."
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
            Intro = "Harven spits blood into the sand and beckons Borzig closer with a broken grin. He is slower than most, but every clean hit lands heavy."
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

function Get-RingOpponentIntro {
    param(
        $Hero,
        $Opponent
    )

    $intro = $Opponent.Intro
    $record = Get-HeroRingRivalryRecord -Hero $Hero -OpponentName $Opponent.Name

    if ($record.HeroWins -eq 0 -and $record.OpponentWins -eq 0) {
        return $intro
    }

    if ($record.HeroWins -gt 0 -and $record.OpponentWins -eq 0) {
        return "$intro `n$($Opponent.Name) does not hide the fact that Borzig has already beaten $([int]$record.HeroWins) time(s), and the crowd can feel the grudge."
    }

    if ($record.OpponentWins -gt 0 -and $record.HeroWins -eq 0) {
        return "$intro `n$($Opponent.Name) carries the easy confidence of someone who has already put Borzig on the canvas $([int]$record.OpponentWins) time(s)."
    }

    if ($record.HeroWins -eq $record.OpponentWins) {
        return "$intro `nTheir record stands even at $($record.HeroWins)-$($record.OpponentWins), and the pit treats it like unfinished business."
    }

    if ($record.HeroWins -gt $record.OpponentWins) {
        return "$intro `nBorzig leads their rivalry $($record.HeroWins)-$($record.OpponentWins), which leaves $($Opponent.Name) tense, proud, and eager to change that."
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

    # Ring bouts use Borzig's current defensive gear baseline, with Block temporarily raising it.
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
        Write-Action "$($Opponent.Definite) crashes through Borzig's guard with a huge hit." "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Opponent.Definite) slips and loses the angle." "DarkGray"
    }
    elseif ($total -ge $heroArmorClass) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $damageRoll + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "$($Opponent.Definite) clips Borzig with a solid shot." "Yellow"
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

    Write-Action "$($Opponent.Definite) dives in for a takedown and Borzig braces hard against it." "DarkCyan"

    if ($opponentRoll -eq 20 -or ($heroRoll -ne 20 -and $opponentTotal -ge $heroTotal)) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $controlDamage = [Math]::Max(1, $damageRoll + $Opponent.DamageBonus)
        $HeroHP.Value -= $controlDamage
        $HeroOffBalance.Value = $true
        Write-Action "$($Opponent.Definite) drags Borzig down into the sand and leaves him scrambling up." "Yellow"

        if ($HeroHP.Value -lt 0) {
            $HeroHP.Value = 0
        }

        Write-ColorLine ""
        return $true
    }

    Write-Action "Borzig fights free before the hold can settle." "DarkGray"
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
            Write-Action "$($Opponent.Definite) forces the clinch through and leaves Borzig off balance for the next exchange." "Yellow"
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

function Resolve-HeroBrawlGrapple {
    param(
        $Hero,
        $Opponent,
        [ref]$OpponentHP,
        [ref]$OpponentOffBalance,
        $HeroHP = $null
    )

    $heroAbility = Get-HeroBrawlAbility -Hero $Hero
    $heroModifier = Get-HeroAbilityModifier -Hero $Hero -Ability $heroAbility
    $trainingBonus = 0

    if ($null -ne $Hero.PSObject.Properties["UnarmedTrainingLevel"]) {
        $trainingBonus = [int]$Hero.UnarmedTrainingLevel
    }

    $opponentGrappleBonus = 0

    if ($null -ne $Opponent.PSObject.Properties["GrappleBonus"]) {
        $opponentGrappleBonus = [int]$Opponent.GrappleBonus
    }
    else {
        $opponentGrappleBonus = [int]$Opponent.AttackBonus
    }

    $heroRoll = Roll-Dice -Sides 20
    $opponentRoll = Roll-Dice -Sides 20
    $heroTotal = $heroRoll + $heroModifier + $trainingBonus
    $opponentTotal = $opponentRoll + $opponentGrappleBonus

    Write-Action "$($Hero.Name) dives for a takedown while $($Opponent.Definite) braces hard against it." "Cyan"

    if ($heroRoll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Opponent -HeroHP $HeroHP
        Write-ColorLine ""
        return $false
    }

    if ($heroRoll -eq 20 -or ($opponentRoll -ne 20 -and $heroTotal -ge $opponentTotal)) {
        $damageRoll = Roll-Dice -Sides 4
        $controlDamage = [Math]::Max(1, $damageRoll + $heroModifier + $trainingBonus)
        $OpponentHP.Value -= $controlDamage
        $OpponentOffBalance.Value = $true
        Write-Action "$($Hero.Name) drags $($Opponent.Definite) down and comes up in control." "Yellow"

        if ($OpponentHP.Value -lt 0) {
            $OpponentHP.Value = 0
        }

        Write-ColorLine ""
        return $true
    }

    Write-Action "$($Opponent.Definite) slips away before Borzig can settle the hold." "DarkGray"
    Write-ColorLine ""
    return $false
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

    Write-SectionTitle -Text $Title -Color "Yellow"
    Write-Scene (Get-RingOpponentIntro -Hero $Hero -Opponent $Opponent)
    Write-ColorLine ""

    while ($heroBrawlHP -gt 0 -and $opponentHP -gt 0) {
        Write-ColorLine "Borzig: $heroBrawlHP HP | $($Opponent.Name): $opponentHP HP" "Green"
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
                    Write-Scene "$($Opponent.Definite) hesitates for a read and gives Borzig the cleaner opening."
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

            if ($TrackRivalry) {
                Update-HeroRingRivalryRecord -Hero $Hero -Opponent $Opponent -HeroWon $true | Out-Null
            }

            return $true
        }

        if ($heroBrawlHP -le 0) {
            Write-Scene "$($Hero.Name) is forced down and the referee calls the bout."

            if ($TrackRivalry) {
                Update-HeroRingRivalryRecord -Hero $Hero -Opponent $Opponent -HeroWon $false | Out-Null
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
    Write-ColorLine "Entry Fee: $(Convert-CopperToCurrencyText -Copper $entryFee)" "DarkYellow"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
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
    Write-ColorLine "0. Back to town" "DarkGray"
    Write-ColorLine ""

    if ($Game.Town.WorkedForRoomToday) {
        Write-Scene "Ringmaster Dorr snorts when Borzig approaches. 'You smell like inn-work and sleep loss. Come back after a real night off.'"
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

    $spendResult = Spend-HeroCurrency -Hero $Game.Hero -Copper $entryFee

    if (-not $spendResult.Success) {
        Write-Scene "$($Game.Hero.Name) does not have enough coin to register for the ring."
        Write-ColorLine ""
        return
    }

    $Game.Hero.RingVisits += 1
    $Game.Town.Ring.Visits += 1
    $Game.Town.Ring.FoughtToday = $true

    $wins = 0

    foreach ($opponent in (Get-RingOpponents -Hero $Game.Hero)) {
        $wonBout = Start-BrawlLoop -Hero $Game.Hero -Opponent $opponent -Title "Ring Round $($wins + 1)" -TrackRivalry $true

        if (-not $wonBout) {
            break
        }

        $wins += 1
        Write-Scene "The crowd roars as Borzig survives another round."
        Write-ColorLine ""
    }

    $rewardCopper = Get-RingRewardCopper -Wins $wins

    if ($rewardCopper -gt 0) {
        Add-HeroCurrency -Hero $Game.Hero -Denomination "CP" -Amount $rewardCopper | Out-Null
        Write-EmphasisLine -Text "Borzig leaves the pit with $(Convert-CopperToCurrencyText -Copper $rewardCopper) in prize money." -Color "Yellow"
    }
    else {
        Write-Scene "Borzig leaves the ring with bruises, noise in his ears, and no prize money."
    }

    if ($wins -gt 0) {
        $trainingResult = Grant-RingTraining -Hero $Game.Hero -Wins $wins

        if ($trainingResult.Unlocked) {
            Write-SectionTitle -Text "Skill Gained" -Color "Green"
            if ($Game.Hero.UnarmedTrainingLevel -eq 1) {
                Write-EmphasisLine -Text "Pit-Fighter Basics unlocked: Borzig gains +1 to hit and +1 damage with bare hands." -Color "Green"
            }
            else {
                Write-EmphasisLine -Text "Pit-Fighter Basics deepens: Borzig now gains +2 to hit and +2 damage with bare hands." -Color "Green"
            }
        }
    }

    Write-ColorLine ""
}


