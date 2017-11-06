# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de services-process ()
  (sys "SSH_ORIGINAL_COMMAND" "services")
  (in (list (pack *Admin_path "bin/wrapper.sh")) (pack (till) ]

[de services-html ()
  (let Services (decode (services-process))
    (mapcar '((N)
              (if (= (cdr N) "running")
                            (text "<li class=\"list-group-item\"><i class=\"fa icon-ok-circled text-success\"></i> @1 <span class=\"pull-right text-success\">@2</span></li>" (str-escape (car N)) (str-escape (cdr N)))
                            (text "<li class=\"list-group-item\"><i class=\"fa icon-cancel-circled text-danger\"></i> @1 <span class=\"pull-right text-danger\">@2</span></li>" (str-escape (car N)) (str-escape (cdr N))) ) )
            (mapcar car (cddr (assoc "services" Services))) ]
