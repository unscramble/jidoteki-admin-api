# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de api-request-get ()
  (let Endpoints (sort (cdr *Allow))
    (response-json (json-encode (list (cons "endpoints" T (mapcar '((N) (pack "/" N)) Endpoints) ]

(check-auth "GET")
