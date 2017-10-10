# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015 Alexander Williams, Unscramble <license@unscramble.jp>

(de *Http_codes
  (200 . "OK")
  (202 . "Accepted")
  (400 . "Bad Request")
  (403 . "Forbidden")
  (404 . "Not Found") )

(de http-code (Code)
  (cdr (assoc Code *Http_codes)) )

[de http-error (Code Error)
  (response-json-generic
    (encode (list (cons "Status" (pack Code " " (http-code Code))) (cons "Error-Message" Error)))
    Code
    NIL
    (list (cons "Content-Type" "application/json") (cons "Error-Message" Error)) ]

(de http-msg (Code Error)
  (if Error
      (http-error Code Error)
      (response-json [encode (list (cons "Status" (pack Code " " (http-code Code)] Code) ) )

[de json-file (Json)
  (if (info Json)
      (setq Info @
        Size (car Info)
        Date '(httpDate (cadr Info) (cddr Info))
        Body (pack (in Json (till (eof)))) )
      (http-msg 404) ]

[de json-string (Json)
  (setq Size (length Json)
        Date '(httpDate (date T) (time T))
        Body Json ]

[de response-json-generic (Json Code Flg Headers)
  (default Code 200)
  (use Info Size Date Body
    (if Flg
        (json-file Json)
        (json-string Json) )

    # Size will be NIL if the file in (json-file) doesn't exist
    (when Size (response-generic Code Size Date Body Headers) ]

[de response-json (Json Code Flg)
  (response-json-generic Json Code Flg '(("Content-Type" . "application/json") ]

[de response-json-nocache (Json Code Flg)
  (response-json-generic Json Code Flg '(("Content-Type" . "application/json") ("Cache-Control" . "no-cache") ]

(de response-async (Endpoint Action)
  (let Location
    (cons "Location" (pack "/api/v1/admin/" Endpoint))

    (unless (fork)
      (sys "SSH_ORIGINAL_COMMAND" Endpoint)
      (exec 'nohup (pack *Admin_path "bin/wrapper.sh") Action) )

    (use Size Date Body
      (json-string [encode (list (cons "Status" (pack 202 " " (http-code 202))) Location])
      (response-generic 202 Size Date Body (list Location '("Content-Type" . "application/json")))
      (audit-log "web" "admin" (pack Endpoint ".post") Action) ]

[de response-generic (Code Size Date Body Headers)
  (prinl "HTTP/1.1 " Code " " (http-code Code) "^M")
  (prinl "Server: PicoLisp^M")
  (prin "Date: ")
  (httpDate (date T) (time T))
  (when Size
    (prinl "Content-Length: " Size "^M") )
  (mapc '((N) (prinl (car N) ": " (cdr N) "^M")) Headers)
  (when Date
    (prin "Last-Modified: ")
    (eval Date)
    (prinl "^M") )
  (prin Body) ]

# Extensions for @lib/http.l
(undef 'http404)

(de http404 ()
  (http-msg 404) )

# Extensions for json.l (32-bit only)
[unless *CPU
  (de encode (Value)
    (pipe (printJson Value) (line T)) )

  (de decode (Value Type)
    (let Json
      (if Type
          (when (info Value) (in Value (till NIL T)))
          Value )
      (parseJson Json T) ]

# API endpoint helpers
[de log-plaintext (Filename)
  (response-json-generic (pack *Admin_path "log/" Filename) 200 T '(("Content-Type" . "text/plain") ("Cache-Control" . "no-cache") ]

[de http-file (Type)
  (let (Data (get Type 'http)
        File (tmp Data) )
    (if (info File)
        (api-request-file File)
        (http-msg 400) ]
