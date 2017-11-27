# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de replication-options ()
  (let (Options   (if (decode "/usr/local/etc/replication-options.json" T) @ (list (cons "options" T '("replication"))))
        Settings  (decode (pack *Admin_path "etc/replication.json") T)
        Status    (decode (pack *Admin_path "etc/replication-status.json") T) )

    (encode (append Settings Options Status) ]

(de api-request-get ()
  (response-json-nocache (replication-options)) )

[de replication-save (Settings)
  (out (pack *Upload_path "replication.json")
    (prinl (encode Settings)) )

  (out (pack *Upload_path "replication.conf")
    (mapcar '((N)
            (prinl (pack (car N) "=\"" (cdr N) "\"")))
            (cdr (assoc "replication" Settings)) ) )

  (response-json-async "replication") ]

# FIXME: validate targets
[de replication-validate-target (Targets) ]

[de replication-validate (Settings)
  (let (Replication (cdr (assoc "replication" Settings)) )

    (let (Status        (cdr (assoc "status" Replication))
          Source        (cdr (assoc "replication_source_pubkey" Replication))
          Target        (cdr (assoc "replication_targets" Replication)) )

      (if Source
          (or (validate-string-range Source 'replication_source_pubkey *Ascii_codes_printable (16 . 2048)))
          (replication-validate-target Targets) )

      (replication-save Settings) ]

[de api-request-file (File)
  (if (decode File T)
      (replication-validate @)
      (http-msg 400) ]

[de api-request-post ()
  (http-file 'settings) ]

(check-auth)
