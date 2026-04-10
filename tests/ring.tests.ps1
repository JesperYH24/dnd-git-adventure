. "$PSScriptRoot\town-test-helpers.ps1"

Set-TestOutputStubs

function Set-TestRollStub {
    param([scriptblock]$Body)

    $global:RollDiceOverride = $Body
}

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

function Test-RingVeteranCircuitUnlocksAfterFifteenWins {
    $hero = Get-Hero
    $hero.RingWinsTotal = 15

    $pitTalk = Get-RingMasterPitTalk -Hero $hero
    $opponents = Get-RingOpponents -Hero $hero

    Assert-True -Condition ($pitTalk -like "*fifteen wins*") -Message "The ring master should acknowledge the deeper post-champion tier."
    Assert-Equal -Actual $opponents.Count -Expected 5 -Message "Fifteen total ring wins should unlock the extended veteran circuit."
}

function Test-SecondRingTrainingTierUnlocksAtTwentyWins {
    $hero = Get-Hero
    $first = Grant-RingTraining -Hero $hero -Wins 10
    $second = Grant-RingTraining -Hero $hero -Wins 10
    $profile = Get-HeroUnarmedProfile -Hero $hero

    Assert-Equal -Actual $first.Unlocked -Expected $true -Message "Ten wins should still unlock the first pit-fighter tier."
    Assert-Equal -Actual $second.Unlocked -Expected $true -Message "Twenty total ring wins should unlock the second pit-fighter tier."
    Assert-Equal -Actual $hero.UnarmedTrainingLevel -Expected 2 -Message "Twenty ring wins should raise unarmed training to tier 2."
    Assert-Equal -Actual $profile.DamageBonus -Expected 4 -Message "Tier 2 unarmed training should give Borzig +2 damage on top of his base modifier."
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

    Set-TestRollStub {
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

    Set-TestRollStub {
        param([int]$Sides)
        return 10
    }

    $choice = Get-OpponentBrawlAction -Opponent $opponent

    Assert-Equal -Actual $choice -Expected "G" -Message "A grapple-heavy opponent should sometimes choose a grapple."
}

function Test-RingOpponentIntroReflectsRivalryRecord {
    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Dockhand Vero"
        Intro = "Base intro."
    }

    $firstIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent
    Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $true | Out-Null
    $secondIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent
    Update-HeroRingRivalryRecord -Hero $hero -Opponent $opponent -HeroWon $false | Out-Null
    $thirdIntro = Get-RingOpponentIntro -Hero $hero -Opponent $opponent

    Assert-Equal -Actual $firstIntro -Expected "Base intro." -Message "A fresh opponent should use the baseline intro."
    Assert-True -Condition ($secondIntro -like "*already beaten 1 time(s)*") -Message "An opponent Borzig has beaten should remember that loss."
    Assert-True -Condition ($thirdIntro -like "*unfinished business*") -Message "An even rivalry should change the intro tone."
}

function Test-PunchVsGrappleUsesPunchBonus {
    Set-TestOutputStubs

    $hero = Get-Hero
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 1
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 2
        GrappleChance = 100
        FocusChance = 0
        BlockChance = 0
        Intro = "Test intro."
    }

    function global:Read-Host {
        param([string]$Prompt)
        return "P"
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(10)
    $script:rollQueue.Enqueue(10)

    Set-TestRollStub {
        param([int]$Sides)

        if ($script:rollQueue.Count -gt 0) {
            return $script:rollQueue.Dequeue()
        }

        return 10
    }

    $won = Start-BrawlLoop -Hero $hero -Opponent $opponent -Title "Test Bout"

    Assert-Equal -Actual $won -Expected $true -Message "Punch versus Grapple should include the punch bonus strongly enough to win this tied roll test."
}

function Test-BlockedGrappleDoesNotReverseIntoCounterGrapple {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 10
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 10
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 4
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(8)
    $script:rollQueue.Enqueue(18)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    $result = Resolve-BrawlGrappleAttempt -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $false -DefenderAction "Block"

    Assert-Equal -Actual $result -Expected "Defender" -Message "A defended grapple should be blocked when the non-grappler wins the contest."
    Assert-Equal -Actual $heroHP -Expected $hero.HP -Message "Blocking a grapple should not make the defender take reverse grapple damage."
    Assert-Equal -Actual $opponentHP -Expected 10 -Message "Blocking a grapple should not deal automatic counter-grapple damage."
    Assert-Equal -Actual $heroOffBalance -Expected $false -Message "Blocking a grapple should not leave the defender off balance."
    Assert-Equal -Actual $opponentOffBalance -Expected $false -Message "Blocking a grapple should not reverse the grapple onto the initiator."
}

function Test-GrappleDamageUsesRolledDamage {
    Set-TestOutputStubs

    $hero = Get-Hero
    $heroHP = $hero.HP
    $opponentHP = 20
    $heroOffBalance = $false
    $opponentOffBalance = $false
    $heroFocusAttackBonus = 0
    $opponentFocusAttackBonus = 0
    $opponent = [PSCustomObject]@{
        Name = "Test Grappler"
        Definite = "Test Grappler"
        ArmorClass = 11
        HP = 20
        AttackBonus = 1
        DamageDiceSides = 4
        DamageBonus = 1
        GrappleBonus = 4
    }

    $script:rollQueue = [System.Collections.Generic.Queue[int]]::new()
    $script:rollQueue.Enqueue(18)
    $script:rollQueue.Enqueue(8)
    $script:rollQueue.Enqueue(3)

    Set-TestRollStub {
        param([int]$Sides)
        return $script:rollQueue.Dequeue()
    }

    $result = Resolve-BrawlGrappleAttempt -Hero $hero -Opponent $opponent -HeroHP ([ref]$heroHP) -OpponentHP ([ref]$opponentHP) -HeroOffBalance ([ref]$heroOffBalance) -OpponentOffBalance ([ref]$opponentOffBalance) -HeroFocusAttackBonus ([ref]$heroFocusAttackBonus) -OpponentFocusAttackBonus ([ref]$opponentFocusAttackBonus) -HeroInitiates $true -DefenderAction "Block"

    Assert-Equal -Actual $result -Expected "Initiator" -Message "The hero grapple should still land in the controlled test."
    Assert-Equal -Actual $opponentHP -Expected 15 -Message "Hero grapple damage should use a rolled d4 plus grapple bonus, not a fixed flat value."
}

function Test-OffBalanceFallsBackToSimpleActions {
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "G") -Expected "P" -Message "Off-balance fighters should not be allowed to grapple again immediately."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "F") -Expected "P" -Message "Off-balance fighters should not be allowed to focus immediately."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "P") -Expected "P" -Message "Off-balance fighters should still be able to punch."
    Assert-Equal -Actual (Get-OffBalanceBrawlAction -Action "B") -Expected "B" -Message "Off-balance fighters should still be able to block."
}

function Test-FightingRingOptionOneStartsTournament {
    $game = Initialize-Game
    $game.Hero.CurrencyCopper = 200
    $script:BrawlStarted = $false

    function global:Read-Host {
        param([string]$Prompt)
        return "1"
    }

    function global:Start-BrawlLoop {
        param($Hero, $Opponent, [string]$Title, [bool]$TrackRivalry)
        $script:BrawlStarted = $true
        return $false
    }

    Start-FightingRing -Game $game

    Assert-Equal -Actual $script:BrawlStarted -Expected $true -Message "Choosing option 1 in the fighting ring should actually start the tournament."
    Assert-Equal -Actual $game.Town.Ring.FoughtToday -Expected $true -Message "Starting the ring should consume today's tournament attempt."
}

Test-RingTrainingUnlocksUnarmedBonus
Test-RingMasterRespectsPhysicalProwess
Test-RingChampionUnlocksHarderCircuit
Test-RingVeteranCircuitUnlocksAfterFifteenWins
Test-SecondRingTrainingTierUnlocksAtTwentyWins
Test-UnarmedProfileIgnoresWeaponAttackBonus
Test-OpponentCritUsesMaxDiePlusRolledDie
Test-GrappleHeavyOpponentCanChooseGrapple
Test-RingOpponentIntroReflectsRivalryRecord
Test-PunchVsGrappleUsesPunchBonus
Test-BlockedGrappleDoesNotReverseIntoCounterGrapple
Test-GrappleDamageUsesRolledDamage
Test-OffBalanceFallsBackToSimpleActions
Test-FightingRingOptionOneStartsTournament

Write-Host "Ring tests passed." -ForegroundColor Green
$global:RollDiceOverride = $null
