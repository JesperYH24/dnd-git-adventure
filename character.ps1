function Get-Hero {
    return [PSCustomObject]@{
        Name  = "Borzig"
        Class = "Barbarian"
        HP    = 20
        STR   = 16
        DamageMin = 1
        DamageMax = 8
    }
}