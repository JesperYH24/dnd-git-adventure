function Show-QuestLog {
    param($Quest)

    Write-ColorLine ""
    Write-ColorLine "===== QUEST LOG =====" "Yellow"
    Write-ColorLine $Quest.Name "White"
    Write-ColorLine $Quest.Description "Gray"
    Write-ColorLine "Objective: $($Quest.Objective)" "White"
    Write-ColorLine "Status: $(if ($Quest.Completed) { 'Complete' } else { 'Active' })" "Cyan"
    Write-ColorLine ""
}

