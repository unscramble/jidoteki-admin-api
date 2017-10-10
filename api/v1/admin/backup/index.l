# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de api-request-get ()
  (response-json-nocache (pack *Upload_path "backup.json") 200 T) ]

[de backup-post-action (Action)
  (if (or (= 'START Action) (= 'STOP Action))
      (response-async "backup" Action)
      (http-msg 400 "Missing or invalid option: action. Expected value 'START' or 'STOP'") ]

[de api-request-post ()
  (let Action (uppc (get 'action 'http))
    (backup-post-action Action) ]

(check-auth)

(if *Post
    (api-request-post)
    (api-request-get) ]
