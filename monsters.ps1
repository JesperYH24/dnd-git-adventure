function Get-MonsterList {
    @(
        @{ 
            name = "skelett"
            article = "Ett"
            definite = "Skelettet"
            hp = 10
            damageMin = 1
            damageMax = 4
            isBoss = $false
        },
        @{ 
            name = "goblin"
            article = "En"
            definite = "Goblinen"
            hp = 8
            damageMin = 1
            damageMax = 6
            isBoss = $false
        },
        @{ 
            name = "zombie"
            article = "En"
            definite = "Zombien"
            hp = 12
            damageMin = 1
            damageMax = 5
            isBoss = $false
        },
        @{ 
            name = "jätteråtta"
            article = "En"
            definite = "Jätteråttan"
            hp = 7
            damageMin = 1
            damageMax = 3
            isBoss = $false
        },
        @{ 
            name = "uråldrig drake"
            article = "En"
            definite = "Den uråldriga draken"
            hp = 50
            damageMin = 8
            damageMax = 12
            isBoss = $true
        }
    )
}

function Get-RandomMonster {
    $monsters = Get-MonsterList
    return ($monsters | Get-Random)
}

function Get-BossMonster {
    $monsters = Get-MonsterList
    return ($monsters | Where-Object { $_.isBoss } | Select-Object -First 1)
}