. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"

$hero = Get-Hero

$monsters = @(
    @{ name = "skelett"; article = "Ett"; definite = "Skelettet" },
    @{ name = "goblin"; article = "En"; definite = "Goblinen" },
    @{ name = "zombie"; article = "En"; definite = "Zombien" },
    @{ name = "jätteråtta"; article = "En"; definite = "Jätteråttan" }
)

$monster = Get-Random $monsters

$roll = Roll-Dice -Sides 20
$damage = Roll-Damage

Write-Host "Hjälten $($hero.Name) går in i en mörk grotta..."
Write-Host "$($hero.Name) är en $($hero.Class) med $($hero.HP) HP."
Write-Host "Du slår en d20 för att upptäcka fara: $roll"

if ($roll -ge 15) {
    Write-Host "Du hör $($monster.article) $($monster.name) innan den hinner attackera. Du är redo!"
    Write-Host "$($hero.Name) anfaller först och gör $damage skada!"
}
elseif ($roll -ge 8) {
    Write-Host "Du anar att $($monster.article) $($monster.name) rör sig i mörkret..."
    Write-Host "$($hero.Name) svingar sitt vapen och gör $damage skada!"
}
else {
    Write-Host "$($monster.article) $($monster.name) hoppar fram ur skuggorna!"
    Write-Host "$($monster.definite) träffar och gör $damage skada!"
}
