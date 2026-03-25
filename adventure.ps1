. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"

function Write-TypeLine {
    param(
        [string]$Text,
        [int]$Delay = 20,
        [string]$Color = "White"
    )

    foreach ($char in $Text.ToCharArray()) {
        Write-Host -NoNewline $char -ForegroundColor $Color
        Start-Sleep -Milliseconds $Delay
    }

    Write-Host ""
}

function Write-Scene {
    param(
        [string]$Text
    )

    Write-TypeLine -Text $Text -Delay 35 -Color "DarkCyan"
}

function Write-Action {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    Write-TypeLine -Text $Text -Delay 10 -Color $Color
}

function Write-ColorLine {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    Write-Host $Text -ForegroundColor $Color
}

$hero = Get-Hero

$monsters = @(
    @{ name = "skelett"; article = "Ett"; definite = "Skelettet"; hp = 10; damageMin = 1; damageMax = 4 },
    @{ name = "goblin"; article = "En"; definite = "Goblinen"; hp = 8; damageMin = 1; damageMax = 6 },
    @{ name = "zombie"; article = "En"; definite = "Zombien"; hp = 12; damageMin = 1; damageMax = 5 },
    @{ name = "jätteråtta"; article = "En"; definite = "Jätteråttan"; hp = 7; damageMin = 1; damageMax = 3 }
)

$monster = Get-Random $monsters

$heroHP = $hero.HP
$monsterHP = $monster.hp

$heroDroppedWeapon = $false
$monsterOffBalance = $false

Write-Scene "Hjälten $($hero.Name) går in i en mörk grotta..."
Write-Scene "$($hero.Name) är en $($hero.Class) med $heroHP HP."
Write-Scene "Något finns här inne..."
Write-ColorLine ""

# Upptäcktsfas
$detectRoll = Roll-Dice -Sides 20
Write-Scene "$($hero.Name) slår en d20 för att upptäcka fara: $detectRoll"
Write-ColorLine ""

$heroStarts = $false
$heroBonusAttack = $false
$monsterStarts = $false

if ($detectRoll -ge 15) {
    Write-Scene "$($hero.Name) upptäcker $($monster.definite) långt innan det hinner reagera!"
    Write-Scene "$($hero.Name) får två attacker direkt."
    $heroStarts = $true
    $heroBonusAttack = $true
}
elseif ($detectRoll -ge 8) {
    Write-Scene "$($hero.Name) och $($monster.definite) upptäcker varandra samtidigt!"
    Write-Scene "$($hero.Name) hinner ändå agera först."
    $heroStarts = $true
}
else {
    Write-Scene "För sent! $($monster.definite) hoppar fram ur skuggorna!"
    Write-Scene "$($monster.definite) får attackera först."
    $monsterStarts = $true
}

Write-ColorLine ""
Write-Scene "$($monster.definite) har $monsterHP HP."
Write-ColorLine ""

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon
    )

    $heroRoll = Roll-Dice -Sides 20
    Write-Action "$($Hero.Name) slår för attack: $heroRoll" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $heroDamage = $Hero.DamageMax + $extraDamage
        $MonsterHP.Value -= $heroDamage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) träffar $($Monster.definite) extra hårt och gör $heroDamage skada! ($($Hero.DamageMax) + $extraDamage)" "Yellow"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumblar, tappar vapnet och måste plocka upp det nästa runda!"
    }
    elseif ($heroRoll -ge 10) {
        $heroDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $MonsterHP.Value -= $heroDamage
        Write-Action "$($Hero.Name) träffar $($Monster.definite) och gör $heroDamage skada!" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) missar attacken!" "DarkGray"
    }

    Write-ColorLine ""
}

function Invoke-MonsterAttack {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterOffBalance
    )

    $monsterRoll = Roll-Dice -Sides 20
    Write-Action "$($Monster.definite) slår för attack: $monsterRoll" "DarkCyan"

    if ($monsterRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage
        $HeroHP.Value -= $monsterDamage
        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Monster.definite) träffar extra hårt och gör $monsterDamage skada! ($($Monster.damageMax) + $extraDamage)" "Yellow"
    }
    elseif ($monsterRoll -eq 1) {
        $MonsterOffBalance.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Monster.definite) kastar sig fram alldeles för vilt, missar och måste samla sig nästa runda!"
    }
    elseif ($monsterRoll -ge 10) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $HeroHP.Value -= $monsterDamage
        Write-Action "$($Monster.definite) träffar och gör $monsterDamage skada!" "Yellow"
    }
    else {
        Write-Action "$($Monster.definite) missar!" "DarkGray"
    }

    Write-ColorLine ""
}
function Get-HeroHPColor {
    param(
        [int]$CurrentHP,
        [int]$MaxHP
    )

    $hpPercent = ($CurrentHP / $MaxHP) * 100

    if ($hpPercent -le 20) {
        return "Red"
    }
    elseif ($hpPercent -le 60) {
        return "Yellow"
    }
    else {
        return "Green"
    }
}

function Get-MonsterHPColor {
    param(
        [int]$CurrentHP,
        [int]$MaxHP
    )

    $hpPercent = ($CurrentHP / $MaxHP) * 100

    if ($hpPercent -le 25) {
        return "Red"
    }
    elseif ($hpPercent -le 50) {
        return "Yellow"
    }
    else {
        return "DarkYellow"
    }
}
function Show-Status {
    param(
        $Hero,
        $HeroHP,
        $Monster,
        $MonsterHP
    )

    $heroColor = Get-HeroHPColor -CurrentHP $HeroHP -MaxHP $Hero.HP
    $monsterColor = Get-MonsterHPColor -CurrentHP $MonsterHP -MaxHP $Monster.hp

    Write-ColorLine "Status:" "White"
    Start-Sleep -Milliseconds 1000

    Write-ColorLine "$($Hero.Name): $HeroHP HP" $heroColor
    Start-Sleep -Milliseconds 1000

    Write-ColorLine "$($Monster.definite): $MonsterHP HP" $monsterColor
    Start-Sleep -Milliseconds 1000

    Write-ColorLine ""
}

# Startfas innan vanliga rundor
if ($heroStarts) {
    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    if ($monsterHP -le 0) {
        Write-Scene "$($monster.definite) faller till marken. Du vann!"
        return
    }

    if ($heroBonusAttack) {
        Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

        if ($monsterHP -le 0) {
            Write-Scene "$($monster.definite) faller till marken. Du vann!"
            return
        }
    }
}
elseif ($monsterStarts) {
    Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

    if ($heroHP -le 0) {
        Write-Scene "$($hero.Name) faller i striden..."
        return
    }
}

# Vanlig stridsloop
while ($heroHP -gt 0 -and $monsterHP -gt 0) {
    Show-Status -Hero $hero -HeroHP $heroHP -Monster $monster -MonsterHP $monsterHP

    if ($heroDroppedWeapon) {
        Write-Scene "$($hero.Name) plockar upp sitt vapen och förlorar rundan!"
        $heroDroppedWeapon = $false
        Write-ColorLine ""

        if (-not $monsterOffBalance) {
            Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

            if ($heroHP -le 0) {
                Write-Scene "$($hero.Name) faller i striden..."
                break
            }
        }
        else {
            Write-Scene "$($monster.definite) försöker återfå balansen och kan inte attackera denna runda."
            $monsterOffBalance = $false
            Write-ColorLine ""
        }

        continue
    }

    $choice = Read-Host "Vad vill du göra? (A/R) - Attack eller Run"

    if ($choice -eq "R") {
        Write-Scene "$($hero.Name) flyr från $($monster.definite)!"
        break
    }
    elseif ($choice -eq "A") {
        Write-ColorLine ""
        Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

        if ($monsterHP -le 0) {
            Write-Scene "$($monster.definite) faller till marken. Du vann!"
            break
        }

        if (-not $monsterOffBalance) {
            Invoke-MonsterAttack -Hero $hero -Monster $monster -HeroHP ([ref]$heroHP) -MonsterOffBalance ([ref]$monsterOffBalance)

            if ($heroHP -le 0) {
                Write-Scene "$($hero.Name) faller i striden..."
                break
            }
        }
        else {
            Write-Scene "$($monster.definite) försöker återfå balansen och kan inte attackera denna runda."
            $monsterOffBalance = $false
            Write-ColorLine ""
        }
    }
    else {
        Write-ColorLine ""
        Write-ColorLine "Skriv A eller R" "DarkYellow"
        Write-ColorLine ""
    }
}