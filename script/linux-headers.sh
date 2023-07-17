#!/bin/sh -eu
printf -- '==> %s\n' 'Installing Linux Headers'
apt-get -y install "linux-headers-$(uname -r)"
