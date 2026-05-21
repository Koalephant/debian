boot_command_pre = [
	"<wait>e<wait><down><down><down><end><wait><bs><bs><bs><bs><bs><bs><bs><bs><bs><bs> <wait>",
]
boot_command_post = [
	" --- quiet",
	"<f10>"
]
parallels_guest_tools = "lin-arm"
parallels_guest_tools_iso = "prl-tools-lin-arm.iso"
vmware_hardware_version = 20
vmware_guest_os_type = "arm-debian-64"
vmware_disk_type = "sata"
vmware_nic_type = "e1000e"
virtualbox_guest_os_type = "Debian_arm64"
virtualbox_guest_arch = "arm"
virtualbox_gfx_controller = "vmsvga"
virtualbox_chipset = "armv8virtual"
virtualbox_firmware = "efi"
virtualbox_guest_tools_installer = "VBoxLinuxAdditions-arm64.run"
qemu_efi_firmware = "/opt/local/share/qemu/edk2-aarch64-code.fd"
qemu_system_binary = "qemu-system-aarch64"
