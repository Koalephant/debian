#!/bin/sh -eu

printf -- '==> %s\n' 'Recording box generation date'
date > /etc/vagrant_box_build_date

case "$(printf -- '%s' "${MOTD:-}" | tr '[:upper:]' '[:lower:]')" in
	(true|yes|on|1)

		printf -- '==> %s\n' 'Customizing message of the day'
		mkdir -p /etc/update-motd.d

		motd_original_release_file=/etc/update-motd.d/00-original-release

		printf -- '%s\n%s \\\n' '#!/bin/sh -eu' "printf -- '%-20s %s\\n'" > ${motd_original_release_file}

		printf -- '\t%s \\\n' "'Vagrant Box:' '$(printf -- '%s %s (%s)' "${BOX_ORG}/${VM_NAME}" "${BOX_VERSION}" "${PACKER_BUILD_NAME}")'" >> ${motd_original_release_file}
		printf -- '\t%s \\\n' "'Build Date:' '$(date +%Y-%m-%d)'" >> ${motd_original_release_file}
		printf -- '\t%s \n' "'Build Release:' '$(lsb_release -sd)'" >> ${motd_original_release_file}
		printf -- '\n' >> ${motd_original_release_file}

		motd_current_version_file=/etc/update-motd.d/01-current-version
		printf -- '%s\n%s \\\n' '#!/bin/sh -eu' "printf -- '%-20s %s\n'" > ${motd_current_version_file}
		printf -- '\t%s \n' "'Current Release:' \"\$(lsb_release -sd)\"" >> ${motd_current_version_file}
		printf -- '\n' >> ${motd_current_version_file}

		chmod +x ${motd_original_release_file} ${motd_current_version_file}

		printf -- '==> %s\n' 'Ensuring /etc/motd is a symlink'
		ln -sfvT /var/run/motd /etc/motd
	;;

esac

if [ ! -e /etc/update-motd.d/10-uname ]; then
	printf -- '%s\n%s\n' '#!/bin/sh' 'uname -snrvm' > /etc/update-motd.d/10-uname
fi
