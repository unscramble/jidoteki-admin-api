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
          (validate-string Interface  'interface *Ascii_codes_alphanumeric) # required
          (validate-range  Interface  'interface (3 . 14))                  # required
          (validate-string Hostname   'hostname *Ascii_codes_fqdn)          # required
          (validate-range  Hostname   'hostname *Range_fqdn)                # required

          # optional
          (when Ip_address
            (or   (validate-string Ip_address 'ip_address *Ascii_codes_ipaddress)
                  (validate-range  Ip_address 'ip_address *Range_ipaddress) ) )
          (when Netmask
            (or   (validate-string Netmask    'netmask *Ascii_codes_ipaddress)
                  (validate-range  Netmask    'netmask *Range_ipaddress) ) )
          (when Gateway
            (or   (validate-string Gateway    'gateway *Ascii_codes_ipaddress)
                  (validate-range  Gateway    'gateway *Range_ipaddress) ) )
          (when Dns1
            (or   (validate-string Dns1       'dns1 *Ascii_codes_ipaddress)
                  (validate-range  Dns1       'dns1 *Range_ipaddress) ) )
          (when Dns2
            (or   (validate-string Dns2       'dns2 *Ascii_codes_ipaddress)
                  (validate-range  Dns2       'dns2 *Range_ipaddress) ) )
          (when Ntpserver
            (or   (validate-string Ntpserver 'ntpserver (pack *Ascii_codes_fqdn ":"))
                  (validate-range  Ntpserver 'ntpserver *Range_fqdn) ) )

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
