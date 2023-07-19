#!/bin/sh

set -eu

box() {
	cd "${0%/*}"


	get_mapped_arch() {
		# shellcheck disable=SC2039
		local arch
		arch="$(uname -m)"
		case "${arch}" in
			(x86_64)
				arch='amd64'
			;;
			(i686)
				arch='i386'
			;;
			(aarch64_be|aarch64|armv8b|armv8l)
				arch='arm64'
			;;
		esac

		printf -- '%s' "${arch}"
	}

	# shellcheck disable=SC2039
	local DEFAULT_ARCH DEFAULT_RELEASES DEFAULT_BUILDERS DEFAULT_BOX_DIR
	readonly DEFAULT_ARCH="$(get_mapped_arch)"
	readonly DEFAULT_RELEASES='10 11 12'
	readonly DEFAULT_BUILDERS='parallels vmware virtualbox'
	readonly DEFAULT_BOX_DIR="${0%/*}/boxes"


	# shellcheck disable=SC2039
	local arch="${ARCH:-$DEFAULT_ARCH}" releases="${RELEASES:-$DEFAULT_RELEASES}" release builders="${BUILDERS:-$DEFAULT_BUILDERS}" boxDir="${BOX_DIR:-$DEFAULT_BOX_DIR}" dryRun="${DRY_RUN:-false}"

	# shellcheck disable=SC2039
	local OP_GROUP_GLOBAL OP_GROUP_BOX OP_GROUP_RELEASE
	readonly OP_GROUP_GLOBAL='global'
	readonly OP_GROUP_BOX='box'
	readonly OP_GROUP_RELEASE='release'


	# shellcheck disable=SC2039
	local OP_ADD OP_BUILD OP_PRINT_DESCRIPTION OP_PRINT_BOX OP_DESCRIPTION OP_CHECKSUM OP_VERIFY OP_BUILDERS OP_PREPARE

	readonly OP_ADD='add'
	readonly OP_BUILD='build'
	readonly OP_PRINT_DESCRIPTION='print-description'
	readonly OP_PRINT_BOX='print-box'
	readonly OP_DESCRIPTION='description'
	readonly OP_CHECKSUM='checksum'
	readonly OP_VERIFY='verify'
	readonly OP_BUILDERS='builders'
	readonly OP_PREPARE='prepare'

	export PYTHONPATH=/Library/Frameworks/ParallelsVirtualizationSDK.framework/Versions/10/Libraries/Python/3.7

	log_status() {
		# shellcheck disable=SC2039
		local format="$1"
		shift

		# shellcheck disable=SC2059
		printf -- "${format}\n" "$@" >&2
	}

	run_command() {
		if [ "${dryRun}" = 'true' ]; then
			printf -- '%s\n' "$*" > /dev/tty
		else
			# shellcheck disable=SC2016
			#printf -- 'Running command `%s`\n' "$*" >&2
			"$@"
		fi
	}

	run_command_redirect_output() {
		# shellcheck disable=SC2039
		local output
		output="$1"
		shift

		if [ "${dryRun}" = 'true' ]; then
			printf -- '%s > %s\n' "$*" "${output}" > /dev/tty
		else
			# shellcheck disable=SC2016
			#printf -- 'Running command `%s > %s`\n' "$*" "${output}"
			"$@" > "${output}"
		fi
	}


	map_provider_name() {
		case "$1" in
			(vmware)
				printf -- '%s' 'vmware_desktop'
			;;

			(*)
				printf -- '%s' "$1"
			;;
		esac
	}

	map_builder_name() {
		# shellcheck disable=SC2039
		local builder="$1"
		printf -- '%s-iso.*' "${builder}"
	}

	read_packer_var() {
		# shellcheck disable=SC2039
		local release="$1"
		packer console -var-file "debian${release}-${arch}.pkrvars.hcl" 'debian.pkr.hcl'
	}

	check_packer_builder() {
		# shellcheck disable=SC2039
		local builder="$1"
		case "${builder}" in
			(parallels)
				command -v prlctl >/dev/null
			;;

			(vmware)
				command -v vmrun >/dev/null
			;;

			(virtualbox)
				command -v vboxmanage >/dev/null
			;;
		esac
	}

	get_packer_builders() {
		# shellcheck disable=SC2039
		local builder fmt='%s';

		for builder; do
			if check_packer_builder "${builder}"; then
				# shellcheck disable=SC2059
				printf -- "$fmt" "$(map_builder_name "${builder}")"
				fmt=',%s'
			fi
		done
		printf -- '\n'
	}

	get_release_version() {
		# shellcheck disable=SC2039
		local release="$1" version

		# shellcheck disable=SC2016
		version="$(printf -- '"${var.version}"' | read_packer_var "${release}")"
		if [ -z "${version}" ]; then
			log_status 'No Box version found for release debian%d' "${release}" >&2
			return 1
		fi

		printf -- '%s' "${version}"
	}

	checksum_boxes() {
		# shellcheck disable=SC2039
		local dir="$1" filename="${2}"
		shift 2
		log_status 'Generating Box checksums using SHA256'
		(
			run_command cd "$dir"
			if [ -z "${filename}" ]; then
				run_command shasum -b -a 256 "$@"
			else
				run_command_redirect_output "${filename}.sha256sum" shasum -b -a 256 "$@"
			fi
		)
	}

	verify_boxes() {
		# shellcheck disable=SC2039
		local dir="$1"
		shift
		log_status 'Verifying Box checksums using SHA256'
		(
			run_command cd "${dir}"
			run_command shasum -c "boxes.sha256sum"
		)
	}

	do_box_operation() {
		# shellcheck disable=SC2039
		local  operation="$1" release="$2" version="$3" provider="$4" releaseDir boxFileName versionFileName
		releaseDir="${boxDir}/debian${release}-${arch}/${version}"
		boxFileName="${provider}.box"
		versionFileName="${provider}.version"
		boxFile="${releaseDir}/${boxFileName}"

		case "${operation}" in
			("${OP_ADD}")
				log_status 'Adding %s box for debian%d-%s (v%s)' "${provider}" "${release}" "${arch}" "${version}"
				run_command vagrant box add -f --provider "$(map_provider_name "${provider}")" --name "koalephant/debian${release}-${arch}-test" "${boxFile}"
			;;

			("${OP_BUILD}")
				run_command packer build -var "box_path=${boxDir}" -var-file="debian-${arch}.pkrvars.hcl" -var-file "debian${release}-${arch}.pkrvars.hcl" -only "$(get_packer_builders "${provider}")" 'debian.pkr.hcl'
			;;

			("${OP_CHECKSUM}")
				checksum_boxes "${releaseDir}" '' "${boxFile}"
			;;

			("${OP_PRINT_BOX}")
				printf -- '%s\n' "${boxFileName}"
			;;

			("${OP_PRINT_DESCRIPTION}")
				cat "${releaseDir}/${versionFileName}"
			;;

			(help|-h|--help|*)
				usage "${OP_GROUP_BOX}"
				exit 0
			;;

		esac
	}

	do_box_loop() {
		# shellcheck disable=SC2039
		local release operation="$1" version
		shift

		for release; do
			version="$(get_release_version "${release}")"
			for provider in ${builders}; do
				do_box_operation "${operation}" "${release}" "${version}" "${provider}"
			done
		done
	}

	do_release_operation() {
		# shellcheck disable=SC2039
		local operation="$1" release="$2" provider version='' releaseDir releaseDirRelative descriptionFile

		version="$(get_release_version "${release}")"
		releaseDirRelative="debian${release}-${arch}/${version}"
		releaseDir="${boxDir}/${releaseDirRelative}"
		descriptionFile="${releaseDir}/version-description.md"


		read_description() {
			# shellcheck disable=SC2016
			printf -- '"${var.box_description}\\n${var.version_description}"' | read_packer_var "${release}"
			do_box_loop "${OP_PRINT_DESCRIPTION}" "${release}"
		}

		case "${operation}" in
			("${OP_BUILD}")
				# shellcheck disable=SC2086
				run_command packer build -var "box_path=${boxDir}" -var-file="debian-${arch}.pkrvars.hcl" -var-file "debian${release}-${arch}.pkrvars.hcl" -only "$(get_packer_builders ${builders})" 'debian.pkr.hcl'
				run_command_redirect_output "${descriptionFile}" read_description
			;;

			("${OP_CHECKSUM}")
				# shellcheck disable=SC2046
				checksum_boxes "${releaseDir}" 'boxes' $(printf -- '%s.box ' ${builders})
			;;

			("${OP_DESCRIPTION}")
				# shellcheck disable=SC2046,SC2016
				run_command_redirect_output "${descriptionFile}" read_description
			;;

			("${OP_PRINT_BOX}")
				# shellcheck disable=SC2046,SC2086
				printf -- "${releaseDirRelative}/%s.box\n" ${builders}
			;;

			("${OP_PRINT_DESCRIPTION}")
				read_description
			;;


			("${OP_VERIFY}")
				verify_boxes "${releaseDirRelative}"
			;;

			(help|-h|--help|*)
				usage "${OP_GROUP_RELEASE}"
				exit 0
			;;

		esac
	}

	do_release_loop() {
		# shellcheck disable=SC2039
		local release operation="$1"
		shift

		for release; do
			do_release_operation "${operation}" "${release}"
		done
	}


	do_global_op() {
		# shellcheck disable=SC2039
		local operation="$1"
		case "${operation}" in
			("${OP_BUILD}")
				# shellcheck disable=SC2086
				do_release_loop "${OP_BUILD}" ${releases}
				do_global_op "${OP_CHECKSUM}"
			;;

			("${OP_CHECKSUM}")
				# shellcheck disable=SC2046,SC2086
				checksum_boxes "${boxDir}" 'boxes' $(do_release_loop "${OP_PRINT_BOX}" ${releases})
			;;


			("${OP_VERIFY}")
				verify_boxes "${boxDir}"
			;;

			("${OP_PRINT_BOX}")
				# shellcheck disable=SC2046,SC2086
				printf -- "${boxDir}/%s\n" $(do_release_loop "${OP_PRINT_BOX}" ${releases})
			;;

			("${OP_PREPARE}")
				run_command packer init 'debian.pkr.hcl'
				run_command mkdir -p 'tools-manual'
				if ! [ -d 'tools-manual/open-vm-tools' ]; then
					run_command git clone 'https://github.com/vmware/open-vm-tools.git' 'tools-manual/open-vm-tools'
				fi
			;;

			("${OP_BUILDERS}")
				# shellcheck disable=SC2086
				get_packer_builders ${builders}
			;;

			(help|-h|--help|*)
				usage
				exit 0
			;;
		esac
	}

	usage() {
		# shellcheck disable=SC2039
		local group="${1:-$OP_GROUP_GLOBAL}"

		invocation() {
			# shellcheck disable=SC2039
			local groupLine="$1"
			printf -- 'usage: [Env Vars] box.sh %s OPERATION\n\n' "$groupLine"
		}

		global_ops() {
			cat <<-EOT
			Operations:

			 ${OP_BUILD}                       Build all release artifacts and boxes, and generate a new checksum of .box files
			 ${OP_BUILDERS}                    List the available builders
			 ${OP_CHECKSUM}                    Generate a checksum of all .box files
			 ${OP_VERIFY}                      Verify all .box files against an existing checksum
			 ${OP_PRINT_BOX}                   Show the box file names for the selected releases
			 ${OP_PREPARE}                     Prepare the environment to build boxes

			EOT
		}

		release_ops() {
			cat <<-EOT
			Release Operations:

			 release ${OP_BUILD}               Build boxes & description file for each release
			 release ${OP_CHECKSUM}            Generate a checksum of release .box files
			 release ${OP_DESCRIPTION}         Write description file for each release
			 release ${OP_PRINT_BOX}           Show the box file names for the selected releases, relative to the box directory
			 release ${OP_PRINT_DESCRIPTION}   Show the descriptions for selected releases
			 release ${OP_VERIFY}              Verify release .box files against an existing checksum

			EOT
		}

		box_ops() {
			cat <<-EOT
			Box Operations:

			 box ${OP_ADD}                     Add box files to Vagrant with '-test' suffix for use in the 'test-vagrant' directory Vagrant environment
			 box ${OP_BUILD}                   Build boxes
			 box ${OP_CHECKSUM}                Print checksum of .box files
			 box ${OP_PRINT_BOX}               Show the .box file names for the selected releases, relative to each release directory
			 box ${OP_PRINT_DESCRIPTION}       Show the descriptions for selected boxes

			EOT
		}



		case "${group}" in
			("${OP_GROUP_GLOBAL}")
				invocation "[${OP_GROUP_RELEASE}|${OP_GROUP_BOX}]"
				global_ops
				release_ops
				box_ops
			;;

			("${OP_GROUP_RELEASE}")
				invocation "${OP_GROUP_RELEASE}"
				release_ops
			;;

			("${OP_GROUP_BOX}")
				invocation "${OP_GROUP_BOX}"
				box_ops
			;;
		esac


		cat <<-EOT
			Environment Vars

			 ARCH - specify the architecture to build for. Defaults to the machine architecture, which is '${DEFAULT_ARCH}' on this machine
			 RELEASES - specify the releases to build, as a space-separated list. Defaults to '${DEFAULT_RELEASES}'
			 BUILDERS - specify the builders to use, as a space separated list. Defaults to '${DEFAULT_BUILDERS}'
			 BOX_DIR - specify the dir for box files to be stored. Defaults to '${DEFAULT_BOX_DIR}'

		EOT
	}

	do_operation() {
		# shellcheck disable=SC2039
		local operation="${1}" group="${OP_GROUP_GLOBAL}"
		shift

		case "${operation}" in
			("${OP_GROUP_BOX}"|"${OP_GROUP_RELEASE}")
				group="${operation}"
				operation="${1:-help}"
			;;
		esac

		case "${group}" in
			("${OP_GROUP_GLOBAL}")
				do_global_op "${operation}"
			;;

			("${OP_GROUP_RELEASE}")
				# shellcheck disable=SC2086
				do_release_loop "${operation}" ${releases}
			;;

			("${OP_GROUP_BOX}")
				# shellcheck disable=SC2086
				do_box_loop "${operation}" ${releases}
			;;
		esac
	}

	if [ "$#" -eq 0 ]; then
		set -- 'help'
	fi

	do_operation "$@"

}

box "$@"
