Param(
    [string][Parameter(Mandatory=$true)] $subscriptionId,
    [string][Parameter(Mandatory=$true)] $principalName,
    [string][Parameter(Mandatory=$true)] $realm,
    [string][Parameter(Mandatory=$true)] $password,
    [string][Parameter(Mandatory=$false)] $defaultRole
)

# Set up default proxy (remove this line if not required)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# Sign in
Write-Host "Logging in...";
Login-AzureRmAccount;
Write-Host "Done." -ForegroundColor Green

# Select subscription
Write-Host "Selecting subscription '$subscriptionId'...";
Select-AzureRmSubscription -SubscriptionID $subscriptionId;
Write-Host "Done." -ForegroundColor Green

# Get the Tenant ID
$tenantId = (Get-AzureRmContext).Tenant.TenantId

# Output the details that we will use within this script.
Write-Host "Subscription: $subscriptionId"
Write-Host "Realm:        $realm"
Write-Host "Tenant:       $tenantId"

# Get the application as registered within Azure AD, using the $realm (Application URL) parameter as the unique identifier of the application
$app = Get-AzureRmADApplication -IdentifierUri $realm

# If the application is not currently registered in Azure AD
if (!$app) {
    # Register Application in Azure AD
    Write-Host "Registering AD application..."
    $app = New-AzureRmADApplication -DisplayName $principalName -HomePage $realm -IdentifierUris $realm -Password $password
    Write-Host "Done." -ForegroundColor Green

    # Create the service principal object
    Write-Host "Creating Service Principal..."
    $sp = New-AzureRmADServicePrincipal -ApplicationId $app.ApplicationId
    Write-Host "Done." -ForegroundColor Green

    # If a default role was passed in as a parameter, then assign to the service principal
    if (![String]::IsNullOrEmpty($defaultRole))
    {
        # Sleep for 15 seconds (to ensure the service principal is ready before trying to assign permissions).
        Write-Host "Waiting..." -ForegroundColor DarkYellow
        Start-Sleep -s 15

        Write-Host "Assigning service principal to default role..."
        New-AzureRmRoleAssignment -RoleDefinitionName $defaultRole -ServicePrincipalName $sp.ApplicationId
        Write-Host "Done." -ForegroundColor Green
    }

    Write-Host "Service Principal Created Successfully" -ForegroundColor Green
    Write-Host ""
    Write-Host "  SubscriptionId:       $subscriptionId"
    Write-Host "  TenantId:             $tenantId"
    Write-Host "  ApplicationId:        $($app.ApplicationId.ToString())"
    Write-Host "  ServicePrincipalName: $($sp.DisplayName)"
}
else {
    Write-Host "Service Principal already exists: $($app.ApplicationId.ToString())"
}
