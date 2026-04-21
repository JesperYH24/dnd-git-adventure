function Get-AdventureSaveDirectory {
    if (-not [string]::IsNullOrWhiteSpace($global:AdventureSaveDirectoryOverride)) {
        return [string]$global:AdventureSaveDirectoryOverride
    }

    return (Join-Path $PSScriptRoot "saves")
}

function Test-AdventureStateMember {
    param(
        $Object,
        [string]$Name
    )

    if ($Object -is [hashtable]) {
        return $Object.ContainsKey($Name)
    }

    return $null -ne $Object.PSObject.Properties[$Name]
}

function Get-AdventureSaveSlotPath {
    param([int]$Slot)

    return (Join-Path (Get-AdventureSaveDirectory) ("slot{0}.clixml" -f $Slot))
}

function Get-AdventureSaveSlotRange {
    return 1..3
}

function Ensure-AdventureSaveDirectory {
    $saveDirectory = Get-AdventureSaveDirectory

    if (-not (Test-Path $saveDirectory)) {
        New-Item -ItemType Directory -Path $saveDirectory -Force | Out-Null
    }

    return $saveDirectory
}

function Get-AdventureSaveLocationText {
    param($Game)

    if ($null -eq $Game) {
        return "Unknown"
    }

    if (-not $Game.Quest.Completed) {
        if ($Game.CurrentRoomId -and $Game.CurrentRoomId -ne "entrance") {
            $roomName = $Game.CurrentRoomId

            if ($null -ne $Game.Rooms -and $null -ne $Game.Rooms[$Game.CurrentRoomId]) {
                $room = $Game.Rooms[$Game.CurrentRoomId]
                if ($null -ne $room.PSObject.Properties["Name"] -and -not [string]::IsNullOrWhiteSpace($room.Name)) {
                    $roomName = $room.Name
                }
            }

            return "Tutorial Cave - $roomName"
        }

        return "Campfire"
    }

    if ($Game.Town.MustChooseFirstInn) {
        return "Town - First Night"
    }

    if ($null -ne $Game.Town.ActiveInn) {
        return "Town - $($Game.Town.ActiveInn.Name)"
    }

    return "Town"
}

function Get-AdventureSaveMetadataFromGame {
    param($Game)

    return [PSCustomObject]@{
        HeroName = $Game.Hero.Name
        HeroClass = $Game.Hero.Class
        HeroLevel = [int]$Game.Hero.Level
        CurrentHP = [int]$Game.HeroHP
        MaxHP = [int]$Game.Hero.HP
        Location = Get-AdventureSaveLocationText -Game $Game
        QuestState = if ($Game.Quest.Completed) { "Town" } else { "Tutorial" }
    }
}

function Get-AdventureSaveSlotMetadata {
    param([int]$Slot)

    $path = Get-AdventureSaveSlotPath -Slot $Slot

    if (-not (Test-Path $path)) {
        return [PSCustomObject]@{
            Slot = $Slot
            Exists = $false
            Path = $path
        }
    }

    try {
        $saveData = Import-Clixml -Path $path
    }
    catch {
        return [PSCustomObject]@{
            Slot = $Slot
            Exists = $true
            Path = $path
            Corrupt = $true
            SavedAtUtc = $null
            Summary = "Unreadable save"
        }
    }

    $metadata = $saveData.Metadata

    if ($null -eq $metadata -and $null -ne $saveData.Game) {
        $metadata = Get-AdventureSaveMetadataFromGame -Game $saveData.Game
    }

    $savedAtUtc = $null
    if (Test-AdventureStateMember -Object $saveData -Name "SavedAtUtc") {
        $savedAtUtc = $saveData.SavedAtUtc
    }

    $summary = "Empty"
    if ($null -ne $metadata) {
        $summary = "{0} the {1} L{2} | {3} | {4}/{5} HP" -f $metadata.HeroName, $metadata.HeroClass, $metadata.HeroLevel, $metadata.Location, $metadata.CurrentHP, $metadata.MaxHP
    }

    return [PSCustomObject]@{
        Slot = $Slot
        Exists = $true
        Path = $path
        Corrupt = $false
        SavedAtUtc = $savedAtUtc
        Metadata = $metadata
        Summary = $summary
    }
}

function Get-AdventureAvailableSaveSlots {
    $slots = @()

    foreach ($slot in (Get-AdventureSaveSlotRange)) {
        $metadata = Get-AdventureSaveSlotMetadata -Slot $slot
        if ($metadata.Exists -and -not $metadata.Corrupt) {
            $slots += $metadata
        }
    }

    return $slots
}

function Ensure-LoadedAdventureShape {
    param($Game)

    if (-not (Test-AdventureStateMember -Object $Game -Name "HeroHP")) {
        if ($Game -is [hashtable]) {
            $Game["HeroHP"] = [int]$Game.Hero.HP
        }
        else {
            $Game | Add-Member -NotePropertyName HeroHP -NotePropertyValue ([int]$Game.Hero.HP)
        }
    }

    if (-not (Test-AdventureStateMember -Object $Game -Name "HeroDroppedWeapon")) {
        if ($Game -is [hashtable]) {
            $Game["HeroDroppedWeapon"] = $false
        }
        else {
            $Game | Add-Member -NotePropertyName HeroDroppedWeapon -NotePropertyValue $false
        }
    }

    if (-not (Test-AdventureStateMember -Object $Game -Name "Town") -or $null -eq $Game.Town) {
        $Game.Town = New-DefaultTownState
    }

    $defaultTown = New-DefaultTownState

    foreach ($key in $defaultTown.Keys) {
        if (-not $Game.Town.ContainsKey($key)) {
            $Game.Town[$key] = $defaultTown[$key]
        }
    }

    foreach ($key in @("StreetFlags", "Discounts", "PerformanceVenuesToday", "Relationships", "InnFlags", "StoryFlags")) {
        if ($null -eq $Game.Town[$key]) {
            $Game.Town[$key] = @{}
        }
    }

    if ($null -eq $Game.Town["Ring"]) {
        $Game.Town["Ring"] = @{ Visits = 0; FoughtToday = $false }
    }
    else {
        if (-not $Game.Town["Ring"].ContainsKey("Visits")) {
            $Game.Town["Ring"]["Visits"] = 0
        }

        if (-not $Game.Town["Ring"].ContainsKey("FoughtToday")) {
            $Game.Town["Ring"]["FoughtToday"] = $false
        }
    }

    if ($null -eq $Game.Town["Quests"]) {
        $Game.Town["Quests"] = Initialize-TownQuests
    }
    else {
        $defaultQuests = @(Initialize-TownQuests)

        foreach ($defaultQuest in $defaultQuests) {
            $existingQuest = $Game.Town["Quests"] | Where-Object { $_.Id -eq $defaultQuest.Id } | Select-Object -First 1

            if ($null -eq $existingQuest) {
                $Game.Town["Quests"] += $defaultQuest
                continue
            }

            foreach ($property in @("DayJobTrackId", "DayJobStep", "RequiredHeroLevel")) {
                if ($null -eq $existingQuest.PSObject.Properties[$property]) {
                    $existingQuest | Add-Member -NotePropertyName $property -NotePropertyValue $defaultQuest.$property
                }
            }
        }
    }

    return $Game
}

function Save-AdventureGame {
    param(
        $Game,
        [int]$HeroHP,
        [bool]$HeroDroppedWeapon = $false,
        [int]$Slot
    )

    Ensure-AdventureSaveDirectory | Out-Null

    $Game.HeroHP = $HeroHP
    $Game.HeroDroppedWeapon = $HeroDroppedWeapon

    $saveData = [PSCustomObject]@{
        Version = 1
        SavedAtUtc = [DateTime]::UtcNow
        Metadata = Get-AdventureSaveMetadataFromGame -Game $Game
        Game = $Game
    }

    $path = Get-AdventureSaveSlotPath -Slot $Slot
    Export-Clixml -Path $path -InputObject $saveData -Force

    return (Get-AdventureSaveSlotMetadata -Slot $Slot)
}

function Load-AdventureGame {
    param([int]$Slot)

    $path = Get-AdventureSaveSlotPath -Slot $Slot

    if (-not (Test-Path $path)) {
        throw "No save exists in slot $Slot."
    }

    $saveData = Import-Clixml -Path $path

    if ($null -eq $saveData.Game) {
        throw "Save slot $Slot is missing game state."
    }

    $game = Ensure-LoadedAdventureShape -Game $saveData.Game
    Set-UiHeroName -Name $game.Hero.Name
    return $game
}

function Show-AdventureSaveSlots {
    param([string]$ModeLabel)

    Write-SectionTitle -Text $ModeLabel -Color "Yellow"

    foreach ($slot in (Get-AdventureSaveSlotRange)) {
        $metadata = Get-AdventureSaveSlotMetadata -Slot $slot

        if (-not $metadata.Exists) {
            Write-ColorLine "$slot. Empty slot" "White"
            continue
        }

        if ($metadata.Corrupt) {
            Write-ColorLine "$slot. Unreadable save" "Red"
            continue
        }

        $savedAtText = ""
        if ($null -ne $metadata.SavedAtUtc) {
            $savedAtText = ([DateTime]$metadata.SavedAtUtc).ToLocalTime().ToString("yyyy-MM-dd HH:mm")
        }

        Write-ColorLine "$slot. $($metadata.Summary)" "White"
        if (-not [string]::IsNullOrWhiteSpace($savedAtText)) {
            Write-ColorLine "   Saved: $savedAtText" "DarkGray"
        }
    }

    Write-ColorLine ""
    Write-ColorLine "0. Back to previous menu" "DarkGray"
    Write-ColorLine ""
}

function Start-AdventureSaveMenu {
    param(
        $Game,
        [int]$HeroHP,
        [bool]$HeroDroppedWeapon = $false
    )

    while ($true) {
        Show-AdventureSaveSlots -ModeLabel "Save Adventure"
        $choice = Read-Host "Choose save slot"

        if ($choice -eq "0") {
            return $null
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose one of the listed save slots." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $slot = [int]$choice

        if ($slot -notin (Get-AdventureSaveSlotRange)) {
            Write-ColorLine "That save slot does not exist." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $metadata = Save-AdventureGame -Game $Game -HeroHP $HeroHP -HeroDroppedWeapon $HeroDroppedWeapon -Slot $slot
        Write-EmphasisLine -Text "Adventure saved to slot $slot." -Color "Green"
        Write-Scene $metadata.Summary
        Write-ColorLine ""
        return $metadata
    }
}

function Start-AdventureLoadMenu {
    while ($true) {
        $availableSlots = @(Get-AdventureAvailableSaveSlots)

        if ($availableSlots.Count -eq 0) {
            Write-ColorLine "No saved adventures are available yet." "DarkYellow"
            Write-ColorLine ""
            return $null
        }

        Show-AdventureSaveSlots -ModeLabel "Load Adventure"
        $choice = Read-Host "Choose save slot"

        if ($choice -eq "0") {
            return $null
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose one of the listed save slots." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $slot = [int]$choice

        if ($slot -notin (Get-AdventureSaveSlotRange)) {
            Write-ColorLine "That save slot does not exist." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $metadata = Get-AdventureSaveSlotMetadata -Slot $slot

        if (-not $metadata.Exists -or $metadata.Corrupt) {
            Write-ColorLine "That slot cannot be loaded." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $game = Load-AdventureGame -Slot $slot
        Write-SectionTitle -Text "Adventure Loaded" -Color "Green"
        Write-Scene $metadata.Summary
        Write-ColorLine ""
        return $game
    }
}

function Start-AdventureStartMenu {
    while ($true) {
        Clear-Host
        Write-SectionTitle -Text "DnD Git Adventure" -Color "Magenta"
        Write-Scene "Steel, rumor, torchlight, and bad decisions are all waiting where the road bends into dark places."
        Write-Scene "Choose whether to begin a fresh adventure or return to one already scarred by dungeon stone, city work, and long nights under rented roofs."
        Write-ColorLine ""
        Write-ColorLine "1. New adventure" "White"

        if ((Get-AdventureAvailableSaveSlots).Count -gt 0) {
            Write-ColorLine "2. Load adventure" "White"
        }
        else {
            Write-ColorLine "2. Load adventure (no saves yet)" "DarkGray"
        }

        Write-ColorLine "0. Exit" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                return [PSCustomObject]@{
                    Mode = "New"
                    Game = $null
                }
            }
            "2" {
                $game = Start-AdventureLoadMenu

                if ($null -ne $game) {
                    return [PSCustomObject]@{
                        Mode = "Load"
                        Game = $game
                    }
                }
            }
            "0" {
                return [PSCustomObject]@{
                    Mode = "Exit"
                    Game = $null
                }
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}
