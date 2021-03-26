#!/bin/bash

cd ~
ln -s -f /workspace/.gitconfig
mkdir -p /workspace/.kube
ln -s -f /workspace/.kube
cd -

ssh_keys=()

# Load .ops_bashrc ... Usually used to set ssh_keys (see example_ops_bashrc)
if [[ -e /workspace/.ops_bashrc ]]; then
  . /workspace/.ops_bashrc
fi

# Ensure ssh-agent is running
if ! . ~/.ssh_agent_env >/dev/null 2>&1 || ! ssh-add -l >/dev/null 2>&1; then
  eval "$(ssh-agent | grep -Ev '^echo' | tee ~/.ssh_agent_env)"
fi

# Load any keys specified in ssh_keys array
for key in "${ssh_keys[@]}"; do
  keyfile="/workspace/.ssh/$key"
  fingerprint="$(ssh-keygen -lf "$keyfile" | awk '{print $2}')"
  # Check if the key is already loaded
  if ! ssh-add -l | grep -q "$fingerprint"; then
    # Check if the file is world-readable
    if [[ "$(find "$keyfile" -perm '/o+r')" != '' ]]; then
      # ssh-add fails for weirdly-mapped windows->docker file perms, assume the
      # key is OK and force loading from STDIN (but this shows the passphrase)
      echo "Adding SSH key $keyfile"
      cat "$keyfile" | ssh-add -
    else
      # Otherwise just load the key like normal
      ssh-add "$keyfile"
    fi
  fi
done

