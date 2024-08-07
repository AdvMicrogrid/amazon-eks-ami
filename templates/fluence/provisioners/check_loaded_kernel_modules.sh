#!/bin/bash

if [[ "$ENABLE_FLUENCE_KERNEL_MODULES" == "true" ]]; then
  # call lsmod with sudo, otherwise there will be error that command is not found
  echo "Check what kernel modules are loaded"
  lsmod
  echo "Check nat ftp module information"
  modinfo nf_nat_ftp
  echo "Check module-load config"
  ls -al /etc/modules-load.d
fi
