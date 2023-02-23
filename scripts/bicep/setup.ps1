Clear-Host
. ".\variables.ps1"

Write-LogInfo "Create Resource Group..."
az group create `
    --name $RESOURCE_GROUP_NAME `
    --location $LOCATION `
    --output none

Test-ExitCode

Write-LogInfo "`nCreate Infrastructure..."
az deployment group create `
    --name FuncAppContainerDeployment `
    --resource-group $RESOURCE_GROUP_NAME `
    --template-file ../../infra/main.bicep `
    --parameters location=$LOCATION `
    --output none

Test-ExitCode

Write-LogInfo "`nGet Resource Group ID..."
$RESOURCE_GROUP_ID = az group show `
    --name $RESOURCE_GROUP_NAME `
    --query id `
    --output tsv

Test-ExitCode

Write-LogInfo "`nCreate Service Principal For RBAC..."
$SERVICE_PRINCIPAL_JSON = az ad sp create-for-rbac `
    --name $SERVICE_PRINCIPAL_NAME `
    --scope $RESOURCE_GROUP_ID `
    --role Contributor `
    --sdk-auth

Test-ExitCode

# Set Service Principal Variables
$SERVICE_PRINCIPAL_JSON_OBJ = $SERVICE_PRINCIPAL_JSON | ConvertFrom-Json
$SERVICE_PRINCIPAL_JSON_STR = $SERVICE_PRINCIPAL_JSON_OBJ | ConvertTo-Json -EscapeHandling EscapeHtml
$CLIENT_ID = $SERVICE_PRINCIPAL_JSON_OBJ.clientId
$CLIENT_SECRET = $SERVICE_PRINCIPAL_JSON_OBJ.clientSecret

Write-LogInfo "`nGet Function App Name..."
$FUNCTION_APP_NAME = az functionapp list `
    --resource-group $RESOURCE_GROUP_NAME `
    --query "[].name" `
    --output tsv

Test-ExitCode

Write-LogInfo "`nGet Container Registry ID..."
$CONTAINER_REGISTRY_ID = az acr list `
    --resource-group $RESOURCE_GROUP_NAME `
    --query "[].id" `
    --output tsv

Test-ExitCode

Write-LogInfo "`nGet Container Registry Login Server..."
$CONTAINER_REGISTRY_LOGIN_SERVER = az acr list `
    --resource-group $RESOURCE_GROUP_NAME `
    --query "[].loginServer" `
    --output tsv

Test-ExitCode

Write-LogInfo "`nSet Container Registry Role..."
az role assignment create `
    --assignee $CLIENT_ID `
    --scope $CONTAINER_REGISTRY_ID `
    --role AcrPush `
    --output none

Test-ExitCode

Write-LogInfo "`nUpdate Azure Function Configuration..."
az functionapp config appsettings set `
    --name $FUNCTION_APP_NAME `
    --resource-group $RESOURCE_GROUP_NAME `
    --settings `
        DOCKER_REGISTRY_SERVER_URL="$CONTAINER_REGISTRY_LOGIN_SERVER" `
        DOCKER_REGISTRY_SERVER_USERNAME="$CLIENT_ID" `
        DOCKER_REGISTRY_SERVER_PASSWORD="$CLIENT_SECRET" `
    --output none

Test-ExitCode

Write-LogInfo "`nSet GitHub Repository Secrets..."
gh secret set AZURE_RBAC_CREDENTIALS_BICEP --body "$SERVICE_PRINCIPAL_JSON_STR"
gh secret set REGISTRY_LOGIN_SERVER_BICEP --body "$CONTAINER_REGISTRY_LOGIN_SERVER"
gh secret set REGISTRY_USERNAME_BICEP --body "$CLIENT_ID"
gh secret set REGISTRY_PASSWORD_BICEP --body "$CLIENT_SECRET"
gh secret set FUNCTION_APP_NAME_BICEP --body "$FUNCTION_APP_NAME"

Write-LogInfo "`nSetup Complete"