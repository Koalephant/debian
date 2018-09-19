#!/bin/sh -eu

printf "==> %s\n" "Setting apt sources"

release="$(lsb_release -sc)"
add_apt_component() {
	printf "deb      %s    %s%s    main contrib\n" "${2:-$APT_MIRROR}" "${release}" "${1:-}"
	printf "deb-src  %s    %s%s    main contrib\n\n" "${2:-$APT_MIRROR}" "${release}" "${1:-}"
}

add_apt_component > /etc/apt/sources.list
add_apt_component "-updates" >> /etc/apt/sources.list
if [ "${APT_MIRROR}" = 'http://deb.debian.org/debian' ] || [ "${APT_MIRROR}" = 'https://deb.debian.org/debian' ]; then
	add_apt_component "/updates" "${APT_MIRROR}-security" >> /etc/apt/sources.list
else
	add_apt_component "/updates" 'http://security.debian.org/' >> /etc/apt/sources.list
fi

case "$(printf "%s" "${APT_BACKPORTS:-}" | tr '[:upper:]' '[:lower:]')" in
	true|yes|on|1)
		add_apt_component "-backports" >> /etc/apt/sources.list
	;;
esac

printf "==> %s\n" "Updating package index"
apt-get -y update