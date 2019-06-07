# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2018 Alexander Williams, Unscramble <license@unscramble.jp>

[de logfiles-log (Filename Lines)
  (in (list 'tail "-n" Lines Filename) (till NIL T) ]

# ensure the file is allowed
[de logfiles-log-validate (Filename)
  (let (Path  (dirname Filename)
        Name  (basename Filename) )
    (and (member Path (make (in *Log_paths (until (eof) (link (log-pathformater (line))))))) (member Name (dir Path)) ]

[de api-request-get ()
  (let (Filename  (get 'filename 'http)
        Lines     (get 'lines 'http) )

    (if (and Filename (logfiles-log-validate Filename))
        (if Lines
            (response-json-generic (logfiles-log Filename Lines) 200 NIL '(("Content-Type" . "text/plain") ("Cache-Control" . "no-cache")))
            (log-plaintext Filename) )
        (http-error 404 "Invalid or missing logfile") ]

(check-auth "GET")
