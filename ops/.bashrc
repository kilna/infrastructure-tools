#!/bin/bash

if [[ -e /workspace/.gitconfig ]]; then
  cp /workspace/.gitconfig ~/
fi

mkdir -p ~/.ssh
cp /workspace/.ssh/* /ops/.ssh
chmod og-rwx ~/.ssh/*

if [[ -e /workspace/.ops_basrc ]]; then
  . /workspace/.ops_bashrc
fi

