# Include a list of subscriptions to apply policy to.
$subscriptions = @( `
    "Subscription1",
    "Subscription2",
    "Subscription3"
    )
 
# Set up default proxy (remove this line if not required)
[System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultCredentials

Login-AzureRmAccount -ErrorAction Stop
 
# Loop through each subscription.
foreach ($subName in $subscriptions) {
    Write-Host  "Selecting subscription: $subName"
 
    # Select the subscription.
    $subscription = Get-AzureRmSubscription –SubscriptionName $subName
    Select-AzureRmSubscription -SubscriptionId $subscription.SubscriptionId
    $scope = "/subscriptions/$($subscription.SubscriptionId)"
 
    Write-host "Assigning policies to the subscription: $subName" -ForegroundColor Green
 
    # 1. A resource must have the following mandatory tags: Solution, Environment, BusinessOwner
    $tagPolicy = New-AzureRmPolicyDefinition -Name 'Mandatory Tag Policy' -Description 'Policy to ensure resources have mandatory tags: Solution, Environment, BusinessOwner' -Policy '{
      "if": {
        "anyOf": [
            {
                "not": {
                  "field" : "tags",
                  "containsKey" : "Solution"
                }
            },
            {
                "not": {
                  "field" : "tags",
                  "containsKey" : "Environment"
                }
            },
            {
                "not": {
                  "field" : "tags",
                  "containsKey" : "BusinessOwner"
                }
            }
        ]
      },
      "then" : {
        "effect" : "deny"
      }
    }';
 
    Write-host "Sleeping for 10 seconds" -ForegroundColor Yellow
    Start-Sleep -s 10
 
    New-AzureRmPolicyAssignment -Name $tagPolicy.Name -PolicyDefinition $tagPolicy -Scope $scope
    Write-host "Policy $($tagPolicy.Name) is assigned to the subscription: $subName" -ForegroundColor Green
}
 
Write-Host "Done." -ForegroundColor Green