#!/bin/bash

(
  if [[ -d /workspace/.host_ssh ]]; then
    while sleep 5; do
      rsync -r /workspace/.host_ssh/ /workspace/.ssh/
      chmod -R og-rwx /workspace/.ssh/*
      rsync -r /workspace/.ssh/ /workspace/.host_ssh/
    done
  fi
) &

exec "$@"

