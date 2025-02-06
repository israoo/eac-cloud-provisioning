#!/bin/bash
{
  set -e

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  ANSIBLE_DIR="$SCRIPT_DIR/../ansible"
  OPA_DIR="$SCRIPT_DIR/../opa"
  TERRAFORM_DIR="$SCRIPT_DIR/../terraform"

  echo "Ansible directory: ${ANSIBLE_DIR}"
  echo "OPA directory: ${OPA_DIR}"
  echo "Terraform directory: ${TERRAFORM_DIR}"
  echo

  cd "${TERRAFORM_DIR}"

  echo "--> Initializing terraform..."
  terraform init
  echo

  echo "--> Creating terraform plan..."
  terraform plan -out=tfplan.binary
  echo

  echo "--> Converting terraform plan to JSON..."
  terraform show -json tfplan.binary > tfplan.json
  echo

  cd "${SCRIPT_DIR}"

  echo "--> Validating terraform plan..."
  opa eval --format pretty --data "${OPA_DIR}/policy.rego" --input "${TERRAFORM_DIR}/tfplan.json" "data.terraform.validation" > "${OPA_DIR}/result.json"
  violations_count=$(jq -r '.violations_count' "${OPA_DIR}/result.json")
  echo

  if [ "$violations_count" -gt 0 ]; then
    violations=$(jq -r '.violations' "${OPA_DIR}/result.json")
    echo "--> Validation failed with $violations_count violations."
    echo "${violations}"
    exit 1
  fi

  echo "--> Validation successful. No violations detected."
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

  cd "${ANSIBLE_DIR}"

  echo "--> Running ansible playbook..."
  ansible-playbook ec2-instance.yml
  echo
}
