# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de license-process ()
  (in (list (pack *Admin_path "bin/license.sh")) (pack (till T) ]

(de api-request-get ()
  (if (license-process)
      (response-json @)
      (http-msg 404) ) )

(de api-request-file (File)
  (call 'mv "-f" File (pack *Upload_path "license.asc"))
  (sys "SSH_ORIGINAL_COMMAND" "license")
  (if (call (pack *Admin_path "bin/wrapper.sh"))
      (license-validate)
      (http-msg 400) ]

[de api-request-post ()
  (http-file 'license) ]

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]

