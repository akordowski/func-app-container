$LOCATION = "westeurope"
$RESOURCE_GROUP_NAME = "rg-func-app-container-manual"
$SERVICE_PRINCIPAL_NAME = "sp-func-app-container-manual"

function Test-ExitCode {
    if ($LastExitCode -ne 0) {
        Write-Host "`nSTOP EXECUTION" -ForegroundColor Red 
        exit $LastExitCode
    }
}

function Write-LogInfo([string]$message) {
    Write-Host $message  -ForegroundColor Green
}