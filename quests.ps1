function Show-QuestLog {
    param($Quest)

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
    Write-ColorLine ""
}
