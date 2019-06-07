# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2018 Alexander Williams, Unscramble <license@unscramble.jp>

# On-Prem Admin API

(load "module.l")

(setq
  *API_VERSION  (if (format (sys "JIDO_API_VERSION")) @ 1)
  *API_PATH     (pack "api/v" *API_VERSION)
  *API_DOC      (if (sys "JIDO_API_CUSTOM") (pack @ "/docs/API.html") "docs/API.html")
  *Admin_path   (if (sys "JIDO_ADMIN_PATH") @ "/opt/jidoteki/tinyadmin/")
  *Upload_path  (pack *Admin_path "home/sftp/uploads/")
  *Audit_log    (pack *Admin_path "log/jidoteki-audit.log")
  *Log_paths    (pack *Admin_path "etc/log_paths.txt") )

# Load dependencies
(unless *Tc_functions_loaded
  (chdir (pack *Admin_path "/lib")
    (load "tc-functions.l") ) )

# Load core
(chdir (pack *API_PATH "/core")
  (load "api.l" "auth.l" "helpers.l") )

(load (pack *API_PATH "/core/allowed.l"))

# Load custom code
(when (sys "JIDO_API_CUSTOM")
      (load (pack @ "/" *API_PATH "/core/custom.l")) )

(api-start)

(wait)
