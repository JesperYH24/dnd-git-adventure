# Fighter-facing arena scaffolding. Mounted jousting waits for horse, heavy tourney armor, and lance systems later.

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
        @{ Key = "PatronAttention"; Value = 0 },
        @{ Key = "LastPatronMilestone"; Value = 0 },
        @{ Key = "PresentationMade"; Value = $false }
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

    if ([bool]$mountedRequirements.CanEnter) {
        return "Mounted Prospect"
    }

    if ([bool]$Game.Town.Jousting.PresentationMade) {
        return "Patron-Backed Aspirant"
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
        PatronAttention = [int]$Game.Town.Jousting.PatronAttention
        PresentationMade = [bool]$Game.Town.Jousting.PresentationMade
        HasHeraldicSurcoat = Test-HeroHasHeraldicSurcoat -Hero $Game.Hero
        Title = Get-JoustingStandingTitle -Game $Game
    }
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

    if ($null -ne $Game -and $null -ne $Game.Hero) {
        $hasTourneyArmor = Test-HeroHasMountedJoustingArmor -Hero $Game.Hero
    }

    $missing = @()

    if (-not $hasHorse) {
        $missing += "horse"
    }

    if (-not $hasTourneyArmor) {
        $missing += "splint or plate armor"
    }

    return [PSCustomObject]@{
        CanEnter = ($hasHorse -and $hasTourneyArmor)
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
        return "{hero}'s name is now spoken near the mounted lists. The arena can still offer ground bouts today, but the real promise is waiting: horse, lance, splint or plate, heraldry, and a crowd that calls violence sport because the right people paid to watch."
    }

    if ($status.HasHorse) {
        return "{hero}'s name is now spoken near the mounted lists, but the list-master still points at the armor racks. A horse is only half the invitation. Splint or plate armor is required before the proper tournament lets {him} ride."
    }

    return "{hero} finds the tourney ground behind painted rails and clean sand. Squires drill with blunted blades while older knights watch posture, shield discipline, and whether a fighter knows how to win without looking desperate. Mounted jousting waits until {hero} owns a horse and wears splint or plate armor; for now, the arena offers squire sparring and a first taste of upper-city attention."
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
        Write-ColorLine "Arena Standing: $($status.Title) | Squire: $($status.SquireWins)-$($status.SquireLosses) | Patron attention: $($status.PatronAttention) | Horse: $horseText | Tourney armor: $armorText" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "1. Spar against a squire on foot" "White"
        Write-ColorLine "2. Ask what the patrons think" "White"
        Write-ColorLine "3. Ask about mounted jousting" "White"
        Write-ColorLine "4. Present colors to the patron rail" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $result = Resolve-JoustingArenaSquireSpar -Game $Game
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                Write-EmphasisLine -Text "Arena standing: $($result.Reputation). Patron attention: $($result.PatronAttention)." -Color "Yellow"
                Write-ColorLine ""
            }
            "2" {
                Write-Scene (Resolve-HeroNarrativeText -Text (Get-JoustingPatronAttentionText -Game $Game) -Hero $Game.Hero)
                Write-ColorLine ""
            }
            "3" {
                $requirements = Get-MountedJoustingRequirements -Game $Game
                Write-Scene "The list-master taps a lance rack with two fingers. 'Horse first. Splint or plate after that. Then we find out whether your shield arm belongs in a tourney or only in an alley.'"
                if ($requirements.CanEnter) {
                    Write-EmphasisLine -Text "Future unlock ready: horse and tourney armor are secured; mounted jousting still waits for the lance system." -Color "Yellow"
                }
                else {
                    Write-EmphasisLine -Text "Future unlock requirements: $($requirements.MissingText)." -Color "Yellow"
                }
                Write-ColorLine ""
            }
            "4" {
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
