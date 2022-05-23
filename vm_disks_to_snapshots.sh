now=$(date -u +"%Y-%m-%d-%H-%M")
az account set --subscription "source Sub ID"
#azurevmnames=$(az vm list --resource-group --show-details --query "[].name" --output tsv)
testazurevmnames="list all VM names that need snapshotting i.e Sitka,Nutmeg,BARNFSSQL
"

IFS='
'
count=0
for vmname in $testazurevmnames
do
  count=$((count+1))
  osDiskID=$(az vm show  --resource-group "enter source resource group name" --name $vmname --query "storageProfile.osDisk.managedDisk.id" --output tsv)
  echo $count $vmname $osDiskID
  snapshotNameOsDisk=$(az disk show --ids $osDiskID --query name --output tsv)
    az snapshot create --name $snapshotNameOsDisk --resource-group "enter dest resource grop name" --source $osDiskID --subscription "enter desk sub ID"
  dataDisks=$(az vm show  --resource-group "enter source resource group name" --name $vmname --query "storageProfile.dataDisks[].managedDisk.id" --output tsv)
  echo $snapshotNameOsDisk
  for singleDataDisk in $dataDisks
  do
     dataDiskName=$(az disk show --ids $singleDataDisk --query name --output tsv)
      az snapshot create --name $dataDiskName --resource-group "enter dest resource grop name" --source $osDiskID --subscription "enter desk sub ID"
    echo $dataDiskName
  done
  echo $snapshotName
done
echo "Please allow 5 minutes for snapshots to appear in the resource group."
