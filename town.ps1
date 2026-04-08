# Town is split into focused scripts so city progression stays readable as it grows.
. "$PSScriptRoot\\town-shops.ps1"
. "$PSScriptRoot\\town-npcs.ps1"
. "$PSScriptRoot\\town-ring.ps1"
. "$PSScriptRoot\\town-inns.ps1"

function Get-TownSourceVisitKey {
    param([string]$Source)

    return ("QuestSourceVisited_" + ($Source -replace "[^A-Za-z0-9]", ""))
}

function Get-TownQuestSourceIntroText {
    param(
        [string]$Source,
        [string]$DefaultIntroText,
        $Game
    )

    $visitKey = Get-TownSourceVisitKey -Source $Source
    $isRepeatVisit = [bool]$Game.Town.StreetFlags[$visitKey]

    if (-not $isRepeatVisit) {
        $Game.Town.StreetFlags[$visitKey] = $true
        return $DefaultIntroText
    }

    switch ($Source) {
        "Quest Board" { return "The board looks thinner now, but there is still work on it for anyone willing to take the coin." }
        "Guard Station" { return "The watch hall is busier than it looks. Hard jobs are passed quietly from one tired hand to the next." }
        "Quest Giver" { return "The patron's clerk recognizes Borzig now and reaches for the stack of private work without wasting words." }
        default { return $DefaultIntroText }
    }
}

function Show-TownQuestSource {
    param(
        [string]$Title,
        [string]$IntroText,
        [string]$Source,
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        $quests = Get-TownQuestList -Game $Game -Source $Source
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-Scene (Get-TownQuestSourceIntroText -Source $Source -DefaultIntroText $IntroText -Game $Game)
        Write-ColorLine ""

        if ($Source -eq "Guard Station") {
            $watchQuest = $quests | Where-Object { $_.Id -eq "guard_night_watch" } | Select-Object -First 1

            if ($null -ne $watchQuest) {
                if ($watchQuest.Completed) {
                    Write-EmphasisLine -Text "Night Watch Relief stands completed on the station ledger." -Color "Green"
                }
                elseif ($watchQuest.Accepted) {
                    Write-EmphasisLine -Text "Night Watch Relief is ready to start from the guard station." -Color "Yellow"
                }
                else {
                    Write-EmphasisLine -Text "Available guard assignment: Night Watch Relief." -Color "Yellow"
                }

                Write-ColorLine ""
            }
        }

        if ($quests.Count -eq 0) {
            Write-Scene "No work is posted here right now."
            Write-ColorLine ""
        }

        for ($i = 0; $i -lt $quests.Count; $i++) {
            $quest = $quests[$i]
            $status = if ($quest.Completed) { "Complete" } elseif ($quest.Accepted) { "Accepted" } else { "Available" }
            Write-ColorLine "$($i + 1). $($quest.Name) [$status]" "White"
            Write-ColorLine "   $($quest.Description)" "DarkGray"
            Write-ColorLine "   Reward: $(Get-QuestRewardText -Quest $quest)" "DarkGray"
        }

        Write-ColorLine ""
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        if ($choice -eq "0") {
            return
        }

        if ($choice -notmatch '^\d+$') {
            Write-ColorLine "Choose a listed number." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $index = [int]$choice - 1

        if ($index -lt 0 -or $index -ge $quests.Count) {
            Write-ColorLine "That quest is not listed." "DarkYellow"
            Write-ColorLine ""
            continue
        }

        $selectedQuest = $quests[$index]

        if ($selectedQuest.Completed) {
            Write-Scene "$($selectedQuest.Name) is already complete."
            Write-ColorLine ""
            continue
        }

        if ($selectedQuest.Accepted) {
            Start-TownQuest -Game $Game -HeroHP $HeroHP -QuestId $selectedQuest.Id
            continue
        }

        $questResult = Accept-TownQuest -Game $Game -QuestId $selectedQuest.Id
        Write-Scene $questResult.Message
        Write-ColorLine ""
    }
}

function Start-QuestHubMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        Write-SectionTitle -Text "Seek Work" -Color "Yellow"
        Write-Scene "Borzig can ask for work from official hands, desperate citizens, or merchants with private problems."
        Write-ColorLine ""
        Write-ColorLine "1. Check the quest board" "White"
        Write-ColorLine "2. Visit the guard station" "White"
        Write-ColorLine "3. Speak with the quest giver's clerk" "White"
        Write-ColorLine "0. Back" "DarkGray"
        Write-ColorLine ""

        $choice = Read-Host "Choose"

        switch ($choice) {
            "1" {
                Show-TownQuestSource -Title "Quest Board" -IntroText "Pinned notices flap in the night wind. Most offer coin, some offer trouble, and all of them want someone else to solve a problem." -Source "Quest Board" -Game $Game -HeroHP $HeroHP
            }
            "2" {
                Show-TownQuestSource -Title "Guard Station" -IntroText "The watch hall smells of lamp oil, damp cloaks, and sleepless men. Steady work hangs here, though rarely easy work." -Source "Guard Station" -Game $Game -HeroHP $HeroHP
            }
            "3" {
                Show-TownQuestSource -Title "Quest Giver" -IntroText "A clerk waits beneath the old patron's seal, ready to pass along jobs too awkward or dangerous for ordinary hirelings." -Source "Quest Giver" -Game $Game -HeroHP $HeroHP
            }
            "0" {
                return
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}

function Start-TownMenu {
    param(
        $Game,
        [ref]$HeroHP
    )

    while ($true) {
        # The first city night is mandatory so the tutorial always lands on the inn chapter ending.
        if ($Game.Town.MustChooseFirstInn -and -not $Game.Town.ChapterOneComplete) {
            Write-SectionTitle -Text "Night Falls" -Color "Yellow"
            Write-Scene "The city can wait until morning. Borzig needs a roof, a locked door, and one real night's sleep before the next chapter begins."
            Write-ColorLine ""

            $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

            if ($innResult -eq "Stayed") {
                $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                if ($innMenuResult -eq "EndGame") {
                    return "EndGame"
                }
            }

            continue
        }

        Write-ColorLine ""
        Write-ColorLine "===== TOWN =====" "Yellow"

        if (-not $Game.Town.StreetFlags["TownMenuVisited"]) {
            Write-Scene "Stone streets spread out before Borzig, loud with merchants, carts, and the clatter of a city living by its own stubborn rhythm."
            Write-Scene "The city no longer feels like refuge alone. It feels like a place where the next chapter might actually begin."
            $Game.Town.StreetFlags["TownMenuVisited"] = $true
        }
        else {
            Write-Scene "The city is awake around Borzig again, full of noise, work, and the feeling that something below it still has not settled."
        }
        Write-ColorLine ""
        Write-ColorLine "What do you want to do?" "Cyan"
        Write-ColorLine "1. Walk the streets" "White"
        Write-ColorLine "2. Browse the market" "White"
        Write-ColorLine "3. Visit the smithy" "White"
        Write-ColorLine "4. Visit the apothecary" "White"
        Write-ColorLine "5. Seek work" "White"
        Write-ColorLine "6. Visit the fighting ring" "White"
        Write-ColorLine "7. Visit your room" "White"
        Write-ColorLine "8. Check inventory" "White"
        Write-ColorLine "9. Check quest log" "White"
        if ($null -eq $Game.Town.ActiveInn) {
            Write-ColorLine "L. Find lodging for the night" "White"
        }
        Write-TextSpeedOption
        Write-ColorLine "0. End the adventure for now" "White"
        Write-ColorLine ""

        $choice = (Read-Host "Choose").ToUpper()

        switch ($choice) {
            "1" {
                Start-TownStreetScene -Game $Game
            }
            "2" {
                Show-TownShop -Title "Market" -IntroText "Canvas stalls crowd the square. Traders wave Borzig over with travel gear, blades, and battered adventuring stock." -Game $Game -Hero $Game.Hero -Offers (Get-MarketOffers)
            }
            "3" {
                Show-TownShop -Title "Smithy" -IntroText "Heat and sparks pour from the forge while the smith sizes Borzig up like a problem that can be solved with steel." -Game $Game -Hero $Game.Hero -Offers (Get-SmithyOffers)
            }
            "4" {
                Show-TownShop -Title "Apothecary" -IntroText "Glass vials glimmer behind the counter as the apothecary speaks in a low voice about wounds, nerves, and battle tonic." -Game $Game -Hero $Game.Hero -Offers (Get-ApothecaryOffers)
            }
            "5" {
                Start-QuestHubMenu -Game $Game -HeroHP $HeroHP
            }
            "6" {
                Start-FightingRing -Game $Game
            }
            "7" {
                if ($null -ne $Game.Town.ActiveInn) {
                    $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                    if ($innMenuResult -eq "EndGame") {
                        return "EndGame"
                    }
                }
                else {
                    Write-Scene "Borzig has not taken a room yet."
                    Write-ColorLine ""
                }
            }
            "8" {
                Open-InventoryMenu -Hero $Game.Hero -HeroHP $HeroHP | Out-Null
            }
            "9" {
                Show-QuestLog -Game $Game -Hero $Game.Hero
            }
            "L" {
                $innResult = Start-InnSelectionMenu -Game $Game -HeroHP $HeroHP

                if ($innResult -eq "Stayed") {
                    $innMenuResult = Start-InnMenu -Game $Game -HeroHP $HeroHP

                    if ($innMenuResult -eq "EndGame") {
                        return "EndGame"
                    }
                }
            }
            "T" {
                Toggle-TextSpeed | Out-Null
            }
            "0" {
                Write-Scene "$($Game.Hero.Name) finds a quiet corner of the city and lets the day finally come to an end."
                $Game.GameWon = $true
                return "EndGame"
            }
            default {
                Write-ColorLine "Invalid choice. Try again." "Red"
                Write-ColorLine ""
            }
        }
    }
}
