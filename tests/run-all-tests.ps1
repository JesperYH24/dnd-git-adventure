param(
    [switch]$ContinueOnFailure
)

$ErrorActionPreference = "Stop"

$testFiles = Get-ChildItem -Path $PSScriptRoot -Filter "*.tests.ps1" |
    Where-Object { $_.Name -ne "run-all-tests.ps1" } |
    Sort-Object Name

$failures = @()

foreach ($testFile in $testFiles) {
    Write-Host "Running $($testFile.Name)" -ForegroundColor Cyan

    & pwsh -NoProfile -ExecutionPolicy Bypass -File $testFile.FullName
    $exitCode = $LASTEXITCODE

    if ($exitCode -ne 0) {
        $failures += [PSCustomObject]@{
            Name = $testFile.Name
            ExitCode = $exitCode
        }

        Write-Host "Failed $($testFile.Name) with exit code $exitCode" -ForegroundColor Red

        if (-not $ContinueOnFailure) {
            break
        }
    }
}

if ($failures.Count -gt 0) {
    Write-Host ""
    Write-Host "Failed test files:" -ForegroundColor Red

    foreach ($failure in $failures) {
        Write-Host "  $($failure.Name) (exit code $($failure.ExitCode))" -ForegroundColor Red
    }

    exit 1
}

Write-Host ""
Write-Host "All test files passed." -ForegroundColor Green
