#!/bin/bash

cp /etc/apt/sources.list /etc/apt/sources.list.bak

sed -i 's/http:\/\/archive\.ubuntu\.com\/ubuntu\//http:\/\/azure\.archive\.ubuntu\.com\/ubuntu\//g' /etc/apt/sources.list
sed -i 's/http:\/\/[a-z][a-z]\.archive\.ubuntu\.com\/ubuntu\//http:\/\/azure\.archive\.ubuntu\.com\/ubuntu\//g' /etc/apt/sources.list
apt-get update

apt update
apt install linux-azure linux-image-azure linux-headers-azure linux-tools-common linux-cloud-tools-common linux-tools-azure linux-cloud-tools-azure
apt full-upgrade

reboot

vi /etc/default/grub
GRUB_CMDLINE_LINUX_DEFAULT="console=tty1 console=ttyS0,115200n8 earlyprintk=ttyS0,115200 rootdelay=300 quiet splash"

apt update
apt install cloud-init netplan.io walinuxagent && systemctl stop walinuxagent

rm -f /etc/cloud/cloud.cfg.d/50-curtin-networking.cfg /etc/cloud/cloud.cfg.d/curtin-preserve-sources.cfg
rm -f /etc/cloud/ds-identify.cfg
rm -f /etc/netplan/*.yaml

cat > /etc/cloud/cloud.cfg.d/90_dpkg.cfg << EOF
 datasource_list: [ Azure ]
EOF

cat > /etc/cloud/cloud.cfg.d/90-azure.cfg << EOF
system_info:
   package_mirrors:
     - arches: [i386, amd64]
       failsafe:
         primary: http://archive.ubuntu.com/ubuntu
         security: http://security.ubuntu.com/ubuntu
       search:
         primary:
           - http://azure.archive.ubuntu.com/ubuntu/
         security: []
     - arches: [armhf, armel, default]
       failsafe:
         primary: http://ports.ubuntu.com/ubuntu-ports
         security: http://ports.ubuntu.com/ubuntu-ports
EOF

cat > /etc/cloud/cloud.cfg.d/10-azure-kvp.cfg << EOF
reporting:
  logging:
    type: log
  telemetry:
    type: hyperv
EOF

sed -i 's/Provisioning.Enabled=y/Provisioning.Enabled=n/g' /etc/waagent.conf
sed -i 's/Provisioning.UseCloudInit=n/Provisioning.UseCloudInit=y/g' /etc/waagent.conf
sed -i 's/ResourceDisk.Format=y/ResourceDisk.Format=n/g' /etc/waagent.conf
sed -i 's/ResourceDisk.EnableSwap=y/ResourceDisk.EnableSwap=n/g' /etc/waagent.conf

cat >> /etc/waagent.conf << EOF
# For Azure Linux agent version >= 2.2.45, this is the option to configure,
# enable, or disable the provisioning behavior of the Linux agent.
# Accepted values are auto (default), waagent, cloud-init, or disabled.
# A value of auto means that the agent will rely on cloud-init to handle
# provisioning if it is installed and enabled, which in this case it will.
Provisioning.Agent=auto
EOF

cloud-init clean --logs --seed
rm -rf /var/lib/cloud/
systemctl stop walinuxagent.service
rm -rf /var/lib/waagent/
rm -f /var/log/waagent.log

waagent -force -deprovision+user
rm -f ~/.bash_history
export HISTSIZE=0
logout