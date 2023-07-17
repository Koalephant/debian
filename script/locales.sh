#!/bin/sh -eu

printf -- '==> %s\n' 'Installing all english Locales'

case "$(printf -- '%s' "${LOCALES_ALL:-}" | tr '[:upper:]' '[:lower:]')" in
	(true|yes|on|1)
		apt-get -y install "linux-headers-$(uname -r)"
	;;
esac
