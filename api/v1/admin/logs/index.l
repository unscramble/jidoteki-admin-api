# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de api-request-get ()
  (sys "SSH_ORIGINAL_COMMAND" "logs")
  (if (call (pack *Admin_path "bin/wrapper.sh"))
      (httpEcho (pack *Upload_path "logs.tar.gz") "application/octet-stream" 1 T)
      (http-msg 404) ]

(check-auth "GET")
