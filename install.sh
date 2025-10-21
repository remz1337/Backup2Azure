#!/bin/bash

#Copy default config file if it doesn't exists
mkdir -p /etc/Backup2Azure
if [ ! -f "/etc/Backup2Azure/backup2azure.conf" ]; then
  cp backup2azure.conf /etc/Backup2Azure/
fi

#Copy executable script
mkdir -p /opt/Backup2Azure
cp AzUpload.sh /opt/Backup2Azure/AzUpload.sh

#Create backup upload service
cat <<EOF >/etc/systemd/system/backup2azure.timer
[Unit]
Description=Backup2Azure timer

[Timer]
Unit=backup2azure.service
#Every 3 months
#OnCalendar=quarterly
OnCalendar=Mon 02,05,08,11-01..07 00:00:00
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat <<EOF >/etc/systemd/system/backup2azure.service
[Unit]
Description=Backup2Azure service
After=network.target
Wants=backup2azure.timer

[Service]
Type=oneshot
EnvironmentFile=/etc/Backup2Azure/backup2azure.conf
ExecStart=bash /opt/Backup2Azure/AzUpload.sh
StandardOutput=truncate:/var/log/backup2azure.log
StandardError=truncate:/var/log/backup2azure.log

[Install]
WantedBy=backup2azure.timer
EOF

systemctl enable -q --now backup2azure.timer

#Installing keepalive service for login token
cat <<EOF >/etc/systemd/system/azlogin.timer
[Unit]
Description=Azure Login keepalive timer
Requires=azlogin.service

[Timer]
Unit=azlogin.service
OnCalendar=monthly
Persistent=true

[Install]
WantedBy=timers.target
EOF

cat <<EOF >/etc/systemd/system/azlogin.service
[Unit]
Description=Azure Login keepalive service
After=network.target
Wants=azlogin.timer

[Service]
Type=oneshot
EnvironmentFile=/etc/Backup2Azure/backup2azure.conf
ExecStart=/bin/bash -c 'az login --service-principal -u \${sp_app_id}  -p \${sp_password} --tenant \${sp_tenant_id}'

[Install]
WantedBy=multi-user.target
EOF

systemctl enable -q --now azlogin.timer
