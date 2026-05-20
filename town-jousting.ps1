# Fighter-facing arena scaffolding: foot lists, patron attention, and first-pass mounted jousting.

function Initialize-JoustingState {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    if ($null -eq $Game.Town.Jousting) {
        $Game.Town.Jousting = @{}
    }

    foreach ($entry in @(
        @{ Key = "Visits"; Value = 0 },
        @{ Key = "HasHorse"; Value = $false },
        @{ Key = "SquireWins"; Value = 0 },
        @{ Key = "SquireLosses"; Value = 0 },
        @{ Key = "DuelWins"; Value = 0 },
        @{ Key = "DuelLosses"; Value = 0 },
        @{ Key = "MountedWins"; Value = 0 },
        @{ Key = "MountedLosses"; Value = 0 },
        @{ Key = "PatronAttention"; Value = 0 },
        @{ Key = "LastPatronMilestone"; Value = 0 },
        @{ Key = "PresentationMade"; Value = $false },
        @{ Key = "ShieldBashUnlocked"; Value = $false }
    )) {
        if (-not $Game.Town.Jousting.ContainsKey($entry.Key)) {
            $Game.Town.Jousting[$entry.Key] = $entry.Value
        }
    }
}

function Get-JoustingStandingTitle {
    param($Game)

    Initialize-JoustingState -Game $Game
    $mountedRequirements = Get-MountedJoustingRequirements -Game $Game

    if ([int]$Game.Town.Jousting.MountedWins -ge 3) {
        return "Jousting Contender"
    }

    if ([bool]$mountedRequirements.CanEnter) {
        return "Mounted Prospect"
    }

    if ([bool]$Game.Town.Jousting.PresentationMade) {
        return "Patron-Backed Aspirant"
    }

    if ([int]$Game.Town.Jousting.DuelWins -ge 5) {
        return "Armored Duelist"
    }

    if ([int]$Game.Town.Jousting.PatronAttention -ge 6) {
        return "Patron-Noticed Aspirant"
    }

    if ([int]$Game.Town.Jousting.SquireWins -ge 3) {
        return "Sponsored Squire"
    }

    if ([bool]$Game.Town.Jousting.HasHorse) {
        return "Horse Ready"
    }

    if ([int]$Game.Town.Jousting.SquireWins -gt 0) {
        return "Recognized Squire"
    }

    return "Unproven Squire"
}

function Get-JoustingPatronAttentionText {
    param($Game)

    Initialize-JoustingState -Game $Game
    $attention = [int]$Game.Town.Jousting.PatronAttention
    $wins = [int]$Game.Town.Jousting.SquireWins

    if ($attention -ge 6) {
        if ([bool]$Game.Town.Jousting.PresentationMade) {
            return "The rail knows {hero}'s colors now. That is still not knighthood, but it is the first useful shape of sponsorship: people with money can imagine {him} standing where a future mounted prospect should stand."
        }

        return "A clerk in a sober blue coat has started writing {hero}'s name without asking twice. No patron has stepped forward yet, but the rail has stopped treating {him} like hired muscle in borrowed manners."
    }

    if ($wins -ge 3) {
        return "The squires know {hero}'s guard now, and that matters. The next step is not just winning; it is winning cleanly enough that a family with money decides the story is useful."
    }

    if ($attention -gt 0) {
        return "A few people at the rail have noticed {hero}'s discipline. It is not sponsorship yet, but it is the first fragile kind of attention: the sort that can become an invitation if it is fed carefully."
    }

    return "For now the upper rail watches the arena the way it watches weather: interested only if something starts to matter."
}

function Get-HeroJoustingStatus {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $null
    }

    Initialize-JoustingState -Game $Game

    $mountedRequirements = Get-MountedJoustingRequirements -Game $Game

    return [PSCustomObject]@{
        Visits = [int]$Game.Town.Jousting.Visits
        HasHorse = [bool]$Game.Town.Jousting.HasHorse
        HasTourneyArmor = [bool]$mountedRequirements.HasTourneyArmor
        MountedReady = [bool]$mountedRequirements.CanEnter
        SquireWins = [int]$Game.Town.Jousting.SquireWins
        SquireLosses = [int]$Game.Town.Jousting.SquireLosses
        DuelWins = [int]$Game.Town.Jousting.DuelWins
        DuelLosses = [int]$Game.Town.Jousting.DuelLosses
        MountedWins = [int]$Game.Town.Jousting.MountedWins
        MountedLosses = [int]$Game.Town.Jousting.MountedLosses
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
        PresentationMade = [bool]$Game.Town.Jousting.PresentationMade
        HasHeraldicSurcoat = Test-HeroHasHeraldicSurcoat -Hero $Game.Hero
        ShieldBashUnlocked = [bool]$Game.Town.Jousting.ShieldBashUnlocked
        Title = Get-JoustingStandingTitle -Game $Game
    }
}

function Test-HeroHasEquippedShield {
    param($Hero)

    if ($null -eq $Hero -or $null -eq $Hero.Inventory) {
        return $false
    }

    return [bool]($Hero.Inventory | Where-Object { $_.Type -eq "Shield" -and $_.Equipped } | Select-Object -First 1)
}

function Test-HeroHasHeraldicSurcoat {
    param($Hero)

    if ($null -eq $Hero) {
        return $false
    }

    $items = @()

    if ($null -ne $Hero.Inventory) {
        $items += @($Hero.Inventory)
    }

    if ($null -ne $Hero.BackpackInventory) {
        $items += @($Hero.BackpackInventory)
    }

    return [bool]($items | Where-Object { $_.Name -eq "Heraldic Surcoat" } | Select-Object -First 1)
}

function Test-HeroHasMountedJoustingHorse {
    param($Game)

    Initialize-JoustingState -Game $Game

    if ($null -eq $Game -or $null -eq $Game.Town -or $null -eq $Game.Town.Jousting) {
        return $false
    }

    if ($null -ne $Game.Town.Mounts -and [bool]$Game.Town.Mounts.HasRidingHorse) {
        $Game.Town.Jousting.HasHorse = $true
        return $true
    }

    return [bool]$Game.Town.Jousting.HasHorse
}

function Test-HeroHasMountedJoustingArmor {
    param($Hero)

    if ($null -eq $Hero -or $null -eq $Hero.Inventory) {
        return $false
    }

    $tourneyArmorNames = @("Splint Armor", "Plate Armor")

    foreach ($item in $Hero.Inventory) {
        if ($item.Type -eq "Armor" -and $item.Equipped -and $item.Name -in $tourneyArmorNames) {
            return $true
        }
    }

    return $false
}

function Get-MountedJoustingRequirements {
    param($Game)

    $hasHorse = Test-HeroHasMountedJoustingHorse -Game $Game
    $hasTourneyArmor = $false
    $hasLevel = $false

    if ($null -ne $Game -and $null -ne $Game.Hero) {
        $hasTourneyArmor = Test-HeroHasMountedJoustingArmor -Hero $Game.Hero
        $hasLevel = [int]$Game.Hero.Level -ge 4
    }

    $missing = @()

    if (-not $hasLevel) {
        $missing += "level 4"
    }

    if (-not $hasHorse) {
        $missing += "horse"
    }

    if (-not $hasTourneyArmor) {
        $missing += "splint or plate armor"
    }

    return [PSCustomObject]@{
        CanEnter = ($hasLevel -and $hasHorse -and $hasTourneyArmor)
        HasLevel = $hasLevel
        HasHorse = $hasHorse
        HasTourneyArmor = $hasTourneyArmor
        Missing = $missing
        MissingText = if ($missing.Count -gt 0) { ($missing -join ", ") } else { "" }
    }
}

function Get-JoustingPresentationPreviewText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -ne "Fighter") {
        return "The rail is not ready to hear a formal presentation from this hero yet."
    }

    Initialize-JoustingState -Game $Game

    if ([bool]$Game.Town.Jousting.PresentationMade) {
        return "Lubert's colors have already been shown to the rail. The next proof has to come from equipment, wins, and eventually the mounted lists."
    }

    if ([int]$Game.Town.Jousting.PatronAttention -lt 6) {
        return "The rail has noticed Lubert, but not enough for a formal presentation. More clean squire wins will make the heraldry matter instead of looking hopeful."
    }

    if (-not (Test-HeroHasHeraldicSurcoat -Hero $Game.Hero)) {
        return "A clerk explains the ugly rule politely: if Lubert wants patron attention to become backing, he needs colors worth recording. The armorer can sell a Heraldic Surcoat now that the rail knows his name."
    }

    return "Lubert has attention, a record, and colors clean enough for the rail. A formal presentation could turn curiosity into early backing."
}

function Resolve-JoustingPatronPresentation {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{
            Success = $false
            Message = "The rail is not ready to hear a formal presentation from this hero yet."
            Reputation = ""
        }
    }

    Initialize-JoustingState -Game $Game

    if ([bool]$Game.Town.Jousting.PresentationMade) {
        return [PSCustomObject]@{
            Success = $false
            Message = "Lubert's colors have already been shown to the rail. The next proof has to come from equipment, wins, and eventually the mounted lists."
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    if ([int]$Game.Town.Jousting.PatronAttention -lt 6) {
        return [PSCustomObject]@{
            Success = $false
            Message = "The upper rail is watching, but not enough for a formal presentation. More clean squire wins will make the heraldry matter."
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    if (-not (Test-HeroHasHeraldicSurcoat -Hero $Game.Hero)) {
        return [PSCustomObject]@{
            Success = $false
            MissingSurcoat = $true
            Message = "The clerk shakes his head gently. 'Your name is known, Stryer, but colors make a prospect legible. Bring a Heraldic Surcoat and the rail can write more than rumors.'"
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    $Game.Town.Jousting.PresentationMade = $true
    $Game.Town.Jousting.PatronAttention = [Math]::Max([int]$Game.Town.Jousting.PatronAttention, 8)
    $Game.Town.Relationships["TourneyPatrons"] = "Backing"
    $Game.Town.StreetFlags["TourneyPresentationAccepted"] = $true
    Set-TownOfferDiscount -Game $Game -OfferId "armorer_splint_armor" -DiscountCopper 150

    return [PSCustomObject]@{
        Success = $true
        MissingSurcoat = $false
        Message = "Lubert steps before the rail in clean heraldic cloth over honest mail. The clerk records the colors, the wins, and the family that agrees to be seen watching. It is not a title. It is backing, and backing has weight."
        Reputation = Get-JoustingStandingTitle -Game $Game
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
    }
}

function Get-JoustingArenaPreviewText {
    param($Game)

    $status = Get-HeroJoustingStatus -Game $Game
    $mountedRequirements = Get-MountedJoustingRequirements -Game $Game

    if ($null -eq $Game -or $Game.Hero.Class -ne "Fighter") {
        return "The tourney ground is not ready to make room for {hero} yet. For now the lists are a rumor of polished shields, horse sweat, and families who only notice heroes once they look like status."
    }

    if ($mountedRequirements.CanEnter) {
        return "{hero}'s name is now spoken near the mounted lists. The arena can still offer ground bouts today, and the list-master can now hand over a blunted practice lance for proper mounted passes."
    }

    if ($status.HasHorse) {
        return "{hero}'s name is now spoken near the mounted lists, but the list-master still points at the armor racks. A horse is only half the invitation. Splint or plate armor is required before the proper tournament lets {him} ride."
    }

    return "{hero} finds the tourney ground behind painted rails and clean sand. Squires drill with blunted blades while older knights watch posture, shield discipline, and whether a fighter knows how to win without looking desperate. Mounted jousting waits until {hero} owns a horse and wears splint or plate armor; for now, the arena offers squire sparring and a first taste of upper-city attention."
}

function Get-TourneyGroundDuelOpponents {
    return @(
        [PSCustomObject]@{
            Id = "shield_squire"
            Name = "Sirren Vale"
            Definite = "Sirren Vale"
            Style = "Shield"
            ArmorClass = 17
            AttackBonus = 4
            Damage = 5
            Intro = "Sirren Vale raises a heater shield painted in careful green quarters. He fights like someone taught to survive first and impress second."
        },
        [PSCustomObject]@{
            Id = "maul_aspirant"
            Name = "Maudren Pike"
            Definite = "Maudren Pike"
            Style = "Two-Handed"
            ArmorClass = 16
            AttackBonus = 5
            Damage = 7
            Intro = "Maudren Pike takes the ring in dented mail with a padded maul across one shoulder, all heavy steps and dangerous timing."
        },
        [PSCustomObject]@{
            Id = "ledger_knight"
            Name = "Elian Voss"
            Definite = "Elian Voss"
            Style = "Shield"
            ArmorClass = 18
            AttackBonus = 5
            Damage = 6
            Intro = "Elian Voss waits under the rail with a family shield and polished mail, calm enough to make every mistake look expensive."
        }
    )
}

function Get-HeroTourneyDuelRivalryRecord {
    param(
        $Hero,
        [string]$OpponentName
    )

    if ($null -eq $Hero.PSObject.Properties["TourneyDuelRivalries"]) {
        $Hero | Add-Member -NotePropertyName TourneyDuelRivalries -NotePropertyValue @{}
    }

    if ($null -eq $Hero.TourneyDuelRivalries[$OpponentName]) {
        $Hero.TourneyDuelRivalries[$OpponentName] = [PSCustomObject]@{
            HeroWins = 0
            OpponentWins = 0
        }
    }

    return $Hero.TourneyDuelRivalries[$OpponentName]
}

function Update-HeroTourneyDuelRivalryRecord {
    param(
        $Hero,
        $Opponent,
        [bool]$HeroWon
    )

    $record = Get-HeroTourneyDuelRivalryRecord -Hero $Hero -OpponentName $Opponent.Name

    if ($HeroWon) {
        $record.HeroWins += 1
    }
    else {
        $record.OpponentWins += 1
    }

    return $record
}

function Get-TourneyDuelRivalIntroText {
    param(
        $Hero,
        $Opponent,
        $Record
    )

    if ($null -eq $Record -or ([int]$Record.HeroWins + [int]$Record.OpponentWins) -eq 0) {
        return $null
    }

    $score = "$($Record.HeroWins)-$($Record.OpponentWins)"

    switch ($Opponent.Name) {
        "Sirren Vale" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Sirren salutes more sharply than before. Losing to Lubert has made his shield quieter and his pride louder; he is here to prove the last exchange was instruction, not judgment."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Sirren taps his shield once, polite enough to look harmless and confident enough to be insulting. The record favors him at $score, and he remembers every clean stop."
            }

            return "Sirren gives a restrained nod toward the marshal. Their record is even at $score, which makes the rail watch the first shield movement instead of the first strike."
        }
        "Maudren Pike" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Maudren rolls his maul hand and smiles without warmth. Lubert has beaten the heavy swing before; now Maudren is trying to make patience look like cowardice."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Maudren plants the maul head in the sand like a flag. The record favors him at $score, and a few squires near the rail clearly expect the same hard ending."
            }

            return "Maudren squints across the ring. Even at $score, neither fighter has solved the question of reach against discipline."
        }
        "Elian Voss" {
            if ($Record.HeroWins -gt $Record.OpponentWins) {
                return "Elian's smile is smaller today. A family shield can forgive one public loss; it has a harder time forgiving a pattern."
            }

            if ($Record.OpponentWins -gt $Record.HeroWins) {
                return "Elian waits with courtly patience, wearing the record like another polished plate. At $score, he has reason to believe the rail already knows the ending."
            }

            return "Elian studies Lubert over the shield rim. The record is even at $score, and the silence around the rail turns formal."
        }
        default {
            return "The marshal reads the record at $score, and the duel stops feeling like ordinary rotation."
        }
    }
}

function Get-TourneyDuelRivalOutcomeText {
    param(
        $Hero,
        $Opponent,
        $Record,
        [bool]$HeroWon
    )

    $score = "$($Record.HeroWins)-$($Record.OpponentWins)"

    switch ($Opponent.Name) {
        "Sirren Vale" {
            if ($HeroWon) {
                return "Sirren lowers his shield and gives Lubert the full salute this time. Their record is $score, and the respect in it has started costing Sirren pride."
            }

            return "Sirren keeps the shield high until the marshal calls it. Their record is $score, and his relief is too disciplined to show anywhere but the hand gripping the strap."
        }
        "Maudren Pike" {
            if ($HeroWon) {
                return "Maudren laughs once and spits sand from his lip. Their record is $score; next time, he says, he will make Lubert's shield arm pay rent."
            }

            return "Maudren rests the maul on one shoulder and lets the rail see him breathing easy. Their record is $score, and he looks pleased that force still has arguments left."
        }
        "Elian Voss" {
            if ($HeroWon) {
                return "Elian accepts the loss with perfect manners and angry eyes. Their record is $score, which means someone at the rail will repeat Lubert's name tonight."
            }

            return "Elian bows just deep enough to be correct. Their record is $score, and the rail hears the quiet lesson: pedigree still knows how to defend itself."
        }
        default {
            if ($HeroWon) {
                return "The record moves to $score in Lubert's favor."
            }

            return "The record moves to $score against Lubert."
        }
    }
}

function Get-TourneyDuelOpponentIntro {
    param(
        $Hero,
        $Opponent
    )

    $intro = Resolve-HeroNarrativeText -Text $Opponent.Intro -Hero $Hero
    $record = Get-HeroTourneyDuelRivalryRecord -Hero $Hero -OpponentName $Opponent.Name
    $rivalText = Get-TourneyDuelRivalIntroText -Hero $Hero -Opponent $Opponent -Record $record

    if (-not [string]::IsNullOrWhiteSpace($rivalText)) {
        return "$intro `n$rivalText"
    }

    return $intro
}

function Get-TourneyGroundDuelOpponent {
    param(
        $Game,
        [string]$OpponentId = ""
    )

    $opponents = @(Get-TourneyGroundDuelOpponents)

    if (-not [string]::IsNullOrWhiteSpace($OpponentId)) {
        $match = $opponents | Where-Object { $_.Id -eq $OpponentId } | Select-Object -First 1
        if ($null -ne $match) {
            return $match
        }
    }

    Initialize-JoustingState -Game $Game
    $wins = [int]$Game.Town.Jousting.DuelWins

    if ($wins -ge 4) {
        return ($opponents | Where-Object { $_.Id -eq "ledger_knight" } | Select-Object -First 1)
    }

    if ($wins -ge 2) {
        return ($opponents | Where-Object { $_.Id -eq "maul_aspirant" } | Select-Object -First 1)
    }

    return ($opponents | Where-Object { $_.Id -eq "shield_squire" } | Select-Object -First 1)
}

function Get-TourneyGroundDuelTechniqueSummary {
    param(
        $Game,
        [string]$Technique = "Measured"
    )

    Initialize-JoustingState -Game $Game
    $hasShield = Test-HeroHasEquippedShield -Hero $Game.Hero
    $shieldBashUnlocked = [bool]$Game.Town.Jousting.ShieldBashUnlocked

    switch ($Technique) {
        "ShieldBash" {
            return [PSCustomObject]@{
                Id = "ShieldBash"
                Name = "Shield Bash"
                CanUse = ($hasShield -and $shieldBashUnlocked)
                AttackBonus = 2
                DefensePenalty = 0
                PatronBonus = 1
                Message = if (-not $hasShield) { "Shield Bash requires an equipped shield." } elseif (-not $shieldBashUnlocked) { "Shield Bash unlocks after three armored duel wins." } else { "" }
            }
        }
        "Committed" {
            return [PSCustomObject]@{
                Id = "Committed"
                Name = "Committed Strike"
                CanUse = $true
                AttackBonus = 2
                DefensePenalty = -1
                PatronBonus = 0
                Message = ""
            }
        }
        default {
            return [PSCustomObject]@{
                Id = "Measured"
                Name = "Measured Guard"
                CanUse = $true
                AttackBonus = 0
                DefensePenalty = 1
                PatronBonus = 0
                Message = ""
            }
        }
    }
}

function Get-TourneyGroundDuelPreviewText {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -ne "Fighter") {
        return "The armed tourney ring is not ready to make room for this hero yet."
    }

    Initialize-JoustingState -Game $Game
    $status = Get-HeroJoustingStatus -Game $Game
    $shieldText = if ($status.ShieldBashUnlocked) { "Shield Bash is known." } else { "Three armored duel wins will teach Shield Bash." }

    return "The foot lists are for armored aspirants who do not yet have the horse, lance, or splint-and-plate proof for mounted jousting. Matches use blunted weapons, real armor, and formal scoring. $shieldText"
}

function Resolve-TourneyGroundDuel {
    param(
        $Game,
        [string]$Technique = "Measured",
        [string]$OpponentId = "",
        [int[]]$HeroRolls = @(),
        [int[]]$OpponentRolls = @()
    )

    if ($null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{
            Success = $false
            Message = "The armed tourney ring is not ready to make room for this hero yet."
            Reputation = ""
        }
    }

    Initialize-JoustingState -Game $Game
    $techniqueSummary = Get-TourneyGroundDuelTechniqueSummary -Game $Game -Technique $Technique

    if (-not $techniqueSummary.CanUse) {
        return [PSCustomObject]@{
            Success = $false
            Blocked = $true
            Message = $techniqueSummary.Message
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    $opponent = Get-TourneyGroundDuelOpponent -Game $Game -OpponentId $OpponentId
    $introText = Get-TourneyDuelOpponentIntro -Hero $Game.Hero -Opponent $opponent
    $weapon = Get-HeroWeaponProfile -Hero $Game.Hero
    $heroArmorClass = Get-HeroArmorClass -Hero $Game.Hero
    $heroScore = 0
    $opponentScore = 0
    $exchangeTexts = @()

    for ($round = 0; $round -lt 3; $round++) {
        $heroRoll = if ($round -lt $HeroRolls.Count -and $HeroRolls[$round] -gt 0) { [int]$HeroRolls[$round] } else { Roll-Dice -Sides 20 }
        $opponentRoll = if ($round -lt $OpponentRolls.Count -and $OpponentRolls[$round] -gt 0) { [int]$OpponentRolls[$round] } else { Roll-Dice -Sides 20 }
        $heroTotal = $heroRoll + [int]$weapon.TotalAttackBonus + [int]$techniqueSummary.AttackBonus
        $opponentTotal = $opponentRoll + [int]$opponent.AttackBonus
        $effectiveHeroArmorClass = $heroArmorClass + [int]$techniqueSummary.DefensePenalty

        if ($heroRoll -eq 20 -or ($heroRoll -ne 1 -and $heroTotal -ge [int]$opponent.ArmorClass)) {
            $heroScore++
        }

        if ($opponentRoll -eq 20 -or ($opponentRoll -ne 1 -and $opponentTotal -ge $effectiveHeroArmorClass)) {
            $opponentScore++
        }

        $exchangeTexts += "Exchange $($round + 1): $($Game.Hero.Name) $heroTotal vs AC $($opponent.ArmorClass); $($opponent.Definite) $opponentTotal vs AC $effectiveHeroArmorClass."

        if ($heroScore -ge 2 -or $opponentScore -ge 2) {
            break
        }
    }

    $heroWon = $heroScore -gt $opponentScore
    $Game.Town.Jousting.Visits = [int]$Game.Town.Jousting.Visits + 1

    if ($heroWon) {
        $updatedRecord = Update-HeroTourneyDuelRivalryRecord -Hero $Game.Hero -Opponent $opponent -HeroWon $true
        $rivalOutcome = Get-TourneyDuelRivalOutcomeText -Hero $Game.Hero -Opponent $opponent -Record $updatedRecord -HeroWon $true
        $Game.Town.Jousting.DuelWins = [int]$Game.Town.Jousting.DuelWins + 1
        $Game.Town.Jousting.SquireWins = [int]$Game.Town.Jousting.SquireWins + 1
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + 2 + [int]$techniqueSummary.PatronBonus
        $Game.Town.Relationships["TourneyGround"] = "Duelist"

        $shieldBashUnlocked = $false
        if (-not [bool]$Game.Town.Jousting.ShieldBashUnlocked -and [int]$Game.Town.Jousting.DuelWins -ge 3 -and (Test-HeroHasEquippedShield -Hero $Game.Hero)) {
            $Game.Town.Jousting.ShieldBashUnlocked = $true
            $shieldBashUnlocked = $true
            $Game.Town.StreetFlags["ShieldBashUnlocked"] = $true
        }

        if ([int]$Game.Town.Jousting.PatronAttention -ge 6) {
            $Game.Town.Relationships["TourneyPatrons"] = "Watching"
            $Game.Town.StreetFlags["TourneyPatronAttentionUnlocked"] = $true
            $Game.Town.Jousting.LastPatronMilestone = [Math]::Max([int]$Game.Town.Jousting.LastPatronMilestone, 6)
        }

        return [PSCustomObject]@{
            Success = $true
            Opponent = $opponent.Name
            IntroText = $introText
            Technique = $techniqueSummary.Name
            Message = if ($shieldBashUnlocked) { "{hero} wins the armored duel and the marshal finally nods at the shield work. Shield Bash is no longer a trick; it is trained technique." } else { "{hero} wins the armored duel by making $($weapon.Name) and armor discipline look like one clean argument." }
            RivalOutcomeText = $rivalOutcome
            ExchangeLog = $exchangeTexts
            HeroScore = $heroScore
            OpponentScore = $opponentScore
            RivalRecord = $updatedRecord
            DuelWins = [int]$Game.Town.Jousting.DuelWins
            DuelLosses = [int]$Game.Town.Jousting.DuelLosses
            PatronAttention = [int]$Game.Town.Jousting.PatronAttention
            ShieldBashUnlocked = [bool]$Game.Town.Jousting.ShieldBashUnlocked
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    $updatedRecord = Update-HeroTourneyDuelRivalryRecord -Hero $Game.Hero -Opponent $opponent -HeroWon $false
    $rivalOutcome = Get-TourneyDuelRivalOutcomeText -Hero $Game.Hero -Opponent $opponent -Record $updatedRecord -HeroWon $false
    $Game.Town.Jousting.DuelLosses = [int]$Game.Town.Jousting.DuelLosses + 1
    $Game.Town.Jousting.SquireLosses = [int]$Game.Town.Jousting.SquireLosses + 1

    if ($heroScore -gt 0) {
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + 1
    }

    return [PSCustomObject]@{
        Success = $false
        Opponent = $opponent.Name
        IntroText = $introText
        Technique = $techniqueSummary.Name
        Message = "{hero} loses the armored duel on points. The marshal calls it clean, which somehow makes it more irritating."
        RivalOutcomeText = $rivalOutcome
        ExchangeLog = $exchangeTexts
        HeroScore = $heroScore
        OpponentScore = $opponentScore
        RivalRecord = $updatedRecord
        DuelWins = [int]$Game.Town.Jousting.DuelWins
        DuelLosses = [int]$Game.Town.Jousting.DuelLosses
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
        ShieldBashUnlocked = [bool]$Game.Town.Jousting.ShieldBashUnlocked
        Reputation = Get-JoustingStandingTitle -Game $Game
    }
}

function Get-MountedJoustingOpponents {
    return @(
        [PSCustomObject]@{
            Id = "red_plume_prospect"
            Name = "Cassian Redplume"
            Definite = "Cassian Redplume"
            LanceBonus = 5
            SeatBonus = 3
            Intro = "Cassian Redplume wheels a bay horse into the near lane, red feathers tied at the helm like a dare."
        },
        [PSCustomObject]@{
            Id = "white_gate_rider"
            Name = "Tamsin of White Gate"
            Definite = "Tamsin of White Gate"
            LanceBonus = 6
            SeatBonus = 4
            Intro = "Tamsin of White Gate lowers a practice lance with courtly precision, her horse already answering the smallest knee pressure."
        }
    )
}

function Get-MountedJoustingOpponent {
    param(
        $Game,
        [string]$OpponentId = ""
    )

    $opponents = @(Get-MountedJoustingOpponents)

    if (-not [string]::IsNullOrWhiteSpace($OpponentId)) {
        $match = $opponents | Where-Object { $_.Id -eq $OpponentId } | Select-Object -First 1
        if ($null -ne $match) {
            return $match
        }
    }

    Initialize-JoustingState -Game $Game
    if ([int]$Game.Town.Jousting.MountedWins -ge 2) {
        return ($opponents | Where-Object { $_.Id -eq "white_gate_rider" } | Select-Object -First 1)
    }

    return ($opponents | Where-Object { $_.Id -eq "red_plume_prospect" } | Select-Object -First 1)
}

function Get-MountedJoustingSectionOption {
    param(
        [int]$DistanceFeet,
        [string]$Choice = ""
    )

    $normalizedChoice = if ([string]::IsNullOrWhiteSpace($Choice)) { "1" } else { $Choice.Trim() }

    switch ($DistanceFeet) {
        90 {
            if ($normalizedChoice -in @("2", "SPUR", "FAST")) {
                return [PSCustomObject]@{
                    Id = "SpurEarly"
                    Name = "Spur Early"
                    LanceBonus = 2
                    SeatBonus = -1
                    PatronBonus = 1
                    Description = "Push speed early and ask the horse to own the lane."
                }
            }

            if ($normalizedChoice -in @("3", "READ", "WATCH")) {
                return [PSCustomObject]@{
                    Id = "ReadLine"
                    Name = "Read the Line"
                    LanceBonus = 0
                    SeatBonus = 2
                    PatronBonus = 1
                    Description = "Read the opponent's angle before the lane narrows."
                }
            }

            return [PSCustomObject]@{
                Id = "HoldLine"
                Name = "Hold the Line"
                LanceBonus = 1
                SeatBonus = 1
                PatronBonus = 1
                Description = "Keep the horse straight and make the first line honest."
            }
        }
        60 {
            if ($normalizedChoice -in @("2", "LOWER", "LANCE")) {
                return [PSCustomObject]@{
                    Id = "LowerLance"
                    Name = "Lower the Lance"
                    LanceBonus = 2
                    SeatBonus = 0
                    PatronBonus = 1
                    Description = "Commit the lance point while there is still time to correct the seat."
                }
            }

            if ($normalizedChoice -in @("3", "SHIELD", "GUARD")) {
                return [PSCustomObject]@{
                    Id = "SetShield"
                    Name = "Set the Shield"
                    LanceBonus = -1
                    SeatBonus = 3
                    PatronBonus = 1
                    Description = "Protect the seat and make the opponent spend force badly."
                }
            }

            return [PSCustomObject]@{
                Id = "AdjustSeat"
                Name = "Adjust Seat"
                LanceBonus = 0
                SeatBonus = 2
                PatronBonus = 1
                Description = "Settle balance before the rail starts deciding the pass."
            }
        }
        default {
            if ($normalizedChoice -in @("2", "BRACE")) {
                return [PSCustomObject]@{
                    Id = "BraceImpact"
                    Name = "Brace for Impact"
                    LanceBonus = -1
                    SeatBonus = 4
                    PatronBonus = 1
                    Description = "Survive the crash first and trust the rail to respect control."
                }
            }

            if ($normalizedChoice -in @("3", "FEINT")) {
                return [PSCustomObject]@{
                    Id = "Last-Breath Feint"
                    Name = "Last-Breath Feint"
                    LanceBonus = 3
                    SeatBonus = -2
                    PatronBonus = 2
                    Description = "Shift the point late and gamble the seat on timing."
                }
            }

            return [PSCustomObject]@{
                Id = "CommitStrike"
                Name = "Commit the Strike"
                LanceBonus = 2
                SeatBonus = 0
                PatronBonus = 2
                Description = "Take the final line and let the lance decide the pass."
            }
        }
    }
}

function Get-MountedJoustingSectionMenuOptions {
    param([int]$DistanceFeet)

    switch ($DistanceFeet) {
        90 { return @("1. Hold the Line", "2. Spur Early", "3. Read the Line") }
        60 { return @("1. Adjust Seat", "2. Lower the Lance", "3. Set the Shield") }
        default { return @("1. Commit the Strike", "2. Brace for Impact", "3. Last-Breath Feint") }
    }
}

function Resolve-MountedJoustingPasses {
    param(
        $Game,
        [string]$Technique = "Steady",
        [string[]]$SectionChoices = @(),
        [string]$OpponentId = "",
        [int[]]$HeroRolls = @(),
        [int[]]$OpponentRolls = @()
    )

    if ($null -eq $Game -or $null -eq $Game.Hero -or $Game.Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{ Success = $false; Blocked = $true; Message = "The mounted lists are not ready to make room for this hero yet."; Reputation = "" }
    }

    Initialize-JoustingState -Game $Game
    $requirements = Get-MountedJoustingRequirements -Game $Game
    if (-not $requirements.CanEnter) {
        return [PSCustomObject]@{
            Success = $false
            Blocked = $true
            Message = "Mounted jousting requires $($requirements.MissingText)."
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    if ($SectionChoices.Count -le 0) {
        $SectionChoices = switch ($Technique) {
            "Spur" { @("2", "2", "3") }
            "Guarded" { @("3", "3", "2") }
            default { @("1", "1", "1") }
        }
    }

    $opponent = Get-MountedJoustingOpponent -Game $Game -OpponentId $OpponentId
    $strengthModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "STR"
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "CON"
    $heroScore = 0
    $opponentScore = 0
    $exchangeTexts = @()
    $distances = @(90, 60, 30)
    $chosenOptions = @()
    $totalPatronBonus = 0

    for ($pass = 0; $pass -lt 3; $pass++) {
        $heroRoll = if ($pass -lt $HeroRolls.Count -and $HeroRolls[$pass] -gt 0) { [int]$HeroRolls[$pass] } else { Roll-Dice -Sides 20 }
        $opponentRoll = if ($pass -lt $OpponentRolls.Count -and $OpponentRolls[$pass] -gt 0) { [int]$OpponentRolls[$pass] } else { Roll-Dice -Sides 20 }
        $choice = if ($pass -lt $SectionChoices.Count) { [string]$SectionChoices[$pass] } else { "1" }
        $sectionOption = Get-MountedJoustingSectionOption -DistanceFeet ([int]$distances[$pass]) -Choice $choice
        $chosenOptions += $sectionOption
        $totalPatronBonus += [int]$sectionOption.PatronBonus
        $heroTotal = $heroRoll + $strengthModifier + $constitutionModifier + [int]$sectionOption.LanceBonus + [int]$sectionOption.SeatBonus
        $opponentTotal = $opponentRoll + [int]$opponent.LanceBonus + [int]$opponent.SeatBonus

        if ($heroRoll -eq 20 -or ($heroRoll -ne 1 -and $heroTotal -ge $opponentTotal)) {
            $heroScore++
        }
        else {
            $opponentScore++
        }

        $exchangeTexts += "Pass $($pass + 1) from $($distances[$pass]) ft: $($Game.Hero.Name) $heroTotal with $($sectionOption.Name); $($opponent.Definite) $opponentTotal."
    }

    $heroWon = $heroScore -gt $opponentScore
    $Game.Town.Jousting.Visits = [int]$Game.Town.Jousting.Visits + 1

    if ($heroWon) {
        $Game.Town.Jousting.MountedWins = [int]$Game.Town.Jousting.MountedWins + 1
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + $totalPatronBonus
        $Game.Town.Relationships["TourneyPatrons"] = "Mounted Watching"
        return [PSCustomObject]@{
            Success = $true
            Opponent = $opponent.Name
            IntroText = $opponent.Intro
            Technique = (@($chosenOptions | ForEach-Object { $_.Name }) -join " / ")
            SectionChoices = $chosenOptions
            Message = "{hero} keeps the horse under him through the final crash and wins the mounted passes by $heroScore-$opponentScore."
            ExchangeLog = $exchangeTexts
            HeroScore = $heroScore
            OpponentScore = $opponentScore
            MountedWins = [int]$Game.Town.Jousting.MountedWins
            MountedLosses = [int]$Game.Town.Jousting.MountedLosses
            PatronAttention = [int]$Game.Town.Jousting.PatronAttention
            Reputation = Get-JoustingStandingTitle -Game $Game
        }
    }

    $Game.Town.Jousting.MountedLosses = [int]$Game.Town.Jousting.MountedLosses + 1
    if ($heroScore -gt 0) {
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + 1
    }

    return [PSCustomObject]@{
        Success = $false
        Opponent = $opponent.Name
        IntroText = $opponent.Intro
        Technique = (@($chosenOptions | ForEach-Object { $_.Name }) -join " / ")
        SectionChoices = $chosenOptions
        Message = "{hero} loses the mounted passes $heroScore-$opponentScore. The marshal calls it clean, and the rail learns exactly what still needs work."
        ExchangeLog = $exchangeTexts
        HeroScore = $heroScore
        OpponentScore = $opponentScore
        MountedWins = [int]$Game.Town.Jousting.MountedWins
        MountedLosses = [int]$Game.Town.Jousting.MountedLosses
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
        Reputation = Get-JoustingStandingTitle -Game $Game
    }
}

function Resolve-JoustingArenaSquireSpar {
    param(
        $Game,
        [int]$Roll = 0
    )

    if ($null -eq $Game -or $Game.Hero.Class -ne "Fighter") {
        return [PSCustomObject]@{
            Success = $false
            Message = "The arena has no proper card for this hero yet."
            Reputation = ""
        }
    }

    if ($Roll -le 0) {
        $Roll = Roll-Dice -Sides 20
    }

    Initialize-JoustingState -Game $Game
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "CON"
    $strengthModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "STR"
    $total = $Roll + $constitutionModifier + $strengthModifier
    $success = $total -ge 15

    $Game.Town.Jousting.Visits = [int]$Game.Town.Jousting.Visits + 1
    $patronAttentionBefore = [int]$Game.Town.Jousting.PatronAttention

    if ($success) {
        $Game.Town.Jousting.SquireWins = [int]$Game.Town.Jousting.SquireWins + 1
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + 2
        $Game.Town.Relationships["TourneyGround"] = "Noticed"

        $milestoneUnlocked = $patronAttentionBefore -lt 6 -and [int]$Game.Town.Jousting.PatronAttention -ge 6
        if ($milestoneUnlocked) {
            $Game.Town.Relationships["TourneyPatrons"] = "Watching"
            $Game.Town.StreetFlags["TourneyPatronAttentionUnlocked"] = $true
            $Game.Town.Jousting.LastPatronMilestone = 6
        }

        return [PSCustomObject]@{
            Success = $true
            Message = if ($milestoneUnlocked) { "{hero} holds the shield line, answers with the shortsword, and wins the exchange cleanly enough that a clerk at the upper rail asks for {his} name. That is not knighthood. It is better than anonymity." } else { "{hero} holds the shield line, answers with the shortsword, and wins the exchange cleanly enough that a watching knight stops pretending not to care." }
            Reputation = Get-JoustingStandingTitle -Game $Game
            RollTotal = $total
            PatronAttention = [int]$Game.Town.Jousting.PatronAttention
            MilestoneUnlocked = $milestoneUnlocked
        }
    }

    $Game.Town.Jousting.SquireLosses = [int]$Game.Town.Jousting.SquireLosses + 1

    if ($total -ge 12) {
        $Game.Town.Jousting.PatronAttention = [int]$Game.Town.Jousting.PatronAttention + 1
    }

    return [PSCustomObject]@{
        Success = $false
        Message = "{hero} stays standing, which matters, but the exchange ends with sand on the knees and a squire's polite little bow that stings worse than mockery."
        Reputation = Get-JoustingStandingTitle -Game $Game
        RollTotal = $total
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
        MilestoneUnlocked = $false
    }
}

function Start-JoustingArena {
    param($Game)

    Write-SectionTitle -Text "Tourney Ground" -Color "Yellow"
    Write-TownTimeTracker -Game $Game -Area "Tourney Ground"
    Write-Scene (Resolve-HeroNarrativeText -Text (Get-JoustingArenaPreviewText -Game $Game) -Hero $Game.Hero)

    if ($Game.Hero.Class -ne "Fighter") {
        Write-ColorLine ""
        return
    }

    while ($true) {
        $status = Get-HeroJoustingStatus -Game $Game
        $horseText = if ($status.HasHorse) { "Owned" } else { "Needed" }
        $armorText = if ($status.HasTourneyArmor) { "Ready" } else { "Needs splint/plate" }
        $bashText = if ($status.ShieldBashUnlocked) { "Shield Bash" } else { "Shield Bash locked" }
        Write-ColorLine "Arena Standing: $($status.Title) | Mounted: $($status.MountedWins)-$($status.MountedLosses) | Duel: $($status.DuelWins)-$($status.DuelLosses) | Squire: $($status.SquireWins)-$($status.SquireLosses) | Patron attention: $($status.PatronAttention) | $bashText | Horse: $horseText | Tourney armor: $armorText" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "1. Enter an armored aspirant duel" "White"
        Write-ColorLine "2. Spar lightly against a squire" "White"
        Write-ColorLine "3. Enter mounted jousting" $(if ($status.MountedReady) { "White" } else { "DarkGray" })
        Write-ColorLine "4. Ask what the patrons think" "White"
        Write-ColorLine "5. Ask about mounted jousting" "White"
        Write-ColorLine "6. Present colors to the patron rail" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Write-Scene (Resolve-HeroNarrativeText -Text (Get-TourneyGroundDuelPreviewText -Game $Game) -Hero $Game.Hero)
                Write-ColorLine "1. Measured Guard" "White"
                Write-ColorLine "2. Committed Strike" "White"
                Write-ColorLine "3. Shield Bash" "White"
                $techniqueChoice = Read-Host "Technique"
                $technique = switch ($techniqueChoice) {
                    "2" { "Committed" }
                    "3" { "ShieldBash" }
                    default { "Measured" }
                }
                $result = Resolve-TourneyGroundDuel -Game $Game -Technique $technique
                if (-not [string]::IsNullOrWhiteSpace($result.IntroText)) {
                    Write-Scene $result.IntroText
                }
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                if (-not [string]::IsNullOrWhiteSpace($result.RivalOutcomeText)) {
                    Write-Scene $result.RivalOutcomeText
                }
                if ($null -ne $result.ExchangeLog) {
                    foreach ($exchange in $result.ExchangeLog) {
                        Write-ColorLine $exchange "DarkGray"
                    }
                }
                Write-EmphasisLine -Text "Duel record: $($result.DuelWins)-$($result.DuelLosses). Arena standing: $($result.Reputation). Patron attention: $($result.PatronAttention)." -Color "Yellow"
                Write-ColorLine ""
            }
            "2" {
                $result = Resolve-JoustingArenaSquireSpar -Game $Game
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                Write-EmphasisLine -Text "Arena standing: $($result.Reputation). Patron attention: $($result.PatronAttention)." -Color "Yellow"
                Write-ColorLine ""
            }
            "3" {
                $requirements = Get-MountedJoustingRequirements -Game $Game
                if (-not $requirements.CanEnter) {
                    Write-EmphasisLine -Text "Mounted jousting requires $($requirements.MissingText)." -Color "Yellow"
                    Write-ColorLine ""
                    continue
                }

                Write-Scene "The list-master sends Lubert to the mounted lane with a blunted practice lance and no patience for pretending this is still footwork."
                $sectionChoices = @()
                foreach ($distance in @(90, 60, 30)) {
                    Write-SectionTitle -Text "$distance ft" -Color "DarkYellow"
                    foreach ($optionText in @(Get-MountedJoustingSectionMenuOptions -DistanceFeet $distance)) {
                        Write-ColorLine $optionText "White"
                    }
                    $sectionChoices += (Read-Host "Choose at $distance ft")
                }
                $result = Resolve-MountedJoustingPasses -Game $Game -SectionChoices $sectionChoices
                Write-Scene $result.IntroText
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                foreach ($exchange in @($result.ExchangeLog)) {
                    Write-ColorLine $exchange "DarkGray"
                }
                Write-EmphasisLine -Text "Mounted record: $($result.MountedWins)-$($result.MountedLosses). Arena standing: $($result.Reputation). Patron attention: $($result.PatronAttention)." -Color "Yellow"
                Write-ColorLine ""
            }
            "4" {
                Write-Scene (Resolve-HeroNarrativeText -Text (Get-JoustingPatronAttentionText -Game $Game) -Hero $Game.Hero)
                Write-ColorLine ""
            }
            "5" {
                $requirements = Get-MountedJoustingRequirements -Game $Game
                Write-Scene "The list-master taps a lance rack with two fingers. 'Level, horse, splint or plate. Then we give you a practice lance and see whether your shield arm belongs in a tourney or only in an alley.'"
                if ($requirements.CanEnter) {
                    Write-EmphasisLine -Text "Mounted jousting ready: choose the mounted list and ride a three-pass match." -Color "Yellow"
                }
                else {
                    Write-EmphasisLine -Text "Future unlock requirements: $($requirements.MissingText)." -Color "Yellow"
                }
                Write-ColorLine ""
            }
            "6" {
                $result = Resolve-JoustingPatronPresentation -Game $Game
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                if ($result.Success) {
                    Write-EmphasisLine -Text "Arena standing: $($result.Reputation). Patron attention: $($result.PatronAttention). Splint armor is easier to afford through patron backing." -Color "Yellow"
                }
                else {
                    Write-EmphasisLine -Text (Resolve-HeroNarrativeText -Text (Get-JoustingPresentationPreviewText -Game $Game) -Hero $Game.Hero) -Color "Yellow"
                }
                Write-ColorLine ""
            }
            "0" { return }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}
