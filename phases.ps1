function Start-Intro {
    param(
        $Hero,
        [ref]$HeroHP
    )

    Write-Scene "Night hangs heavy over the forest."
    Write-Scene "$($Hero.Name) sits by the campfire outside a dark cave."
    Write-Scene "The fire crackles softly while the wind slips through the trees."
    Write-Scene "$($Hero.Name) is a $($Hero.Class) with $($HeroHP.Value)/$($Hero.HP) HP."
    Write-Scene "Somewhere in the depths, danger waits..."
    Write-ColorLine ""

    $enterCave = $false

    while (-not $enterCave) {
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Check inventory" "White"
        Write-ColorLine "2. Enter the cave" "White"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP | Out-Null
            }

            "2" {
                Write-Scene "$($Hero.Name) rises, grips the weapon, and walks toward the cave entrance..."
                Write-Scene "Darkness closes in around him."
                Write-ColorLine ""
                $enterCave = $true
            }

            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }

    Write-Scene "$($Hero.Name) steps into the dark cave..."
    Write-Scene "Something is waiting in here..."
    Write-ColorLine ""

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
    Write-Scene "$($Hero.Name) rolls a d20 for initiative: $detectRoll"
    Write-ColorLine ""

    if ($detectRoll -ge 15) {
        Write-Scene "$($Hero.Name) seizes the initiative before $($Monster.definite) can react!"
        Write-Scene "$($Hero.Name) gains two immediate attacks."
        $HeroStarts.Value = $true
        $HeroBonusAttack.Value = $true
    }
    elseif ($detectRoll -ge 8) {
        Write-Scene "$($Hero.Name) and $($Monster.definite) clash at the same moment!"
        Write-Scene "$($Hero.Name) still manages to act first."
        $HeroStarts.Value = $true
    }
    else {
        Write-Scene "Too late! $($Monster.definite) lunges out of the shadows!"
        Write-Scene "$($Monster.definite) attacks first."
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
            Write-ColorLine ""
            Write-Action "Opening attack $i of $attacks" "Cyan"

            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                return $false
            }

            if ($HeroDroppedWeapon.Value) {
                break
            }
        }

        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) falls in battle..."
            return $false
        }
    }
    elseif ($MonsterStarts) {
        Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

        Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value

        if ($HeroHP.Value -le 0) {
            Write-Scene "$($Hero.Name) falls in battle..."
            return $false
        }
    }

    return $true
}
