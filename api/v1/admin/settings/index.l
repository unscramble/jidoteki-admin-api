# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de settings-fetch ()
  (let (App     (decode (pack *Admin_path "etc/app.json") T)
        Network (decode (pack *Admin_path "etc/network.json") T) )

    (list (append '("network") Network) (append '("app") App)) ]

(de settings-static (Interface Ip_address Netmask Gateway Dns1 Dns2 Hostname Ntpserver)
  (out (pack *Upload_path "network.conf")
    (prinl "mode=static")
    (if Interface
        (prinl "interface=" Interface)
        (prinl "interface=eth0") )
    (prinl "ip=" Ip_address)
    (prinl "subnet=" Netmask)
    (prinl "router=" Gateway)
    (prin "dns=\"") (when Dns1 (prin @)) (when Dns2 (prin " " @)) (prinl "\"")
    (prin "hostname=\"") (when Hostname (prin @)) (prinl "\"")
    (prin "ntpserver=\"") (when Ntpserver (prin @)) (prinl "\"") )
  (response-async "settings" "static") )

(de settings-dhcp (Interface Hostname)
  (out (pack *Upload_path "network.conf")
    (prinl "mode=dhcp")
    (if Interface
        (prinl "interface=" Interface)
        (prinl "interface=eth0") )
    (prin "hostname=\"") (when Hostname (prin @)) (prinl "\"")
    (prin "ntpserver=\"") (when Ntpserver (prin @)) (prinl "\"") )
  (response-async "settings" "dhcp") )

[de settings-store (Settings)
  (let (App     (cdr (assoc "app" Settings))
        Network (cdr (assoc "network" Settings)) )

    (let (Ip_address  (cdr (assoc "ip_address" Network))
          Netmask     (cdr (assoc "netmask" Network))
          Gateway     (cdr (assoc "gateway" Network))
          Interface   (cdr (assoc "interface" Network))
          Dns1        (cdr (assoc "dns1" Network))
          Dns2        (cdr (assoc "dns2" Network))
          Hostname    (cdr (assoc "hostname" Network))
          Ntpserver   (cdr (assoc "ntpserver" Network)) )

      (or
          # required string character/length validations
          (validate-string-range Interface  'interface *Ascii_codes_alphanumeric (3 . 14))
          (validate-string-range Hostname   'hostname *Ascii_codes_fqdn *Range_fqdn)

          # optional
          (when Ip_address  (validate-string-range Ip_address 'ip_address *Ascii_codes_ipaddress *Range_ipaddress))
          (when Netmask     (validate-string-range Netmask    'netmask *Ascii_codes_ipaddress *Range_ipaddress))
          (when Gateway     (validate-string-range Gateway    'gateway *Ascii_codes_ipaddress *Range_ipaddress))
          (when Dns1        (validate-string-range Dns1       'dns1 *Ascii_codes_ipaddress *Range_ipaddress))
          (when Dns2        (validate-string-range Dns2       'dns2 *Ascii_codes_ipaddress *Range_ipaddress))
          (when Ntpserver   (validate-string-range Ntpserver  'ntpserver (pack *Ascii_codes_fqdn ":") *Range_fqdn))

          (prog
            # output JSON files if validation success
            (out (pack *Upload_path "app.json") (prinl (encode App)))
            (out (pack *Upload_path "network.json") (prinl (encode Network)))

            # output CONF files if validation success
            (if (and Ip_address Netmask Gateway)
                (settings-static Interface Ip_address Netmask Gateway Dns1 Dns2 Hostname Ntpserver)
                (settings-dhcp Interface Hostname Ntpserver) ]

[de api-request-file (File)
  (if (decode File T)
      (settings-store @)
      (http-msg 400) ]

[de api-request-post ()
  (http-file 'settings) ]

(de api-request-get ()
  (response-json (encode (settings-fetch))) )

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]
