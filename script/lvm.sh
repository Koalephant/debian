#!/bin/sh -eu
printf -- '==> %s\n' 'Disabling LVM cache'

if [ -f /etc/lvm/lvm.conf ]; then
	sed -i -E -e 's#use_lvmetad = .+#use_lvmetad = 0#' /etc/lvm/lvm.conf

	case "$(printf "%s" "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1)
			printf -- 'Deferring new initramfs image generation until Guest Tools are installed\n'
			exit 0
		;;
	esac

	update-initramfs -k "$(uname -r)" -u -v
fi
