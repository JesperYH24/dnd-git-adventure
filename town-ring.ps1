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
    )
}

function Get-RingOpponents {
    param($Hero)

    $pool = Get-RingOpponentPool
    $maxTier = 3
    $roundCount = 3

    if ($null -ne $Hero.PSObject.Properties["RingWinsTotal"] -and [int]$Hero.RingWinsTotal -ge 10) {
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
        default { return 0 }
    }
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
        [string]$TargetAction = "Punch"
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

    Write-Action "$($Hero.Name) throws a punch into ${TargetAction}: roll $roll, total $total$bonusText vs AC $targetArmorClass" "Cyan"

    if ($roll -eq 20) {
        $extraRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $profile.DamageMax + $extraRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) lands a brutal hook for $damage damage! ($($profile.DamageMax) + $extraRoll + $($profile.DamageBonus))" "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Hero.Name) overcommits and stumbles wide." "DarkGray"
    }
    elseif ($total -ge $targetArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $profile
        $damage = [Math]::Max(1, $damageRoll + $profile.DamageBonus)
        $OpponentHP.Value -= $damage
        Write-Action "$($Hero.Name) hits for $damage damage! ($damageRoll + $($profile.DamageBonus))" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) misses!" "DarkGray"
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

    Write-Action "$($Opponent.Definite) throws a punch into ${TargetAction}: roll $roll, total $total vs AC $heroArmorClass$blockText" "DarkCyan"

    if ($roll -eq 20) {
        $secondDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $Opponent.DamageDiceSides + $secondDamage + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Opponent.Definite) crashes through Borzig's guard for $damage damage! ($($Opponent.DamageDiceSides) + $secondDamage + $($Opponent.DamageBonus))" "Yellow"
    }
    elseif ($roll -eq 1) {
        Write-Action "$($Opponent.Definite) slips and loses the angle." "DarkGray"
    }
    elseif ($total -ge $heroArmorClass) {
        $damageRoll = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $damageRoll + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "$($Opponent.Definite) hits for $damage damage! ($damageRoll + $($Opponent.DamageBonus))" "Yellow"
    }
    else {
        Write-Action "$($Opponent.Definite) misses!" "DarkGray"
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

    Write-Action "$($Opponent.Definite) lunges for a takedown: roll $opponentRoll, total $opponentTotal" "DarkCyan"
    Write-Action "$($Hero.Name) braces against it: roll $heroRoll, total $heroTotal" "Cyan"

    if ($opponentRoll -eq 20 -or ($heroRoll -ne 20 -and $opponentTotal -ge $heroTotal)) {
        $controlDamage = [Math]::Max(1, 1 + $Opponent.DamageBonus)
        $HeroHP.Value -= $controlDamage
        $HeroOffBalance.Value = $true
        Write-Action "$($Opponent.Definite) drags Borzig down for $controlDamage damage and steals the next beat of the fight!" "Yellow"

        if ($HeroHP.Value -lt 0) {
            $HeroHP.Value = 0
        }

        Write-ColorLine ""
        return $true
    }

    Write-Action "$($Opponent.Definite) fails to secure the hold." "DarkGray"
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
    $heroTotal = $heroRoll + $heroModifier + $trainingBonus
    $opponentTotal = $opponentRoll + $opponentModifier

    Write-Action "$($Hero.Name) commits to ${HeroActionLabel}: roll $heroRoll, total $heroTotal" "Cyan"
    Write-Action "$($Opponent.Definite) answers with ${OpponentActionLabel}: roll $opponentRoll, total $opponentTotal" "DarkCyan"

    if ($heroRoll -eq 20 -or ($opponentRoll -ne 20 -and $heroTotal -gt $opponentTotal)) {
        $controlDamage = [Math]::Max(1, 1 + [Math]::Max(0, $heroModifier) + $trainingBonus)
        $OpponentHP.Value -= $controlDamage

        if ($OpponentHP.Value -lt 0) {
            $OpponentHP.Value = 0
        }

        $OpponentOffBalance.Value = $true
        Write-Action "$($Hero.Name) wins the clinch, deals $controlDamage damage, and leaves $($Opponent.Definite) off balance for the next round." "Yellow"
        Write-ColorLine ""
        return "Hero"
    }

    if ($opponentRoll -eq 20 -or $opponentTotal -gt $heroTotal) {
        $controlDamage = [Math]::Max(1, 1 + [Math]::Max(0, $opponentModifier))
        $HeroHP.Value -= $controlDamage

        if ($HeroHP.Value -lt 0) {
            $HeroHP.Value = 0
        }

        $HeroOffBalance.Value = $true
        Write-Action "$($Opponent.Definite) wins the clinch, deals $controlDamage damage, and leaves $($Hero.Name) off balance for the next round." "Yellow"
        Write-ColorLine ""
        return "Opponent"
    }

    Write-Action "Neither fighter secures the hold cleanly." "DarkGray"
    Write-ColorLine ""
    return "Tie"
}

function Resolve-HeroBrawlGrapple {
    param(
        $Hero,
        $Opponent,
        [ref]$OpponentHP,
        [ref]$OpponentOffBalance
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

    Write-Action "$($Hero.Name) shoots in for a grapple: roll $heroRoll, total $heroTotal" "Cyan"
    Write-Action "$($Opponent.Definite) braces against it: roll $opponentRoll, total $opponentTotal" "DarkCyan"

    if ($heroRoll -eq 20 -or ($opponentRoll -ne 20 -and $heroTotal -ge $opponentTotal)) {
        $controlDamage = [Math]::Max(1, 1 + $heroModifier + $trainingBonus)
        $OpponentHP.Value -= $controlDamage
        $OpponentOffBalance.Value = $true
        Write-Action "$($Hero.Name) drags $($Opponent.Definite) to the ground for $controlDamage damage and steals the tempo!" "Yellow"

        if ($OpponentHP.Value -lt 0) {
            $OpponentHP.Value = 0
        }

        Write-ColorLine ""
        return $true
    }

    Write-Action "$($Hero.Name) fails to secure the hold." "DarkGray"
    Write-ColorLine ""
    return $false
}

function Start-BrawlLoop {
    param(
        $Hero,
        $Opponent,
        [string]$Title = "Brawl"
    )

    $heroBrawlHP = $Hero.HP
    $opponentHP = $Opponent.HP
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $heroOffBalance = $false
    $opponentOffBalance = $false

    Write-SectionTitle -Text $Title -Color "Yellow"
    Write-Scene $Opponent.Intro
    Write-ColorLine ""

    while ($heroBrawlHP -gt 0 -and $opponentHP -gt 0) {
        Write-ColorLine "Borzig: $heroBrawlHP HP | $($Opponent.Name): $opponentHP HP" "Green"
        Write-ColorLine "P. Punch" "White"
        Write-ColorLine "G. Grapple" "White"
        Write-ColorLine "B. Block" "White"
        Write-ColorLine "F. Focus" "White"
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
        $displayHeroChoice = if ($heroOffBalance) { "R" } else { $choice }
        $displayOpponentChoice = if ($opponentOffBalance) { "R" } else { $opponentChoice }

        Write-Action "$($Hero.Name) commits to $(Get-BrawlActionLabel -Action $displayHeroChoice)." "Cyan"
        Write-Action "$($Opponent.Definite) commits to $(Get-BrawlActionLabel -Action $displayOpponentChoice)." "DarkCyan"
        Write-ColorLine ""

        if ($heroOffBalance -and $opponentOffBalance) {
            Write-Scene "Both fighters are still reeling from the last exchange and spend the round regaining their footing."
            $heroOffBalance = $false
            $opponentOffBalance = $false
            continue
        }

        if ($heroOffBalance) {
            Write-Scene "$($Hero.Name) is off balance and can only recover this round."
            $heroOffBalance = $false

            switch ($opponentChoice) {
                "F" {
                    $opponentFocusAttackBonus = 2
                    Write-Action "$($Opponent.Definite) uses the opening to focus on the next strike." "Yellow"
                    Write-ColorLine ""
                }
                "G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $false -OpponentUsesModifier $true -HeroActionLabel "Recover" -OpponentActionLabel "Grapple" | Out-Null
                }
                "B" {
                    Write-Scene "$($Opponent.Definite) keeps the guard high and lets Borzig spend the round recovering."
                    Write-ColorLine ""
                }
                default {
                    Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Recover"
                    $opponentFocusAttackBonus = 0
                }
            }
        }
        elseif ($opponentOffBalance) {
            Write-Scene "$($Opponent.Definite) is off balance and can only recover this round."
            $opponentOffBalance = $false

            switch ($choice) {
                "F" {
                    $heroFocusAttackBonus = 2
                    Write-Action "$($Hero.Name) uses the opening to focus on the next strike." "Yellow"
                    Write-ColorLine ""
                }
                "G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $true -OpponentUsesModifier $false -HeroActionLabel "Grapple" -OpponentActionLabel "Recover" | Out-Null
                }
                "B" {
                    Write-Scene "$($Hero.Name) keeps the guard tight and lets the round breathe."
                    Write-ColorLine ""
                }
                default {
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetAction "Recover"
                    $heroFocusAttackBonus = 0
                }
            }
        }
        else {
            switch ("$choice/$opponentChoice") {
                "P/P" {
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetAction "Punch"
                    $heroFocusAttackBonus = 0

                    if ($opponentHP -gt 0) {
                        Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Punch"
                        $opponentFocusAttackBonus = 0
                    }
                }
                "P/B" {
                    Write-Scene "$($Opponent.Definite) reads the attack and brings the guard up in time."
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetArmorBonus 2 -TargetAction "Block"
                    $heroFocusAttackBonus = 0
                }
                "B/P" {
                    Write-Scene "$($Hero.Name) braces behind a tight guard."
                    Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -BlockArmorBonus 2 -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Block"
                    $opponentFocusAttackBonus = 0
                }
                "P/F" {
                    Write-Scene "$($Opponent.Definite) tries to read the rhythm, but that leaves an opening."
                    Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus -TargetAction "Focus"
                    $heroFocusAttackBonus = 0

                    if ($opponentHP -gt 0) {
                        $opponentFocusAttackBonus = 2
                        Write-Action "$($Opponent.Definite) still gains +2 to hit on the next punch." "Yellow"
                        Write-ColorLine ""
                    }
                }
                "F/P" {
                    Write-Scene "$($Hero.Name) tries to read the rhythm, but that leaves an opening."
                    Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -AttackBonusModifier $opponentFocusAttackBonus -TargetAction "Focus"
                    $opponentFocusAttackBonus = 0

                    if ($heroBrawlHP -gt 0) {
                        $heroFocusAttackBonus = 2
                        Write-Action "$($Hero.Name) still gains +2 to hit on the next punch." "Yellow"
                        Write-ColorLine ""
                    }
                }
                "B/B" {
                    Write-Scene "Both fighters settle behind careful guards and give the crowd a tense but harmless round."
                    Write-ColorLine ""
                }
                "F/F" {
                    $heroFocusAttackBonus = 2
                    $opponentFocusAttackBonus = 2
                    Write-Scene "Both fighters spend the round reading timing and distance, each building toward the next exchange."
                    Write-ColorLine ""
                }
                "F/B" {
                    $heroFocusAttackBonus = 2
                    Write-Scene "$($Hero.Name) uses the guarded pause to study the rhythm of the fight."
                    Write-Action "$($Hero.Name) gains +2 to hit on the next punch." "Yellow"
                    Write-ColorLine ""
                }
                "B/F" {
                    $opponentFocusAttackBonus = 2
                    Write-Scene "$($Opponent.Definite) uses the guarded pause to study the rhythm of the fight."
                    Write-Action "$($Opponent.Definite) gains +2 to hit on the next punch." "Yellow"
                    Write-ColorLine ""
                }
                "G/G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroActionLabel "Grapple" -OpponentActionLabel "Grapple" | Out-Null
                }
                "G/B" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $true -OpponentUsesModifier $false -HeroActionLabel "Grapple" -OpponentActionLabel "Block" | Out-Null
                }
                "B/G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $false -OpponentUsesModifier $true -HeroActionLabel "Block" -OpponentActionLabel "Grapple" | Out-Null
                }
                "G/F" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $true -OpponentUsesModifier $false -HeroActionLabel "Grapple" -OpponentActionLabel "Focus" | Out-Null
                }
                "F/G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $false -OpponentUsesModifier $true -HeroActionLabel "Focus" -OpponentActionLabel "Grapple" | Out-Null
                }
                "G/P" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $true -OpponentUsesModifier $false -HeroActionLabel "Grapple" -OpponentActionLabel "Punch" | Out-Null
                }
                "P/G" {
                    Resolve-BrawlGrappleContest -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroUsesModifier $false -OpponentUsesModifier $true -HeroActionLabel "Punch" -OpponentActionLabel "Grapple" | Out-Null
                }
            }
        }

        if ($opponentHP -le 0) {
            Write-Scene "$($Opponent.Name) drops to one knee and yields the fight."
            return $true
        }

        if ($heroBrawlHP -le 0) {
            Write-Scene "$($Hero.Name) is forced down and the referee calls the bout."
            return $false
        }
    }

    return $false
}

function Start-FightingRing {
    param($Game)

    $entryFee = 100
    $trainingGoal = 10
    Write-SectionTitle -Text "Fighting Ring" -Color "Yellow"
    Write-Scene "In a sunken pit behind heavy canvas, wagers trade hands faster than greetings and every bruise is worth an opinion."
    Write-Scene "Weapons stay out. Pride stays in. Coin changes hands either way."
    Write-Scene "Each round is read in the same breath: both fighters commit first, then the pit learns who guessed right."
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
        Write-ColorLine "Pit-Fighter Basics: unlocked" "DarkYellow"
    }
    else {
        $progressWins = [Math]::Min($Game.Hero.RingWinsTotal, $trainingGoal)
        Write-ColorLine "Pit-Fighter Basics progress: $progressWins/$trainingGoal wins" "DarkYellow"
    }
    Write-ColorLine ""
    Write-ColorLine "1. Enter the ring" "White"
    Write-ColorLine "0. Back" "DarkGray"
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

    $choice = Read-Host "Choose"

    if ($choice -ne "1") {
        return
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
        $wonBout = Start-BrawlLoop -Hero $Game.Hero -Opponent $opponent -Title "Ring Round $($wins + 1)"

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
            Write-EmphasisLine -Text "Pit-Fighter Basics unlocked: Borzig gains +1 to hit and +1 damage with bare hands." -Color "Green"
        }
    }

    Write-ColorLine ""
}


