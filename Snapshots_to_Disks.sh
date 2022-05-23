az account set --subscription "enter snapshot sub ID"

snapshotIDS=$(az snapshot list --resource-group "enter source resource group name" --query "[].id" --output tsv)
#echo $snapshotIDS
IFS='
'
for singleSnapshotID in $snapshotIDS
do
  count=$((count+1))
#  echo $count $singleSnapshotName
  diskSize=$(az snapshot show --ids $singleSnapshotID --query "diskSizeGb"  --output tsv)
  snapshotName=$(az snapshot show --ids $singleSnapshotID --query "name"  --output tsv)
  storageType=$(az snapshot show --ids $singleSnapshotID --query "sku.name"  --output tsv)
  az disk create --name $snapshotName --resource-group "enter dest resource group name" --source $singleSnapshotID --sku $storageType --size-gb $diskSize
done

