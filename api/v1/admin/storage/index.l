# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de storage-save (Settings)
  (out (pack *Upload_path "storage.json")
    (prinl (encode Settings)) )

  (out (pack *Upload_path "storage.conf")
    (mapcar '((N)
            (prinl (pack (car N) "=\"" (cdr N) "\"")))
            (cdr (assoc "storage" Settings)) ) )

  (response-async "storage") ]

[de api-request-file (File)
  (if (decode File T)
      (storage-save @)
      (http-msg 400) ]

[de api-request-post ()
  (http-file 'settings) ]

[de storage-options ()
  (let (Options   (if (decode "/usr/local/etc/storage-options.json" T) @ (list (cons "options" T '("local"))))
        Settings  (decode (pack *Admin_path "etc/storage.json") T) )

    (encode (append Settings Options) ]

(de api-request-get ()
  (response-json-nocache (storage-options)) )

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]
