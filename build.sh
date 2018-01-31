#!/bin/bash

function usage() {
    echo -e "
Usage: $0 [ec2ami|qemu-kvm]

Env Vars:

BUILD_REF - Reference to use when tagging/naming build artifacts - Default: Current git tag/branch/commit

ec2ami:

AMI_REGIONS - AWS regions to which the AMIs should be copied - Default: none
AWS_ACCESS_KEY_ID - AWS access key - Required
AWS_REGION - AWS region - Required
AWS_SECRET_ACCESS_KEY - AWS secret key
AWS_SECURITY_GROUP_ID - VPC Security Group ID (must be in configured region and VPC)
AWS_SUBNET_ID - VPC Subnet ID (must be in configured region and VPC)
AWS_VPC_ID - VPC ID (must be in configured region)
SOURCE_AMI - An existing Debian 9 EC2 AMI (must be in configured region) - Default: auto-discover latest official Debian 9 AMI.
"
    exit 1
}

which packer > /dev/null || { echo "ERROR: 'packer' executable not found. Download and install packer before continuing."; exit 1; }
[[ -z ${BUILD_REF+x} ]] || [[ ${BUILD_REF} == "" ]] && export BUILD_REF=$(git describe --tags)

if [[ $1 == "ec2ami" ]] ; then
    [[ -z ${AWS_ACCESS_KEY_ID+x} ]] || [[ ${AWS_ACCESS_KEY_ID} == "" ]] && { echo "ERROR: 'AWS_ACCESS_KEY_ID' environment variable not defined"; usage; }
    [[ -z ${AWS_REGION+x} ]] || [[ ${AWS_REGION} == "" ]] && { echo "ERROR: 'AWS_REGION' environment variable not defined"; usage; }
    [[ -z ${AWS_SECRET_ACCESS_KEY+x} ]] || [[ ${AWS_SECRET_ACCESS_KEY} == "" ]] && { echo "ERROR: 'AWS_SECRET_ACCESS_KEY' environment variable not defined"; usage; }
    [[ -z ${AWS_SECURITY_GROUP_ID+x} ]] || [[ ${AWS_SECURITY_GROUP_ID} == "" ]] && { echo "ERROR: 'AWS_SECURITY_GROUP_ID' environment variable not defined"; usage; }
    [[ -z ${AWS_SUBNET_ID+x} ]] || [[ ${AWS_SUBNET_ID} == "" ]] && { echo "ERROR: 'AWS_SUBNET_ID' environment variable not defined"; usage; }
    [[ -z ${AWS_VPC_ID+x} ]] || [[ ${AWS_VPC_ID} == "" ]] && { echo "ERROR: 'AWS_VPC_ID' environment variable not defined"; usage; }
    if [[ -z ${SOURCE_AMI+x} ]] || [[ ${SOURCE_AMI} == "" ]] ; then
        which jq > /dev/null || { echo "ERROR: 'jq' executable not found. Set SOURCE_AMI or install 'jq' to allow AMI auto-discovery"; exit 1; }
        which aws > /dev/null || { echo "ERROR: 'aws' executable not found. Set SOURCE_AMI or install 'awscli' to AMI auto-discovery"; exit 1; }
        export SOURCE_AMI=$(aws --region $AWS_REGION ec2 describe-images --filters "Name=owner-id,Values=379101102735" "Name=root-device-type,Values=ebs" "Name=architecture,Values=x86_64" "Name=state,Values=available" | jq --raw-output '.Images | sort_by(.Name) | .[] | select(.Name | test("^debian-stretch-hvm-x86_64-gp2.*")) | .ImageId' | tail -n 1)
    fi
    aws --region $AWS_REGION ec2 describe-images --image-ids $SOURCE_AMI > /dev/null ||  { echo "ERROR: SOURCE_AMI is not available"; exit 1; }
    shift 1
    packer build $@ ./packer-debian9-ec2ami.json
elif [[ $1 == "qemu-kvm" ]] ; then
    shift 1
    packer build $@ ./packer-debian9-qemu-kvm.json
else
    usage
fi
