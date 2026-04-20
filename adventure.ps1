. "$PSScriptRoot\Setup.ps1"

$startupChoice = Start-AdventureStartMenu

if ($startupChoice.Mode -eq "Exit") {
    return
}

if ($startupChoice.Mode -eq "Load" -and $null -ne $startupChoice.Game) {
    $game = $startupChoice.Game
}
else {
    $selectedClass = Start-ClassSelection
    $game = Initialize-Game -Class $selectedClass
}

$heroHP = $game.HeroHP
$heroDroppedWeapon = $game.HeroDroppedWeapon

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon

if ($startupChoice.Mode -eq "New") {
    Start-Intro -Hero $game.Hero -HeroHP ([ref]$heroHP)
}

while ($heroHP -gt 0 -and -not $game.GameWon) {
    if ($game.Quest.Completed) {
        $game.HeroHP = $heroHP
        $game.HeroDroppedWeapon = $heroDroppedWeapon
        Start-TownMenu -Game $game -HeroHP ([ref]$heroHP) | Out-Null
        continue
    }

    $game.HeroHP = $heroHP
    $game.HeroDroppedWeapon = $heroDroppedWeapon
    $campAction = Start-CampfireMenu -Game $game -HeroHP ([ref]$heroHP)

    if ($campAction -eq "EnterCave") {
        Start-CaveExploration `
            -Game $game `
            -HeroHP ([ref]$heroHP) `
            -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

        $game.HeroHP = $heroHP
        $game.HeroDroppedWeapon = $heroDroppedWeapon
    }
    elseif ($campAction -eq "EnterTown") {
        $game.HeroHP = $heroHP
        $game.HeroDroppedWeapon = $heroDroppedWeapon
        Start-TownMenu -Game $game -HeroHP ([ref]$heroHP) | Out-Null
    }
}

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon
