function Get-ReadableTextWidth {
    $defaultWidth = 88

    try {
        $windowWidth = $Host.UI.RawUI.WindowSize.Width

        if ($windowWidth -gt 0) {
            return [Math]::Max(40, [Math]::Min(88, $windowWidth - 8))
        }
    }
    catch {
    }

    return $defaultWidth
}

function Get-UiOutputSuppressed {
    return [bool]$global:SuppressUiOutput
}

function Set-UiHeroName {
    param([string]$Name)

    if ([string]::IsNullOrWhiteSpace($Name)) {
        $global:UiHeroName = "Borzig"
        return
    }

    $global:UiHeroName = $Name
}

function Set-UiHeroContext {
    param($Hero)

    if ($null -eq $Hero) {
        Set-UiHeroName -Name "Borzig"
        $global:UiHeroClass = "Barbarian"
        $global:UiHeroPronouns = @{
            Subject = "he"
            Object = "him"
            Possessive = "his"
            Reflexive = "himself"
        }
        return
    }

    Set-UiHeroName -Name $Hero.Name
    $global:UiHeroClass = if ([string]::IsNullOrWhiteSpace([string]$Hero.Class)) { "Hero" } else { [string]$Hero.Class }

    $pronouns = @{
        Subject = "he"
        Object = "him"
        Possessive = "his"
        Reflexive = "himself"
    }

    if ($null -ne $Hero.PSObject.Properties["Pronouns"] -and $null -ne $Hero.Pronouns) {
        foreach ($key in @("Subject", "Object", "Possessive", "Reflexive")) {
            if ($null -ne $Hero.Pronouns[$key] -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Pronouns[$key])) {
                $pronouns[$key] = [string]$Hero.Pronouns[$key]
            }
        }
    }

    $global:UiHeroPronouns = $pronouns
}

function Get-UiHeroName {
    if ([string]::IsNullOrWhiteSpace($global:UiHeroName)) {
        return "Borzig"
    }

    return [string]$global:UiHeroName
}

function Get-UiHeroClass {
    if ([string]::IsNullOrWhiteSpace($global:UiHeroClass)) {
        return "Barbarian"
    }

    return [string]$global:UiHeroClass
}

function Get-UiHeroPronouns {
    if ($null -eq $global:UiHeroPronouns) {
        $global:UiHeroPronouns = @{
            Subject = "he"
            Object = "him"
            Possessive = "his"
            Reflexive = "himself"
        }
    }

    return $global:UiHeroPronouns
}

function Get-UiHeroNarrativeContext {
    return [PSCustomObject]@{
        Name = Get-UiHeroName
        Class = Get-UiHeroClass
        Pronouns = Get-UiHeroPronouns
    }
}

function ConvertTo-TitleCaseToken {
    param([string]$Value)

    if ([string]::IsNullOrWhiteSpace($Value)) {
        return $Value
    }

    if ($Value.Length -eq 1) {
        return $Value.ToUpper()
    }

    return ($Value.Substring(0, 1).ToUpper() + $Value.Substring(1))
}

function Resolve-HeroNarrativeText {
    param(
        [string]$Text,
        $Hero = $null
    )

    if ([string]::IsNullOrEmpty($Text)) {
        return $Text
    }

    $context = if ($null -ne $Hero) {
        $heroPronouns = @{
            Subject = "he"
            Object = "him"
            Possessive = "his"
            Reflexive = "himself"
        }

        if ($null -ne $Hero.PSObject.Properties["Pronouns"] -and $null -ne $Hero.Pronouns) {
            foreach ($key in @("Subject", "Object", "Possessive", "Reflexive")) {
                if ($null -ne $Hero.Pronouns[$key] -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Pronouns[$key])) {
                    $heroPronouns[$key] = [string]$Hero.Pronouns[$key]
                }
            }
        }

        [PSCustomObject]@{
            Name = if ([string]::IsNullOrWhiteSpace([string]$Hero.Name)) { "the hero" } else { [string]$Hero.Name }
            Class = if ([string]::IsNullOrWhiteSpace([string]$Hero.Class)) { "Hero" } else { [string]$Hero.Class }
            Pronouns = $heroPronouns
        }
    }
    else {
        Get-UiHeroNarrativeContext
    }

    $heroName = [string]$context.Name
    $heroClass = [string]$context.Class
    $pronouns = $context.Pronouns

    $resolved = $Text
    $resolved = $resolved.Replace("{hero}", $heroName).Replace("{Hero}", $heroName)
    $resolved = $resolved.Replace("{class}", $heroClass.ToLower()).Replace("{Class}", $heroClass)
    $resolved = $resolved.Replace("{he}", [string]$pronouns.Subject).Replace("{He}", (ConvertTo-TitleCaseToken -Value ([string]$pronouns.Subject)))
    $resolved = $resolved.Replace("{him}", [string]$pronouns.Object).Replace("{Him}", (ConvertTo-TitleCaseToken -Value ([string]$pronouns.Object)))
    $resolved = $resolved.Replace("{his}", [string]$pronouns.Possessive).Replace("{His}", (ConvertTo-TitleCaseToken -Value ([string]$pronouns.Possessive)))
    $resolved = $resolved.Replace("{himself}", [string]$pronouns.Reflexive).Replace("{Himself}", (ConvertTo-TitleCaseToken -Value ([string]$pronouns.Reflexive)))

    if ($heroName -eq "Borzig") {
        return $resolved
    }

    return $resolved.Replace("Borzig", $heroName)
}

function Resolve-UiHeroText {
    param([string]$Text)

    return (Resolve-HeroNarrativeText -Text $Text)
}

function Get-ClassNarrativeText {
    param(
        $Hero,
        [string]$DefaultText,
        [hashtable]$ClassText = @{}
    )

    $className = if ($null -ne $Hero -and -not [string]::IsNullOrWhiteSpace([string]$Hero.Class)) { [string]$Hero.Class } else { "" }
    $selectedText = $DefaultText

    if (-not [string]::IsNullOrWhiteSpace($className) -and $null -ne $ClassText -and $ClassText.ContainsKey($className) -and -not [string]::IsNullOrWhiteSpace([string]$ClassText[$className])) {
        $selectedText = [string]$ClassText[$className]
    }

    return (Resolve-HeroNarrativeText -Text $selectedText -Hero $Hero)
}

function Get-FastTextEnabled {
    if ($null -eq $global:FastTextEnabled) {
        $global:FastTextEnabled = $false
    }

    return [bool]$global:FastTextEnabled
}

function Set-TransientTextSkip {
    param([int]$Milliseconds = 2000)

    $global:TransientTextSkipUntil = [DateTime]::UtcNow.AddMilliseconds($Milliseconds)
}

function Get-TransientTextSkipEnabled {
    if ($null -eq $global:TransientTextSkipUntil) {
        return $false
    }

    return [DateTime]::UtcNow -lt $global:TransientTextSkipUntil
}

function Set-FastTextEnabled {
    param([bool]$Enabled)

    $global:FastTextEnabled = $Enabled
}

function Get-TextSpeedLabel {
    if (Get-FastTextEnabled) {
        return "Fast"
    }

    return "Normal"
}

function Toggle-TextSpeed {
    $newValue = -not (Get-FastTextEnabled)
    Set-FastTextEnabled -Enabled $newValue
    Write-ColorLine "Text speed: $(Get-TextSpeedLabel)" "DarkYellow"
    Write-ColorLine ""
    return $newValue
}

function Write-TextSpeedOption {
    Write-ColorLine "T. Toggle text speed ($(Get-TextSpeedLabel))" "White"
}

function Get-TypewriterInputAction {
    try {
        if (-not [Console]::KeyAvailable) {
            return ""
        }

        $key = [Console]::ReadKey($true)

        if ($key.Key -eq [ConsoleKey]::Enter) {
            Set-TransientTextSkip -Milliseconds 2000
            return "SkipBlock"
        }

        if ($key.Key -eq [ConsoleKey]::Spacebar -or $key.Key -eq [ConsoleKey]::S) {
            Set-FastTextEnabled -Enabled (-not (Get-FastTextEnabled))
            return "ToggleFastText"
        }
    }
    catch {
        return ""
    }

    return ""
}

function Split-DisplayText {
    param(
        [string]$Text,
        [int]$Width = 0
    )

    if ([string]::IsNullOrWhiteSpace($Text)) {
        return @("")
    }

    if ($Width -le 0) {
        $Width = Get-ReadableTextWidth
    }

    $words = $Text -split '\s+'
    $lines = @()
    $currentLine = ""

    foreach ($word in $words) {
        if ([string]::IsNullOrEmpty($currentLine)) {
            $currentLine = $word
            continue
        }

        $candidate = "$currentLine $word"

        if ($candidate.Length -le $Width) {
            $currentLine = $candidate
        }
        else {
            $lines += $currentLine
            $currentLine = $word
        }
    }

    if (-not [string]::IsNullOrEmpty($currentLine)) {
        $lines += $currentLine
    }

    return $lines
}

function Write-TypeLine {
    param(
        [string]$Text,
        [int]$Delay = 20,
        [string]$Color = "White"
    )

    if (Get-UiOutputSuppressed) {
        return ""
    }

    $Text = Resolve-UiHeroText -Text $Text

    if ((Get-FastTextEnabled) -or (Get-TransientTextSkipEnabled)) {
        Write-Host $Text -ForegroundColor $Color
        return ""
    }

    $characters = $Text.ToCharArray()

    for ($i = 0; $i -lt $characters.Length; $i++) {
        Write-Host -NoNewline $characters[$i] -ForegroundColor $Color

        $action = Get-TypewriterInputAction

        if ($action -eq "SkipBlock" -or $action -eq "ToggleFastText") {
            if ($i -lt ($characters.Length - 1)) {
                Write-Host -NoNewline (-join $characters[($i + 1)..($characters.Length - 1)]) -ForegroundColor $Color
            }

            break
        }

        $remainingDelay = [Math]::Max(0, $Delay)

        while ($remainingDelay -gt 0) {
            $sleepSlice = [Math]::Min(10, $remainingDelay)
            Start-Sleep -Milliseconds $sleepSlice
            $remainingDelay -= $sleepSlice

            $action = Get-TypewriterInputAction

            if ($action -eq "SkipBlock" -or $action -eq "ToggleFastText") {
                if ($i -lt ($characters.Length - 1)) {
                    Write-Host -NoNewline (-join $characters[($i + 1)..($characters.Length - 1)]) -ForegroundColor $Color
                }

                $remainingDelay = 0
                break
            }
        }
    }

    Write-Host ""
    return $action
}

function Write-TypeBlock {
    param(
        [string[]]$Lines,
        [int]$Delay,
        [string]$Color
    )

    for ($i = 0; $i -lt $Lines.Count; $i++) {
        $action = Write-TypeLine -Text $Lines[$i] -Delay $Delay -Color $Color

        if ($action -eq "SkipBlock") {
            for ($remainingIndex = $i + 1; $remainingIndex -lt $Lines.Count; $remainingIndex++) {
                Write-Host $Lines[$remainingIndex] -ForegroundColor $Color
            }

            return
        }
    }
}

function Write-SectionTitle {
    param(
        [string]$Text,
        [string]$Color = "Cyan"
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $title = "  $($Text.ToUpper())  "
    $borderWidth = [Math]::Max($title.Length, 26)
    $border = "".PadLeft($borderWidth, "=")

    Write-ColorLine "" $Color
    Write-ColorLine $border $Color
    Write-ColorLine $title $Color
    Write-ColorLine $border $Color
}

function Write-EmphasisLine {
    param(
        [string]$Text,
        [string]$Color = "Yellow"
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $Text = Resolve-UiHeroText -Text $Text

    foreach ($line in Split-DisplayText -Text $Text) {
        Write-Host ("  " + $line) -ForegroundColor $Color
    }
}

function Get-TownTimeTrackerColor {
    param($Game)

    if ((Get-TownTimeOfDay -Game $Game) -eq "Night") {
        return "Cyan"
    }

    return "DarkYellow"
}

function Get-TownTimeTrackerBanner {
    param(
        $Game,
        [string]$Area = "City"
    )

    $dayNumber = Get-TownDayNumber -Game $Game
    $timeOfDay = Get-TownTimeOfDay -Game $Game
    $innId = if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.ActiveInn) { [string]$Game.Town.ActiveInn.Id } else { "" }

    if ($Area -in @("Inn Visit", "Common Room", "Innkeeper", "Inn Room", "Lodging")) {
        switch ($innId) {
            "bent_nail" {
                if ($timeOfDay -eq "Night") {
                    return "[ Day $dayNumber ]  [ Bent Nail after dark ]"
                }

                return "[ Day $dayNumber ]  [ Bent Nail in daylight ]"
            }
            "lantern_rest" {
                if ($timeOfDay -eq "Night") {
                    return "[ Day $dayNumber ]  [ Lantern Rest by lamplight ]"
                }

                return "[ Day $dayNumber ]  [ Lantern Rest at table ]"
            }
            "silver_kettle" {
                if ($timeOfDay -eq "Night") {
                    return "[ Day $dayNumber ]  [ Silver Kettle in evening service ]"
                }

                return "[ Day $dayNumber ]  [ Silver Kettle at luncheon ]"
            }
        }
    }

    switch ($Area) {
        "Market" {
            if ($timeOfDay -eq "Night") {
                return "[ Day $dayNumber ]  [ Market after shutters ]"
            }

            return "[ Day $dayNumber ]  [ Market in full trade ]"
        }
        "Quest Board" {
            if ($timeOfDay -eq "Night") {
                return "[ Day $dayNumber ]  [ Quest Board by lanternlight ]"
            }

            return "[ Day $dayNumber ]  [ Quest Board in public view ]"
        }
        "Guard Station" {
            if ($timeOfDay -eq "Night") {
                return "[ Day $dayNumber ]  [ Guard Station on late watch ]"
            }

            return "[ Day $dayNumber ]  [ Guard Station in daylight duty ]"
        }
        "Quest Giver" {
            if ($timeOfDay -eq "Night") {
                return "[ Day $dayNumber ]  [ Private patron after dark ]"
            }

            return "[ Day $dayNumber ]  [ Private patron in daylight ]"
        }
    }

    if ($timeOfDay -eq "Night") {
        return "[ Day $dayNumber ]  [ Night settles over the city ]"
    }

    return "[ Day $dayNumber ]  [ Daylight and open streets ]"
}

function Get-TownTimeTrackerMoodText {
    param(
        $Game,
        [string]$Area = "City"
    )

    $isNight = (Get-TownTimeOfDay -Game $Game) -eq "Night"
    $innId = if ($null -ne $Game -and $null -ne $Game.Town -and $null -ne $Game.Town.ActiveInn) { [string]$Game.Town.ActiveInn.Id } else { "" }

    switch ($Area) {
        "Town" { return $(if ($isNight) { "Lanterns rule the crossroads now, and the city's business grows quieter and sharper." } else { "Trade, errands, and loose talk spill across the streets in full daylight." }) }
        "Seek Work" { return $(if ($isNight) { "The late jobs are the dangerous ones, and the people offering them know it." } else { "Posted work still looks respectable in daylight, even when it clearly is not." }) }
        "Quest Source" { return $(if ($isNight) { "Private offers and guarded voices fit the hour better than open promises." } else { "Notices, contracts, and official requests still pretend to belong to a normal city." }) }
        "Quest Board" { return $(if ($isNight) { "The posted work looks meaner by lanternlight, as if the city's problems know they are being read by desperate people." } else { "Pinned notices and posted rewards still try to make danger look orderly in the daytime." }) }
        "Guard Station" { return $(if ($isNight) { "Lamp oil, tired boots, and the hard end of duty define the station once the city goes dark." } else { "In daylight the station still carries itself like official order can hold the whole city together." }) }
        "Quest Giver" { return $(if ($isNight) { "Discreet work belongs naturally to the night, when clerks speak lower and coin travels quieter." } else { "Even in daylight, this sort of work wears a private face and asks for discretion." }) }
        "Quest Preparation" { return $(if ($isNight) { "Night work leaves less room for hesitation and more room for mistakes." } else { "Daylight gives a little more room to prepare before the city asks something costly." }) }
        "Quest Log" { return $(if ($isNight) { "Open leads feel more immediate when the streets outside have already gone dark." } else { "The city's unfinished business reads cleaner in daylight, even when it is not." }) }
        "Performance" { return $(if ($isNight) { "Rooms listen harder after dark, when coin, vanity, and drink all loosen together." } else { "A daytime crowd hears you; a nighttime crowd remembers you." }) }
        "Streets" { return $(if ($isNight) { "Doorways close, whispers travel farther, and every familiar face feels more deliberate." } else { "People still move openly through the lanes, carrying gossip, work, and unfinished worry." }) }
        "Belor" { return $(if ($isNight) { "The watchman's hour has truly started now, under lamps and tired suspicion." } else { "Official concern still wears its daylight face, even when the worry underneath is real." }) }
        "Hadrik" { return $(if ($isNight) { "The forge has mostly banked down, leaving heat, iron smell, and after-hours talk." } else { "Hammer work, soot, and trade still fill the forge-side air." }) }
        "Elira" { return $(if ($isNight) { "Kindness sounds softer at night, but never less important." } else { "The district still speaks in plain thanks while the day is up." }) }
        "Market" { return $(if ($isNight) { "Only the last lantern-trade, shuttered stalls, and a few stubborn deals remain to remember the market's noise." } else { "Coins, produce, and impatient bargaining keep the market fully alive." }) }
        "Smithy" { return $(if ($isNight) { "Late forge heat clings to the air, but the honest day's business is nearly done." } else { "The forge is still in full working rhythm, all sparks, sweat, and blunt opinions." }) }
        "Apothecary" { return $(if ($isNight) { "Glass, herbs, and candlelight make the apothecary feel quieter and more exacting." } else { "Daylight turns the shelves bright, clinical, and faintly medicinal." }) }
        "Instrument Shop" { return $(if ($isNight) { "Strings, varnish, and hush give the shop a more intimate sort of promise after dark." } else { "In daylight the instruments look ready for trade, practice, and public ambition." }) }
        "Armorer" { return $(if ($isNight) { "Closed shutters and stored steel leave only the memory of the armorer's trade." } else { "Buckles, plate, and fitting straps still speak the language of practical protection." }) }
        "Sell Gear" { return $(if ($isNight) { "Late selling always feels a touch more desperate, even when the buyer smiles." } else { "In daylight a sale can still pass for ordinary business." }) }
        "Inn Visit" {
            switch ($innId) {
                "bent_nail" { return $(if ($isNight) { "The Bent Nail lives its truest life in smoke, rough cups, and table talk that turns useful when the lamps burn low." } else { "By day the Bent Nail feels all stew steam, dockside weariness, and people eating before rumor wakes fully." }) }
                "lantern_rest" { return $(if ($isNight) { "The Lantern Rest gathers warmth at night, with supper, company, and the sort of civility travelers remember." } else { "The Lantern Rest by day is a house of meals, routes, and decent order." }) }
                "silver_kettle" { return $(if ($isNight) { "At night the Silver Kettle turns elegant in a sharper way, all wine, low voices, and expensive attention." } else { "By day the Silver Kettle wears its refinement through luncheon, service, and careful social distance." }) }
                default { return $(if ($isNight) { "Under one roof, the city sounds muffled enough to bargain with, drink against, or ignore." } else { "The inn moves on meals, service, and the temporary peace of people sitting down indoors." }) }
            }
        }
        "Common Room" {
            switch ($innId) {
                "bent_nail" { return $(if ($isNight) { "Here the hour belongs to dice, hard ale, and the people who trust a rough room more than a polished one." } else { "In daylight the same benches belong to bowls, bread, and laborers taking their peace without ceremony." }) }
                "lantern_rest" { return $(if ($isNight) { "The room holds supper, travel songs, and the easy clatter of people glad to be indoors." } else { "Day service turns the room into a reliable place for breakfast, broth, and practical road-talk." }) }
                "silver_kettle" { return $(if ($isNight) { "By evening the room is all fine dinner, low amusement, and patrons deciding who deserves another glance." } else { "At midday the room is measured, polished, and built for luncheon more than lingering." }) }
                default { return $(if ($isNight) { "Night gives the room its real voice: drink, rumor, wagers, and the people who stay out late on purpose." } else { "By day the same room belongs more to plates, practical talk, and whoever paid to sit a while." }) }
            }
        }
        "Innkeeper" {
            switch ($innId) {
                "bent_nail" { return $(if ($isNight) { "At the Bent Nail, good innkeeping means feeding people, watching trouble, and knowing when not to ask questions." } else { "At the Bent Nail by day, hospitality is blunt, filling, and earned by staying useful." }) }
                "lantern_rest" { return $(if ($isNight) { "Here the keeper's craft is warmth, timing, and keeping a mixed room comfortable after sunset." } else { "Daytime innkeeping at the Lantern Rest feels like order made generous." }) }
                "silver_kettle" { return $(if ($isNight) { "At the Silver Kettle, evening service is half hospitality and half social choreography." } else { "Day service here is polished enough to make discipline look effortless." }) }
                default { return $(if ($isNight) { "An innkeeper's real talent is clearest after dark, when comfort and trouble share the same tables." } else { "Day service makes hospitality look easy, which is part of the craft." }) }
            }
        }
        "Inn Room" {
            switch ($innId) {
                "bent_nail" { return $(if ($isNight) { "Even a rough room feels precious when it shuts out the quarter's late noise." } else { "By day the room feels spare, practical, and honest about what it is." }) }
                "lantern_rest" { return $(if ($isNight) { "The room offers the kind of quiet that makes tomorrow feel manageable." } else { "In daylight it feels like a decent pause between roads and obligations." }) }
                "silver_kettle" { return $(if ($isNight) { "Above the elegant noise below, the room feels private in a way money usually buys." } else { "By day the room feels composed, bright, and deliberately restful." }) }
                default { return $(if ($isNight) { "Above the street, the room feels like a borrowed island against the dark." } else { "In daylight the room is less refuge than pause, a place between errands and decisions." }) }
            }
        }
        "Lodging" {
            switch ($innId) {
                "bent_nail" { return $(if ($isNight) { "Choosing the Bent Nail means trusting rough walls, cheap light, and a quarter that minds its own business." } else { "Even in daylight, this is the sort of lodging chosen for grit more than comfort." }) }
                "lantern_rest" { return $(if ($isNight) { "A bed at the Lantern Rest promises a steadier night than most of the city can offer." } else { "In daylight it already feels like the sensible choice for anyone who values rest." }) }
                "silver_kettle" { return $(if ($isNight) { "The Silver Kettle sells more than a room at night; it sells insulation from the city itself." } else { "Even before evening, a room here announces comfort, status, and expense." }) }
                default { return $(if ($isNight) { "A chosen roof matters more once the city stops pretending the day will save anyone." } else { "Even in daylight, a good room still means tomorrow starts on steadier feet." }) }
            }
        }
        "Storage" { return $(if ($isNight) { "Putting gear away at night feels like choosing what kind of trouble you expect before dawn." } else { "In daylight, stored gear feels less hidden and more simply managed." }) }
        "Ring" { return $(if ($isNight) { "This is the pit's proper hour, when wagers, bruises, and pride all draw a crowd." } else { "The ring without night around it is only canvas, chalk, and waiting." }) }
        default { return $(if ($isNight) { "The city wears its sharper face after dark." } else { "Daylight still lets the city pretend to be ordinary." }) }
    }
}

function Get-TownHeroHudText {
    param(
        $Game,
        [Nullable[int]]$HeroHP = $null
    )

    if ($null -eq $Game -or $null -eq $Game.Hero) {
        return ""
    }

    $hero = $Game.Hero
    $heroName = if (-not [string]::IsNullOrWhiteSpace([string]$hero.Name)) { [string]$hero.Name } else { "Hero" }
    $heroClass = if (-not [string]::IsNullOrWhiteSpace([string]$hero.Class)) { [string]$hero.Class } else { "Adventurer" }
    $currentHP = $hero.HP

    if ($null -ne $HeroHP) {
        $currentHP = [int]$HeroHP
    }
    elseif ($null -ne $Game.PSObject.Properties["HeroHP"]) {
        $currentHP = [int]$Game.HeroHP
    }

    $currencyText = Get-HeroCurrencyText -Hero $hero
    return "$heroName the $heroClass | HP $currentHP/$($hero.HP) | Coin $currencyText"
}

function Write-TownTimeTracker {
    param(
        $Game,
        [string]$Area = "City",
        [Nullable[int]]$HeroHP = $null
    )

    if ($null -eq $Game -or $null -eq $Game.Town) {
        return
    }

    $color = Get-TownTimeTrackerColor -Game $Game
    $banner = Get-TownTimeTrackerBanner -Game $Game -Area $Area
    $moodText = Get-TownTimeTrackerMoodText -Game $Game -Area $Area
    $heroHud = Get-TownHeroHudText -Game $Game -HeroHP $HeroHP
    $borderLength = [Math]::Max([Math]::Max($banner.Length, $heroHud.Length), 38)
    $border = ("-".PadLeft($borderLength, "-"))

    Write-ColorLine ("  " + $border) $color
    Write-ColorLine ("  " + $banner) $color
    if (-not [string]::IsNullOrWhiteSpace($heroHud)) {
        Write-ColorLine ("  " + $heroHud) "White"
    }
    Write-ColorLine ("  " + $moodText) "DarkGray"
    Write-ColorLine ("  " + $border) $color
}

function Write-Scene {
    param(
        [string]$Text
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $Text = Resolve-UiHeroText -Text $Text
    $lines = @(Split-DisplayText -Text $Text | ForEach-Object { "  " + $_ })
    Write-TypeBlock -Lines $lines -Delay 35 -Color "Gray"
}

function Write-Action {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $Text = Resolve-UiHeroText -Text $Text
    $lines = @(Split-DisplayText -Text $Text | ForEach-Object { "  " + $_ })
    Write-TypeBlock -Lines $lines -Delay 16 -Color $Color
}

function Write-ColorLine {
    param(
        [string]$Text,
        [string]$Color = "White"
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $Text = Resolve-UiHeroText -Text $Text
    Write-Host $Text -ForegroundColor $Color
}

function Write-BlinkingLine {
    param(
        [string]$Text,
        [string]$Color1 = "Red",
        [string]$Color2 = "DarkRed",
        [int]$Times = 3
    )

    if (Get-UiOutputSuppressed) {
        return
    }

    $Text = Resolve-UiHeroText -Text $Text

    for ($i = 0; $i -lt $Times; $i++) {
        Write-Host "`r$Text" -ForegroundColor $Color1 -NoNewline
        Start-Sleep -Milliseconds 150

        Write-Host "`r$Text" -ForegroundColor $Color2 -NoNewline
        Start-Sleep -Milliseconds 150
    }

    Write-Host "`r$Text" -ForegroundColor $Color1
}
