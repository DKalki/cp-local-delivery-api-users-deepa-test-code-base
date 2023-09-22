#!/usr/bin/env bash

# Temporarily install Terraform, whilst we wait for https://github.com/emisgroup/jenkins-infrastructure/issues/1411

# Find Terraform
TERRAFORM=$(which terraform)

if [ -z "${TERRAFORM}" ]; then
	printf "Terraform needs installing...\\n"
	curl -sSL https://releases.hashicorp.com/terraform/1.1.8/terraform_1.1.8_linux_amd64.zip > /tmp/terraform.zip
	unzip -o /tmp/terraform.zip -d /tmp
	mv /tmp/terraform /usr/local/bin/
	rm /tmp/terraform*
else
	printf "Terraform is already installed!\\n"
	exit
fi

# Find Terraform, again
TERRAFORM=$(which terraform)

# Check for Terraform after installation
if [ -z "${TERRAFORM}" ]; then
	printf "Terraform installation failed\\n"
	exit 1
else
	printf "Terraform installation succeeded!\\n"
fi
