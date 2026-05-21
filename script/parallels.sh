#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

if [ "${BOX_PROVIDER}" = 'parallels' ]; then
	case "$(printf "%s" "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- 'Parallels Tools not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac

	mkdir -p /mnt/tools
	if [ -f "/home/${SSH_USER}/tools-manual/${PARALLELS_GUEST_TOOLS_ISO}" ]; then
		mount -o loop,ro "/home/${SSH_USER}/tools-manual/${PARALLELS_GUEST_TOOLS_ISO}" /mnt/tools
	else
		mount -o loop,ro "/home/${SSH_USER}/${PARALLELS_GUEST_TOOLS_ISO}" /mnt/tools
	fi

	apt-get install -y build-essential dkms

	/mnt/tools/"${PARALLELS_GUEST_TOOLS_INSTALLER}" --install-unattended
	umount /mnt/tools
	rmdir /mnt/tools
	printf -- 'Parallels Tools version %s\n' "$(prltoolsd  -V | cut -f 3 -d ' ')" > /tmp/guest-additions-version.txt
	rm -frv "/home/${SSH_USER:?}/${PARALLELS_GUEST_TOOLS_ISO:?}" "/home/${SSH_USER}/tools-manual" "/home/${SSH_USER}/.prlctl_version"
fi
