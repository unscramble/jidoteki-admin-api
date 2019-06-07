# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de update-log (Lines)
  (in (list 'tail "-n" Lines (pack *Admin_path "log/update.log")) (pack (replace (till (eof)) "^J" "\\n") ]

[de update-status ()
  (let Jsonfile (pack *Admin_path "etc/status_update.json")
    (if (info Jsonfile)
        (chain (json-decode Jsonfile T))
        (link (cons "status" (if (info (pack *Admin_path "etc/status_update.txt")) (update-status-update) 'null) ]

[de update-status-update ()
  (in (pack *Admin_path "etc/status_update.txt") (line T)) ]

[de update-error-message ()
  (in (pack *Admin_path "etc/status_error_message.txt") (line T)) ]

[de update-error-code ()
  (in (pack *Admin_path "etc/status_error_code.txt") (line T)) ]

[de update-process ()
  (let (Log     (if (info (pack *Admin_path "log/update.log")) (update-log 10) 'null)
        Message (when (info (pack *Admin_path "etc/status_error_message.txt")) (update-error-message))
        Code    (when (info (pack *Admin_path "etc/status_error_code.txt")) (update-error-code)) )

    (make (update-status) (link (cons "log" Log)) (when Message (link (cons "error-message" Message))) (when Code (link (cons "error-code" Code) ]

(de api-request-get ()
  (response-json (json-encode (update-process))) )

(de api-request-file (File)
  (call 'mv "-f" File (pack *Upload_path "software_package-zzz.enc"))
  (response-async "update") )

[de api-request-post ()
  (http-file 'update) ]

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]
