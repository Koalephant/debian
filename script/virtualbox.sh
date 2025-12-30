#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"

install_from_iso() {
	# shellcheck disable=SC2039,SC3043
	local iso="$1" tempdir

	apt-get install -y build-essential perl dkms
	mkdir -p /mnt/tools
	mount -o loop,ro "$iso" /mnt/tools
	retCode=0

	tempdir="$(mktemp -d)"

	/mnt/tools/"${VIRTUALBOX_GUEST_TOOLS_INSTALLER}" --nox11 --noexec --target "$tempdir"

	umount /mnt/tools
	rmdir /mnt/tools

	cd "${tempdir}"
	sh "install.sh" || retCode="$?"

	if [ ${retCode} -eq 1 ]; then
		printf -- 'VirtualBox Guest Additions installation failed\n' >&2
		exit 1
	fi
	cd "/"
	rm -rf "${tempdir}"
}

if [ "${PACKER_BUILDER_TYPE}" = 'virtualbox-iso' ]; then

	if [ -d /sys/firmware/efi ]; then
		printf -- '==> Copying EFI boot manager to fallback position because VirtualBox EFI is flaky\n'
		(
			cd /boot/efi/EFI
			mkdir -p boot
			for f in debian/grub*.efi; do
				if [ -f "$f" ]; then
					cp "$f" "boot/boot${f#debian/grub}"
				fi
			done
		)
	fi

	case "$(printf -- '%s' "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- 'VirtualBox Guest Additions not installed\n' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac

	case "$(printf -- '%s' "${GUEST_TOOLS_DISTRO:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1|*virtualbox*)
			printf -- '==> Installing Distro Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- 'Package: virtualbox-guest-utils virtualbox-guest-dkms virtualbox-guest-additions-iso\nPin: release a=%s\nPin-Priority: 500\n\n' "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/virtualbox-additions

			if apt-cache policy virtualbox-guest-utils | grep 'Candidate: [[:digit:]]' > /dev/null; then
				apt-get -y install virtualbox-guest-utils virtualbox-guest-dkms
			elif apt-cache policy virtualbox-guest-additions-iso | grep 'Candidate: [[:digit:]]' > /dev/null; then
				apt-get -y install virtualbox-guest-additions-iso
				install_from_iso "/usr/share/virtualbox/VBoxGuestAdditions.iso"
				apt-get -y purge virtualbox-guest-additions-iso
			fi
		;;
	esac


	if ! command -v VBoxControl > /dev/null; then
		printf -- '==> Installing Hypervisor Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		if [ -f "/home/${SSH_USER}/tools-manual/${VIRTUALBOX_GUEST_TOOLS_ISO}" ]; then
			install_from_iso "/home/${SSH_USER}/tools-manual/${VIRTUALBOX_GUEST_TOOLS_ISO}"
		else
			install_from_iso "/home/${SSH_USER}/${VIRTUALBOX_GUEST_TOOLS_ISO}"
		fi
	fi

	if ! command -v VBoxControl > /dev/null || ! modinfo vboxsf > /dev/null 2>&1; then
		printf -- '==> Virtualbox guest additions install failed'
		exit 1
	fi

	printf -- 'VirtualBox Guest Additions version %s\n' "$(VBoxControl -v)" > /tmp/guest-additions-version.txt
	rm -frv "/home/${SSH_USER:?}/${VIRTUALBOX_GUEST_TOOLS_ISO:?}" "/home/${SSH_USER}/tools-manual/" "/home/${SSH_USER}/.vbox_version"
fi
