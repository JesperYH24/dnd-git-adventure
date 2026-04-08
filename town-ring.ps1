# The ring is a self-contained unarmed combat loop with its own rewards and progression hooks.
function Get-RingOpponentPool {
    return @(
        [PSCustomObject]@{
            Name = "Dockhand Vero"
            Definite = "Dockhand Vero"
            Tier = 1
            ArmorClass = 11
            HP = 8
            AttackBonus = 2
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 2
            Intro = "A square-shouldered dockhand cracks his knuckles and grins through a split lip."
        }
        [PSCustomObject]@{
            Name = "Street Bruiser Nella"
            Definite = "Street Bruiser Nella"
            Tier = 1
            ArmorClass = 12
            HP = 7
            AttackBonus = 2
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 1
            Intro = "Nella rolls her neck once and comes in hard, like she expects every problem to break on impact."
        }
        [PSCustomObject]@{
            Name = "Pit Runner Sella"
            Definite = "Pit Runner Sella"
            Tier = 2
            ArmorClass = 12
            HP = 10
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 1
            GrappleBonus = 3
            Intro = "Sella circles lightly on her feet, measuring Borzig with the patience of someone used to tiring out bigger foes."
        }
        [PSCustomObject]@{
            Name = "Gravel-Tooth Harven"
            Definite = "Gravel-Tooth Harven"
            Tier = 2
            ArmorClass = 12
            HP = 11
            AttackBonus = 3
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 2
            Intro = "Harven spits blood into the sand and beckons Borzig closer with a broken grin."
        }
        [PSCustomObject]@{
            Name = "Ironjaw Marn"
            Definite = "Ironjaw Marn"
            Tier = 3
            ArmorClass = 13
            HP = 12
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 4
            Intro = "Ironjaw Marn steps into the lantern light to a chorus of shouts. The crowd knows him, and that alone is warning enough."
        }
        [PSCustomObject]@{
            Name = "Silent Torh"
            Definite = "Silent Torh"
            Tier = 3
            ArmorClass = 14
            HP = 11
            AttackBonus = 4
            DamageDiceSides = 4
            DamageBonus = 2
            GrappleBonus = 4
            Intro = "Torh says nothing at all. He only plants his feet and raises his hands, which somehow feels worse."
        }
    )
}

function Get-RingOpponents {
    $pool = Get-RingOpponentPool
    $selected = @()

    foreach ($tier in 1..3) {
        $options = @($pool | Where-Object { $_.Tier -eq $tier })

        if ($options.Count -gt 0) {
            $selected += ($options | Get-Random)
        }
    }

    return $selected
}

function Get-RingRewardCopper {
    param([int]$Wins)

    switch ($Wins) {
        1 { return 100 }
        2 { return 220 }
        3 { return 350 }
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
        [int]$AttackBonusModifier = 0
    )

    $profile = Get-HeroUnarmedProfile -Hero $Hero
    $roll = Roll-Dice -Sides 20
    $total = $roll + $profile.TotalAttackBonus + $AttackBonusModifier
    $bonusText = ""

    if ($AttackBonusModifier -gt 0) {
        $bonusText = " (+$AttackBonusModifier focus)"
    }

    Write-Action "$($Hero.Name) swings with bare hands: roll $roll, total $total$bonusText vs AC $($Opponent.ArmorClass)" "Cyan"

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
    elseif ($total -ge $Opponent.ArmorClass) {
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
        [int]$BlockArmorBonus = 0
    )

    $heroArmorClass = 10 + [Math]::Max((Get-HeroAbilityModifier -Hero $Hero -Ability "STR"), (Get-HeroAbilityModifier -Hero $Hero -Ability "DEX")) + $BlockArmorBonus
    $roll = Roll-Dice -Sides 20
    $total = $roll + $Opponent.AttackBonus
    $blockText = ""

    if ($BlockArmorBonus -gt 0) {
        $blockText = " (including +$BlockArmorBonus block)"
    }

    Write-Action "$($Opponent.Definite) throws a punch: roll $roll, total $total vs AC $heroArmorClass$blockText" "DarkCyan"

    if ($roll -eq 20) {
        $firstDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $secondDamage = Roll-Dice -Sides $Opponent.DamageDiceSides
        $damage = $firstDamage + $secondDamage + $Opponent.DamageBonus
        $HeroHP.Value -= $damage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Opponent.Definite) crashes through Borzig's guard for $damage damage! ($firstDamage + $secondDamage + $($Opponent.DamageBonus))" "Yellow"
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
    $opponentOffBalance = $false
    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0

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

        if ($choice -eq "B") {
            Write-Scene "$($Hero.Name) tightens the guard and waits for the incoming strike."
            $heroBlockArmorBonus = 2
            Write-Action "$($Hero.Name) gains +2 AC against the next punch." "Yellow"
            Write-ColorLine ""
        }
        elseif ($choice -eq "F") {
            Write-Scene "$($Hero.Name) studies the rhythm of the fight and times the next opening."
            $heroFocusAttackBonus = 2
            Write-Action "$($Hero.Name) gains +2 to hit on the next bare-handed attack." "Yellow"
            Write-ColorLine ""
        }
        elseif ($choice -eq "G") {
            Resolve-HeroBrawlGrapple -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -OpponentOffBalance ([ref]$opponentOffBalance) | Out-Null
        }
        else {
            Invoke-HeroBrawlAttack -Hero $Hero -Opponent $Opponent -OpponentHP ([ref]$opponentHP) -AttackBonusModifier $heroFocusAttackBonus
            $heroFocusAttackBonus = 0
        }

        if ($opponentHP -le 0) {
            Write-Scene "$($Opponent.Name) drops to one knee and yields the fight."
            return $true
        }

        if ($opponentOffBalance) {
            Write-Scene "$($Opponent.Definite) scrambles to recover and loses the next beat of the fight."
            Write-ColorLine ""
            $opponentOffBalance = $false
        }
        else {
            Invoke-OpponentBrawlAttack -Hero $Hero -Opponent $Opponent -HeroHP ([ref]$heroBrawlHP) -BlockArmorBonus $heroBlockArmorBonus
            $heroBlockArmorBonus = 0
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
    Write-Scene (Get-RingMasterGreeting -Hero $Game.Hero)
    Write-ColorLine "Entry Fee: $(Convert-CopperToCurrencyText -Copper $entryFee)" "DarkYellow"
    Write-ColorLine "Gold Pouch: $(Get-HeroCurrencyText -Hero $Game.Hero)" "DarkYellow"
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

    foreach ($opponent in (Get-RingOpponents)) {
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


