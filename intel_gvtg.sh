#!/usr/bin/env bash

export DEFAULT_TYPE="i915-GVTg_V4_4"
export NAME='intel_gvtg.sh'
export HELP="Use either the 'supported', 'add', or 'del' commands.

Examples:
  ./$NAME supported
  ./$NAME add or ./$NAME add '$DEFAULT_TYPE'
  ./$NAME del"


function listSupportedTypes() {
	for type in $(ls /sys/devices/*/*/mdev_supported_types 2> /dev/null); do 
		echo "Type: $type"
		cat /sys/devices/*/*/mdev_supported_types/$type/description
		echo '--'
	done
}

function createVirtualGfx() {
	local type="${1:-$DEFAULT_TYPE}"
	echo "Type: $type"

	local device=$(dirname /sys/devices/*/*/mdev_supported_types/)
	local name=$(basename "$device")
	local uuid=$(uuidgen)
	local create="$device/mdev_supported_types/$type/create"

	if echo "$uuid" > "$create"; then
		echo "/sys/bus/pci/devices/$name/$uuid"
	else
		echo "Could not create device $uuid"
		return 1
	fi
}

function deleteVirtualGfx() {
	if ! ls /sys/bus/pci/devices/*/*/intel_vgpu &> /dev/null ; then
		echo "No virtual devices to remove." 
		return 0
	fi

	for dir in $(dirname /sys/bus/pci/devices/*/*/intel_vgpu); do
		echo "Removing $dir"
		echo 1 > "$dir/remove"
	done
}

function main() {
	local cmd="${1:-help}"
	local arg="$2"

	case "$cmd" in
		supported)
			listSupportedTypes
			;;
		add)
			createVirtualGfx "$arg"
			;;
		del*)
			deleteVirtualGfx "$arg"
			;;
		*)
			echo "$HELP"
			;;
	esac
}

main "$1" "$2"
