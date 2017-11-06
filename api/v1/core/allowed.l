# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

# default endpoints
(setq *Endpoints
  '("setup"
    "update"
    "logs"
    "debug"
    "reboot"
    "services"
    "version"
    "changelog"
    "build"
    "health"
    "endpoints" ) )

(allowed
  # allow the endpoints
  `(mapcar '((N) (pack *API_PATH "/admin/" N)) *Endpoints)

  # default actions
  "index.html" "v" "newtoken" "token" "hash" "update" "settings" )

[de helper-loader (Endpoint)
  (let Helper (pack *API_PATH "/admin/" Endpoint "/helper.l")
    (when (info Helper) (load Helper) ]

# load the endpoint helpers
(mapcar helper-loader *Endpoints)

(off *Endpoints)

(allow "docs" T)

(when (info "/usr/local/etc/jidoteki-admin-api.json")
      (setq *Api_config (decode "/usr/local/etc/jidoteki-admin-api.json" T)) )

# optional api endpoints
(mapcar '((N)
          (allow (pack *API_PATH "/admin/" N) T)
          (helper-loader N) )
        (cddr (assoc "endpoints" *Api_config)) )

# optional api parameters
(mapcar allow (cddr (assoc "parameters" *Api_config)))
