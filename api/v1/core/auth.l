# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

[de get-sha256 (String Key)
  # works around output diff between openssl 0.9.8 and 1.0.x
  (pipe (out (trim (list 'openssl "dgst" "-sha256" (when Key "-hmac") Key)) (prin String))
        (pack (last (split (chop (line T)) " ") ]

[de get-http-method ()
  (if *Post
      "POST"
      "GET" ]

# Chop the end of the requested URL
[de get-http-url ()
  (glue "/" (head -1 (mapcar pack (split (chop *Url) "/") ]

[de validate-hash (Hash)
  (let (Path      (pack *Admin_path "etc/api.token")
        Token     (when (num? (car (info Path))) (in Path (line T)))
        Tokenhash (when Token (get-sha256 Token))
        Hmac      (when Tokenhash (get-sha256 (pack (get-http-method) "/" (get-http-url)) Tokenhash)) )

    (when Hmac (= Hash Hmac)) ]

[de validate-token (Token)
  (let Path (pack *Admin_path "etc/api.token")
    (when (and Token (num? (car (info Path))))
      (= Token (in Path (line T) ]

[de validate-auth ()
  (let (Hash  (get 'hash 'http)
        Token (get 'token 'http) )
    (if Hash
        (validate-hash Hash)
        (validate-token Token) ]

[de update-token (Token)
  (or (validate-string-range Token 'newtoken *Ascii_codes_printable (1 . 255))
      (prog
        (out (pack *Upload_path "api.token") (prinl Token))
        (sys "SSH_ORIGINAL_COMMAND" "token")
        (call (pack *Admin_path "bin/wrapper.sh")) ]

[de audit-log (Location User Action Target)
 (let (Date (in (list 'date (pack "+%s.%N")) (pack (till "^J")))
       Hash (in (list 'openssl "rand" "-hex" 8) (pack (till "^J"))) )

   (out (pack "+" *Audit_log) (prinl (glue "," (list Date Hash Location User Action (pack "\"" Target "\"") ]

# returns 403 if authentication failed
# returns 400 if "GET" and "POST" methods are reversed
# returns NIL otherwise
(de check-auth-request (Method)
 (if (validate-auth)
     (case Method
       ("GET"  (when   *Post (http-msg 400 "Invalid authentication method. Expected GET") (bye)))
       ("POST" (unless *Post (http-msg 400 "Invalid authentication method. Expected POST") (bye))) )
     (audit-log "web" "admin" "token.authenticate.failed" (get-http-url))
     (http-msg 403 "Authentication error")
     (bye) ) )

[de check-auth (Method)
 (check-auth-request Method)
 (case Method
   ("GET"  (api-request-get))
   ("POST" (api-request-post)) ]
