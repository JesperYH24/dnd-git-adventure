function Start-Intro {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP
    )

    Write-Scene "Natten ligger tung över skogen."
    Write-Scene "$($Hero.Name) sitter vid sin lägerplats utanför en mörk grotta."
    Write-Scene "Elden knastrar svagt medan vinden drar mellan träden."
    Write-Scene "$($Hero.Name) är en $($Hero.Class) med $($HeroHP.Value)/$($Hero.HP) HP."
    Write-Scene "Djupt där inne väntar fara..."
    Write-ColorLine ""

    if ($Monster.isBoss) {
        Write-Scene "Luften känns märkligt tung runt grottans öppning..."
        Write-Scene "Något där inne känns större än vanligt."
        Write-ColorLine ""
    }

    $enterCave = $false

    while (-not $enterCave) {
        Write-ColorLine "Vad vill du göra?" "Cyan"
        Write-ColorLine "1. Kolla inventory" "White"
        Write-ColorLine "2. Gå in i grottan" "White"
        Write-ColorLine ""

        $choice = Read-Host "Välj"

        switch ($choice) {
            "1" {
                Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP | Out-Null
            }

            "2" {
                Write-Scene "$($Hero.Name) reser sig, greppar sitt vapen och går mot grottans öppning..."
                Write-Scene "Mörkret sluter sig runt honom."
                Write-ColorLine ""
                $enterCave = $true
            }

            default {
                Write-ColorLine "Ogiltigt val. Försök igen." "Red"
                Write-ColorLine ""
            }
        }
    }

    Write-Scene "$($Hero.Name) går in i den mörka grottan..."
    Write-Scene "Något finns här inne..."
    Write-ColorLine ""

    if ($Monster.isBoss) {
        Write-Scene "Luften blir plötsligt iskall..."
        Start-Sleep -Milliseconds 1000
        Write-Scene "Marken skakar under dina fötter..."
        Start-Sleep -Milliseconds 1000
        Write-Scene "Något rör sig i mörkret..."
        Start-Sleep -Milliseconds 1000
    }
}

function Start-DetectionPhase {
    param(
        $Hero,
        $Monster,
        [ref]$HeroStarts,
        [ref]$HeroBonusAttack,
        [ref]$MonsterStarts
    )

    $detectRoll = Roll-Dice -Sides 20
    Write-Scene "$($Hero.Name) slår en d20 för att upptäcka fara: $detectRoll"
    Write-ColorLine ""

    if ($detectRoll -ge 15) {
        Write-Scene "$($Hero.Name) upptäcker $($Monster.definite) långt innan det hinner reagera!"
        Write-Scene "$($Hero.Name) får två attacker direkt."
        $HeroStarts.Value = $true
        $HeroBonusAttack.Value = $true
    }
    elseif ($detectRoll -ge 8) {
        Write-Scene "$($Hero.Name) och $($Monster.definite) upptäcker varandra samtidigt!"
        Write-Scene "$($Hero.Name) hinner ändå agera först."
        $HeroStarts.Value = $true
    }
    else {
        Write-Scene "För sent! $($Monster.definite) hoppar fram ur skuggorna!"
        Write-Scene "$($Monster.definite) får attackera först."
        $MonsterStarts.Value = $true
    }
}

function Start-OpeningPhase {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance,
        [bool]$HeroStarts,
        [bool]$HeroBonusAttack,
        [bool]$MonsterStarts
    )

    if ($HeroStarts) {
        $attacks = if ($HeroBonusAttack) { 2 } else { 1 }

        for ($i = 1; $i -le $attacks; $i++) {
            Write-Scene ""
            Write-Scene "Öppningsattack $i av $attacks"

            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                Write-Scene "$($Monster.definite) faller till marken. Du vann!"
                Resolve-LootDrop -Hero $Hero -Monster $Monster
                return $false
            }

            if ($HeroDroppedWeapon.Value) {
                break
            }
        }

        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) faller i striden..."
            return $false
        }
    }
    elseif ($MonsterStarts) {
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) faller i striden..."
            return $false
        }
    }

    return $true
}
