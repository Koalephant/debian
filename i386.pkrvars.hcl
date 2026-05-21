boot_command = [
	"<esc><wait>",
	"install auto=true priority=critical url=http://{{ .HTTPIP }}:{{ .HTTPPort }}/preseed.cfg ",
	"debian-installer=en_US.UTF-8 locale=en_US.UTF-8 keymap=us ",
	"netcfg/get_hostname=vagrant netcfg/get_domain=vm ",
	"vga=normal fb=false ",
	"<enter>"
]
parallels_guest_tools = "lin"
virtualbox_guest_os_type = "Debian"
qemu_system_binary = "qemu-system-i386"
