<#	
	Version:        2.0
	Author:         Saravanan Muthiah
	Creation Date:  25th Apr, 2018
	Purpose/Change: Creating Azure Managed Disk Snapshot
#>

Login-AzureRmAccount -Credential $psCred –SubscriptionId $SubscriptionId -ErrorAction Stop | out-null
Connect-AzureRmAccount
Get-AzureRmSubscription -SubscriptionId $SubscriptionId | Select-AzureRmSubscription

$tagResList = Get-AzureRmResource -TagName Environment -TagValue Staging
#$tagResList = Find-AzureRmResource -ResourceGroupNameEquals testrs

#$tagRsList[0].ResourceId.Split("//")
#subscriptions
#<SubscriptionId>
#resourceGroups
#<ResourceGroupName>
#providers
#Microsoft.Compute
#virtualMachines
#<vmName>

foreach($tagRes in $tagResList) { 
		if($tagRes.ResourceId -match "Microsoft.Compute")
		{
			$vmInfo = Get-AzureRmVM sandbox207478603000 #$tagRes.ResourceId.Split("//")[4] -Name $tagRes.ResourceId.Split("//")[8]

				#Set local variables
				$location = $vmInfo.Location
				$resourceGroupName = $vmInfo.ResourceGroupName
                $timestamp = Get-Date -f MM-dd-yyyy_HH_mm_ss

                #Snapshot name of OS data disk
                $snapshotName = $vmInfo.Name + $timestamp 

				#Create snapshot configuration
                $snapshot =  New-AzureRmSnapshotConfig -SourceUri $vmInfo.StorageProfile.OsDisk.ManagedDisk.Id -Location $location  -CreateOption copy
				
				#Take snapshot
                New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName -ResourceGroupName $resourceGroupName 
				
                
				if($vmInfo.StorageProfile.DataDisks.Count -ge 1){
						#Condition with more than one data disks
						for($i=0; $i -le $vmInfo.StorageProfile.DataDisks.Count - 1; $i++){
								
							#Snapshot name of OS data disk
							$snapshotName = $vmInfo.StorageProfile.DataDisks[$i].Name + $timestamp 
							
							#Create snapshot configuration
							$snapshot =  New-AzureRmSnapshotConfig -SourceUri $vmInfo.StorageProfile.DataDisks[$i].ManagedDisk.Id -Location $location  -CreateOption copy
							
							#Take snapshot
							New-AzureRmSnapshot -Snapshot $snapshot -SnapshotName $snapshotName 
                            c53a2132-ad79-4669-8dbf-958afcf11a13 $SubscriptionId snapshots $ResourceGroupName
						}
					}
				else{
						Write-Host $vmInfo.Name + " doesn't have any additional data disk."
				}
		}
		else{
			$tagRes.ResourceId + " is not a compute instance"
		}
}

$tagRgList = Get-AzureRmResourceGroup -Tag @{ Environment = "Staging" }