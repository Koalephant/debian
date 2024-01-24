#!/bin/sh -eu

printf -- '==> %s\n' 'Running ZeroFree to reduce disk image file'

for type in ext2 ext3 ext4; do
	for fs in $(blkid --output device --match-token "TYPE=$type"); do
		printf -- '==> Remounting filesystem(%s) as readonly\n' "$fs"
		mount -o remount,ro "${fs}"
		printf -- '==> Zeroing free blocks in filesystem(%s)\n' "$fs"
		zerofree -v "$fs"
	done
done

printf -- '==> %s\n' 'Clear out swap and disable until reboot'

for swapUUID in $(/sbin/blkid --output value --match-tag UUID --match-token TYPE=swap); do
	partition="$(readlink -f "/dev/disk/by-uuid/$swapUUID")"
	printf -- '==> Disabling swap (%s)\n' "$partition"
	swapoff -v "${partition}"
	dd if=/dev/zero of="$partition" bs=1M || true
	mkswap -U "$swapUUID" "$partition"
done

# shellcheck disable=SC2016
printf -- '==> %s\n' 'Restoring original `fstab`'
mount -o remount,rw '/'
mv /etc/fstab.old /etc/fstab

sync
