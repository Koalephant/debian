#!/bin/sh -eu

# Make sure Udev doesn't block our network
# http://6.ptmc.org/?p=164
printf -- '==> %s\n' 'Cleaning up udev rules'
rm -rfv /dev/.udev/
# Better fix that persists package updates: http://serverfault.com/a/485689
touch /etc/udev/rules.d/75-persistent-net-generator.rules

printf -- '==> %s\n' 'Cleaning up leftover dhcp leases'
if [ -d '/var/lib/dhcp' ]; then
	rm -fv /var/lib/dhcp/*
fi

# cleanup systemd machine-id. see https://salsa.debian.org/cloud-team/vagrant-boxes/blob/master/helpers/vagrant-setup#L103
printf -- '==> %s\n' 'Cleaning up dbus machine ID'
rm -fv /var/lib/dbus/machine-id
printf -- '' > /etc/machine-id

printf -- '==> %s\n' 'Cleaning up tmp'
rm -rf /tmp/*

# Cleanup apt cache
apt-get -y autoremove --purge
apt-get -y clean
apt-get -y autoclean

printf -- '==> %s\n' 'Installed packages'
dpkg --get-selections | grep -v deinstall

DISK_USAGE_BEFORE_CLEANUP="$(df -h)"

# Remove Bash history
unset HISTFILE
rm -fv /root/.bash_history
rm -fv /home/vagrant/.bash_history

# Clean up log files
find /var/log -type f | while read -r f; do printf -- '' > "${f}"; done;

printf -- '==> %s\n' 'Clearing last login information'
printf -- '' > /var/log/lastlog
printf -- '' > /var/log/wtmp
printf -- '' > /var/log/btmp

printf -- '==> %s\n' 'Disk usage before cleanup'
printf -- '%s\n' "${DISK_USAGE_BEFORE_CLEANUP}"

printf -- '==> %s\n' 'Disk usage after cleanup'
df -h

printf -- '==> %s\n' 'Rebooting'
nohup shutdown --reboot now </dev/null >/dev/null 2>&1 &
