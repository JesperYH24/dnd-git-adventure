. "$PSScriptRoot\..\setup.ps1"

function Assert-Equal {
    param(
        $Actual,
        $Expected,
        [string]$Message
    )

    if ($Actual -ne $Expected) {
        throw "$Message Expected: $Expected, Actual: $Actual"
    }
}

function Assert-True {
    param(
        [bool]$Condition,
        [string]$Message
    )

    if (-not $Condition) {
        throw $Message
    }
}

# Town tests touch a lot of narrative helpers, so we stub them to keep the output quiet and the runs fast.
function Set-TestOutputStubs {
    $global:SuppressUiOutput = $true
    $global:FastTextEnabled = $true
    $global:TransientTextSkipUntil = $null
}

function Set-TestReadHostSequence {
    param([string[]]$Values)

    $script:ReadHostSequence = @($Values)
    $script:ReadHostIndex = 0

    function global:Read-Host {
        param([string]$Prompt)

        if ($script:ReadHostIndex -ge $script:ReadHostSequence.Count) {
            throw "Read-Host was called more times than the test expected."
        }

        $value = $script:ReadHostSequence[$script:ReadHostIndex]
        $script:ReadHostIndex += 1
        return $value
    }
}
