. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\ui.ps1"

function Get-BarbarianCriticalKillText {
    param(
        $Hero,
        $Monster,
        $Weapon
    )

    $weaponName = "weapon"

    if ($null -ne $Weapon -and -not [string]::IsNullOrWhiteSpace($Weapon.Name)) {
        $weaponName = $Weapon.Name.ToLower()
    }

    return "$($Hero.Name) tears through $($Monster.definite) in a savage finishing blow, driving the $weaponName clean through the kill!"
}

function Get-RandomCombatFlavorText {
    param([string[]]$Options)

    if ($null -eq $Options -or $Options.Count -eq 0) {
        return ""
    }

    return $Options[(Get-Random -Minimum 0 -Maximum $Options.Count)]
}

function Resolve-CombatFlavorText {
    param(
        [string]$Text,
        $Hero,
        $Monster = $null
    )

    $resolved = Resolve-HeroNarrativeText -Text $Text -Hero $Hero

    if ($null -ne $Monster) {
        $targetName = if (-not [string]::IsNullOrWhiteSpace([string]$Monster.definite)) { [string]$Monster.definite } else { "the enemy" }
        $resolved = $resolved.Replace("{target}", $targetName)
    }

    return $resolved
}

function Get-BarbarianRageFlavorText {
    param($Hero)

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero}'s breathing turns heavy and wrong, like a forge being fed too much air.",
        "Something old and red wakes behind {hero}'s eyes, and pain starts looking like a useful language.",
        "{Hero} rolls {his} shoulders once, and the room suddenly remembers what fear is for.",
        "A low growl climbs out of {hero}'s chest, too controlled to be panic and too ugly to be mercy.",
        "{Hero} lets the anger in cleanly, like opening a door that should have stayed barred."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero)
}

function Get-BarbarianRecklessCommitFlavorText {
    param($Hero)

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero} stops defending and starts arriving.",
        "{Hero} grins like the wound is already worth it and throws {himself} into the opening.",
        "Caution dies first. {Hero} follows it in with both hands on the weapon.",
        "{Hero} leans past safety and turns the next heartbeat into a challenge.",
        "The smart move leaves. {Hero} stays."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero)
}

function Get-BarbarianRecklessSwingFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero}'s reckless swing comes in wide, fast, and mean enough to make {target} answer it or break.",
        "{Hero} attacks like getting hit back is someone else's problem until it happens.",
        "{Hero} sells the guard for momentum, driving the weapon at {target} with ugly confidence.",
        "{Hero} gives {target} a clean opening and makes the price of taking it look painful.",
        "No shield, no second thought: {hero} turns the attack into a dare."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-BardViciousMockeryFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero} looks {target} up and down. 'I've heard doors threaten better than you, and at least doors know when to close.'",
        "{Hero} gives {target} a pitying smile. 'That stance is brave. Not useful, but very brave.'",
        "{Hero} clicks {his} tongue. 'If confidence were armor, you'd still need a helmet.'",
        "{Hero} points at {target}'s weapon. 'Careful with that. It looks like the clever one between you.'",
        "{Hero} sighs. 'Somewhere, a village idiot is fighting unarmed because you stole the family talent.'",
        "{Hero} bows slightly. 'I would insult your technique, but I try not to punch downward twice in one sentence.'"
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-BardViciousMockeryHitFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "The words land under {target}'s skin and twist.",
        "{target} flinches like the insult found a bruise no blade could reach.",
        "The joke gets a laugh from exactly no one, which somehow makes it hurt worse.",
        "{target}'s focus cracks, and {hero}'s smile says the line did its work."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-BardViciousMockerySaveFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "{target} snarls through the insult before it can fully bite.",
        "For once, {target} has just enough dignity left to survive the joke.",
        "{target} shakes the words off, though the silence afterward is not flattering.",
        "The mockery glances off. {Hero} looks personally offended by the waste of good material."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-BardCuttingWordsFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero} cuts across {target}'s swing with a smile sharp enough to leave a mark. 'Careful. You almost looked trained.'",
        "{Hero} flicks a glance at {target}. 'That was the attack? I thought you were still looking for one.'",
        "{Hero} leans into the opening. 'Bold choice, letting your weapon embarrass you first.'",
        "{Hero} snaps, 'Less battle cry, more apology,' and the timing of {target}'s strike buckles.",
        "{Hero} laughs once, perfectly timed and absolutely cruel, right as {target} commits to the blow.",
        "{Hero} says, 'I've seen tavern doors hit with more intent,' and somehow the words get in the way."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-BardCuttingWordsPreventedHitFlavorText {
    param(
        $Hero,
        $Monster
    )

    $line = Get-RandomCombatFlavorText -Options @(
        "{target}'s attack falls apart mid-motion, murdered by timing and bad self-esteem.",
        "The blow loses its line, and {hero}'s grin makes it very clear that was the point.",
        "{target} overcorrects, hesitates, and suddenly the hit is gone.",
        "The insult lands first. The weapon arrives late, weak, and useless."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Get-HeroCriticalFailFlavorText {
    param(
        $Hero,
        $Monster
    )

    if ($Hero.Class -eq "Barbarian") {
        $line = Get-RandomCombatFlavorText -Options @(
            "{Hero} overcommits hard enough to turn rage into a bad landing.",
            "{Hero}'s swing bites empty air, and the momentum comes back mean.",
            "{Hero} drives in too deep, catches a brutal angle, and pays for it in blood.",
            "The attack goes wide. {Hero} keeps hold of the weapon, but not the clean footing."
        )

        return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
    }

    if ($Hero.Class -eq "Bard") {
        $line = Get-RandomCombatFlavorText -Options @(
            "{Hero}'s flourish turns one beat too clever, and the mistake bites back.",
            "{Hero} commits to the bit, loses the rhythm, and catches pain instead of applause.",
            "{Hero}'s attack slips off tempo, leaving no graceful way out of the recoil.",
            "The move needed confidence. {Hero} supplied too much and pays for the extra."
        )

        return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
    }

    $line = Get-RandomCombatFlavorText -Options @(
        "{Hero}'s attack goes wrong, turning momentum into a painful stumble.",
        "{Hero} misses badly and catches the ugly cost of the opening."
    )

    return (Resolve-CombatFlavorText -Text $line -Hero $Hero -Monster $Monster)
}

function Resolve-HeroCriticalFail {
    param(
        $Hero,
        $Monster,
        $HeroHP = $null,
        $HeroTurnEnded = $null
    )

    $damage = Roll-Dice -Sides 4

    Write-Action "CRITICAL FAIL!" "Magenta"
    Write-Scene (Get-HeroCriticalFailFlavorText -Hero $Hero -Monster $Monster)

    if ($null -ne $HeroHP) {
        $HeroHP.Value = [Math]::Max(0, $HeroHP.Value - $damage)
        Write-Action "$($Hero.Name) takes $damage mishap damage and loses the rest of this turn." "Red"
    }
    else {
        Write-Action "$($Hero.Name) loses the rest of this turn." "Red"
    }

    if ($null -ne $HeroTurnEnded) {
        $HeroTurnEnded.Value = $true
    }
}

function Get-HeroRageDamageBonus {
    param(
        $Hero,
        $Weapon
    )

    if (-not (Test-HeroRageActive -Hero $Hero)) {
        return 0
    }

    return 2
}

function Get-HeroRageReducedDamage {
    param(
        $Hero,
        [int]$Damage
    )

    if (-not (Test-HeroRageActive -Hero $Hero)) {
        return $Damage
    }

    return [Math]::Max(1, [Math]::Ceiling($Damage / 2))
}

function Roll-D20Attack {
    param(
        [bool]$Advantage = $false
    )

    $firstRoll = Roll-Dice -Sides 20

    if (-not $Advantage) {
        return [PSCustomObject]@{
            Roll = $firstRoll
            FirstRoll = $firstRoll
            SecondRoll = $null
            Advantage = $false
        }
    }

    $secondRoll = Roll-Dice -Sides 20

    return [PSCustomObject]@{
        Roll = [Math]::Max($firstRoll, $secondRoll)
        FirstRoll = $firstRoll
        SecondRoll = $secondRoll
        Advantage = $true
    }
}

function Format-D20AttackRollText {
    param($RollResult)

    if ($null -ne $RollResult -and $RollResult.Advantage) {
        return "d20 advantage rolls $($RollResult.FirstRoll)/$($RollResult.SecondRoll), using $($RollResult.Roll)"
    }

    return "d20 roll $($RollResult.Roll)"
}

function Get-MonsterCriticalDamage {
    param($Monster)

    $profile = Get-MonsterDamageProfile -Monster $Monster
    $extraDamageRoll = Roll-Dice -Sides $profile.DiceSides

    return [PSCustomObject]@{
        Damage = [Math]::Max(1, $profile.DamageMax + $extraDamageRoll)
        DamageMax = $profile.DamageMax
        ExtraDamageRoll = $extraDamageRoll
    }
}

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [int]$AttackBonusModifier = 0,
        [bool]$Advantage = $false,
        $HeroHP = $null,
        $HeroTurnEnded = $null
    )

    $weapon = Get-HeroWeaponProfile -Hero $Hero
    $targetArmorClass = [int]$Monster.armorClass
    $rollResult = Roll-D20Attack -Advantage $Advantage
    $heroRoll = $rollResult.Roll
    $attackTotal = $heroRoll + $weapon.TotalAttackBonus + $AttackBonusModifier
    $rollText = Format-D20AttackRollText -RollResult $rollResult

    $bonusText = ""

    if ($AttackBonusModifier -gt 0) {
        $bonusText = " (+$AttackBonusModifier attack bonus)"
    }

    if ($Advantage -and $Hero.Class -eq "Barbarian") {
        Write-Scene (Get-BarbarianRecklessSwingFlavorText -Hero $Hero -Monster $Monster)
    }

    Write-Action "$($Hero.Name) attacks with $($weapon.Name): $rollText, total $attackTotal$bonusText vs AC $targetArmorClass" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $bonusDamageRoll = Roll-WeaponBonusDamage -WeaponProfile $weapon
        $rageDamageBonus = Get-HeroRageDamageBonus -Hero $Hero -Weapon $weapon
        $heroDamage = [Math]::Max(1, $weapon.DamageMax + $extraDamageRoll + $weapon.DamageBonus + $bonusDamageRoll + $rageDamageBonus)
        $MonsterHP.Value -= $heroDamage
        $damageText = "$($weapon.DamageMax) + $extraDamageRoll + $($weapon.DamageBonus)"

        if ($bonusDamageRoll -gt 0 -and -not [string]::IsNullOrWhiteSpace($weapon.BonusDamageType)) {
            $damageText = "$damageText + $bonusDamageRoll $($weapon.BonusDamageType.ToLower())"
        }

        if ($rageDamageBonus -gt 0) {
            $damageText = "$damageText + $rageDamageBonus rage"
        }

        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($damageText)" "Yellow"

        if ($MonsterHP.Value -le 0 -and $Hero.Class -eq "Barbarian") {
            Write-Scene (Get-BarbarianCriticalKillText -Hero $Hero -Monster $Monster -Weapon $weapon)
        }
    }
    elseif ($heroRoll -eq 1) {
        Resolve-HeroCriticalFail -Hero $Hero -Monster $Monster -HeroHP $HeroHP -HeroTurnEnded $HeroTurnEnded
    }
    elseif ($attackTotal -ge $targetArmorClass) {
        $damageRoll = Roll-WeaponDamage -WeaponProfile $weapon
        $bonusDamageRoll = Roll-WeaponBonusDamage -WeaponProfile $weapon
        $rageDamageBonus = Get-HeroRageDamageBonus -Hero $Hero -Weapon $weapon
        $heroDamage = [Math]::Max(1, $damageRoll + $weapon.DamageBonus + $bonusDamageRoll + $rageDamageBonus)
        $MonsterHP.Value -= $heroDamage
        $damageText = "$damageRoll + $($weapon.DamageBonus)"

        if ($bonusDamageRoll -gt 0 -and -not [string]::IsNullOrWhiteSpace($weapon.BonusDamageType)) {
            $damageText = "$damageText + $bonusDamageRoll $($weapon.BonusDamageType.ToLower())"
        }

        if ($rageDamageBonus -gt 0) {
            $damageText = "$damageText + $rageDamageBonus rage"
        }

        Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage! ($damageText)" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) misses the attack!" "DarkGray"
    }

    if ($MonsterHP.Value -lt 0) {
        $MonsterHP.Value = 0
    }

    Write-ColorLine ""
}

function Invoke-MonsterAttack {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance,
        [int]$BlockArmorBonus = 0,
        [int]$AttackPenaltyModifier = 0,
        [int]$AttackBonusModifier = 0,
        [bool]$Advantage = $false
    )

    $heroArmorClass = (Get-HeroArmorClass -Hero $Hero) + $BlockArmorBonus
    $rollResult = Roll-D20Attack -Advantage $Advantage
    $attackRoll = $rollResult.Roll
    $attackTotal = $attackRoll + [int]$Monster.attackBonus - $AttackPenaltyModifier + $AttackBonusModifier
    $rollText = Format-D20AttackRollText -RollResult $rollResult
    $blockText = ""
    $penaltyText = ""
    $bonusText = ""

    if ($BlockArmorBonus -gt 0) {
        $blockText = " (including +$BlockArmorBonus block)"
    }

    if ($AttackPenaltyModifier -gt 0) {
        $penaltyText = " (-$AttackPenaltyModifier distract)"
    }

    if ($AttackBonusModifier -gt 0) {
        $bonusText = " (+$AttackBonusModifier attack bonus)"
    }

    Write-Action "$($Monster.definite) attacks: $rollText, total $attackTotal$penaltyText$bonusText vs AC $heroArmorClass$blockText" "DarkCyan"

    if ($attackRoll -eq 20) {
        Write-Action "CRITICAL HIT!" "Red"
        $criticalDamage = Get-MonsterCriticalDamage -Monster $Monster
        $rawDamage = $criticalDamage.Damage
        $monsterDamage = Get-HeroRageReducedDamage -Hero $Hero -Damage $rawDamage

        $HeroHP.Value -= $monsterDamage

        if ($monsterDamage -lt $rawDamage) {
            Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage after rage resistance! ($($criticalDamage.DamageMax) + $($criticalDamage.ExtraDamageRoll), reduced from $rawDamage)" "Yellow"
        }
        else {
            Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage! ($($criticalDamage.DamageMax) + $($criticalDamage.ExtraDamageRoll))" "Yellow"
        }
    }
    elseif ($attackRoll -eq 1) {
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Action "$($Monster.definite) stumbles and loses its balance!" "DarkYellow"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackTotal -ge $heroArmorClass) {
        $cuttingWordsResult = Try-Resolve-BardCuttingWords `
            -Hero $Hero `
            -Monster $Monster `
            -AttackTotal ([ref]$attackTotal) `
            -TargetArmorClass $heroArmorClass

        if ($cuttingWordsResult.PreventedHit) {
            Write-Scene (Get-BardCuttingWordsPreventedHitFlavorText -Hero $Hero -Monster $Monster)
            Write-Action "$($Monster.definite) misses after the bard's cutting words throw off the strike!" "DarkGray"
            Write-ColorLine ""
            return
        }

        $rawDamage = Roll-MonsterDamage -Monster $Monster
        $monsterDamage = Get-HeroRageReducedDamage -Hero $Hero -Damage $rawDamage
        $HeroHP.Value -= $monsterDamage

        if ($monsterDamage -lt $rawDamage) {
            Write-Action "$($Monster.definite) hits for $monsterDamage damage after rage resistance! (reduced from $rawDamage)" "Yellow"
        }
        else {
            Write-Action "$($Monster.definite) hits for $monsterDamage damage!" "Yellow"
        }
    }
    else {
        Write-Action "$($Monster.definite) misses!" "DarkGray"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
    }

    Write-ColorLine ""
}

function Resolve-HeroInspirationBoost {
    param(
        $Hero,
        [string]$PrimaryAction,
        [ref]$HeroAttackBonus,
        [ref]$HeroBlockArmorBonus,
        [ref]$HeroFocusAttackBonus
    )

    if ($Hero.Class -ne "Bard") {
        return
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return
    }

    if ($PrimaryAction -eq "A") {
        $boostLabel = "boost this attack"
    }
    elseif ($PrimaryAction -eq "B") {
        $boostLabel = "strengthen this block"
    }
    elseif ($PrimaryAction -eq "F") {
        $boostLabel = "sharpen this focus"
    }
    else {
        return
    }

    Write-ColorLine "Spend bardic inspiration to ${boostLabel}?" "Cyan"
    Write-ColorLine "1. Yes ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
    Write-ColorLine "2. No" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        if ($choice -eq "2") {
            Write-ColorLine ""
            return
        }

        if ($choice -eq "1") {
            $inspiration = Use-HeroBardicInspirationDie -Hero $Hero -UseInstrumentBonus $false

            if (-not $inspiration.Success) {
                Write-ColorLine "No prepared bardic inspiration remains." "DarkYellow"
                Write-ColorLine ""
                return
            }

            if ($PrimaryAction -eq "A") {
                $HeroAttackBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) snaps into tempo and draws a sharper opening out of the moment."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) = +$($inspiration.TotalBonus) to hit." "Yellow"
            }
            elseif ($PrimaryAction -eq "B") {
                $HeroBlockArmorBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) lifts the rhythm at just the right instant and turns defense into a tighter guard."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) = +$($inspiration.TotalBonus) AC on this block." "Yellow"
            }
            else {
                $HeroFocusAttackBonus.Value += $inspiration.TotalBonus
                Write-Scene "$($Hero.Name) lets a quick refrain hang in the air for the next clean opening."
                Write-Action "Bardic inspiration: d$($bardicStatus.DieSides) roll $($inspiration.Roll) = +$($inspiration.TotalBonus) to the next attack." "Yellow"
            }

            Write-ColorLine ""
            return
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-HeroRecklessAttackChoice {
    param(
        $Hero,
        [ref]$HeroAttackAdvantage,
        [ref]$HeroRecklessExposure
    )

    if ($Hero.Class -ne "Barbarian") {
        return
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    Write-ColorLine "Attack Style" "Cyan"
    Write-ColorLine "1. Normal attack" "White"
    Write-ColorLine "2. Reckless Attack (advantage now, enemy advantage next)" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        if ($choice -eq "1") {
            Write-ColorLine ""
            return
        }

        if ($choice -eq "2") {
            $HeroAttackAdvantage.Value = $true
            $HeroRecklessExposure.Value = $true
            $Hero.RecklessAttackExposed = $true
            Write-Scene (Get-BarbarianRecklessCommitFlavorText -Hero $Hero)
            Write-Action "Reckless Attack: $($Hero.Name) attacks with advantage now, but the next enemy attack against him also has advantage." "Yellow"
            Write-ColorLine ""
            return
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-HeroBonusAction {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        $HeroHP = $null,
        $HeroTurnEnded = $null
    )

    if ($MonsterHP.Value -le 0) {
        return $false
    }

    if ($Hero.Class -eq "Barbarian") {
        Initialize-HeroBarbarianResources -Hero $Hero
        Write-ColorLine "Bonus Action" "Cyan"
        Write-ColorLine "R. Rage ($($Hero.CurrentRages)/$($Hero.MaxRages) left)   N. No bonus action" "White"
        Write-ColorLine ""

        while ($true) {
            $choice = (Read-Host "Choose bonus action").ToUpper()

            if ($choice -eq "N") {
                Write-ColorLine ""
                return $false
            }

            if ($choice -eq "R") {
                $rage = Start-HeroRage -Hero $Hero
                Write-Scene $rage.Message

                if ($rage.Success) {
                    Write-Scene (Get-BarbarianRageFlavorText -Hero $Hero)
                    Write-Action "Rage: +2 weapon damage and incoming weapon damage is halved until the fight ends." "Yellow"
                }

                Write-ColorLine ""
                return $rage.Success
            }

            Write-ColorLine "Choose R or N." "DarkYellow"
            Write-ColorLine ""
        }
    }

    if ($Hero.Class -ne "Bard") {
        return $false
    }

    Write-ColorLine "Bonus Action" "Cyan"
    Write-ColorLine "M. Vicious Mockery   N. No bonus action" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = (Read-Host "Choose bonus action").ToUpper()

        if ($choice -eq "N") {
            Write-ColorLine ""
            return $false
        }

        if ($choice -eq "M") {
            $spellSaveDC = Get-HeroSpellSaveDC -Hero $Hero
            $wisdomSaveBonus = 0

            if ($null -ne $Monster.PSObject.Properties["wisdomSaveBonus"]) {
                $wisdomSaveBonus = [int]$Monster.wisdomSaveBonus
            }

            $saveRoll = Roll-Dice -Sides 20
            $saveTotal = $saveRoll + $wisdomSaveBonus

            Write-Scene (Get-BardViciousMockeryFlavorText -Hero $Hero -Monster $Monster)
            Write-Action "$($Monster.definite) makes a Wisdom save: d20 roll $saveRoll $(Format-AbilityModifier -Modifier $wisdomSaveBonus) = $saveTotal vs DC $spellSaveDC." "DarkCyan"

            if ($saveTotal -lt $spellSaveDC) {
                $damage = Roll-Dice -Sides 4
                $MonsterHP.Value = [Math]::Max(0, $MonsterHP.Value - $damage)
                Write-Scene (Get-BardViciousMockeryHitFlavorText -Hero $Hero -Monster $Monster)
                Write-Action "Vicious Mockery deals $damage psychic damage." "Yellow"
            }
            else {
                Write-Scene (Get-BardViciousMockerySaveFlavorText -Hero $Hero -Monster $Monster)
                Write-Action "$($Monster.definite) shakes off the mockery and takes no damage." "DarkGray"
            }

            Write-ColorLine ""
            return $true
        }

        Write-ColorLine "Choose M or N." "DarkYellow"
        Write-ColorLine ""
    }
}

function Try-Resolve-BardCuttingWords {
    param(
        $Hero,
        $Monster,
        [ref]$AttackTotal,
        [int]$TargetArmorClass
    )

    $result = [PSCustomObject]@{
        Used = $false
        PreventedHit = $false
    }

    if ($Hero.Class -ne "Bard") {
        return $result
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return $result
    }

    Write-ColorLine "Reaction? The attack would hit." "Cyan"
    Write-ColorLine "1. Use Cutting Words ($($bardicStatus.CurrentDice)/$($bardicStatus.MaxDice) d$($bardicStatus.DieSides) ready)" "White"
    Write-ColorLine "2. Let the hit land" "White"
    Write-ColorLine ""

    while ($true) {
        $choice = Read-Host "Choose"

        if ($choice -eq "2") {
            Write-ColorLine ""
            return $result
        }

        if ($choice -eq "1") {
            $inspiration = Use-HeroBardicInspirationDie -Hero $Hero -UseInstrumentBonus $false

            if (-not $inspiration.Success) {
                Write-ColorLine "No prepared bardic inspiration remains." "DarkYellow"
                Write-ColorLine ""
                return $result
            }

            $AttackTotal.Value -= $inspiration.TotalBonus
            $result.Used = $true
            Write-Scene (Get-BardCuttingWordsFlavorText -Hero $Hero -Monster $Monster)
            Write-Action "Cutting Words: d$($bardicStatus.DieSides) roll $($inspiration.Roll) = -$($inspiration.TotalBonus) to hit." "Yellow"

            if ($AttackTotal.Value -lt $TargetArmorClass) {
                $result.PreventedHit = $true
            }

            Write-ColorLine ""
            return $result
        }

        Write-ColorLine "Choose 1 or 2." "DarkYellow"
        Write-ColorLine ""
    }
}

function Resolve-DroppedWeaponTurn {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance
    )

    $choice = "P"

    if ($Hero.Class -eq "Barbarian") {
        Write-ColorLine "What do you do?" "Cyan"
        Write-ColorLine "P. Pick up the weapon and lose the turn" "White"
        Write-ColorLine "G. Grapple with raw strength" "White"
        Write-ColorLine ""

        while ($true) {
            $choice = (Read-Host "Choose (P/G)").ToUpper()

            if ($choice -in @("P", "G")) {
                break
            }

            Write-ColorLine "Choose P or G." "DarkYellow"
            Write-ColorLine ""
        }
    }

    if ($choice -eq "G") {
        $heroStrengthModifier = Get-HeroAbilityModifier -Hero $Hero -Ability "STR"
        $monsterStrengthBonus = 0

        if ($null -ne $Monster.strengthCheckBonus) {
            $monsterStrengthBonus = [int]$Monster.strengthCheckBonus
        }
        elseif ($null -ne $Monster.attackBonus) {
            $monsterStrengthBonus = [int]$Monster.attackBonus
        }

        $heroRoll = Roll-Dice -Sides 20
        $monsterRoll = Roll-Dice -Sides 20
        $heroTotal = $heroRoll + $heroStrengthModifier
        $monsterTotal = $monsterRoll + $monsterStrengthBonus

        Write-Action "$($Hero.Name) lunges for a grapple: d20 roll $heroRoll, total $heroTotal" "Cyan"
        Write-Action "$($Monster.definite) resists: d20 roll $monsterRoll, total $monsterTotal" "DarkCyan"

        if ($heroRoll -eq 20 -or ($monsterRoll -ne 20 -and $heroTotal -ge $monsterTotal)) {
            Write-Action "$($Hero.Name) slams into $($Monster.definite), forces it off balance, and snatches the weapon back!" "Yellow"
            $HeroDroppedWeapon.Value = $false
            $MonsterOffBalance.Value = $true
            Write-ColorLine ""
            return
        }

        Write-Scene "$($Hero.Name) fails to overpower $($Monster.definite) and is left exposed!"
        Write-ColorLine ""
    }
    else {
        Write-Scene "$($Hero.Name) picks up the weapon and loses the turn!"
        $HeroDroppedWeapon.Value = $false
        Write-ColorLine ""
    }

    if (-not $MonsterOffBalance.Value) {
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance
    }
    else {
        Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
        $MonsterOffBalance.Value = $false
        Write-ColorLine ""
    }
}

function Show-BardTutorialCombatHint {
    param($Hero)

    if ($Hero.Class -ne "Bard" -or [int]$Hero.Level -ne 1) {
        return
    }

    if ($null -eq $Hero.PSObject.Properties["TutorialCombatHintShown"]) {
        $Hero | Add-Member -NotePropertyName TutorialCombatHintShown -NotePropertyValue $false
    }

    if ($Hero.TutorialCombatHintShown) {
        return
    }

    $bardicStatus = Get-HeroBardicInspirationStatus -Hero $Hero

    if ($null -eq $bardicStatus -or $bardicStatus.CurrentDice -le 0) {
        return
    }

    Write-Scene "Prepared bardic inspiration can strengthen Attack, Block, or Focus after you choose the action. Each round opens with a combat menu where $($Hero.Name) can choose Action or Bonus Action, and Cutting Words can still interrupt a hit as a reaction."
    Write-ColorLine ""
    $Hero.TutorialCombatHintShown = $true
}

function Show-BarbarianTutorialCombatHint {
    param($Hero)

    if ($Hero.Class -ne "Barbarian" -or [int]$Hero.Level -ne 1) {
        return
    }

    if ($null -eq $Hero.PSObject.Properties["TutorialCombatHintShown"]) {
        $Hero | Add-Member -NotePropertyName TutorialCombatHintShown -NotePropertyValue $false
    }

    if ($Hero.TutorialCombatHintShown) {
        return
    }

    Initialize-HeroBarbarianResources -Hero $Hero
    Write-Scene "Barbarian combat now has two hard choices: Rage uses the Bonus Action menu for more damage and resistance, while Reckless Attack gives $($Hero.Name) advantage on the attack but gives the next enemy attack against $($Hero.GenderPronouns.Objective) advantage too."
    Write-ColorLine ""
    $Hero.TutorialCombatHintShown = $true
}

function Show-CombatTurnMenu {
    param(
        $Hero,
        [bool]$ActionSpent = $false,
        [bool]$BonusActionSpent = $false
    )

    $actionText = "1. Action"
    $bonusText = "2. Bonus Action"

    if ($ActionSpent) {
        $actionText = "1. Action (used)"
    }

    if ($BonusActionSpent) {
        $bonusText = "2. Bonus Action (used)"
    }

    Write-ColorLine "$actionText   $bonusText   3. End Turn   T. Text Speed ($(Get-TextSpeedLabel))" "White"
    Write-ColorLine ""
}

function Show-CombatChoiceMenu {
    Write-ColorLine "A. Attack   B. Block   F. Focus" "White"
    Write-ColorLine "I. Inventory   P. Pass Action   R. Run   T. Text Speed ($(Get-TextSpeedLabel))" "White"
    Write-ColorLine ""
}

function Resolve-MonsterCombatTurn {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance,
        [ref]$HeroBlockArmorBonus,
        [ref]$HeroRecklessExposure
    )

    if (-not $MonsterOffBalance.Value) {
        $recklessAdvantage = ($null -ne $HeroRecklessExposure -and $HeroRecklessExposure.Value)
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -BlockArmorBonus $HeroBlockArmorBonus.Value -Advantage $recklessAdvantage
        $HeroBlockArmorBonus.Value = 0

        if ($null -ne $HeroRecklessExposure) {
            $HeroRecklessExposure.Value = $false
        }

        if ($Hero.Class -eq "Barbarian") {
            Initialize-HeroBarbarianResources -Hero $Hero
            $Hero.RecklessAttackExposed = $false
        }

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) falls in battle..."
        }
    }
    else {
        Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
        $MonsterOffBalance.Value = $false
        Write-ColorLine ""
    }
}

function Resolve-HeroCombatTurn {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance,
        [ref]$EncounterFled,
        [ref]$HeroBlockArmorBonus,
        [ref]$HeroFocusAttackBonus,
        [ref]$HeroRecklessExposure
    )

    if ($HeroDroppedWeapon.Value) {
        Resolve-DroppedWeaponTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon -MonsterOffBalance $MonsterOffBalance
        return
    }

    $choice = $null
    $turnHeroAttackBonus = 0
    $turnHeroAttackAdvantage = $false
    $turnHeroEnded = $false
    $actionSpent = $false
    $bonusActionSpent = $false

    while (-not $actionSpent -or -not $bonusActionSpent) {
        Show-CombatTurnMenu -Hero $Hero -ActionSpent $actionSpent -BonusActionSpent $bonusActionSpent
        $turnMenuChoice = (Read-Host "Choose").ToUpper()

        if ($turnMenuChoice -eq "T") {
            Toggle-TextSpeed | Out-Null
            continue
        }

        if ($turnMenuChoice -eq "3") {
            Write-Scene "$($Hero.Name) lets the moment pass and ends the turn."
            Write-ColorLine ""
            return
        }

        if ($turnMenuChoice -eq "2") {
            if ($bonusActionSpent) {
                Write-ColorLine ""
                Write-ColorLine "The bonus action is already spent this round." "DarkYellow"
                Write-ColorLine ""
                continue
            }

            if ($Hero.Class -notin @("Bard", "Barbarian")) {
                Write-ColorLine ""
                Write-ColorLine "$($Hero.Name) passes the bonus action." "DarkGray"
                Write-ColorLine ""
                $bonusActionSpent = $true
                continue
            }

            Resolve-HeroBonusAction -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroHP $HeroHP -HeroTurnEnded ([ref]$turnHeroEnded) | Out-Null
            $bonusActionSpent = $true

            if ($MonsterHP.Value -le 0 -or $HeroHP.Value -le 0 -or $turnHeroEnded) {
                return
            }

            continue
        }

        if ($turnMenuChoice -ne "1") {
            Write-ColorLine ""
            Write-ColorLine "Choose 1, 2, 3 or T." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        if ($actionSpent) {
            Write-ColorLine ""
            Write-ColorLine "The action is already spent this round." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        Show-CombatChoiceMenu
        $choice = (Read-Host "Choose action").ToUpper()

        if ($choice -eq "T") {
            Toggle-TextSpeed | Out-Null
            $choice = $null
            continue
        }

        if ($choice -eq "P") {
            Write-Scene "$($Hero.Name) passes the action and keeps the guard up."
            Write-ColorLine ""
            $actionSpent = $true
            continue
        }

        if ($choice -eq "I") {
            Write-ColorLine ""
            $usedItem = Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP -InCombat

            if ($usedItem) {
                $actionSpent = $true
            }

            continue
        }
        elseif ($choice -eq "R") {
            Write-Scene "$($Hero.Name) flees from $($Monster.definite)!"
            $EncounterFled.Value = $true
            return
        }

        if ($choice -notin @("A", "B", "F")) {
            Write-ColorLine ""
            Write-ColorLine "Type A, B, F, I, P, R or T." "DarkYellow"
            Write-ColorLine ""
            $choice = $null
            continue
        }

        Resolve-HeroInspirationBoost `
            -Hero $Hero `
            -PrimaryAction $choice `
            -HeroAttackBonus ([ref]$turnHeroAttackBonus) `
            -HeroBlockArmorBonus $HeroBlockArmorBonus `
            -HeroFocusAttackBonus $HeroFocusAttackBonus

        if ($choice -eq "B") {
            Write-Scene "$($Hero.Name) braces for impact and raises a tight defense."
            $HeroBlockArmorBonus.Value += 2
            Write-Action "$($Hero.Name) gains +2 AC against the next attack." "Yellow"
            Write-ColorLine ""
            $actionSpent = $true
            continue
        }

        if ($choice -eq "F") {
            Write-Scene "$($Hero.Name) slows the breath, studies the opening, and waits for the right strike."
            $HeroFocusAttackBonus.Value += 2
            Write-Action "$($Hero.Name) gains +2 to hit on the next attack." "Yellow"
            Write-ColorLine ""
            $actionSpent = $true
            continue
        }

        if ($choice -eq "A") {
            Resolve-HeroRecklessAttackChoice -Hero $Hero -HeroAttackAdvantage ([ref]$turnHeroAttackAdvantage) -HeroRecklessExposure $HeroRecklessExposure
            Write-ColorLine ""
            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -AttackBonusModifier ($HeroFocusAttackBonus.Value + $turnHeroAttackBonus) -Advantage $turnHeroAttackAdvantage -HeroHP $HeroHP -HeroTurnEnded ([ref]$turnHeroEnded)
            $HeroFocusAttackBonus.Value = 0
            $actionSpent = $true

            if ($MonsterHP.Value -le 0 -or $HeroHP.Value -le 0 -or $turnHeroEnded) {
                return
            }
        }
    }

    Write-Scene "$($Hero.Name) has spent both action slots. The enemy gets the next opening."
    Write-ColorLine ""
}

function Start-CombatLoop {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance,
        [ref]$EncounterFled,
        [bool]$HeroStarts = $true
    )

    $heroBlockArmorBonus = 0
    $heroFocusAttackBonus = 0
    $heroRecklessExposure = $false

    while ($HeroHP.Value -gt 0 -and $MonsterHP.Value -gt 0) {
        Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value
        Show-BardTutorialCombatHint -Hero $Hero
        Show-BarbarianTutorialCombatHint -Hero $Hero

        if ($HeroStarts) {
            Resolve-HeroCombatTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon -MonsterOffBalance $MonsterOffBalance -EncounterFled $EncounterFled -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -HeroRecklessExposure ([ref]$heroRecklessExposure)

            if ($EncounterFled.Value -or $MonsterHP.Value -le 0 -or $HeroHP.Value -le 0) {
                break
            }

            Resolve-MonsterCombatTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) -HeroRecklessExposure ([ref]$heroRecklessExposure)
        }
        else {
            Resolve-MonsterCombatTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) -HeroRecklessExposure ([ref]$heroRecklessExposure)

            if ($HeroHP.Value -le 0) {
                break
            }

            Resolve-HeroCombatTurn -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon -MonsterOffBalance $MonsterOffBalance -EncounterFled $EncounterFled -HeroBlockArmorBonus ([ref]$heroBlockArmorBonus) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -HeroRecklessExposure ([ref]$heroRecklessExposure)

            if ($EncounterFled.Value -or $MonsterHP.Value -le 0 -or $HeroHP.Value -le 0) {
                break
            }
        }
    }

    Stop-HeroRage -Hero $Hero
}
