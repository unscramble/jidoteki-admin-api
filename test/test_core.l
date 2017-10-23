(prinl "^J  Testing Core^J")

(de test-update-token ()
  (call 'rm "-f" (pack *Admin_path "etc/api.token"))
  (update-token "testtoken") )

# Only checks if the size of the file matches
(de test-json-file ()
  (use Info Size Date Body
    (json-file "settings.json")
    (when (= Size 305) T) ) )

# Only checks if the size of the string matches
(de test-json-string ()
  (use Size Date Body
    (json-string "{\"Status\":\"200 OK\"}")
    (when (= Size 19) T) ) )

[de test-response-json ()
  (pipe
    (response-json "{\"Status\": \"200 OK\"}")
    (when
      (and
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "0" " " "O" "K"))
        (= (line) '("S" "e" "r" "v" "e" "r" ":" " " "P" "i" "c" "o" "L" "i" "s" "p"))
        # Verify the Secure HTTP headers
        (= (line) '("S" "t" "r" "i" "c" "t" "-" "T" "r" "a" "n" "s" "p" "o" "r" "t" "-" "S" "e" "c" "u" "r" "i" "t" "y" ":" " " "m" "a" "x" "-" "a" "g" "e" "=" "3" "1" "5" "3" "6" "0" "0" "0" " " ";" " " "i" "n" "c" "l" "u" "d" "e" "S" "u" "b" "D" "o" "m" "a" "i" "n" "s"))
        (= (line) '("X" "-" "F" "r" "a" "m" "e" "-" "O" "p" "t" "i" "o" "n" "s" ":" " " "d" "e" "n" "y"))
        (= (line) '("X" "-" "X" "S" "S" "-" "P" "r" "o" "t" "e" "c" "t" "i" "o" "n" ":" " " "1"))
        (= (line) '("X" "-" "C" "o" "n" "t" "e" "n" "t" "-" "T" "y" "p" "e" "-" "O" "p" "t" "i" "o" "n" "s" ":" " " "n" "o" "s" "n" "i" "f" "f"))
        (line) # Skip the Date header
        (= (line) '("C" "o" "n" "t" "e" "n" "t" "-" "L" "e" "n" "g" "t" "h" ":" " " "2" "0"))
        (= (line) '("C" "o" "n" "t" "e" "n" "t" "-" "T" "y" "p" "e" ":" " " "a" "p" "p" "l" "i" "c" "a" "t" "i" "o" "n" "/" "j" "s" "o" "n")) )
      T ]

[de test-202-accepted ()
  (pipe
    (http-msg 202)
    (when
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "2" " " "A" "c" "c" "e" "p" "t" "e" "d"))
      T ]

[de test-hmac-request ()
  (let *Url "api/v1/admin/version/index.l"
    (validate-hash "39791be66bfbce4966b6c3feb7bfcb9118c285fa952b030a9af2fcf64f1a67ac") ]

[de test-invalid-token ()
  (pipe
    (update-token (char 168))
    (when
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
      T ]

(de test-validate-string-printable ()
  (validate-string "!abc012ABC~" 'test-printable *Ascii_codes_printable) )

(de test-validate-string-alphanumeric ()
  (validate-string "abc012ABC" 'test-alphanumeric *Ascii_codes_alphanumeric) )

(de test-validate-string-ipaddress-v4 ()
  (validate-string "192.0.2.0" 'test-ipaddress-v4 *Ascii_codes_ipaddress) )

(de test-validate-string-ipaddress-v6 ()
  (validate-string "2001:db8:BeEf:1" 'test-ipaddress-v6 *Ascii_codes_ipaddress) )

(de test-validate-string-fqdn ()
  (validate-string "localhost.localdomain" 'test-fqdn *Ascii_codes_fqdn) )

(de test-validate-string-custom ()
  (validate-string "jidoteki" 'test-custom "jidoteki") )

(de test-validate-string-custom-invalid ()
  (pipe
    (validate-string "invalid" 'test-custom "jidoteki")
    (when
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
      T ]

(de test-validate-range-valid ()
  (validate-range "jidoteki" 'test-range-valid (3 . 8)) )

(de test-validate-range-invalid ()
  (pipe
    (validate-range "jidoteki" 'test-range-invalid (3 . 7))
    (when
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
      T ]

(de test-validate-string-range-valid ()
  (validate-string-range "jidoteki" 'test-range-valid "jidoteki "(3 . 8)) )

(de test-validate-string-range-invalid ()
  (pipe
    (validate-string-range "jidoteki" 'test-range-invalid "jidoteki" (3 . 7))
    (when
      (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
      T ]

[execute
  '(assert-t      (validate-token "testtoken") "Ensure token gets validated")
  '(assert-nil    (validate-token "badtoken") "Ensure invalid token doesn't get validated")
  '(assert-t      (test-update-token) "Ensure token gets updated")
  '(assert-equal  "OK" (http-code 200) "Ensure the HTTP message for 200 is 'OK'")
  '(assert-t      (test-202-accepted) "Ensure the HTTP message for 202 is returned as JSON")
  '(assert-t      (test-json-file) "Ensure JSON file is validated")
  '(assert-t      (test-json-string) "Ensure JSON string is validated")
  '(assert-t      (test-response-json) "Ensure a generic HTTP response is returned")
  '(assert-t      (test-hmac-request) "Ensure HMAC gets validated")
  '(assert-t      (test-invalid-token) "Ensure invalid characters (non-printable) are not accepted")
  '(assert-nil    (test-validate-string-printable) "Ensure printable characters are accepted")
  '(assert-nil    (test-validate-string-alphanumeric) "Ensure alphanumeric characters are accepted")
  '(assert-nil    (test-validate-string-ipaddress-v4) "Ensure IPv4 IP address characters are accepted")
  '(assert-nil    (test-validate-string-ipaddress-v6) "Ensure IPv6 IP address characters are accepted")
  '(assert-nil    (test-validate-string-fqdn) "Ensure FQDN characters are accepted")
  '(assert-nil    (test-validate-string-custom) "Ensure custom characters are accepted")
  '(assert-t      (test-validate-string-custom-invalid) "Ensure invalid custom characters are not accepted")
  '(assert-nil    (test-validate-range-valid) "Ensure string is between 1 and 8 characters")
  '(assert-t      (test-validate-range-invalid) "Ensure string is not between 1 and 7 characters")
  '(assert-t      (in-range? "test1234" 1 8) "Ensure token is between 1 and 8 characters")
  '(assert-nil    (in-range? "test12345" 1 8) "Ensure token is not more than 8 characters")
  '(assert-t      (in-range? "::1" (car *Range_ipaddress) (cdr *Range_ipaddress)) "Ensure IPv6 address is within range")
  '(assert-nil    (in-range? "1" (car *Range_ipaddress) (cdr *Range_ipaddress)) "Ensure IPv4 address is not within range")
  '(assert-nil    (test-validate-string-range-valid) "Ensure string is valid, and range is between 1 and 8 characters")
  '(assert-t      (test-validate-string-range-invalid) "Ensure string is valid, but range is not between 1 and 7 characters")
  ]
