# Backup2Azure
Small script to upload a set of files to Azure Blob Storage (using the Azure CLI). Storage tier can be configured. Tested with Debian and Ubuntu

By default, this will look for Proxmox LXC/VM backups (`vzdump*.zst`) and PVE host config backups (`pve-host*.zst`) and upload to your Azure storage container every 3 months. **It will not overwrite already uploaded backups**. Setting up a retention policy in your container is recommended (eg. 1 year)

## Requirements
- An active [Azure](https://azure.microsoft.com/en-us/) account
  - Create a storage account
    - Create a container (where the files will be uploaded)

## Setup
1. Download and extract the repo
2. Run `install_deps.sh`
3. Run `install.sh`
4. Configure `/etc/Backup2Azure/backup2azure.conf`
- `account_name` --> Azure storage account name
- `container_name` --> Azure storage container name
- `search_dir` --> local directory containing the files to upload (can be a mounted directory)
- `tier` --> Azure storage tier to use (**ARCHIVE**, **COLD** or **HOT**)
6. Run `CreateServicePrincipale.sh <YourAzureSubscriptionId> <YourAzureStorageResourceGroup>` to create a service principal that the script will use to authenticate 
7. Add the service principal details to `/etc/Backup2Azure/backup2azure.conf`
- `sp_app_id` --> Service principal application ID
- `sp_password` --> Service principal password
- `sp_tenant_id` --> Service principal tenant ID
