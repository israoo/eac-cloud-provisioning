#!/bin/bash
{
  set -e

  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
  ANSIBLE_DIR="$SCRIPT_DIR/../ansible"

  echo "Ansible directory: ${ANSIBLE_DIR}"
  echo

  cd "${ANSIBLE_DIR}"

  echo "--> Running ansible playbook..."
  ansible-playbook ec2-instance.yml
  echo
}
