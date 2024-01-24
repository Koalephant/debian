#!/bin/sh -eu
printf -- '==> %s\n' 'Installing Linux Headers'
apt-get -y install "$(dpkg --list 'linux-image*' | grep -F 'ii' | grep -F 'meta-package' | xargs | cut -d' ' -f 2 | sed -e 's/image/headers/')"
