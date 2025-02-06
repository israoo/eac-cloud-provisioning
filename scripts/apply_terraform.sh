#!/bin/bash
{
  set -e

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

  echo "Terraform directory: ${TERRAFORM_DIR}"
  echo

  cd "${TERRAFORM_DIR}"

  echo "--> Initializing terraform..."
  terraform init
  echo

  echo "--> Creating terraform plan..."
  terraform plan -out=tfplan.binary
  echo

  read -p "Do you want to apply the plan? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "--> Aborting terraform apply."
    exit 1
  fi

  echo "--> Applying terraform plan..."
  terraform apply tfplan.binary
  echo
}
