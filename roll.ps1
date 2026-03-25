function Roll-Dice {
    param(
        [int]$Sides = 20
    )

    return Get-Random -Minimum 1 -Maximum ($Sides + 1)
}

function Roll-Damage {
    param(
        [int]$Minimum = 1,
        [int]$Maximum = 6
    )

    return Get-Random -Minimum $Minimum -Maximum ($Maximum + 1)
}