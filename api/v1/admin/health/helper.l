# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de health-html ()
  (let (Data      (decode (pack *Admin_path "etc/health.json") T)
        Cpu       (cdr (assoc "cpu" Data))
        Disk      (cdr (assoc "disk" Data))
        Memory    (cdr (assoc "memory" Data))
        Cpudanger   (when (>= (cdr (assoc "cpu5min" Cpu)) (cdr (assoc "num" Cpu))) "jido-health-danger")
        Diskdanger  (when (>= (cdr (assoc "percentage" Disk)) 98) "jido-health-danger")
        Memdanger   (when (>= (cdr (assoc "percentage" Memory)) 90) "jido-health-danger") )

    (pack
      (text "<li class=\"@1\">cpu @2 (@3 cores)</li>" Cpudanger (cdr (assoc "load" Cpu)) (cdr (assoc "num" Cpu)))
      (text "<li class=\"@1\">disk @2 of @3 (@4%)</li>" Diskdanger (cdr (assoc "used" Disk)) (cdr (assoc "total" Disk)) (cdr (assoc "percentage" Disk)))
      (text "<li class=\"@1\">memory @2 of @3 (@4%)</li>" Memdanger (cdr (assoc "used" Memory)) (cdr (assoc "total" Memory)) (cdr (assoc "percentage" Memory))) ]
