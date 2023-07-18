#!/bin/sh -eu

printf -- '==> %s\n' 'Configuring settings for vagrant'

SSH_USER="${SSH_USERNAME:-vagrant}"
SSH_USER_HOME="${SSH_USER_HOME:-/home/${SSH_USER}}"
VAGRANT_INSECURE_KEY='ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key'

# Tweak sshd to prevent DNS resolution (speed up logins)
printf -- '==> %s\n' 'Turning off DNS lookups for SSH Server'
sed -i -e 's/^#UseDNS no/UseDNS no/' /etc/ssh/sshd_config

# Packer passes boolean user variables through as '1', but this might change in
# the future, so also check for 'true'.
case "$(printf -- '%s' "${INSTALL_VAGRANT_KEY:-}" | tr '[:upper:]' '[:lower:]')" in
	(true|yes|on|1)
		printf -- '==> %s\n' 'Installing Vagrant SSH key'
		mkdir -pm 700 "${SSH_USER_HOME}/.ssh"
		# https://raw.githubusercontent.com/mitchellh/vagrant/master/keys/vagrant.pub
		printf -- '%s\n' "${VAGRANT_INSECURE_KEY}" > "${SSH_USER_HOME}/.ssh/authorized_keys"
		chmod 600 "${SSH_USER_HOME}/.ssh/authorized_keys"
		chown -R "${SSH_USER}:${SSH_USER}" "${SSH_USER_HOME}/.ssh"
	;;
esac
