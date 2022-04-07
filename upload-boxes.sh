#!/bin/sh

upload_boxes() {
	# shellcheck disable=SC2039
	local KNOWN_PROVIDERS HOSTED_URL_BASE RSYNC_BASE BOX_DIR BASE_DIR INITIAL_DIR
	readonly BASE_DIR="${0%/*}"
	readonly BOX_DIR="${BASE_DIR}/box"
	readonly INITIAL_DIR="${PWD}"
	readonly KNOWN_PROVIDERS='parallels virtualbox vmware'
	readonly HOSTED_URL_BASE='https://boxes.storage.koalephant.com'
	readonly RSYNC_BASE='dal-web-01.koalephant.net:/srv/www/boxes.storage.koalephant.com'

	# shellcheck disable=SC2039
	local varsFile boxName boxVersion boxTag boxDescription versionDescription activeProviders="${PROVIDERS:-$KNOWN_PROVIDERS}"

	build_description() {
		# shellcheck disable=SC2039
		local provider
		printf -- '%s\n' "${versionDescription}" > "${boxName}/${boxVersion}/version-description.md" || true
		for provider in ${activeProviders}; do
			if [ -f "${boxName}/${boxVersion}/${provider}.version" ]; then
				cat "${boxName}/${boxVersion}/${provider}.version" >> "${boxName}/${boxVersion}/version-description.md"
			fi
		done
	}

	build_checksums() {
		grep -v -F -e "$(get_box_files)" boxes.sha1sum > boxes.sha1sum.new
		# shellcheck disable=SC2046
		shasum --algorithm 1 --binary $(get_box_files) >> boxes.sha1sum.new
		mv -f boxes.sha1sum.new boxes.sha1sum
	}

	map_provider_name() {
		case "$1" in
			(vmware)
				printf -- 'vmware_desktop'
			;;

			(*)
				printf -- '%s' "$1"
			;;

		esac
	}

	get_box_files() {
		# shellcheck disable=SC2046
		# shellcheck disable=SC2086
		get_box_paths $(printf -- '%s.box ' ${activeProviders})
	}

	get_box_paths() {
		printf -- "${boxName}/${boxVersion}/%s\n" "$@"
	}

	get_sync_files() {
		get_box_paths 'version-description.md'
		get_box_files
	}

	get_box_url() {
		printf -- '%s/%s/%s/%s.box' "${HOSTED_URL_BASE}" "${boxName}" "${boxVersion}" "$1"
	}

	rsync_boxes() {
		# shellcheck disable=SC2046
		rsync --verbose --checksum --relative $(get_sync_files) "${RSYNC_BASE}"
	}

	get_box_data() {
		jq --compact-output --null-input --arg boxOwner "${VAGRANT_CLOUD_ORG}" --arg boxName "$boxName" --arg boxDescription "$boxDescription" '{"box": {"username": $boxOwner, "name": $boxName, "short_description": $boxDescription, "is_private": false}}'
	}

	get_version_data() {
		jq  -sR --compact-output --arg boxVersion "${boxVersion}" '{"version": {"version": $boxVersion, "description": .}}' < "${boxName}/${boxVersion}/version-description.md"
	}

	get_provider_data() {
		jq --compact-output --null-input --arg boxChecksum "$(grep -F "${boxName}/${boxVersion}/$1" 'boxes.sha1sum' | cut -c 1-40)" --arg name "$(map_provider_name "$1")" --arg url "$(get_box_url "$1")" '{"provider": {"checksum": $boxChecksum, "checksum_type": "sha1", "name": $name, "url": $url}}'
	}

	make_api_request() {
		# shellcheck disable=SC2039
		local path="$1" data="$2" method="${3:-POST}"

		curl \
			--header 'Content-Type: application/json' \
			--header "Authorization: Bearer ${VAGRANT_CLOUD_TOKEN}" \
			--request "${method}" \
			--data "${data}" \
			"https://app.vagrantup.com/api/v1/${path}"
	}

	make_box_api_request() {
		# shellcheck disable=SC2039
		local path="$1"
		shift
		make_api_request "box/${boxTag}/${path}" "$@"

	}

	create_vagrant_box() {
		make_api_request 'boxes' "$(get_box_data)"
	}

	create_vagrant_version() {
		make_box_api_request 'versions' "$(get_version_data)"
	}

	update_vagrant_version() {
		make_box_api_request 'versions' "$(get_version_data)" 'PUT'
	}

	release_vagrant_version() {
		make_box_api_request "version/${boxVersion}/release" '' 'PUT'
	}

	create_vagrant_provider() {
		make_box_api_request "version/${boxVersion}/providers" "$(get_provider_data "$1")"
	}

	create_known_vagrant_providers() {
		for provider in ${activeProviders}; do
			create_vagrant_provider "$provider"
		done
	}

	read_vars_file() {
		boxName="$(jq -r '.vm_name' < "$1")"
		boxTag="${VAGRANT_CLOUD_ORG}/${boxName}"
		boxVersion="$(jq -r '.version' < "$1")"
		boxDescription="$(jq -r '.box_description' < "$1")"
		versionDescription="$(jq -r '.version_description' < "$1")"
	}


	for varsFile; do
		read_vars_file "${varsFile}"
		cd "${BOX_DIR}" || exit
		build_description
		build_checksums
		rsync_boxes
		create_vagrant_box
		create_vagrant_version
		create_known_vagrant_providers
		release_vagrant_version
		cd "${INITIAL_DIR}" || exit
	done
}


upload_boxes "$@"
