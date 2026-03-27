. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\ui.ps1"

function Invoke-HeroAttack {
    param(
        $Hero,
        $Monster,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon
    )

    $heroRoll = Roll-Dice -Sides 20
    Write-Action "$($Hero.Name) rolls to attack: $heroRoll" "Cyan"

    if ($heroRoll -eq 20) {
        $extraDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $heroDamage = $Hero.DamageMax + $extraDamage
        $MonsterHP.Value -= $heroDamage

        Write-Action "CRITICAL HIT!" "Red"
        Write-Action "$($Hero.Name) hits $($Monster.definite) with brutal force for $heroDamage damage! ($($Hero.DamageMax) + $extraDamage)" "Yellow"
    }
    elseif ($heroRoll -eq 1) {
        $HeroDroppedWeapon.Value = $true
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Scene "$($Hero.Name) fumbles, drops the weapon, and must pick it up next turn!"
    }
    elseif ($heroRoll -ge 10) {
        $heroDamage = Roll-Damage -Minimum $Hero.DamageMin -Maximum $Hero.DamageMax
        $MonsterHP.Value -= $heroDamage

        Write-Action "$($Hero.Name) hits $($Monster.definite) for $heroDamage damage!" "Yellow"
    }
    else {
        Write-Action "$($Hero.Name) misses the attack!" "DarkGray"
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

    $attackRoll = Roll-Dice -Sides 20
    Write-Action "$($Monster.definite) rolls to attack: $attackRoll" "DarkCyan"

    if ($attackRoll -eq 20) {
        Write-Action "CRITICAL HIT!" "Red"
        $extraDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $monsterDamage = $Monster.damageMax + $extraDamage

        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) lands a crushing blow for $monsterDamage damage! ($($Monster.damageMax) + $extraDamage)" "Yellow"
    }
    elseif ($attackRoll -eq 1) {
        Write-Action "CRITICAL FAIL!" "Magenta"
        Write-Action "$($Monster.definite) stumbles and loses its balance!" "DarkYellow"
        $MonsterOffBalance.Value = $true
    }
    elseif ($attackRoll -ge 10) {
        $monsterDamage = Roll-Damage -Minimum $Monster.damageMin -Maximum $Monster.damageMax
        $HeroHP.Value -= $monsterDamage

        Write-Action "$($Monster.definite) hits for $monsterDamage damage!" "Yellow"
    }
    else {
        Write-Action "$($Monster.definite) misses!" "DarkGray"
    }

    if ($HeroHP.Value -lt 0) {
        $HeroHP.Value = 0
    }

    Write-ColorLine ""
}

function Show-Inventory {
    param($Hero)

    Write-ColorLine ""
    Write-ColorLine "===== INVENTORY =====" "Cyan"

    if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
        Write-ColorLine "Inventory is empty." "DarkGray"
        Write-ColorLine ""
        return
    }

    for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
        $item = $Hero.Inventory[$i]
        Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)]" "White"
    }

    Write-ColorLine ""
}

function Resolve-LootDrop {
    param(
        $Hero,
        $Monster
    )

    $loot = Get-MonsterLoot -Monster $Monster

    if (-not $loot -or $loot.Count -eq 0) {
        Write-Scene "$($Monster.definite) carried no loot."
        return
    }

    Write-ColorLine ""
    Write-ColorLine "===== LOOT =====" "Yellow"

    foreach ($item in $loot) {
        Write-ColorLine "- $($item.Name) [$($item.Type)]" "White"
    }

    Write-ColorLine ""

    foreach ($item in $loot) {
        $choice = (Read-Host "Pick up '$($item.Name)'? (Y/N)").ToUpper()

        if ($choice -eq "Y") {
            $Hero.Inventory += $item
            Write-Scene "$($Hero.Name) picks up $($item.Name)."
        }
        else {
            Write-Scene "$($Hero.Name) leaves $($item.Name) behind."
        }

        Write-ColorLine ""
    }

    Show-Inventory -Hero $Hero
}

function Use-InventoryItem {
    param(
        $Hero,
        [ref]$HeroHP,
        $Item
    )

    if ($Item.Type -eq "Consumable" -and $null -ne $Item.HealAmount) {
        if ($HeroHP.Value -ge $Hero.HP) {
            Write-Scene "$($Hero.Name) is already at full HP and cannot use $($Item.Name)."
            return $false
        }

        $oldHP = $HeroHP.Value
        $HeroHP.Value = [Math]::Min($HeroHP.Value + $Item.HealAmount, $Hero.HP)
        $healed = $HeroHP.Value - $oldHP

        Write-Scene "$($Hero.Name) drinks $($Item.Name) and recovers $healed HP!"
        Write-Scene "$($Hero.Name) now has $($HeroHP.Value)/$($Hero.HP) HP."

        return $true
    }

    Write-Scene "$($Item.Name) cannot be used right now."
    return $false
}

function Open-InventoryMenu {
    param(
        $Hero,
        [ref]$HeroHP
    )

    while ($true) {
        Write-ColorLine ""
        Write-ColorLine "===== INVENTORY =====" "Cyan"

        if (-not $Hero.Inventory -or $Hero.Inventory.Count -eq 0) {
            Write-ColorLine "Inventory is empty." "DarkGray"
            Write-ColorLine ""
            Read-Host "Press Enter to go back"
            return $false
        }

        for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
            $item = $Hero.Inventory[$i]

            if ($item.Type -eq "Consumable" -and $null -ne $item.HealAmount) {
                Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)] (+$($item.HealAmount) HP)" "White"
            }
            else {
                Write-ColorLine "$($i + 1). $($item.Name) [$($item.Type)]" "White"
            }
        }

        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose item number"

        if ($choice -eq "0") {
            return $false
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Enter a valid number." "DarkYellow"
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $Hero.Inventory.Count) {
            Write-ColorLine "That item does not exist." "DarkYellow"
            continue
        }

        $selectedItem = $Hero.Inventory[$index]
        $used = Use-InventoryItem -Hero $Hero -HeroHP $HeroHP -Item $selectedItem

        if ($used) {
            $newInventory = @()
            for ($i = 0; $i -lt $Hero.Inventory.Count; $i++) {
                if ($i -ne $index) {
                    $newInventory += $Hero.Inventory[$i]
                }
            }

            $Hero.Inventory = $newInventory
            return $true
        }
    }
}

function Start-CombatLoop {
    param(
        $Hero,
        $Monster,
        [ref]$HeroHP,
        [ref]$MonsterHP,
        [ref]$HeroDroppedWeapon,
        [ref]$MonsterOffBalance
    )

    while ($HeroHP.Value -gt 0 -and $MonsterHP.Value -gt 0) {
        Show-Status -Hero $Hero -HeroHP $HeroHP.Value -Monster $Monster -MonsterHP $MonsterHP.Value

        if ($HeroDroppedWeapon.Value) {
            Write-Scene "$($Hero.Name) picks up the weapon and loses the turn!"
            $HeroDroppedWeapon.Value = $false
            Write-ColorLine ""

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                if ($HeroHP.Value -le 0) {
                    Write-Scene "$($Hero.Name) falls in battle..."
                    break
                }
            }
            else {
                Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
                $MonsterOffBalance.Value = $false
                Write-ColorLine ""
            }

            continue
        }

        $choice = (Read-Host "What do you want to do? (A/I/R) - Attack, Inventory or Run").ToUpper()

        if ($choice -eq "I") {
            Write-ColorLine ""
            $usedItem = Open-InventoryMenu -Hero $Hero -HeroHP $HeroHP

            if ($usedItem) {
                if (-not $MonsterOffBalance.Value) {
                    Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                    if ($HeroHP.Value -le 0) {
                        Write-Scene "$($Hero.Name) falls in battle..."
                        break
                    }
                }
                else {
                    Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
                    $MonsterOffBalance.Value = $false
                    Write-ColorLine ""
                }
            }

            continue
        }
        elseif ($choice -eq "R") {
            Write-Scene "$($Hero.Name) flees from $($Monster.definite)!"
            break
        }
        elseif ($choice -eq "A") {
            Write-ColorLine ""
            Invoke-HeroAttack -Hero $Hero -Monster $Monster -MonsterHP $MonsterHP -HeroDroppedWeapon $HeroDroppedWeapon

            if ($MonsterHP.Value -le 0) {
                Write-Scene "$($Monster.definite) collapses to the ground. You win!"
                Resolve-LootDrop -Hero $Hero -Monster $Monster
                break
            }

            if (-not $MonsterOffBalance.Value) {
                Invoke-MonsterAttack -Hero $Hero -Monster $Monster -HeroHP $HeroHP -MonsterOffBalance $MonsterOffBalance

                if ($HeroHP.Value -le 0) {
                    Write-Scene "$($Hero.Name) falls in battle..."
                    break
                }
            }
            else {
                Write-Scene "$($Monster.definite) tries to recover its balance and cannot attack this turn."
                $MonsterOffBalance.Value = $false
                Write-ColorLine ""
            }
        }
        else {
            Write-ColorLine ""
            Write-ColorLine "Type A, I or R" "DarkYellow"
            Write-ColorLine ""
        }
    }
}
