#!/bin/sh -eu

printf -- '==> %s\n' 'Recording box generation date'
date > /etc/vagrant_box_build_date

printf -- "BOX_NAME='%s'\nBOX_SHORT_DESCRIPTION='%s'\nBOX_VERSION='%s'\nBOX_ARCH='%s'\nBOX_PROVIDER='%s'\nBOX_BUILD_DATE='%s'\n" \
		"${BOX_ORG}/${BOX_NAME}" "${BOX_SHORT_DESCRIPTION}" "${BOX_VERSION}" "${BOX_ARCH}" "${BOX_PROVIDER}" "$(date +%Y-%m-%d)" > /etc/vagrant-box-info

case "$(printf -- '%s' "${MOTD:-}" | tr '[:upper:]' '[:lower:]')" in
	(true|yes|on|1)

		printf -- '==> %s\n' 'Customizing message of the day'
		mkdir -p /etc/update-motd.d

		motd_original_release_file=/etc/update-motd.d/00-original-release

		cat <<-EOF  > "${motd_original_release_file}"
			#!/bin/sh -eu

			. /etc/vagrant-box-info

			printf -- '%-20s %s\n' \
				'Vagrant Box:' "\${BOX_NAME} \${BOX_VERSION} (\${BOX_ARCH}, \${BOX_PROVIDER})" \
				'Build Date:' "\${BOX_BUILD_DATE}" \
				'Build Description:' "\${BOX_SHORT_DESCRIPTION}"
		EOF

		chmod +x "${motd_original_release_file}"

		printf -- '==> %s\n' 'Ensuring /etc/motd is a symlink'
		ln -sfvT /var/run/motd /etc/motd
	;;

esac

if [ ! -e /etc/update-motd.d/10-uname ]; then
	printf -- '%s\n%s\n' '#!/bin/sh' 'uname -snrvm' > /etc/update-motd.d/10-uname
fi
