function Show-QuestLog {
    param(
        $Quest,
        $Hero = $null
    )

    $status = "Active"

    if ($Quest.Completed) {
        $status = "Complete"
    }
    elseif ($Quest.SeenDragon) {
        $status = "Turn In"
    }

    Write-ColorLine ""
    Write-ColorLine "===== QUEST LOG =====" "Yellow"
    Write-ColorLine $Quest.Name "White"
    Write-ColorLine $Quest.Description "Gray"
    Write-ColorLine "Objective: $($Quest.Objective)" "White"
    Write-ColorLine "Status: $status" "Cyan"

    if ($Hero) {
        $nextLevelXP = Get-HeroNextLevelXPThreshold -Hero $Hero
        $displayXP = [Math]::Min($Hero.XP, $nextLevelXP)
        Write-ColorLine "XP: $displayXP/$nextLevelXP" "White"

        if ((Get-HeroAvailableLevelUps -Hero $Hero) -gt 0) {
            Write-ColorLine "Level Up Ready: Take a long rest to reach level $($Hero.Level + 1)." "Yellow"
        }
    }

    Write-ColorLine ""
}
