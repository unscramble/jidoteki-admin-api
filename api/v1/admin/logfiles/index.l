# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de logfiles-response (Json)
  (json-encode
    (list
      (cons
        "logfiles"
        T
        (mapcar '((N)
                  (list
                    (cons "path"        (; N 1))
                    (cons "name"        (; N 2))
                    (cons "modified"    (; N 3))
                    (cons "size"        (; N 4)) ) )
                  Json ) )
      (cons "num" (length Json)) ]

# returns the list of all logfiles and their filesize and modified date
[de logfiles-list ()
  (make
    (in *Log_paths (until (eof)
      (let Dir (log-pathformater (line))
        (when (=T (car (info Dir)))
          (chdir Dir
            (mapc '[(S)
                    (when (sub? ".log" S)
                      (let
                        (X      (chop S)
                         Info   (info S)
                         Size   (car Info)
                         Fn     (pack Dir S)
                         Ts     (pack (datStr (cadr Info)) "T" (tim$ (cddr Info) T) "Z") )

                        (link (list Dir Fn Ts Size)) ]
                  (sort (dir)) ]

[de api-request-get ()
  (response-json (logfiles-response (logfiles-list))) ]

(check-auth "GET")
