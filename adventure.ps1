. "$PSScriptRoot\roll.ps1"
. "$PSScriptRoot\character.ps1"

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

Write-Host "Hjälten $($hero.Name) går in i en mörk grotta..."
Write-Host "$($hero.Name) är en $($hero.Class) med $heroHP HP."
Write-Host "Plötsligt hoppar $($monster.article) $($monster.name) fram!"
Write-Host "$($monster.definite) har $monsterHP HP."
Write-Host ""

while ($heroHP -gt 0 -and $monsterHP -gt 0) {
    $choice = Read-Host "Vad vill du göra? (attack/fly)"

    if ($choice -eq "fly") {
        Write-Host "$($hero.Name) flyr från $($monster.definite)!"
        break
    }

    if ($choice -eq "attack") {
        $heroRoll = Roll-Dice -Sides 20
        Write-Host ""
        Write-Host "$($hero.Name) slår för attack: $heroRoll"

        if ($heroRoll -ge 10) {
            $heroDamage = Roll-Damage -Minimum $hero.DamageMin -Maximum $hero.DamageMax
            $monsterHP -= $heroDamage
            Write-Host "$($hero.Name) träffar $($monster.definite) och gör $heroDamage skada!"
        }
        else {
            Write-Host "$($hero.Name) missar attacken!"
        }

        if ($monsterHP -le 0) {
            Write-Host "$($monster.definite) faller till marken. Du vann!"
            break
        }

        $monsterRoll = Roll-Dice -Sides 20
        Write-Host "$($monster.definite) slår för attack: $monsterRoll"

        if ($monsterRoll -ge 10) {
            $monsterDamage = Roll-Damage -Minimum $monster.damageMin -Maximum $monster.damageMax
            $heroHP -= $monsterDamage
            Write-Host "$($monster.definite) träffar och gör $monsterDamage skada!"
        }
        else {
            Write-Host "$($monster.definite) missar!"
        }

        if ($heroHP -le 0) {
            Write-Host "$($hero.Name) faller i striden..."
            break
        }

        Write-Host ""
        Write-Host "Status:"
        Write-Host "$($hero.Name): $heroHP HP"
        Write-Host "$($monster.definite): $monsterHP HP"
        Write-Host ""
    }
    else {
        Write-Host "Skriv attack eller fly."
        Write-Host ""
    }
}