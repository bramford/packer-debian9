#!/bin/bash -x

# Downloads the latest iso checksum and updates the variables in the json template
which jq || { echo "ERROR: 'jq' not found in PATH"; exit 1; }
which wget || { echo "ERROR: 'wget' not found in PATH"; exit 1; }
iso_checksum_type="$(jq --raw-output '.variables.iso_checksum_type' packer-debian9-qemu-kvm.json)"
iso_file_url="$(jq --raw-output '.variables.remote_mirror_url' packer-debian9-qemu-kvm.json)"
iso_file_name="$(jq --raw-output '.variables.iso_name' packer-debian9-qemu-kvm.json)"
new_iso_checksum=$(curl -sq ${iso_file_url}/$(echo ${iso_checksum_type} | awk '{print toupper($0)}')SUMS  | grep ${iso_file_name} | awk '{ print $1 }')
sed -i packer-debian9-qemu-kvm.json -r -e "s/(\"iso_checksum\"\:\ \")\w{128}(\",)/\1${new_iso_checksum}\2/g"
