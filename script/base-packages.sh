#!/bin/sh -eu
printf -- '==> %s\n' 'Installing base packages'

apt-get -y install dkms nfs-common
