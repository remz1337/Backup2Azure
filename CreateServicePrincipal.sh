#!/bin/bash

echo "Creating service principal account for scripted login"

source /etc/Backup2Azure/backup2azure.conf

if [ -z "$account_name" ]; then
  echo "Missing account_name environment variable"
  exit
fi
if [ -z "$container_name" ]; then
  echo "Missing container_name environment variable"
  exit
fi


sp_name="sp-blob-pve-archive"
#az_subscription_id="XXX"
#az_storage_rg="XXX"
# account_name="XXX"
# container_name="XXX"

#Check if info has been passed as arguments
if [ $# -ge 2 ] && [ ! -z "$1" ] && [ ! -z "$2" ]; then
  az_subscription_id="$1"
  echo "az_subscription_id has been set to $az_subscription_id"
  az_storage_rg="$2"
  echo "az_storage_rg has been set to $az_storage_rg"
else
  echo "Missing az_subscription_id and/or az_storage_rg. Pass them as arguments when calling this script."
  exit
fi

az ad sp create-for-rbac --name $sp_name \
                         --role "Storage Blob Data Contributor" \
                         --scopes /subscriptions/${az_subscription_id}/resourceGroups/${az_storage_rg}/providers/Microsoft.Storage/storageAccounts/${account_name}/blobServices/default/containers/${container_name}