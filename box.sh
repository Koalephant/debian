#!/bin/sh

set -eu

box() {
	# shellcheck disable=SC2039
	local DEFAULT_ARCH DEFAULT_RELEASES DEFAULT_BUILDERS
	readonly DEFAULT_ARCH="$(arch)"
	readonly DEFAULT_RELEASES='10 11 12'
	readonly DEFAULT_BUILDERS='parallels vmware virtualbox'


	# shellcheck disable=SC2039
	local arch="${ARCH:-$DEFAULT_ARCH}" releases="${RELEASES:-$DEFAULT_RELEASES}" release builders="${BUILDERS:-$DEFAULT_BUILDERS}"

	# shellcheck disable=SC2039
	local OP_ADD OP_BOXES OP_BUILD OP_PRINT_BOX_FILE OP_PRINT_BOX_DESCRIPTION OP_PRINT_DESCRIPTION OP_PRINT_BOX \
		OP_DESCRIPTION OP_PRINT_DESCRIPTION_FILE \
		OP_CHECKSUM OP_CHECK OP_BUILDERS

	readonly OP_ADD='add'
	readonly OP_BOXES='boxes'
	readonly OP_BUILD='build'
	readonly OP_PRINT_BOX_FILE='print-box-file'
	readonly OP_PRINT_DESCRIPTION='print-description'
	readonly OP_PRINT_BOX_DESCRIPTION='print-box-description'
	readonly OP_PRINT_BOX='print-box'
	readonly OP_DESCRIPTION='description'
	readonly OP_PRINT_DESCRIPTION_FILE='print-description-file'
	readonly OP_CHECKSUM='checksum'
	readonly OP_CHECK='check'
	readonly OP_BUILDERS='builders'

	export PYTHONPATH=/Library/Frameworks/ParallelsVirtualizationSDK.framework/Versions/10/Libraries/Python/3.7

	# shellcheck disable=SC2039
	local operation

	log_status() {
		# shellcheck disable=SC2039
		local format="$1"
		shift

		printf -- "${format}\n" "$@" >&2
	}

	get_provider_name() {
		case "$1" in
			(vmware)
				printf -- '%s' 'vmware_desktop'
			;;

			(*)
				printf -- '%s' "$1"
			;;
		esac
	}

	get_builder_name() {
		# shellcheck disable=SC2039
		local builder="$1"
		printf -- '%s-iso.*' "${builder}"
	}

	read_packer_var () {
		packer console -var-file "debian${release}-${arch}.pkrvars.hcl" 'debian.pkr.hcl'
	}

	get_packer_var() {
		 # shellcheck disable=SC2016
		 printf -- '"${var.%s}"' "$1"  | read_packer_var
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

		for builder in ${builders}; do
			if check_packer_builder "${builder}"; then
				# shellcheck disable=SC2059
				printf -- "$fmt" "$(get_builder_name "${builder}")"
				fmt=',%s'
			fi
		done
		printf -- '\n'
	}

	get_version_file_template() {
		# shellcheck disable=SC2039
		local release="$1" version="$2" extension="$3"
		printf -- 'box/debian%d-%s/%s/%%s.%s' "${release}" "${arch}" "${version}" "${extension}"
	}

	get_version_file() {
		# shellcheck disable=SC2039
		local release="$1" version="$2" extension="$3"
		shift 3
		# shellcheck disable=SC2059
		printf -- "$(get_version_file_template "${release}" "${version}" "${extension}")\n" "$@"
	}

	get_box_providers() {
		# shellcheck disable=SC2039
		local release="$1" version="$2" file

		for file in "box/debian${release}-${arch}/${version}/"*.box; do
			if [ -f "${file}" ]; then
				basename "${file}" .box
			fi
		done
	}

	do_box_operation() {
		# shellcheck disable=SC2039
		local  boxOp="$1" release="$2" version="$3" provider="$4"
		boxFile="$(get_version_file "${release}" "${version}" "box" "${provider}")"

		case "${boxOp}" in
			("${OP_ADD}")
				log_status 'Adding %s box for debian%d-%s (v%s)' "${provider}" "${release}" "${arch}" "${version}"
				vagrant box add -f --provider "$(get_provider_name "${provider}")" --name "koalephant/debian${release}-${arch}-test" "${boxFile}"
			;;

			("${OP_PRINT_BOX_FILE}")
				printf -- '%s\n' "${boxFile}"
			;;

			("${OP_PRINT_BOX_DESCRIPTION}")
				cat "$(get_version_file "${release}" "${version}" 'version' "${provider}")"
			;;

			("${OP_PRINT_BOX}")
				printf -- '%s\n' "${boxFile#box/}"
			;;
		esac
	}

	do_release_operation() {
		# shellcheck disable=SC2039
		local releaseOp="$1" boxOp="$2" release="$3" version='' provider


#		get_version() {
#			# shellcheck disable=SC2038
#			find "box/debian${release}-${arch}" -type d -depth 1 | xargs basename | sort -r | head -n1
#		}

		read_version() {
			# shellcheck disable=SC2038
			if [ -z "${version:-}" ]; then
				version="$(get_packer_var 'version')"
			fi

			if [ -z "${version}" ]; then
				log_status 'No Box version found for release debian%d' "${release}" >&2
				return 1
			fi
		}

		read_description() {
			printf -- '"${var.box_description}\\n${var.version_description}"' | read_packer_var
			do_release_operation '' "${OP_PRINT_BOX_DESCRIPTION}" "${release}" "${version}" "${provider}"
		}

		version_description_file() {
			get_version_file "${release}" "${version}" 'md' 'version-description'
		}

		case "${releaseOp}" in
			("${OP_BOXES}")
				# shellcheck disable=SC2086
				packer build -var-file="debian-${arch}.pkrvars.hcl" -var-file "debian${release}-${arch}.pkrvars.hcl" -only "$(get_packer_builders)" 'debian.pkr.hcl'
				version=''
			;;

			("${OP_PRINT_DESCRIPTION}")
				read_description
			;;

			("${OP_DESCRIPTION}")
				read_version
				log_status 'Generating version description for debian%s-%s' "${release}" "${arch}"
				# shellcheck disable=SC2046,SC2016
				read_description > "$(version_description_file)"
			;;

			("${OP_PRINT_DESCRIPTION_FILE}")
				read_version
				version_description_file
			;;
		esac

		if [ -n "${boxOp}" ]; then
			read_version
			for provider in $(get_box_providers "${release}" "${version}"); do
				do_box_operation "$boxOp" "${release}" "${version}" "${provider}"
			done
		fi
	}

	checksum_boxes() {
		# shellcheck disable=SC2039
		local algo="$1"
		shift
		log_status 'Generating Box checksums using SHA%d' "$algo"
		(
			cd box
			shasum -b -a "$algo" "$@" > "boxes.sha${algo}sum"
		)
	}

	check_boxes() {
		# shellcheck disable=SC2039
		local algo="$1"
		shift
		log_status 'Verifying Box checksums using SHA%d' "$algo"
		(
			cd box
			shasum -c "boxes.sha${algo}sum"
		)
	}

	do_global_op() {
		# shellcheck disable=SC2039
		local globalOp="$1"
		case "${globalOp}" in
			("${OP_CHECKSUM}")
				# shellcheck disable=SC2046
				checksum_boxes 256 $(do_operation "${OP_PRINT_BOX}")
			;;

			("${OP_CHECK}")
				check_boxes 256
			;;

			("${OP_BUILDERS}")
				get_packer_builders
			;;

		esac
	}

	usage() {
		cat <<-EOT
			usage: box.sh operations...

			Operations:

			 help                      Show this help
			 ${OP_BUILD}                     Build all boxes and description files. The same as specifying '${OP_BOXES} ${OP_DESCRIPTION}'
			 ${OP_ADD}                       Add box files to Vagrant with '-test' suffix for use in the 'test-vagrant' directory Vagrant environment
			 ${OP_PRINT_BOX}                 Show the box file names relative to the box directory
			 ${OP_PRINT_BOX_FILE}            Show the box file name relative
			 ${OP_PRINT_BOX_DESCRIPTION}     Show the descriptions for selected boxes
			 ${OP_DESCRIPTION}               Record the descriptions for selected releases in 'version-description.md' files
			 ${OP_PRINT_DESCRIPTION}         Show the descriptions for selected releases
			 ${OP_BOXES}                     Generate the boxes using 'packer'
			 ${OP_CHECKSUM}                  Generate checksums
			 ${OP_CHECK}                     Verify box files against existing checksums
			 ${OP_BUILDERS}                  List the selected and available builders

		EOT
	}

	do_operation() {
		# shellcheck disable=SC2039
		local operation="$1" globalOp="" releaseOp="" boxOp=""
		case "${operation}" in
			("${OP_BUILD}")
				do_operation "${OP_BOXES}"
				do_operation "${OP_DESCRIPTION}"
			;;

			("${OP_ADD}"|"${OP_PRINT_BOX}"|"${OP_PRINT_BOX_FILE}"|"${OP_PRINT_BOX_DESCRIPTION}")
				boxOp="${operation}"
			;;

			("${OP_DESCRIPTION}"|"${OP_PRINT_DESCRIPTION}"|"${OP_BOXES}")
				releaseOp="${operation}"
			;;

			("${OP_CHECKSUM}"|"${OP_CHECK}"|"${OP_BUILDERS}")
				globalOp="${operation}"
			;;

			(help|-h|--help|*)
				usage
				exit 0
			;;
		esac


		if [ -n "${globalOp}" ]; then
			do_global_op "${globalOp}"
		else
			for release in ${releases}; do
				do_release_operation "${releaseOp}" "${boxOp}" "${release}"
			done
		fi
	}

	if [ "$#" -eq 0 ]; then
		set -- 'help'
	fi

	for operation; do
		do_operation "$operation"
	done

}

box "$@"
