packer {
	required_plugins {
		parallels = {
			version	= ">= 1.0.1"
			source	= "github.com/hashicorp/parallels"
		}
		virtualbox = {
			version	= ">= 1.0.2"
			source	= "github.com/hashicorp/virtualbox"
		}
		vagrant = {
			version	= ">= 1.0.0"
			source	= "github.com/hashicorp/vagrant"
		}
		vmware = {
			version	= ">= 1.0.0"
			source	= "github.com/hashicorp/vmware"
		}
	}
}

variable "pugilist_box_dir" {
	type = string
}

variable "pugilist_box_file" {
	type = string
}

variable "pugilist_version_file" {
	type = string
}

variable "pugilist_provider" {
	type = string
}

variable "pugilist_release" {
	type = string
}

variable "pugilist_arch" {
	type = string
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

variable "virtualbox_guest_os_type" {
	type = string
}
variable "vmware_guest_os_type" {
	type = string
}

variable "vmware_hardware_version" {
	type = number
	default = 9
}

variable "vmware_nic_type" {
	type = string
	default = "e1000"
}

variable "vmware_disk_type" {
	type = string
	default = "ide"
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

variable "version" {
	type = string
	default = "0.1.0"
}

variable "version_description" {
	type = string
	default = ""
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

local "iso_urls" {
	expression = [
		local.iso_path_name,
		var.iso_url
	]
}

local "vmware_guest_tools_flavours" {
	expression = {
		"vmware" = "",
	}
}

local environment_vars {
	expression = [
		"APT_BACKPORTS=${var.apt_backports}",
		"APT_MIRROR=${var.apt_mirror}",
		"APT_UPDATES=${var.apt_updates}",
		"BOX_ORG=${var.vagrantcloud_org}",
		"BOX_VERSION=${var.version}",
		"GUEST_TOOLS=${var.guest_tools}",
		"GUEST_TOOLS_DISTRO=${var.guest_tools_distro}",
		"INSTALL_VAGRANT_KEY=${var.install_vagrant_key}",
		"LOCALES_ALL=${var.locales_all}",
		"MOTD=${var.motd}",
		"SSH_PASSWORD=${var.ssh_password}",
		"SSH_USERNAME=${var.ssh_username}",
		"UPDATE=${var.update}",
		"VM_NAME=${var.pugilist_release}",
		"VM_ARCH=${var.pugilist_arch}",
		"ftp_proxy=${var.ftp_proxy}",
		"http_proxy=${var.http_proxy}",
		"https_proxy=${var.https_proxy}",
		"no_proxy=${var.no_proxy}",
		"rsync_proxy=${var.rsync_proxy}"
	]
}

source "parallels-iso" "parallels" {
	boot_command	= local.boot_command
	cpus = var.cpus
	disk_size = var.disk_size
	guest_os_type = var.parallels_guest_os_type
	http_directory = local.http_dir
	iso_checksum	= "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	memory = var.memory
	output_directory = "output-${var.pugilist_release}-parallels-iso"
	parallels_tools_flavor = var.parallels_guest_tools
	parallels_tools_guest_path = "prl-tools-lin.iso"
	parallels_tools_mode = "upload"
	prlctl = [
		["set", "{{ .Name }}", "--shf-host-defined", "off"],
		["set", "{{ .Name }}", "--shared-profile", "off"],
		["set", "{{ .Name }}", "--sh-app-host-to-guest", "off"],
		["set", "{{ .Name }}", "--sh-app-guest-to-host", "off"],
		["set", "{{ .Name }}", "--shared-cloud", "off"],
		["set", "{{ .Name }}", "--smart-mount", "off"],
		["set", "{{ .Name }}", "--sync-host-printers", "off"],
		["set", "{{ .Name }}", "--auto-share-camera", "off"],
		["set", "{{ .Name }}", "--auto-share-bluetooth", "off"],
		["set", "{{ .Name }}", "--time-sync", "off"],
		["set", "{{ .Name }}", "--disable-timezone-sync", "on"],
		["set", "{{ .Name }}", "--autostop", "shutdown"]
	]
	prlctl_version_file = ".prlctl_version"
	shutdown_command = "sudo shutdown -h now"
	ssh_password = var.ssh_password
	ssh_timeout = "10000s"
	ssh_username = var.ssh_username
	vm_name = var.pugilist_release
}

source "virtualbox-iso" "virtualbox" {
	boot_command	= local.boot_command
	bundle_iso = true
	cpus = var.cpus
	disk_size = var.disk_size
	guest_additions_mode = "upload"
	guest_additions_path = "VBoxGuestAdditions.iso"
	guest_os_type = var.virtualbox_guest_os_type
	headless = var.headless
	http_directory = local.http_dir
	iso_checksum	= "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	memory = var.memory
	output_directory = "output-${var.pugilist_release}-virtualbox-iso"
	post_shutdown_delay = "1m"
	shutdown_command = "sudo shutdown -h now"
	ssh_password	= var.ssh_password
	ssh_timeout = "10000s"
	ssh_username	= var.ssh_username
	vrdp_bind_address = "0.0.0.0"
	vboxmanage = [
		["modifyvm", "{{ .Name }}", "--nat-localhostreachable1", "on"],
		["setextradata", "{{ .Name }}", "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled", "1"],
#		["storageattach", "{{ .Name }}", "--storagectl", "IDE Controller", "--port", "0", "--device", "1", "--type", "dvddrive", "--medium", "none"]
	]
	virtualbox_version_file = ".vbox_version"
	vm_name = var.pugilist_release
}

source "vmware-iso" "vmware" {
	boot_command	= local.boot_command
	cdrom_adapter_type = var.vmware_disk_type
	cpus = var.cpus
	disk_adapter_type = var.vmware_disk_type
	disk_size = var.disk_size
	guest_os_type = var.vmware_guest_os_type
	headless = var.headless
	http_directory = local.http_dir
	iso_checksum	= "${var.iso_checksum_type}:${var.iso_checksum}"
	iso_target_path = local.iso_path_name
	iso_urls = local.iso_urls
	memory = var.memory
	network = "nat"
	network_adapter_type = var.vmware_nic_type
	output_directory = "output-${var.pugilist_release}-vmware-iso"
	shutdown_command = "sudo shutdown -h now"
	ssh_password	= var.ssh_password
	ssh_timeout = "10000s"
	ssh_username	= var.ssh_username
	tools_upload_flavor = lookup(local.vmware_guest_tools_flavours, var.guest_tools_distro, "linux")
	tools_upload_path = "vmware-tools-lin.iso"
	version = var.vmware_hardware_version
	vnc_bind_address = "0.0.0.0"
	vm_name = var.pugilist_release
	vmx_data = {
		"suspend.disabled"	= true,
		"svga.autodetect" = true,
		"time.synchronize.continue" = "FALSE"
		"time.synchronize.restore" = "FALSE"
		"time.synchronize.resume.disk" = "FALSE"
		"time.synchronize.resume.host" = "FALSE"
		"time.synchronize.shrink" = "FALSE"
		"time.synchronize.tools.enable" = "FALSE"
		"time.synchronize.tools.startup" = "FALSE"
		"usb_xhci.present"	= true
	}
}

build {
	sources = [
		"source.parallels-iso.parallels",
		"source.virtualbox-iso.virtualbox",
		"source.vmware-iso.vmware"
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
		destination = "${var.pugilist_box_dir}/${var.pugilist_version_file}"
		direction = "download"
		source = "/tmp/guest-additions-version.txt"
	}

	provisioner "shell" {
		environment_vars = local.environment_vars
		execute_command	= local.script_command
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
			keep_input_artifact = false
			output = "${var.pugilist_box_dir}/${var.pugilist_box_file}"
			vagrantfile_template = var.vagrantfile_template
		}
	}

}
