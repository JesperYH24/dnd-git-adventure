. "$PSScriptRoot\Setup.ps1"

$game = Initialize-Game
$heroHP = $game.HeroHP
$heroDroppedWeapon = $game.HeroDroppedWeapon

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon

Start-Intro -Hero $game.Hero -HeroHP ([ref]$heroHP)

while ($heroHP -gt 0 -and -not $game.GameWon) {
    $campAction = Start-CampfireMenu -Game $game -HeroHP ([ref]$heroHP)

    if ($campAction -eq "EnterCave") {
        Start-CaveExploration `
            -Game $game `
            -HeroHP ([ref]$heroHP) `
            -HeroDroppedWeapon ([ref]$heroDroppedWeapon)
    }
    elseif ($campAction -eq "EnterTown") {
        Start-TownMenu -Game $game -HeroHP ([ref]$heroHP) | Out-Null
    }
}

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon
