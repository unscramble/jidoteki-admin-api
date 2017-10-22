# Regression tests

# Server cannot start when JIDO_API_PORT env var is set - https://github.com/unscramble/jidoteki-admin-api/issues/12
[de test-gh-issue-12 ()
  (assert-equal  49888
                      *JIDO_API_PORT # PORT should be converted to an integer
                      "Regression test GH issue #12 - Server cannot start when JIDO_API_PORT env var is set" ]

#  HMAC auth bypassed when no token is set - https://github.com/unscramble/jidoteki-admin-api/issues/17
[de test-gh-issue-17 ()
  (use *Admin_path *Url
    (setq *Admin_path "/tmp"
          *Url        "api/v1/admin/version/index.l" )

    # This would theoretically be the hash of an empty token + the *Url above
    (assert-nil    (validate-hash "99256a631b6a3ecae8c503dfffab1e1c8fe91100f3dddb24a1f24f30907618da")
                        "Regression test GH issue #17 - HMAC auth bypassed when no token is set" ]

# Authenticated API endpoints are not carefully validated - jidoteki/issues/416
[de test-jidoteki-issue-416 (Testname)
  (use *Url *Post
    (setq *Url "api/v1/admin/settings/index.l")
    (on *Post)
    (put 'token 'http "testtoken")
    (put 'settings 'http "settings")

    (Testname) ]

[de test-jidoteki-issue-416-invalid ()
  (pipe
      # file must be copied into child (pipe)
      (when
        (call 'cp "-f" "settings-invalid.json" (tmp 'settings))
        (chdir ".."
          (load "api/v1/admin/settings/index.l" ) ) )

      (when
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "4" "0" "0" " " "B" "a" "d" " " "R" "e" "q" "u" "e" "s" "t"))
        T ]

[de test-jidoteki-issue-416-valid ()
  (pipe
      # file must be copied into child (pipe)
      (when
        (call 'cp "-f" "settings.json" (tmp 'settings))
        (chdir ".."
          (load "api/v1/admin/settings/index.l" ) ) )

      (when
        (= (line) '("H" "T" "T" "P" "/" "1" "." "1" " " "2" "0" "2" " " "A" "c" "c" "e" "p" "t" "e" "d"))
        T ]

[execute
  '(test-gh-issue-12)
  '(test-gh-issue-17)
  '(assert-t (test-jidoteki-issue-416 'test-jidoteki-issue-416-invalid) "Regression test (a) Jidoteki issue #416 - Authenticated API endpoint validation")
  '(assert-t (test-jidoteki-issue-416 'test-jidoteki-issue-416-valid) "Regression test (b) Jidoteki issue #416 - Authenticated API endpoint validation")
  ]
