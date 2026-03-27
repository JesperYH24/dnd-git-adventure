. "$PSScriptRoot\..\setup.ps1"

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected: $Expected, Actual: $Actual"
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

function Test-BetterArmorRaisesArmorClass {
    $hero = Get-Hero
    $startingArmorClass = Get-HeroArmorClass -Hero $hero

    $newArmor = New-ArmorItem -Name "Rotten Armor Scraps" -Value 3 -ArmorBonus 1 -SlotCost 2
    $hero.Inventory += $newArmor

    Set-EquippedItem -Hero $hero -Item $newArmor

    Assert-Equal -Actual $startingArmorClass -Expected 11 -Message "The hero should start with AC 11 from the helmet."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 12 -Message "Equipping better armor should raise armor class."
}

function Test-GreatAxeDamageProfile {
    $hero = Get-Hero
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $weapon.DamageDiceCount -Expected 1 -Message "Great Axe should roll one damage die."
    Assert-Equal -Actual $weapon.DamageDiceSides -Expected 12 -Message "Great Axe should use a d12 for damage."
    Assert-Equal -Actual $weapon.TotalDamageMin -Expected 3 -Message "Great Axe minimum damage should allow a 1 on the die plus Strength modifier."
    Assert-Equal -Actual $weapon.TotalDamageMax -Expected 14 -Message "Great Axe maximum damage should include the hero's Strength modifier."
}

function Test-BarbarianStartsWithPointBuyStatsAndLevelOneHP {
    $hero = Get-Hero
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $hero.STR -Expected 15 -Message "The barbarian should start with 15 Strength from point buy."
    Assert-Equal -Actual $hero.DEX -Expected 14 -Message "The barbarian should start with 14 Dexterity from point buy."
    Assert-Equal -Actual $hero.CON -Expected 15 -Message "The barbarian should start with 15 Constitution from point buy."
    Assert-Equal -Actual $hero.INT -Expected 8 -Message "The barbarian should start with 8 Intelligence from point buy."
    Assert-Equal -Actual $hero.WIS -Expected 10 -Message "The barbarian should start with 10 Wisdom from point buy."
    Assert-Equal -Actual $hero.CHA -Expected 8 -Message "The barbarian should start with 8 Charisma from point buy."
    Assert-Equal -Actual $hero.HP -Expected 14 -Message "A level 1 barbarian should start with max hit die plus Constitution modifier."
    Assert-Equal -Actual $weapon.TotalAttackBonus -Expected 4 -Message "The hero's total attack bonus should include Strength, proficiency, and weapon modifier."
}

function Test-TutorialMonsterArmorClassStaysForgiving {
    $monsters = Get-MonsterList | Where-Object { -not $_.isBoss }

    $skeleton = $monsters | Where-Object { $_.name -eq "skeleton" } | Select-Object -First 1
    $goblin = $monsters | Where-Object { $_.name -eq "goblin" } | Select-Object -First 1
    $zombie = $monsters | Where-Object { $_.name -eq "zombie" } | Select-Object -First 1
    $giantRat = $monsters | Where-Object { $_.name -eq "giant rat" } | Select-Object -First 1

    Assert-Equal -Actual $skeleton.armorClass -Expected 11 -Message "Skeleton AC should stay approachable for the tutorial."
    Assert-Equal -Actual $goblin.armorClass -Expected 12 -Message "Goblin AC should stay approachable for the tutorial."
    Assert-Equal -Actual $zombie.armorClass -Expected 9 -Message "Zombie AC should stay low for the tutorial."
    Assert-Equal -Actual $giantRat.armorClass -Expected 10 -Message "Giant rat AC should stay approachable for the tutorial."
}

function Test-HeroCriticalHitUsesMaxDiePlusNewRollPlusStrength {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }

    function global:Roll-Dice {
        param([int]$Sides = 20)

        if ($Sides -eq 20) { return 20 }
        if ($Sides -eq 12) { return 7 }
        return 1
    }

    $hero = Get-Hero
    $monster = @{
        name = "training dummy"
        definite = "The Training Dummy"
        hp = 30
        armorClass = 10
        attackBonus = 0
        isBoss = $false
    }
    $monsterHP = $monster.hp
    $heroDroppedWeapon = $false

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP) -HeroDroppedWeapon ([ref]$heroDroppedWeapon)

    Assert-Equal -Actual $monsterHP -Expected 9 -Message "Hero crit should deal max weapon die plus a new die roll plus Strength modifier."
    Assert-True -Condition (-not $heroDroppedWeapon) -Message "A critical hit should not drop the hero's weapon."
}

Test-BetterArmorRaisesArmorClass
Test-GreatAxeDamageProfile
Test-BarbarianStartsWithPointBuyStatsAndLevelOneHP
Test-TutorialMonsterArmorClassStaysForgiving
Test-HeroCriticalHitUsesMaxDiePlusNewRollPlusStrength

Write-Host "Armor upgrade tests passed." -ForegroundColor Green
