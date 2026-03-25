. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"

$hero = Get-Hero
$roll = Roll-Dice -Sides 20

Write-Host "Hjälten $($hero.Name) går in i en mörk grotta..."
Write-Host "$($hero.Name) är en $($hero.Class) med $($hero.HP) HP."
Write-Host "Du slår en d20 för att upptäcka fara: $roll"

if ($roll -ge 15) {
    Write-Host "Du hör ett monster innan det hinner attackera. Du är redo!"
}
elseif ($roll -ge 8) {
    Write-Host "Du anar att något rör sig i mörkret..."
}
else {
    Write-Host "För sent! Ett skelett hoppar fram ur skuggorna!"
}
