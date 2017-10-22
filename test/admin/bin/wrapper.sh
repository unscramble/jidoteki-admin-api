#!/bin/sh
#
# Wrapper for executing admin commands
#
# Copyright (c) 2013-2015 Alex Williams, Unscramble. See the LICENSE file (MIT).
# https://unscramble.co.jp
#
# VERSION: 1.0.0
#
#
# Borrowed from: https://github.com/unscramble/jidoteki-admin

admin_dir="admin"

case "${SSH_ORIGINAL_COMMAND}" in
  "update")
    sudo ${admin_dir}/bin/update_vm.sh
    ;;
  "version")
    if [ -f "${admin_dir}/etc/version.txt" ]; then cat ${admin_dir}/etc/version.txt; fi
    ;;
  "changelog")
    if [ -f "${admin_dir}/etc/changelog.txt" ]; then cat ${admin_dir}/etc/changelog.txt; fi
    ;;
  "license")
    sudo ${admin_dir}/bin/update_license.sh
    ;;
  "settings")
    ./test/admin/bin/update_settings.sh "$1"
    ;;
  "token")
    ./admin/bin/update_token.sh
    ;;
  "logs")
    if [ -f "${admin_dir}/etc/logs.txt" ]; then
      sudo ${admin_dir}/bin/update_logs.sh "$(cat ${admin_dir}/etc/logs.txt)";
    fi
    ;;
  *)
    exit 1
    ;;
esac
