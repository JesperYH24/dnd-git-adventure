function Roll-Dice {
    param(
        [int]$Sides = 20
    )

    # Tests can inject deterministic rolls without replacing the function itself.
    if ($null -ne $global:RollDiceOverride) {
        return (& $global:RollDiceOverride $Sides)
    }

    return Get-Random -Minimum 1 -Maximum ($Sides + 1)
}
