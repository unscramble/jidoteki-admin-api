# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de settings-fetch ()
  (let (App     (decode (pack *Admin_path "etc/app.json") T)
        Network (decode (pack *Admin_path "etc/network.json") T) )

    (list (append '("network") Network) (append '("app") App)) ]

[de settings-html ()
  (let (Data      (settings-fetch)
        Network   (cdr (assoc "network" Data)) )

    (use Key
      (mapcar '((N)
                (setq Key (case (car N)
                  ("interface"  "Interface")
                  ("hostname"   "Hostname")
                  ("netmask"    "Netmask")
                  ("gateway"    "Gateway")
                  ("ip_address" "IP address")
                  ("dns1"       "DNS 1")
                  ("dns2"       "DNS 2")
                  ("ntpserver"  "NTP server")
                  (T            (str-escape (car N))) ) )

                (text "<li class=\"list-group-item\">@1 <span class=\"pull-right text-primary\">@2</span></li>" Key (str-escape (cdr N))) )
              Network ]
