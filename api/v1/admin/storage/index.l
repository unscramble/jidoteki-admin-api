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

[de storage-validate-nfs (Mount_options Ip Share)
  (or (validate-string-range Mount_options 'mount_options (pack *Ascii_codes_fqdn "=,") *Range_fqdn)
      (validate-string-range Ip 'ip *Ascii_codes_ipaddress *Range_ipaddress)
      (validate-string-range Share 'share (pack *Ascii_codes_fqdn "_/") *Range_fqdn) ]

[de storage-validate-aoe (Device)
  (or (validate-string-range Device 'device *Ascii_codes_fqdn *Range_fqdn) ]

[de storage-validate-iscsi (Target Ip Username Password)
  (or (validate-string-range Target 'target (pack *Ascii_codes_fqdn "_:") *Range_fqdn)
      (validate-string-range Ip 'ip *Ascii_codes_ipaddress *Range_ipaddress)
      (validate-string-range Username 'username *Ascii_codes_printable *Range_fqdn)
      (validate-string-range Password 'password *Ascii_codes_printable *Range_fqdn) ]

[de storage-validate-nbd (Export_name Ip Port)
  (or (validate-string-range Export_name 'export_name (pack *Ascii_codes_fqdn "_/") *Range_fqdn)
      (validate-string-range Ip 'ip *Ascii_codes_ipaddress *Range_ipaddress)
      (validate-string-range Port 'port "0123456789" (1 . 5)) ]

[de storage-validate (Settings)
  (let (Storage (cdr (assoc "storage" Settings)) )

    (let (Type          (cdr (assoc "type" Storage))
          Mount_options (cdr (assoc "mount_options" Storage))
          Ip            (cdr (assoc "ip" Storage))
          Share         (cdr (assoc "share" Storage))
          Device        (cdr (assoc "device" Storage))
          Target        (cdr (assoc "target" Storage))
          Username      (cdr (assoc "username" Storage))
          Password      (cdr (assoc "password" Storage))
          Export_name   (cdr (assoc "export_name" Storage))
          Port          (cdr (assoc "port" Storage)) )

      (or
        # required string character/length validations
        (unless (member Type '("local" "nfs" "aoe" "iscsi" "nbd"))
                (http-msg 400 (pack "Invalid option: type. Allowed: local, nfs, aoe, iscsi, nbd")) )

        # 'local' Type has no parameters / nothing to validate
        (case Type
              ("nfs"    (storage-validate-nfs Mount_options Ip Share))
              ("aoe"    (storage-validate-aoe Device))
              ("iscsi"  (storage-validate-iscsi Target Ip Username Password))
              ("nbd"    (storage-validate-nbd Export_name Ip Port)) )

        (storage-save Settings) ]

[de api-request-file (File)
  (if (decode File T)
      (storage-validate @)
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
