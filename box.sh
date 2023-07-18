#!/bin/sh

set -eu

box() {
	# shellcheck disable=SC2039
	local DEFAULT_ARCH DEFAULT_RELEASES
	readonly DEFAULT_ARCH="$(arch)"
	readonly DEFAULT_RELEASES="10 11 12"

	# shellcheck disable=SC2039
	local arch="${ARCH:-$DEFAULT_ARCH}" releases="${RELEASES:-$DEFAULT_RELEASES}" release

	# shellcheck disable=SC2039
	local OP_ADD OP_PRINT_BOX_FILE OP_PRINT_VERSION_FILE OP_PRINT_BOX \
		OP_DESCRIPTION OP_PRINT_DESCRIPTION_FILE \
		OP_CHECKSUM OP_CHECK

	readonly OP_ADD='add'
	readonly OP_PRINT_BOX_FILE 'print-box-file'
	readonly OP_PRINT_VERSION_FILE='print-version-file'
	readonly OP_PRINT_BOX='print-box'
	readonly OP_DECSRIPTION='description'
	readonly OP_PRINT_DESCRIPTION_FILE='print-description-file'
	readonly OP_CHECKSUM='checksum'
	readonly OP_CHECK='check'

	# shellcheck disable=SC2039
	local operation='help'

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

			("${OP_PRINT_VERSION_FILE}")
				get_version_file "${release}" "${version}" 'version' "${provider}"
			;;

			("${OP_PRINT_BOX}")
				printf -- '%s\n' "${boxFile#box/}"
			;;
		esac
	}

	do_release_operation() {
		# shellcheck disable=SC2039
		local releaseOp="$1" boxOp="$2" release="$3" version provider
		# shellcheck disable=SC2038
		version="$(find "box/debian${release}-${arch}" -type d -depth 1 | xargs basename | sort -r | head -n1)"

		if [ -z "${version}" ]; then
			log_status 'No Box version found for release debian%d' "${release}" >&2
			return 1
		fi

		version_description_file() {
			get_version_file "${release}" "${version}" 'md' 'version-description'
		}

		case "${releaseOp}" in
			("${OP_DESCRIPTION}")
				log_status 'Generating %s' "$(version_description_file)"
				 # shellcheck disable=SC2046
				cat > "$(version_description_file)" \
					"$(get_version_file "${release}" "${version}" 'version' 'box')" \
					 $(do_release_operation '' "${OP_PRINT_VERSION_FILE}" "${release}" "${version}" "${provider}")
			;;

			("${OP_PRINT_DESCRIPTION_FILE}")
				version_description_file
			;;
		esac

		if [ -n "${boxOp}" ]; then
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

		esac
	}

	do_operation() {
		# shellcheck disable=SC2039
		local operation="$1" globalOp="" releaseOp="" boxOp=""
		case "${operation}" in
			(help|-h|--help)
				print_usage
				exit 0
			;;

			("${OP_ADD}"|"${OP_PRINT_BOX}"|"${OP_PRINT_BOX_FILE}"|"${OP_PRINT_VERSION_FILE}")
				boxOp="${operation}"
			;;

			("${OP_DESCRIPTION}"|desc)
				releaseOp="${OP_DESCRIPTION}"
			;;

			("${OP_CHECKSUM}"|"${OP_CHECK}")
				globalOp="${operation}"
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
