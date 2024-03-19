$subscriptionId = "c3bffe7f-e643-4393-ae69-ab6e9fd0668f"
Select-AzSubscription -SubscriptionId $subscriptionId

# Define the path to your CSV file
$csvPath = "C:\Users\akundu00\Documents\psscrps\Vnetintegration\vnetintegration.csv"

# Import the CSV file
$data = Import-Csv -Path $csvPath

# Loop through each row in the CSV file
foreach ($row in $data) {
    $vNetResourceGroupName = $row.VNetResourceGroupName
    $webAppResourceGroupName = $row.ResourceGroupName
    $siteName = $row.AppServiceName
    $vNetName = $row.VNetName
    $integrationSubnetName = $row.SubnetName

$vnet = Get-AzVirtualNetwork -Name $vNetName -ResourceGroupName $vNetResourceGroupName
$subnet = Get-AzVirtualNetworkSubnetConfig -Name $integrationSubnetName -VirtualNetwork $vnet
Get-AzDelegation -Subnet $subnet

$subnet = Add-AzDelegation -Name "myDelegation" -ServiceName "Microsoft.Web/serverFarms" -Subnet $subnet
Set-AzVirtualNetwork -VirtualNetwork $vnet

$subnetResourceId = "/subscriptions/$subscriptionId/resourceGroups/$vNetResourceGroupName/providers/Microsoft.Network/virtualNetworks/$vNetName/subnets/$integrationSubnetName"
$webApp = Get-AzResource -ResourceType Microsoft.Web/sites -ResourceGroupName $webAppResourceGroupName -ResourceName $siteName
$webApp.Properties.virtualNetworkSubnetId = $subnetResourceId
$webApp.Properties.vnetRouteAllEnabled = 'true'
$webApp | Set-AzResource -Force

Write-Host "Azure VNet Integration added to App Services based on CSV file."
}


