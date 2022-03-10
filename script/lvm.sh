#!/bin/sh -eu
printf -- '==> %s\n' 'Disabling LVM cache'

if [ -f /etc/lvm/lvm.conf ]; then
	sed -i -E -e 's#use_lvmetad = .+#use_lvmetad = 0#' /etc/lvm/lvm.conf
	update-initramfs -k "$(uname -r)" -u -v
fi
