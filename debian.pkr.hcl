packer {
	required_plugins {
		parallels = {
			version = ">= 1.2.3"
			source = "github.com/hashicorp/parallels"
		}
		virtualbox = {
			version = ">= 1.1.1"
			source = "github.com/hashicorp/virtualbox"
		}
		vagrant = {
			version = ">= 1.0.0"
			source = "github.com/hashicorp/vagrant"
		}
		vmware = {
			version = ">= 1.0.0"
			source = "github.com/hashicorp/vmware"
		}
		qemu = {
			version = "~> 1"
			source  = "github.com/hashicorp/qemu"
		}
	}
}

variable "box_organisation" {
	type = string
	default = "koalephant"
}

variable "box_temp_dir" {
	type = string
}

local "box_build_dir" {
	expression = "${var.box_temp_dir}/build"
}

variable "box_output_dir" {
	type = string
}

variable "box_output_file" {
	type = string
}

variable "box_info_file" {
	type = string
}

local "box_info_template" {
	expression = {
		name = var.box_name,
		organisation = var.box_organisation,
		description = var.box_description,
		version = var.box_version,
		provider = var.box_provider,
		arch = var.box_arch,
		contact = "packaging@koalephant.com"
	}
}

variable "box_version_file" {
	type = string
}

variable "box_provider" {
	type = string
}

variable "box_name" {
	type = string
}

variable "box_arch" {
	type = string
}

variable "pugilist_rsync_base" {
	type = string
	default = "dal-web-01.koalephant.net:/srv/www/boxes.storage.koalephant.com/"
}

variable "pugilist_url_base" {
	type = string
	default = "https://boxes.storage.koalephant.com"
}

variable "pugilist_enable" {
	type = bool
	default = false
}

variable "apt_backports" {
	type = bool
	default = true
}

variable "apt_updates" {
	type = bool
	default = true
}

variable "apt_mirror" {
	type = string
	default = "https://deb.debian.org/debian"
}

variable "cpus" {
	type = number
	default = 1
}

variable "disk_size" {
	type = number
	default = 65536
}

variable "ftp_proxy" {
	type = string
	default = "${env("ftp_proxy")}"
}

variable "guest_tools" {
	type = bool
	default = true
}

variable "guest_tools_distro" {
	type = string
	default = "vmware"
}

variable "headless" {
	type = bool
	default = true
}

variable "http_proxy" {
	type = string
	default = "${env("http_proxy")}"
}

variable "https_proxy" {
	type = string
	default = "${env("https_proxy")}"
}

variable "install_vagrant_key" {
	type = bool
	default = true
}


variable "iso_path" {
	type = string
	default = "iso"
}

variable "iso_checksum_type" {
	type = string
	default = "file"
}

variable "iso_checksum" {
	type = string
	default = ""
}

variable "iso_name" {
	type = string
	default = ""
}
variable "iso_url" {
	type = string
	default = ""
}

variable "locales_all" {
	type = bool
	default = false
}

variable "memory" {
	type = number
	default = 1024
}

variable "motd" {
	type = bool
	default = true
}

variable "no_proxy" {
	type = bool
	default = false
}

variable "parallels_guest_os_type" {
	type = string
	default = "debian"
}

variable "parallels_guest_tools" {
	type = string
}

variable "parallels_guest_tools_iso" {
	type = string
	default = "prl-tools-lin.iso"
}

variable "parallels_guest_tools_installer" {
	type = string
	default = "install"
}

variable "virtualbox_guest_os_type" {
	type = string
	default = ""
}

variable "virtualbox_guest_arch" {
	type = string
	default = "x86"
}

variable "virtualbox_chipset" {
	type = string
	default = "ich9"
}

variable "virtualbox_firmware" {
	type = string
	default = "bios"
}

variable "virtualbox_gfx_controller" {
	type = string
	default = ""
}

variable "virtualbox_guest_tools_iso" {
	type = string
	default = "VBoxGuestAdditions.iso"
}

variable "virtualbox_guest_tools_installer" {
	type = string
	default = "VBoxLinuxAdditions.run"
}

variable "vmware_guest_os_type" {
	type = string
	default = ""
}

variable "vmware_guest_tools" {
	type = string
	default = "linux"
}

variable "vmware_guest_tools_iso" {
	type = string
	default = "vmware-tools-lin.iso"
}

variable "vmware_guest_tools_installer" {
	type = string
	default = "vmware-install.pl"
}


variable "vmware_hardware_version" {
	type = number
	default = 19
}

variable "vmware_nic_type" {
	type = string
	default = "e1000"
}

variable "vmware_disk_type" {
	type = string
	default = "ide"
}

variable "qemu_accelerator" {
	type = string
	default = "hvf"
}

variable "qemu_machine_type" {
	type = string
	default = "virt"
}

variable "qemu_system_binary" {
	type = string
	default = ""
}

variable "qemu_efi_firmware" {
	type = string
	default = ""
}

local "qemu_efi_vars" {
	expression = "${var.box_temp_dir}/efi-vars.raw"
}

variable "preseed" {
	type = string
	default = "preseed.cfg"
}

variable "rsync_proxy" {
	type = string
	default = "${env("rsync_proxy")}"
}

variable "ssh_password" {
	type = string
	default = "vagrant"
}

variable "ssh_username" {
	type = string
	default = "vagrant"
}

variable "ssh_timeout" {
	type = string
	default = "10000s"
}

variable "update" {
	type = bool
	default = true
}

variable "vagrantcloud_org" {
	type = string
	default = "${env("VAGRANT_CLOUD_ORG")}"
}

variable "vagrantcloud_token" {
	type = string
	default = "${env("VAGRANT_CLOUD_TOKEN")}"
}

variable "vagrantfile_template" {
	type = string
	default = "tpl/vagrantfile-koalephant.rb"
}

variable "box_version" {
	type = string
	default = "0.1.0"
}

variable "box_version_description" {
	type = list(string)
	default = []
}

variable "box_description" {
	type = string
	default = ""
}

variable "boot_command_pre" {
	type = list(string)
	default = []
}

variable "boot_command_post" {
	type = list(string)
	default = []
}

local "boot_command" {
	expression = concat(
		var.boot_command_pre,
		[
			"install auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/${var.preseed} ",
			"debian-installer=en_US.UTF-8 locale=en_US.UTF-8 keymap=us ",
			"netcfg/get_hostname=vagrant netcfg/get_domain=vm "
		],
		var.boot_command_post
	)
}

local "shutdown_command" {
	expression = "sudo shutdown -h now"
}

local "http_dir" {
	expression = "http"
}

local "script_command" {
	expression = "chmod +x {{ .Path }}; {{ .Vars }} sudo -E {{ .Path }}"
}

local "iso_path" {
	expression = abspath(var.iso_path)
}

local iso_path_name {
	expression = "${local.iso_path}/${var.iso_name}"
}

local checksum_path_name {
	expression = "file:${local.iso_path}/sha256sums"
}

local "iso_urls" {
	expression = [
		local.iso_path_name,
		var.iso_url
	]
}

local environment_vars {
	expression = [
		"APT_BACKPORTS=${var.apt_backports}",
		"APT_MIRROR=${var.apt_mirror}",
		"APT_UPDATES=${var.apt_updates}",
		"BOX_ORG=${var.vagrantcloud_org}",
		"BOX_VERSION=${var.box_version}",
		"BOX_PROVIDER=${var.box_provider}",
		"GUEST_TOOLS=${var.guest_tools}",
		"GUEST_TOOLS_DISTRO=${var.guest_tools_distro}",
		"INSTALL_VAGRANT_KEY=${var.install_vagrant_key}",
		"LOCALES_ALL=${var.locales_all}",
		"MOTD=${var.motd}",
		"SSH_PASSWORD=${var.ssh_password}",
		"SSH_USERNAME=${var.ssh_username}",
		"UPDATE=${var.update}",
		"VM_NAME=${var.box_name}",
		"VM_ARCH=${var.box_arch}",
		"PARALLELS_GUEST_TOOLS_ISO=${var.parallels_guest_tools_iso}",
		"PARALLELS_GUEST_TOOLS_INSTALLER=${var.parallels_guest_tools_installer}",
		"VIRTUALBOX_GUEST_TOOLS_INSTALLER=${var.virtualbox_guest_tools_installer}",
		"VIRTUALBOX_GUEST_TOOLS_ISO=${var.virtualbox_guest_tools_iso}",
		"VMWARE_GUEST_TOOLS_INSTALLER=${var.vmware_guest_tools_installer}",
		"VMWARE_GUEST_TOOLS_ISO=${var.vmware_guest_tools_iso}",
		"ftp_proxy=${var.ftp_proxy}",
		"http_proxy=${var.http_proxy}",
		"https_proxy=${var.https_proxy}",
		"no_proxy=${var.no_proxy}",
		"rsync_proxy=${var.rsync_proxy}"
	]
}

source "qemu" "qemu" {
	# Qemu args
	efi_boot = true
	display = "cocoa"
	efi_firmware_code = var.qemu_efi_firmware
	efi_firmware_vars = local.qemu_efi_vars
	accelerator = var.qemu_accelerator
	machine_type = var.qemu_machine_type
	cpu_model = "host"
	format = "qcow2"
	net_device = "virtio-net"
	disk_interface = "virtio"
	headless = false
	qemu_binary = var.qemu_system_binary
	# Basic VM args
	cpus = var.cpus
	memory = var.memory
	disk_size = var.disk_size
	# Installer args
	http_directory = local.http_dir
	iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	output_directory = local.box_build_dir
	# Commands
	boot_command = local.boot_command
	shutdown_command = local.shutdown_command
	# Communicator args
	ssh_password = var.ssh_password
	ssh_timeout = var.ssh_timeout
	ssh_username = var.ssh_username
	vm_name = "${var.box_name}-${var.box_arch}"
}

source "parallels-iso" "parallels" {
	# Parallels args
	prlctl_version_file = ".prlctl_version"
	parallels_tools_flavor = var.parallels_guest_tools
	parallels_tools_guest_path = var.parallels_guest_tools_iso
	parallels_tools_mode = "upload"
	guest_os_type = var.parallels_guest_os_type
	prlctl = [
		["set", "{{ .Name }}", "--shf-host-defined", "off"],
		["set", "{{ .Name }}", "--shared-profile", "off"],
		["set", "{{ .Name }}", "--sh-app-host-to-guest", "off"],
		["set", "{{ .Name }}", "--sh-app-guest-to-host", "off"],
		["set", "{{ .Name }}", "--shared-cloud", "off"],
		["set", "{{ .Name }}", "--smart-mount", "off"],
		["set", "{{ .Name }}", "--sync-host-printers", "off"],
		["set", "{{ .Name }}", "--auto-share-camera", "off"],
		["set", "{{ .Name }}", "--time-sync", "off"],
		["set", "{{ .Name }}", "--disable-timezone-sync", "on"],
		["set", "{{ .Name }}", "--autostop", "shutdown"]
	]
	# Basic VM args
	cpus = var.cpus
	memory = var.memory
	disk_size = var.disk_size
	# Installer args
	http_directory = local.http_dir
	iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	output_directory = local.box_build_dir
	# Commands
	boot_command = local.boot_command
	shutdown_command = local.shutdown_command
	# Communicator args
	ssh_password = var.ssh_password
	ssh_timeout = var.ssh_timeout
	ssh_username = var.ssh_username
	vm_name = "${var.box_name}-${var.box_arch}"
}

source "virtualbox-iso" "virtualbox" {
	# VirtualBox args
	firmware = var.virtualbox_firmware
	#chipset = var.virtualbox_chipset
	guest_additions_mode = "upload"
	guest_additions_path = var.virtualbox_guest_tools_iso
	guest_os_type = var.virtualbox_guest_os_type
	gfx_controller = var.virtualbox_gfx_controller
	gfx_vram_size = "22"
	hard_drive_interface = "virtio"
	iso_interface = "virtio"
	bundle_iso = true
	headless = var.headless
	vrdp_bind_address = "0.0.0.0"
	vboxmanage = [
		["modifyvm", "{{ .Name }}", "--chipset", var.virtualbox_chipset],
		["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
		["modifyvm", "{{.Name}}", "--audio-enabled", "off"],
		["modifyvm", "{{ .Name }}", "--boot1", "disk"],
		["modifyvm", "{{ .Name }}", "--boot2", "dvd"],
		["modifyvm", "{{ .Name }}", "--usb-xhci", "on"],
		["modifyvm", "{{ .Name }}", "--keyboard", "usb"],
		["modifyvm", "{{ .Name }}", "--mouse", "usb"],
		["setextradata", "{{ .Name }}", "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", "1"],
		["storagectl", "{{.Name}}", "--name", "IDE Controller", "--remove"],
	]
	# Basic VM args
	cpus = var.cpus
	disk_size = var.disk_size
	memory = var.memory
	# Installer args
	http_directory = local.http_dir
	iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	output_directory = local.box_build_dir
	# Commands
	post_shutdown_delay = "1m"
	boot_command = local.boot_command
	shutdown_command = local.shutdown_command
	# Communicator args
	ssh_password = var.ssh_password
	ssh_timeout = var.ssh_timeout
	ssh_username = var.ssh_username
	vm_name = "${var.box_name}-${var.box_arch}"
}

source "vmware-iso" "vmware" {
	# VMWare args
	cdrom_adapter_type = var.vmware_disk_type
	disk_adapter_type = var.vmware_disk_type
	guest_os_type = var.vmware_guest_os_type
	headless = var.headless
	network = "nat"
	network_adapter_type = var.vmware_nic_type
	tools_mode = "disable"
	tools_upload_flavor = var.vmware_guest_tools
	tools_upload_path = "vmware-tools-lin.iso"
	version = var.vmware_hardware_version
	vnc_bind_address = "0.0.0.0"
	vmx_data = {
		"suspend.disabled" = true,
		"svga.autodetect" = true,
		"time.synchronize.continue" = "FALSE"
		"time.synchronize.restore" = "FALSE"
		"time.synchronize.resume.disk" = "FALSE"
		"time.synchronize.resume.host" = "FALSE"
		"time.synchronize.shrink" = "FALSE"
		"time.synchronize.tools.enable" = "FALSE"
		"time.synchronize.tools.startup" = "FALSE"
		"usb_xhci.present" = true
	}
	# Basic VM args
	cpus = var.cpus
	memory = var.memory
	disk_size = var.disk_size
	# Installer args
	http_directory = local.http_dir
	iso_checksum = "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	output_directory = local.box_build_dir
	# Commands
	boot_command = local.boot_command
	shutdown_command = local.shutdown_command
	# Communicator args
	ssh_password = var.ssh_password
	ssh_timeout = var.ssh_timeout
	ssh_username = var.ssh_username
	vm_name = "${var.box_name}-${var.box_arch}"
}

build {
	sources = [
		"source.parallels-iso.parallels",
		"source.virtualbox-iso.virtualbox",
		"source.vmware-iso.vmware",
		"source.qemu.qemu"
	]

	provisioner "shell-local" {
		inline = [
			"mkdir -p tools-manual",
		]
		pause_before = "10s"
	}

	provisioner "file" {
		destination = "/home/vagrant"
		source = "tools-manual"
		generated = true
	}

	provisioner "shell" {
		environment_vars = local.environment_vars
		execute_command = local.script_command
		expect_disconnect = true
		scripts = [
			"script/set-apt-sources.sh",
			"script/base-packages.sh",
			"script/systemd.sh",
			"script/grub.sh",
			"script/lvm.sh",
			"script/linux-headers.sh",
			"script/update.sh",
		]
		skip_clean = true
	}

	provisioner "shell" {
		environment_vars = local.environment_vars
		execute_command = local.script_command
		pause_before = "10s"
		scripts = [
			"script/motd.sh",
			"script/locales.sh",
			"script/vagrant.sh",
			"script/vmware.sh",
			"script/virtualbox.sh",
			"script/parallels.sh",
		]
	}

	provisioner "file" {
		destination = "${var.box_output_dir}/${var.box_version_file}"
		direction = "download"
		source = "/tmp/guest-additions-version.txt"
	}

	provisioner "shell" {
		environment_vars = local.environment_vars
		execute_command = local.script_command
		expect_disconnect = true
		scripts = [
			"script/zero-prepare.sh",
			"script/minimize.sh",
			"script/cleanup.sh",
		]
	}

	provisioner "shell" {
		environment_vars = local.environment_vars
		execute_command = local.script_command
		scripts = [
			"script/zero.sh"
		]
	}

	post-processors {
		post-processor "vagrant" {
			output = "${var.box_output_dir}/${var.box_output_file}"
			vagrantfile_template = var.vagrantfile_template

		}
	}

}
