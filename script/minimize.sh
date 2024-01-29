#!/bin/sh -eu

purge_packages() {
	printf -- '%s\n' "$@" | xargs -n 1 apt-cache --generate pkgnames | xargs apt-get -y purge
}

printf -- '==> %s\n' 'Installed packages before cleanup'
dpkg --get-selections | grep -v deinstall

DISK_USAGE_BEFORE_MINIMIZE="$(df -h)"

# Remove some packages to get a minimal install
printf -- '==> %s\n' 'Removing all linux kernels except the current one'
dpkg --list | awk '{ print $2 }' | grep 'linux-image-*' | grep -v $(uname -r) | grep -v linux-image-$(uname -r | cut -f '3' -d '-') | xargs apt-get -y purge
printf -- '==> %s\n' 'Removing linux source'
dpkg --list | awk '{ print $2 }' | grep linux-source | xargs apt-get -y purge
printf -- '==> %s\n' 'Removing development packages'
dpkg --list | awk '{ print $2 }' | grep -v 'dpkg-dev' | grep -- '-dev$' | xargs apt-get -y purge

printf -- '==> %s\n' 'Removing X11 libraries'
purge_packages libx11-data xauth libxmuu1 libxcb1 libx11-6 libxext6

printf -- '==> %s\n' 'Removing desktop components'
purge_packages gnome-getting-started-docs libreoffice

printf -- '==> %s\n' 'Removing obsolete networking components'
purge_packages ppp pppconfig pppoeconf

printf -- '==> %s\n' 'Removing other oddities'
purge_packages popularity-contest installation-report wireless-tools wpasupplicant

printf -- '==> %s\n' 'Removing default system Ruby'
purge_packages ruby ri

printf -- '==> %s\n' 'Removing default system Python'
purge_packages python-dbus libnl1 python-smartpm python-twisted-core libiw30 python-twisted-bin libdbus-glib-1-2 python-pexpect python-pycurl python-serial python-gobject python-pam python-openssl

# Clean up the apt cache
printf -- '==> %s\n' 'Cleaning up the apt cache'
apt-get -y autoremove --purge
apt-get -y autoclean
apt-get -y clean

printf -- '==> %s\n' 'Removing APT files'
find /var/lib/apt -type f -delete

printf -- '==> %s\n' 'Removing caches (except DebConf)'
find /var/cache -path /var/cache/debconf -prune -false -o -type f -exec rm -f {} \;
printf -- '==> %s\n' 'Removing lintian linda'
rm -rfv /usr/share/lintian/* /usr/share/linda/*

printf -- '==> %s\n' 'Disk usage before minimization'
printf -- '%s\n' "${DISK_USAGE_BEFORE_MINIMIZE}"

printf -- '==> %s\n' 'Disk usage after minimization'
df -h
