#!/bin/bash

#Copy default config file if it doesn't exists
mkdir -p /etc/Backup2Azure
if [ ! -f "/etc/Backup2Azure/backup2azure.conf" ]; then
  cp backup2azure.conf /etc/Backup2Azure/
fi

#Create link to executable script
mkdir -p /opt/Backup2Azure
cp AzUpload.sh /opt/Backup2Azure/AzUpload.sh


#Create systemd timer
cat <<EOF >/etc/systemd/system/backup2azure.timer
[Unit]
Description=Backup2Azure timer
Requires=backup2azure.service

[Timer]
Unit=backup2azure.service
#Every minute
#OnCalendar=*-*-* *:*:00
#Every 3 months
#OnCalendar=quarterly
#OnCalendar=02,05,08,11-01 00:00:00
OnCalendar=Mon 02,05,08,11-01..07 00:00:00

[Install]
WantedBy=timers.target
EOF


#Create systemd service
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
WantedBy=multi-user.target
EOF

#systemctl enable -q --now backup2azure
systemctl enable -q --now backup2azure.timer


echo "done"
exit
