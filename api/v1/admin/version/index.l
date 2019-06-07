# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de version-number ()
  (in (list 'cat (pack *Admin_path "etc/version.txt")) (pack (till "^J") ]

[de api-request-get ()
  (if (version-number)
      (response-json (json-encode (list (cons "version" @))))
      (http-msg 404) ]

(check-auth "GET")
