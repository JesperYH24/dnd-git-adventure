# Fighter-facing arena scaffolding. Mounted jousting waits for horse, heavy tourney armor, and lance systems later.

function Get-HeroJoustingStatus {
    param($Game)

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return $null
    }

    if ($null -eq $Game.Town.Jousting) {
        $Game.Town.Jousting = @{
            Visits = 0
            HasHorse = $false
            SquireWins = 0
        }
    }

    $mountedRequirements = Get-MountedJoustingRequirements -Game $Game

    return [PSCustomObject]@{
        Visits = [int]$Game.Town.Jousting.Visits
        HasHorse = [bool]$Game.Town.Jousting.HasHorse
        HasTourneyArmor = [bool]$mountedRequirements.HasTourneyArmor
        MountedReady = [bool]$mountedRequirements.CanEnter
        SquireWins = [int]$Game.Town.Jousting.SquireWins
        Title = if ([bool]$mountedRequirements.CanEnter) { "Mounted Prospect" } elseif ([bool]$Game.Town.Jousting.HasHorse) { "Horse Ready" } elseif ([int]$Game.Town.Jousting.SquireWins -gt 0) { "Recognized Squire" } else { "Unproven Squire" }
    }
}

function Test-HeroHasMountedJoustingHorse {
    param($Game)

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

    $status = Get-HeroJoustingStatus -Game $Game
    $constitutionModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "CON"
    $strengthModifier = Get-HeroAbilityModifier -Hero $Game.Hero -Ability "STR"
    $total = $Roll + $constitutionModifier + $strengthModifier
    $success = $total -ge 15

    $Game.Town.Jousting.Visits = [int]$Game.Town.Jousting.Visits + 1

    if ($success) {
        $Game.Town.Jousting.SquireWins = [int]$Game.Town.Jousting.SquireWins + 1
        $Game.Town.Relationships["TourneyGround"] = "Noticed"

        return [PSCustomObject]@{
            Success = $true
            Message = "{hero} holds the shield line, answers with the shortsword, and wins the exchange cleanly enough that a watching knight stops pretending not to care."
            Reputation = "Recognized Squire"
            RollTotal = $total
        }
    }

    return [PSCustomObject]@{
        Success = $false
        Message = "{hero} stays standing, which matters, but the exchange ends with sand on the knees and a squire's polite little bow that stings worse than mockery."
        Reputation = $status.Title
        RollTotal = $total
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
        Write-ColorLine "Arena Standing: $($status.Title) | Squire wins: $($status.SquireWins) | Horse: $horseText | Tourney armor: $armorText" "DarkYellow"
        Write-ColorLine ""
        Write-ColorLine "1. Spar against a squire on foot" "White"
        Write-ColorLine "2. Ask about mounted jousting" "White"
        Write-ColorLine "0. Back to town" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                $result = Resolve-JoustingArenaSquireSpar -Game $Game
                Write-Scene (Resolve-HeroNarrativeText -Text $result.Message -Hero $Game.Hero)
                Write-EmphasisLine -Text "Arena standing: $($result.Reputation)." -Color "Yellow"
                Write-ColorLine ""
            }
            "2" {
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
            "0" { return }
            default {
                Write-ColorLine "Choose a listed option." "DarkYellow"
                Write-ColorLine ""
            }
        }
    }
}
