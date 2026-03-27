. "$PSScriptRoot\Setup.ps1"

$game = Initialize-Game
$heroHP = $game.HeroHP
$heroDroppedWeapon = $game.HeroDroppedWeapon

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon

Start-Intro -Hero $game.Hero -HeroHP ([ref]$heroHP)

Start-CaveExploration `
    -Game $game `
    -HeroHP ([ref]$heroHP) `
    -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

$game.HeroHP = $heroHP
$game.HeroDroppedWeapon = $heroDroppedWeapon
