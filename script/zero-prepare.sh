#!/bin/sh -eu

printf -- '==> %s\n' 'Installing ZeroFree to reduce disk image file'
apt-get -y install zerofree

# shellcheck disable=SC2016
printf -- '==> %s\n' 'Mounting `/` read-only on next reboot'
cp /etc/fstab /etc/fstab.old
sed -E 's#([^[:space:]]+\s+/\s+[a-z0-9]+\s+)([^[:space:]]+)#\1\2,ro#' /etc/fstab > /etc/fstab.new

# shellcheck disable=SC2016
printf -- '==> %s\n' 'Mounting `/` in RAM on next reboot'
printf -- 'none\t/tmp\tramfs\tdefaults\t0\t0\n' >> /etc/fstab.new

printf -- '==> %s\n' 'Verifying temporary fstab file'
if findmnt --verify --tab-file /etc/fstab.new; then
	mv -fv /etc/fstab.new /etc/fstab
fi
