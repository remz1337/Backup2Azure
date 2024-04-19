#!/bin/bash

function validate_env(){
  if [ -z "$account_name" ]; then
    echo "Missing account_name environment variable"
    exit
  fi
  if [ -z "$container_name" ]; then
    echo "Missing container_name environment variable"
    exit
  fi
  if [ -z "$sp_app_id" ]; then
    echo "Missing sp_app_id environment variable"
    exit
  fi
  if [ -z "$sp_password" ]; then
    echo "Missing sp_password environment variable"
    exit
  fi
  if [ -z "$sp_tenant_id" ]; then
    echo "Missing sp_tenant_id environment variable"
    exit
  fi
  if [ -z "$email" ]; then
    echo "Missing email environment variable"
    exit
  fi
}


validate_env

exit
#WIP, haven't tested past this

logfile="log.txt"

echo "Uploading backups..." > $logfile

account_name="XXX"
container_name="XXX"

sp_app_id="XXX"
sp_password="XXX"
sp_tenant_id="XXX"

email="XXX"

search_dir=/mnt/pve/backup/dump
#file_pattern=vzdump-*.tar.zst
#*.tar.zst for CT and pve host backups
#*.vma.zst for VM backups
pve_config_file_pattern=pve-host*.zst
backups_file_pattern=vzdump*.zst
#after=$(date -u --date="90 days ago" +"%Y-%m-%dT%H:%M:%SZ")
tier="ARCHIVE" #Hot,Cold,Archive

start=$(date +%s)

#Token expires after 90 of inactivity. Use a different scheduled (monthly) job to keep login alive
az login --service-principal -u ${sp_app_id}  -p ${sp_password} --tenant ${sp_tenant_id} > $logfile 2>&1

#az storage blob upload-batch -d $container_name --account-name $account_name --auth-mode login -s $search_dir --pattern $file_pattern --tier $tier --overwrite false >> $logfile 2>&1

echo "Starting upload of PVE host config..." >> $logfile
{ # try
    az storage blob upload-batch -d $container_name --account-name $account_name --auth-mode login -s $search_dir --pattern $pve_config_file_pattern --tier $tier --overwrite false >> $logfile 2>&1
} || { # catch
    echo "Exception while uploading PVE host config." >> $logfile
}

echo "Starting upload of backups..." >> $logfile
{ # try
    az storage blob upload-batch -d $container_name --account-name $account_name --auth-mode login -s $search_dir --pattern $backups_file_pattern --tier $tier --overwrite false >> $logfile 2>&1
} || { # catch
    echo "Exception while uploading backups." >> $logfile
}

end=$(date +%s)
seconds=$(($end-$start))
elapsed=$(date -d@$seconds -u +"%j days %H:%M:%S")

body=$(cat <<-END
Upload of homelab backups to cloud completed.
Job time: $elapsed

END
)


#Confirm upload
mail -A $logfile -s "[Homelab] Offsite backup completed" "$email" <<< "$body"

#rm $logfile

echo "Done"
