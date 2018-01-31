Packer Templates: Debian 9 (stretch)
===================================

[![Build Status](https://travis-ci.org/bramford/packer-debian9.svg?branch=master)](https://travis-ci.org/bramford/packer-debian9)
 
Fully automated installation of Debian 9

## Supported Platforms

* AWS EC2 (EBS AMI)
* QEMU-KVM (qcow2)

## Dependencies
 
 - Packer [1.0.3+](https://releases.hashicorp.com/packer/)

## EC2 AMI

### Uses

- [EC2](https://aws.amazon.com/ec2/)
- [Ansible](http://docs.ansible.com/ansible/index.html)

### Key Features

- Dynamically discovers (and uses) latest official stretch AMI

### Instructions

#### Build

    ./build.sh ec2ami

It will likely fail, requiring that some environment variables be set. Set the required variables and run it again, for example:

    AWS_ACCESS_KEY_ID=AMJYP8GJ2LPLJHFCQIL \
    AWS_SECRET_ACCESS_KEY=dNJubuKt5xWn32x4GaGjH2QlrvGWEdQ5fdDKKCoZ \
    AWS_REGION=us-east-1 \
    AWS_VPC_ID=vpc-qq05ntcj \
    AWS_SUBNET_ID=subnet-tcjt9nfm \
    AWS_SECURITY_GROUP_ID=sg-ia7repbg \
    ./build.sh ec2ami

Run `./build.sh --help` for further usage instructions

## QEMU-KVM

### Uses

- [QEMU](https://www.qemu.org/) with [KVM](https://www.linux-kvm.org/page/Main_Page)
- [Debian Preseed](https://wiki.debian.org/DebianInstaller/Preseed)
- [Ansible](http://docs.ansible.com/ansible/index.html)

### Key Features

- Partitioning with LVM
- Enables persistent network names
- Enables serial console

### Instructions

#### Install Dependencies (Debian/Ubuntu)

    apt-get update && apt-get install qemu-kvm

#### Install Dependencies (RHEL/CentOS)

    yum install qemu-kvm

#### Build

    ./build.sh qemu-kvm

##### Output
 
Output directory defaults to `./output/`, configurable with `-var 'output_dir=/path/to/dir'`
