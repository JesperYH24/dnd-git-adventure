. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"

$hero = Get-Hero

$monsters = @(
    @{ name = "skelett"; article = "ett"; definite = "skelettet"; hp = 10; damageMin = 1; damageMax = 4 },
    @{ name = "goblin"; article = "en"; definite = "goblinen"; hp = 8; damageMin = 1; damageMax = 6 },
    @{ name = "zombie"; article = "en"; definite = "zombien"; hp = 12; damageMin = 1; damageMax = 5 },
    @{ name = "jätteråtta"; article = "en"; definite = "jätteråttan"; hp = 7; damageMin = 1; damageMax = 3 }
)

$monster = Get-Random $monsters

$heroHP = $hero.HP
$monsterHP = $monster.hp

$heroDroppedWeapon = $false
$monsterOffBalance = $false

Write-Host "Hjälten $($hero.Name) går in i en mörk grotta..."
Write-Host "$($hero.Name) är en $($hero.Class) med $heroHP HP."
Write-Host "Något finns här inne..."
Write-Host ""

# Upptäcktsfas
$detectRoll = Roll-Dice -Sides 20
Write-Host "$($hero.Name) slår en d20 för att upptäcka fara: $detectRoll"
Write-Host ""

$heroStarts = $false
$heroBonusAttack = $false
$monsterStarts = $false

if ($detectRoll -ge 15) {
    Write-Host "$($hero.Name) upptäcker $($monster.definite) långt innan det hinner reagera!"
    Write-Host "$($hero.Name) får två attacker direkt."
    $heroStarts = $true
    $heroBonusAttack = $true
}
elseif ($detectRoll -ge 8) {
    Write-Host "$($hero.Name) och $($monster.definite) upptäcker varandra samtidigt!"
    Write-Host "$($hero.Name) hinner ändå agera först."
    $heroStarts = $true
}
else {
    Write-Host "För sent! $($monster.definite) hoppar fram ur skuggorna!"
    Write-Host "$($monster.definite) får attackera först."
    $monsterStarts = $true
}

Write-Host ""
Write-Host "$($monster.definite) har $monsterHP HP."
Write-Host ""

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon
    )

    $heroRoll = Roll-Dice -Sides 20
    Write-Host "$($Hero.Name) slår för attack: $heroRoll"

    if ($heroRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $heroDamage = $Hero.DamageMax + $extraDamage
        $MonsterHP.Value -= $heroDamage
        Write-Host "CRITICAL HIT!"
        Write-Host "$($Hero.Name) träffar $($Monster.definite) extra hårt och gör $heroDamage skada! ($($Hero.DamageMax) + $extraDamage)"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Host "CRITICAL FAIL!"
        Write-Host "$($Hero.Name) fumblar, tappar vapnet och måste plocka upp det nästa runda!"
    }
    elseif ($heroRoll -ge 10) {
        $heroDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $MonsterHP.Value -= $heroDamage
        Write-Host "$($Hero.Name) träffar $($Monster.definite) och gör $heroDamage skada!"
    }
    else {
        Write-Host "$($Hero.Name) missar attacken!"
    }

    Write-Host ""
}

function Invoke-MonsterAttack {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance
    )

    $monsterRoll = Roll-Dice -Sides 20
    Write-Host "$($Monster.definite) slår för attack: $monsterRoll"

    if ($monsterRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage
        $HeroHP.Value -= $monsterDamage
        Write-Host "CRITICAL HIT!"
        Write-Host "$($Monster.definite) träffar extra hårt och gör $monsterDamage skada! ($($Monster.damageMax) + $extraDamage)"
    }
    elseif ($monsterRoll -eq 1) {
        $MonsterOffBalance.Value = $true
        Write-Host "CRITICAL FAIL!"
        Write-Host "$($Monster.definite) kastar sig fram alldeles för vilt, missar och måste samla sig nästa runda!"
    }
    elseif ($monsterRoll -ge 10) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $HeroHP.Value -= $monsterDamage
        Write-Host "$($Monster.definite) träffar och gör $monsterDamage skada!"
    }
    else {
        Write-Host "$($Monster.definite) missar!"
    }

    Write-Host ""
}

# Startfas innan vanliga rundor
if ($heroStarts) {
    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    if ($monsterHP -le 0) {
        Write-Host "$($monster.definite) faller till marken. Du vann!"
        return
    }

    if ($heroBonusAttack) {
        Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

        if ($monsterHP -le 0) {
            Write-Host "$($monster.definite) faller till marken. Du vann!"
            return
        }
    }
}
elseif ($monsterStarts) {
    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    if ($heroHP -le 0) {
        Write-Host "$($hero.Name) faller i striden..."
        return
    }
}

# Vanlig stridsloop
while ($heroHP -gt 0 -and $monsterHP -gt 0) {
    Write-Host "Status:"
    Write-Host "$($hero.Name): $heroHP HP"
    Write-Host "$($monster.definite): $monsterHP HP"
    Write-Host ""

    $choice = Read-Host "Vad vill du göra? (A/R) - Attack eller Run"

    if ($choice -eq "R") {
        Write-Host "$($hero.Name) flyr från $($monster.definite)!"
        break
    }
    elseif ($choice -eq "A") {
        Write-Host ""
        Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

        if ($monsterHP -le 0) {
            Write-Host "$($monster.definite) faller till marken. Du vann!"
            break
        }

        Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

        if ($heroHP -le 0) {
            Write-Host "$($hero.Name) faller i striden..."
            break
        }
    }
    else {
        Write-Host ""
        Write-Host "Skriv A eller R"
        Write-Host ""
    }
}