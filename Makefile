.PHONY: setup
setup:
	opam switch create . --no-install
	opam install -y dune utop ocamlformat ocaml-lsp-server

.PHONY: deps
deps:
	dune build
	opam install . -y --deps-only --with-test

.PHONY: run
run:
	dune exec -w otmui
