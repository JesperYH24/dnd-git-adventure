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

    $newArmor = New-ArmorItem -Name "Chain Shirt" -Value 380 -ArmorBonus 3 -AddsDexModifier $true -DexBonusCap 2 -SlotCost 3
    $hero.Inventory += $newArmor

    Set-EquippedItem -Hero $hero -Item $newArmor | Out-Null

    Assert-Equal -Actual $startingArmorClass -Expected 14 -Message "The barbarian should start with AC 14 from Unarmored Defense."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 15 -Message "Equipping good armor should replace Unarmored Defense and raise armor class."
}

function Test-BarbarianStartsWithoutHelmet {
    $hero = Get-Hero

    Assert-Equal -Actual @($hero.Inventory | Where-Object { $_.Name -eq "Helmet" }).Count -Expected 0 -Message "The barbarian should no longer start with a helmet."
}

function Test-BarbarianUnarmoredDefenseDoesNotStackWithArmor {
    $hero = Get-Hero
    $weakArmor = New-ArmorItem -Name "Rotten Armor Scraps" -Value 3 -ArmorBonus 1 -SlotCost 2
    $hero.Inventory += $weakArmor

    Set-EquippedItem -Hero $hero -Item $weakArmor | Out-Null

    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 11 -Message "Unarmored Defense should not stack while actual armor is equipped."
}

function Test-BarbarianUnarmoredDefenseStatusExplainsArmorClass {
    $hero = Get-Hero
    $status = Get-HeroStatusSnapshot -Hero $hero -HeroHP $hero.HP

    Assert-Equal -Actual $status.UnarmoredDefense.Active -Expected $true -Message "Status should show Unarmored Defense as active when no armor is equipped."
    Assert-Equal -Actual $status.UnarmoredDefense.ArmorClass -Expected 14 -Message "Status should explain the barbarian's unarmored AC."
    Assert-Equal -Actual $status.UnarmoredDefense.DexterityModifier -Expected 2 -Message "Status should include the DEX modifier used by Unarmored Defense."
    Assert-Equal -Actual $status.UnarmoredDefense.ConstitutionModifier -Expected 2 -Message "Status should include the CON modifier used by Unarmored Defense."
}

function Test-BarbarianUnarmoredDefenseStatusTurnsOffWithArmor {
    $hero = Get-Hero
    $weakArmor = New-ArmorItem -Name "Rotten Armor Scraps" -Value 3 -ArmorBonus 1 -SlotCost 2
    $hero.Inventory += $weakArmor
    Set-EquippedItem -Hero $hero -Item $weakArmor | Out-Null

    $status = Get-HeroStatusSnapshot -Hero $hero -HeroHP $hero.HP

    Assert-Equal -Actual $status.UnarmoredDefense.Active -Expected $false -Message "Status should show Unarmored Defense as inactive when armor is equipped."
}

function Test-GreatAxeDamageProfile {
    $hero = Get-Hero
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $weapon.DamageDiceCount -Expected 1 -Message "Great Axe should roll one damage die."
    Assert-Equal -Actual $weapon.DamageDiceSides -Expected 12 -Message "Great Axe should use a d12 for damage."
    Assert-Equal -Actual $weapon.TotalDamageMin -Expected 3 -Message "Great Axe minimum damage should allow a 1 on the die plus Strength modifier."
    Assert-Equal -Actual $weapon.TotalDamageMax -Expected 14 -Message "Great Axe maximum damage should include the hero's Strength modifier."
}

function Test-StrengthAsiUpdatesWeaponAttackAndDamage {
    $hero = Get-Hero

    $result = Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "STR+2"
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $hero.STR -Expected 17 -Message "A Strength ASI should raise the barbarian's Strength score."
    Assert-Equal -Actual $result.Increases[0].Amount -Expected 2 -Message "The ASI result should report the applied Strength increase."
    Assert-Equal -Actual $weapon.TotalAttackBonus -Expected 5 -Message "Strength ASI should improve Strength weapon attack rolls."
    Assert-Equal -Actual $weapon.DamageBonus -Expected 3 -Message "Strength ASI should improve Strength weapon damage."
    Assert-Equal -Actual $weapon.TotalDamageMax -Expected 15 -Message "Great Axe max damage should include the improved Strength modifier."
}

function Test-DexterityAsiUpdatesLightArmorAndFinesseWeapon {
    $hero = Get-Hero -Class "Bard"

    Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "DEX+2" | Out-Null
    $weapon = Get-HeroWeaponProfile -Hero $hero

    Assert-Equal -Actual $hero.DEX -Expected 16 -Message "A Dexterity ASI should raise the bard's Dexterity score."
    Assert-Equal -Actual (Get-HeroAbilityModifier -Hero $hero -Ability "DEX") -Expected 3 -Message "Dexterity ASI should improve Dexterity checks and initiative modifier."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 14 -Message "Dexterity ASI should improve light armor armor class."
    Assert-Equal -Actual $weapon.Ability -Expected "DEX" -Message "The bard's rapier should still use Dexterity."
    Assert-Equal -Actual $weapon.TotalAttackBonus -Expected 5 -Message "Dexterity ASI should improve finesse weapon attack rolls."
    Assert-Equal -Actual $weapon.DamageBonus -Expected 3 -Message "Dexterity ASI should improve finesse weapon damage."
}

function Test-ConstitutionAsiRetroactivelyUpdatesMaxHPAndUnarmoredDefense {
    $hero = Get-Hero
    $hero.Level = 4
    $hero.HP = Get-HeroMaxHP -Hero $hero
    $heroHP = $hero.HP

    $asi = Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "CON+2"
    $hpSync = Sync-HeroMaxHPFromAbilityScores -Hero $hero -HeroHP ([ref]$heroHP) -MaxHPDelta $asi.MaxHPDelta

    Assert-Equal -Actual $hero.CON -Expected 17 -Message "A Constitution ASI should raise the barbarian's Constitution score."
    Assert-Equal -Actual $asi.MaxHPDelta -Expected 4 -Message "Constitution ASI should report one max HP per level when the modifier rises."
    Assert-Equal -Actual $hpSync.Delta -Expected 4 -Message "Constitution ASI should retroactively add one HP per level."
    Assert-Equal -Actual $hero.HP -Expected 45 -Message "Max HP should be recalculated from the improved Constitution modifier."
    Assert-Equal -Actual $heroHP -Expected 45 -Message "Current HP should rise with retroactive max HP during a rest."
    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 15 -Message "Constitution ASI should improve barbarian Unarmored Defense."
}

function Test-ConstitutionAsiPreservesRolledMaxHP {
    $hero = Get-Hero
    $hero.Level = 4
    $hero.HP = 50
    $heroHP = 50

    $asi = Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "CON+2"
    Sync-HeroMaxHPFromAbilityScores -Hero $hero -HeroHP ([ref]$heroHP) -MaxHPDelta $asi.MaxHPDelta | Out-Null

    Assert-Equal -Actual $hero.HP -Expected 54 -Message "CON ASI should add a level-based delta instead of overwriting rolled max HP."
    Assert-Equal -Actual $heroHP -Expected 54 -Message "Current HP should preserve rolled max HP plus the CON ASI delta."
}

function Test-CharismaAsiUpdatesBardSaveSkillsAndInspiration {
    $hero = Get-Hero -Class "Bard"

    Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "CHA+2" | Out-Null
    $check = Get-HeroAbilityCheckModifier -Hero $hero -Ability "CHA" -CheckTag "Performance"

    Assert-Equal -Actual $hero.CHA -Expected 17 -Message "A Charisma ASI should raise the bard's Charisma score."
    Assert-Equal -Actual (Get-HeroSpellSaveDC -Hero $hero) -Expected 13 -Message "Charisma ASI should improve bard spell save DC."
    Assert-Equal -Actual $check.TotalModifier -Expected 5 -Message "Charisma ASI should improve Charisma skill checks."
    Assert-Equal -Actual (Get-HeroBardicInspirationMaxDice -Hero $hero) -Expected 4 -Message "Charisma ASI should improve prepared Bardic Inspiration dice."
}

function Test-IntelligenceAsiUpdatesInvestigationChecks {
    $hero = Get-Hero -Class "Bard"

    Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "INT+2" | Out-Null
    $check = Get-HeroAbilityCheckModifier -Hero $hero -Ability "INT" -CheckTag "Investigation"

    Assert-Equal -Actual $hero.INT -Expected 12 -Message "An Intelligence ASI should raise Intelligence."
    Assert-Equal -Actual $check.TotalModifier -Expected 1 -Message "Intelligence ASI should improve Investigation-style checks."
}

function Test-AbilityScoreIncreaseCanSplitDifferentAbilities {
    $hero = Get-Hero -Class "Bard"

    Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "DEX+CHA" | Out-Null

    Assert-Equal -Actual $hero.DEX -Expected 15 -Message "A split ASI should add +1 to the first chosen ability."
    Assert-Equal -Actual $hero.CHA -Expected 16 -Message "A split ASI should add +1 to the second chosen ability."
}

function Test-AbilityScoreIncreaseCapsScoresAtTwenty {
    $hero = Get-Hero
    $hero.STR = 19

    $result = Resolve-HeroAbilityScoreIncrease -Hero $hero -Level 4 -Mode "STR+2"

    Assert-Equal -Actual $hero.STR -Expected 20 -Message "ASI should respect the DnD 5e ability score cap of 20."
    Assert-Equal -Actual $result.Increases[0].Amount -Expected 1 -Message "The ASI result should report only the amount actually applied before the cap."
}

function Test-UnarmoredDefenseUsesRawDexterityAndConstitutionModifiers {
    $hero = Get-Hero
    $hero.DEX = 8
    $hero.CON = 8

    Assert-Equal -Actual (Get-HeroArmorClass -Hero $hero) -Expected 8 -Message "Unarmored Defense should use raw DEX and CON modifiers, including penalties."
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

function Test-BardStartsWithLightCombatProfileAndCharismaEdge {
    $hero = Get-Hero -Class "Bard"
    $weapon = Get-HeroWeaponProfile -Hero $hero
    $check = Get-HeroAbilityCheckModifier -Hero $hero -Ability "CHA"
    $armorClass = Get-HeroArmorClass -Hero $hero
    $instrument = Get-HeroInstrument -Hero $hero

    Assert-Equal -Actual $hero.Class -Expected "Bard" -Message "Get-Hero should be able to create a bard profile."
    Assert-Equal -Actual $hero.Name -Expected "Gariand" -Message "The bard should use the class-specific hero name."
    Assert-Equal -Actual $hero.HP -Expected 9 -Message "A level 1 bard should start with d8 hit points plus Constitution modifier."
    Assert-Equal -Actual $hero.CHA -Expected 15 -Message "The bard should start with strong Charisma."
    Assert-Equal -Actual $weapon.Name -Expected "Rapier" -Message "The bard should start with a lighter one-handed weapon."
    Assert-Equal -Actual $weapon.Ability -Expected "DEX" -Message "Dexterity-based weapons should use the hero's better finesse stat."
    Assert-Equal -Actual $weapon.TotalAttackBonus -Expected 4 -Message "The bard's rapier should still be accurate enough to fight with."
    Assert-Equal -Actual $armorClass -Expected 13 -Message "The bard's leather armor should add Dexterity to armor class."
    Assert-Equal -Actual $check.TotalModifier -Expected 4 -Message "The bard should get a small class bonus on Charisma ability checks."
    Assert-Equal -Actual $instrument.Name -Expected "Travel Lute" -Message "The bard should begin with a starter instrument for bardic inspiration."
    Assert-Equal -Actual $instrument.InspirationBonus -Expected 1 -Message "The starter instrument should add a fixed bonus to bardic inspiration."
}

function Test-InitializeGameCanStartWithChosenClass {
    $game = Initialize-Game -Class "Bard"

    Assert-Equal -Actual $game.Hero.Class -Expected "Bard" -Message "Initialize-Game should honor the selected class."
    Assert-Equal -Actual $game.Hero.Name -Expected "Gariand" -Message "Initialize-Game should carry the bard's class-specific name into the game state."
}

function Test-UiHeroTextUsesCurrentHeroName {
    Set-UiHeroName -Name "Gariand"
    $resolved = Resolve-UiHeroText -Text "Borzig walks into town."
    Set-UiHeroName -Name "Borzig"

    Assert-Equal -Actual $resolved -Expected "Gariand walks into town." -Message "UI text should swap the default hero name for the active hero name."
}

function Test-BardCanPrepareInspirationFromInstrument {
    $hero = Get-Hero -Class "Bard"

    $result = Prepare-HeroBardicInspiration -Hero $hero

    Assert-Equal -Actual $result.Success -Expected $true -Message "A bard with an instrument should be able to prepare bardic inspiration before danger."
    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 3 -Message "Prepared bardic inspiration should equal 1 plus the bard's Charisma modifier."
}

function Test-ShortRestRestoresPreparedBardicInspiration {
    $global:RollDiceOverride = {
        param([int]$Sides = 20)

        if ($Sides -eq 6) { return 3 }
        return 4
    }

    $hero = Get-Hero -Class "Bard"
    $heroHP = 5
    Prepare-HeroBardicInspiration -Hero $hero | Out-Null
    Use-HeroBardicInspirationDie -Hero $hero | Out-Null

    $restResult = Resolve-HeroShortRest -Hero $hero -HeroHP ([ref]$heroHP)

    Assert-Equal -Actual $hero.CurrentBardicInspirationDice -Expected 3 -Message "A short rest should restore the bard's prepared inspiration dice."
    Assert-Equal -Actual $restResult.RestoredBardicInspiration -Expected 1 -Message "Short rest feedback should report how many inspiration dice came back."
    $global:RollDiceOverride = $null
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

    $global:RollDiceOverride = {
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

    Invoke-HeroAttack -Hero $hero -Monster $monster -MonsterHP ([ref]$monsterHP)

    Assert-Equal -Actual $monsterHP -Expected 9 -Message "Hero crit should deal max weapon die plus a new die roll plus Strength modifier."
    $global:RollDiceOverride = $null
}

function Test-TutorialXPLevelsHeroToTwo {
    $hero = Get-Hero
    $heroHP = $hero.HP

    Grant-HeroXP -Hero $hero -XP 300
    Assert-Equal -Actual $hero.Level -Expected 1 -Message "The hero should still be level 1 until a long rest happens."
    $levelUpReady = Get-HeroAvailableLevelUps -Hero $hero
    $levelUpResult = Resolve-HeroLongRestLevelUp -Hero $hero -HeroHP ([ref]$heroHP) -HPMode "F"

    Assert-True -Condition $levelUpResult.LeveledUp -Message "The tutorial XP reward should level the hero up."
    Assert-Equal -Actual $levelUpReady -Expected 1 -Message "The tutorial should make one level up available before the long rest."
    Assert-Equal -Actual $hero.Level -Expected 2 -Message "Tutorial completion should raise the hero to level 2."
    Assert-Equal -Actual $hero.XP -Expected 300 -Message "Tutorial completion should grant 300 XP."
    Assert-Equal -Actual $hero.HP -Expected 23 -Message "A level 2 barbarian should gain average hit die plus Constitution modifier."
    Assert-Equal -Actual $heroHP -Expected 23 -Message "Current HP should increase along with max HP on level up."
}

function Test-LevelUpCanUseRolledHPGain {
    function global:Write-TypeLine { param([string]$Text, [int]$Delay, [string]$Color) }
    function global:Write-Scene { param([string]$Text) }
    function global:Write-Action { param([string]$Text, [string]$Color) }
    function global:Write-ColorLine { param([string]$Text, [string]$Color) }
    function global:Write-SectionTitle { param([string]$Text, [string]$Color) }
    function global:Write-EmphasisLine { param([string]$Text, [string]$Color) }
    $global:RollDiceOverride = {
        param([int]$Sides = 20)

        if ($Sides -eq 12) { return 10 }
        return 1
    }

    $hero = Get-Hero
    $heroHP = $hero.HP

    Grant-HeroXP -Hero $hero -XP 300
    Assert-Equal -Actual $hero.Level -Expected 1 -Message "The hero should not level before the long rest when rolling HP either."
    $levelUpResult = Resolve-HeroLongRestLevelUp -Hero $hero -HeroHP ([ref]$heroHP) -HPMode "R"

    Assert-True -Condition $levelUpResult.LeveledUp -Message "Rolled HP mode should still level the hero up."
    Assert-Equal -Actual $levelUpResult.Results.Count -Expected 1 -Message "The tutorial should only grant one level."
    Assert-Equal -Actual $levelUpResult.Results[0].Mode -Expected "R" -Message "The level up should record that HP was rolled."
    Assert-Equal -Actual $levelUpResult.Results[0].Roll -Expected 10 -Message "The rolled HP result should be captured."
    Assert-Equal -Actual $levelUpResult.Results[0].Gain -Expected 12 -Message "Rolled HP gain should add Constitution modifier to the die roll."
    Assert-Equal -Actual $hero.HP -Expected 26 -Message "A strong HP roll should raise max HP accordingly."
    Assert-Equal -Actual $heroHP -Expected 26 -Message "Current HP should rise by the rolled HP gain."
    $global:RollDiceOverride = $null
}

Test-BetterArmorRaisesArmorClass
Test-BarbarianStartsWithoutHelmet
Test-BarbarianUnarmoredDefenseDoesNotStackWithArmor
Test-BarbarianUnarmoredDefenseStatusExplainsArmorClass
Test-BarbarianUnarmoredDefenseStatusTurnsOffWithArmor
Test-GreatAxeDamageProfile
Test-StrengthAsiUpdatesWeaponAttackAndDamage
Test-DexterityAsiUpdatesLightArmorAndFinesseWeapon
Test-ConstitutionAsiRetroactivelyUpdatesMaxHPAndUnarmoredDefense
Test-ConstitutionAsiPreservesRolledMaxHP
Test-CharismaAsiUpdatesBardSaveSkillsAndInspiration
Test-IntelligenceAsiUpdatesInvestigationChecks
Test-AbilityScoreIncreaseCanSplitDifferentAbilities
Test-AbilityScoreIncreaseCapsScoresAtTwenty
Test-UnarmoredDefenseUsesRawDexterityAndConstitutionModifiers
Test-BarbarianStartsWithPointBuyStatsAndLevelOneHP
Test-BardStartsWithLightCombatProfileAndCharismaEdge
Test-InitializeGameCanStartWithChosenClass
Test-UiHeroTextUsesCurrentHeroName
Test-BardCanPrepareInspirationFromInstrument
Test-ShortRestRestoresPreparedBardicInspiration
Test-TutorialMonsterArmorClassStaysForgiving
Test-HeroCriticalHitUsesMaxDiePlusNewRollPlusStrength
Test-TutorialXPLevelsHeroToTwo
Test-LevelUpCanUseRolledHPGain

Write-Host "Armor upgrade tests passed." -ForegroundColor Green
