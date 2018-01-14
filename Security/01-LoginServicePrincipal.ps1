function Login-AzureRMServicePrincipal{
    Param(
         [string][Parameter(Mandatory=$true)] $applicationId,
         [string][Parameter(Mandatory=$true)] $password,
         [string][Parameter(Mandatory=$true)] $tenantId
    )
    
    # Convert the plain text password to a secure string.
    $pass = ConvertTo-SecureString $password -AsPlainText -Force

    # Create a PsCredential object based on the applicationId and secure string password.
    $cred = New-Object -TypeName pscredential -ArgumentList $applicationId, $pass

    # Login to Azure with the service principal credentials.
    Login-AzureRmAccount -Credential $cred -ServicePrincipal -TenantId $tenantId
}

# Set up default proxy (remove this line if not required)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

# Call the helper function to login as the service principal.
Login-AzureRMServicePrincipal -applicationId "2a0b6f1d-3b59-48d5-80d4-a14f154bd0cf" -password "E7rDkSVWfX05fLPWMyJhXgZ4sml1ePaEQBWej+R7Pag=" -tenantId "0696cd8d-a2ef-4dc2-8889-e64d4825c0bd"

# Test the login was successful by running a command...
Get-AzureRmResource
