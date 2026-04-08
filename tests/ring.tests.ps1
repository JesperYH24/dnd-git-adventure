. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Test-RingTrainingUnlocksUnarmedBonus {
    $game = Initialize-Game
    $before = Get-HeroUnarmedProfile -Hero $game.Hero

    $partial = Grant-RingTraining -Hero $game.Hero -Wins 6
    $training = Grant-RingTraining -Hero $game.Hero -Wins 4
    $after = Get-HeroUnarmedProfile -Hero $game.Hero

    Assert-Equal -Actual $partial.Unlocked -Expected $false -Message "Six ring wins should still be too few to unlock unarmed training."
    Assert-Equal -Actual $training.Unlocked -Expected $true -Message "Ten total ring wins should unlock the first unarmed training tier."
    Assert-Equal -Actual $after.TotalAttackBonus -Expected ($before.TotalAttackBonus + 1) -Message "Unarmed training should raise hit chance by 1."
    Assert-Equal -Actual $after.DamageBonus -Expected ($before.DamageBonus + 1) -Message "Unarmed training should raise bare-hand damage by 1."
}

function Test-RingMasterRespectsPhysicalProwess {
    $barbarian = Get-Hero
    $rogueLikeHero = Get-Hero
    $rogueLikeHero.Class = "Rogue"
    $rogueLikeHero.STR = 10
    $rogueLikeHero.DEX = 16
    $rogueLikeHero.CON = 12

    $barbarianGreeting = Get-RingMasterGreeting -Hero $barbarian
    $rogueGreeting = Get-RingMasterGreeting -Hero $rogueLikeHero

    Assert-True -Condition ($barbarianGreeting -like "*Real shoulders, real lungs, real scars*") -Message "The ring master should admire strong and hardy heroes."
    Assert-True -Condition ($rogueGreeting -like "*Fast feet survive longer*") -Message "The ring master should notice quick fighters differently."
}

function Test-RingChampionUnlocksHarderCircuit {
    $hero = Get-Hero
    $hero.RingWinsTotal = 10

    $greeting = Get-RingMasterGreeting -Hero $hero
    $opponents = Get-RingOpponents -Hero $hero

    Assert-True -Condition ($greeting -like "*Champion's back*") -Message "The ring master should acknowledge a ten-win champion."
    Assert-Equal -Actual $opponents.Count -Expected 4 -Message "Champion status should unlock a longer ring circuit."
}

function Test-UnarmedProfileIgnoresWeaponAttackBonus {
    $hero = Get-Hero
    $steelAxe = New-WeaponItem -Name "Steel Great Axe" -Value 0 -AttackBonus 1 -DamageDiceCount 1 -DamageDiceSides 12 -Handedness "Two-Handed" -RequiredSTR 13 -SlotCost 2
    $hero.Inventory += $steelAxe

    foreach ($item in $hero.Inventory) {
        if ($item.Type -eq "Weapon") {
            $item.Equipped = $false
        }
    }

    $steelAxe.Equipped = $true

    $unarmed = Get-HeroUnarmedProfile -Hero $hero

    Assert-Equal -Actual $unarmed.TotalAttackBonus -Expected 4 -Message "Bare-handed attacks should use proficiency and ability, not weapon attack bonuses."
}

function Test-OpponentCritUsesMaxDiePlusRolledDie {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = 20
    $opponent = [PSCustomObject]@{
        Name = "Test Bruiser"
        Definite = "Test Bruiser"
        ArmorClass = 12
        HP = 10
        AttackBonus = 2
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 2
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(20)
    $script:rollQueue.Enqueue(3)

    function global:Roll-Dice {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    Invoke-OpponentBrawlAttack -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $heroHP -Expected 12 -Message "Opponent crits should deal max die + rolled die + modifier."
}

function Test-GrappleHeavyOpponentCanChooseGrapple {
    $opponent = [PSCustomObject]@{
        GrappleChance = 45
        FocusChance = 5
        BlockChance = 5
    }

    function global:Roll-Dice {
        param([int]$Sides)
        return 10
    }

    $choice = Get-OpponentBrawlAction -Opponent $opponent

    Assert-Equal -Actual $choice -Expected "G" -Message "A grapple-heavy opponent should sometimes choose a grapple."
}

Test-RingTrainingUnlocksUnarmedBonus
Test-RingMasterRespectsPhysicalProwess
Test-RingChampionUnlocksHarderCircuit
Test-UnarmedProfileIgnoresWeaponAttackBonus
Test-OpponentCritUsesMaxDiePlusRolledDie
Test-GrappleHeavyOpponentCanChooseGrapple

Write-Host "Ring tests passed." -ForegroundColor Green
