# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de services-process ()
  (sys "SSH_ORIGINAL_COMMAND" "services")
  (in (list (pack *Admin_path "bin/wrapper.sh")) (pack (till) ]

(de api-request-get ()
  (if (services-process)
      (response-json @)
      (http-msg 404) ) )

(check-auth "GET")
