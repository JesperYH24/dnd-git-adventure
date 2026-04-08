# Town is split into focused scripts so city progression stays readable as it grows.
. "$PSScriptRoot\\town-shops.ps1"
. "$PSScriptRoot\\town-npcs.ps1"
. "$PSScriptRoot\\town-ring.ps1"
. "$PSScriptRoot\\town-inns.ps1"

function Show-TownQuestSource {
    param(
        [string]$Title,
        [string]$IntroText,
        [string]$Source,
        $Game
    )

    while ($true) {
        $quests = Get-TownQuestList -Game $Game -Source $Source
        Write-SectionTitle -Text $Title -Color "Yellow"
        Write-Scene $IntroText
        Write-ColorLine ""

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

        $questResult = Accept-TownQuest -Game $Game -QuestId $quests[$index].Id
        Write-Scene $questResult.Message
        Write-ColorLine ""
    }
}

function Start-QuestHubMenu {
    param($Game)

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
                Show-TownQuestSource -Title "Quest Board" -IntroText "Pinned notices flap in the night wind. Most offer coin, some offer trouble, and all of them want someone else to solve a problem." -Source "Quest Board" -Game $Game
            }
            "2" {
                Show-TownQuestSource -Title "Guard Station" -IntroText "The watch hall smells of lamp oil, damp cloaks, and sleepless men. Steady work hangs here, though rarely easy work." -Source "Guard Station" -Game $Game
            }
            "3" {
                Show-TownQuestSource -Title "Quest Giver" -IntroText "A clerk waits beneath the old patron's seal, ready to pass along jobs too awkward or dangerous for ordinary hirelings." -Source "Quest Giver" -Game $Game
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
                Start-InnMenu -Game $Game -HeroHP $HeroHP | Out-Null
            }

            continue
        }

        Write-ColorLine ""
        Write-ColorLine "===== TOWN =====" "Yellow"
        Write-Scene "Stone streets spread out before Borzig, loud with merchants, carts, and the clatter of a city living by its own stubborn rhythm."
        Write-Scene "The city no longer feels like refuge alone. It feels like a place where the next chapter might actually begin."
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
                Start-QuestHubMenu -Game $Game
            }
            "6" {
                Start-FightingRing -Game $Game
            }
            "7" {
                if ($null -ne $Game.Town.ActiveInn) {
                    Start-InnMenu -Game $Game -HeroHP $HeroHP | Out-Null
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
                    Start-InnMenu -Game $Game -HeroHP $HeroHP | Out-Null
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
