(lang dune 3.10)

(name tmui)

(generate_opam_files true)

(source
 (github dupe-codes/tmui))

(authors "dupe")

(maintainers "dupe")

(package
  (name tmui)
  (synopsis "The text message universal interface")
  (description "An SMS based system for getting stuff done")
  (depends
    ocaml
    dream
    ppx_yojson_conv
    caqti-driver-sqlite3
    (dune
      (and
        :build
        (>= 3.11.1)))
    (alcotest
      (and
        :with-test
        (>= 1.7.0)))
    (ppx_inline_alcotest
      (and
        :with-test
        (>= 1.0.0)))))
