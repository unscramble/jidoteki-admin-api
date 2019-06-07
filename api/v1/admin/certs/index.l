# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de certs-log (Lines)
  (in (list 'tail "-n" Lines (pack *Admin_path "log/update_certs.log")) (pack (replace (till (eof)) "^J" "\\n") ]

[de certs-status ()
  (in (list 'cat (pack *Admin_path "etc/status_certs.txt")) (pack (till "^J") ]

[de certs-process ()
  (let (Log     (if (info (pack *Admin_path "log/update_certs.log")) (certs-log 10) 'null)
        Status  (if (info (pack *Admin_path "etc/status_certs.txt")) (certs-status) 'null) )

    (list (append '("status") Status) (append '("log") Log) ]

(de api-request-get ()
  (response-json (json-encode (certs-process))) )

(de certs-store (File Type)
  (let Filename
    (case Type
      ("public_key"   "appliance.pem")
      ("private_key"  "appliance.key")
      ("ca_key"       "ca.pem") )

    (if (info File)
        (unless (call 'mv "-f" File (pack *Upload_path Filename))
                (http-msg 400) )
        (http-msg 400) ]

[de api-request-post ()
  (let (Public  (get 'public 'http)
        Private (get 'private 'http)
        Ca      (get 'ca 'http) )

    (if (and Public Private)
        (or (certs-store (tmp Public) "public_key")
            (certs-store (tmp Private) "private_key")
            (when Ca (certs-store (tmp Ca) "ca_key"))
            (response-async "certs") )
        (http-msg 400) ]

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]
