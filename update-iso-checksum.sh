#!/bin/bash -x

# Downloads the latest iso checksum and updates the variables in the json template

template_filename="packer-debian9-qemu-kvm.json"

which jq || { echo "ERROR: 'jq' not found in PATH"; exit 1; }
which curl || { echo "ERROR: 'curl' not found in PATH"; exit 1; }
which sed || { echo "ERROR: 'sed' not found in PATH"; exit 1; }
iso_checksum_type="$(jq --raw-output '.variables.iso_checksum_type' ${template_filename})"
iso_file_url="$(jq --raw-output '.variables.dynamic_mirror_url' ${template_filename})"
iso_file_name="$(jq --raw-output '.variables.iso_name' ${template_filename})"
new_iso_checksum=$(curl -svL ${iso_file_url}/$(echo ${iso_checksum_type} | awk '{print toupper($0)}')SUMS | grep ${iso_file_name} | awk '{ print $1 }')
sed -r -e "s/(\"iso_checksum\"\:\ \")(\w{128}|)(\",)/\1${new_iso_checksum}\3/g" -i ${template_filename} 
