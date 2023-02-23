Clear-Host
. ".\variables.ps1"

Write-LogInfo "Delete Resource Group..."
az group delete --name $RESOURCE_GROUP_NAME --yes

Test-ExitCode

Write-LogInfo "`nGet AD App ID..."
$AD_APP_ID = az ad app list `
  --display-name $SERVICE_PRINCIPAL_NAME `
  --query "[].id" `
  --output tsv

Test-ExitCode

Write-LogInfo "`nDelete AD App..."
az ad app delete --id $AD_APP_ID

Test-ExitCode

Write-LogInfo "`nDelete GitHub Repository Secrets..."
gh secret delete AZURE_RBAC_CREDENTIALS_BICEP
gh secret delete REGISTRY_LOGIN_SERVER_BICEP
gh secret delete REGISTRY_USERNAME_BICEP
gh secret delete REGISTRY_PASSWORD_BICEP
gh secret delete FUNCTION_APP_NAME_BICEP

Write-LogInfo "`nCleanup Complete"