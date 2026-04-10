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
}
