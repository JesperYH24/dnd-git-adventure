function Roll-Dice {
    param(
        [int]$Sides = 20
    )

    return Get-Random -Minimum 1 -Maximum ($Sides + 1)
}
