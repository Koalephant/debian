#!/bin/sh -eu

SSH_USER="${SSH_USERNAME:-vagrant}"


vmware_tools_source() {
	for dir; do
		if [ -d "${dir}" ]; then
			apt-get -y install automake make gobjc++ libtool pkg-config libmspack-dev libglib2.0-dev libpam0g-dev libssl-dev libxml2-dev libxmlsec1-dev libx11-dev libxext-dev libxinerama-dev libxi-dev libxrender-dev libxrandr-dev libxtst-dev libgdk-pixbuf2.0-dev libgtk-3-dev libgtkmm-3.0-dev
			cd "/home/${SSH_USER}/tools-manual/open-vm-tools/open-vm-tools/"
			autoreconf -i
			./configure --disable-dependency-tracking
			make
			make install

			ldconfig
			if ! systemctl list-unit-files open-vm-tools.service > /dev/null; then
				mkdir -p /usr/local/lib/systemd/system
				cat <<-'UNIT' > /usr/local/lib/systemd/system/open-vm-tools.service
				[Unit]
				Description=Service for virtual machines hosted on VMware
				Documentation=http://github.com/vmware/open-vm-tools
				After=network-online.target

				[Service]
				ExecStart=/usr/local/bin/vmtoolsd
				Restart=always
				TimeoutStopSec=5

				[Install]
				WantedBy=multi-user.target

				UNIT
			fi
			systemctl enable --now open-vm-tools.service
			apt-mark auto automake make gobjc++ libtool pkg-config libmspack-dev libglib2.0-dev libpam0g-dev libssl-dev libxml2-dev libxmlsec1-dev libx11-dev libxext-dev libxinerama-dev libxi-dev libxrender-dev libxrandr-dev libxtst-dev libgdk-pixbuf2.0-dev libgtk-3-dev libgtkmm-3.0-dev
			return 0
		fi
	done

	return 1
}

vmware_tools_iso() {
	for iso; do
		if [ -f "${iso}" ]; then
			printf -- '==> Installing Hypervisor Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"

			mkdir -p /mnt/tools
			mount -o loop,ro "${iso}" /mnt/tools

			toolsPath="$(find /mnt -name 'VMwareTools-*.tar.gz')"
			version="$(printf '%s' "${toolsPath}" | cut -f2 -d'-')"

			tar zxf "${toolsPath}" -C /tmp/
			if dpkg --compare-versions "${version}" lt 10; then
				/tmp/vmware-tools-distrib/vmware-install.pl -d
			else
				/tmp/vmware-tools-distrib/vmware-install.pl --force-install
			fi

			umount /mnt/tools
			rmdir /mnt/tools
			return 0
		fi
	done

	return 1
}

if [ "${PACKER_BUILDER_TYPE}" = 'vmware-iso' ]; then
	case "$(printf -- '%s' "${GUEST_TOOLS:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1)
			printf -- '==> Installing Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
		;;

		(*)
			printf -- '==> Skipping Guest Tools install for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- '- VMWare Tools not installed' > /tmp/guest-additions-version.txt
			exit 0
		;;
	esac


	case "$(printf -- '%s' "${GUEST_TOOLS_DISTRO:-}" | tr '[:upper:]' '[:lower:]')" in
		(true|yes|on|1|*vmware*)
			printf -- '==> Installing Distro Provided Guest Tools for %s\n' "${PACKER_BUILDER_TYPE}"
			printf -- 'Package: open-vm-tools open-vm-tools-dkms open-vm-tools-dev open-vm-tools-desktop\nPin: release a=%s\nPin-Priority: 500\n\n' "$(lsb_release -sc)-updates" "$(lsb_release -sc)-backports" > /etc/apt/preferences.d/open-vm-tools

			if apt-get -y install open-vm-tools && dpkg --compare-versions "$(apt-cache policy open-vm-tools | grep Installed | cut -f 3 -d ':')" lt 10; then
				printf -- '%s\n' open-vm-dkms open-vm-tools-dkms | xargs -n 1 apt-cache --generate pkgnames | xargs apt-get -y install
			else
				vmware_tools_source "/home/${SSH_USER}/tools-manual/open-vm-tools/open-vm-tools/"
			fi

			printf -- '- Open VM Tools (VMWare) version %s\n' "$(vmtoolsd -v | cut -d ' ' -f 5)" > /tmp/guest-additions-version.txt
			mkdir -p /mnt/hgfs
		;;
	esac

	if ! command -v vmware-toolbox-cmd > /dev/null; then
		if vmware_tools_iso "/home/${SSH_USER}/tools-manual/vmware-tools-lin.iso" "/home/${SSH_USER}/vmware-tools-lin.iso"; then
			printf -- '- VMWare Tools version %s\n' "$(vmware-toolbox-cmd -v | cut -d ' ' -f 1)" > /tmp/guest-additions-version.txt
		else
			vmware_tools_source "/home/${SSH_USER}/tools-manual/open-vm-tools/open-vm-tools/"
			printf -- '- Open VM Tools (VMWare) version %s\n' "$(vmtoolsd -v | cut -d ' ' -f 5)" > /tmp/guest-additions-version.txt
		fi
	fi

	rm -fvr "/home/${SSH_USER}/tools-manual/" "/home/${SSH_USER}/vmware-tools-lin.iso" "/tmp/vmware-tools-distrib/"

fi
