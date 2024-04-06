.PHONY: setup
setup: ## Create initial project setup
	opam switch create . --no-install
	opam install -y dune utop ocamlformat ocaml-lsp-server

.PHONY: deps
deps: ## Install project dependencies
	dune build
	opam install . -y --deps-only --with-test

.PHONY: run
run: ## Run the TMUI
	eval $$(opam env) && dune exec -w otmui

.PHONY: help
help: ## Show this help
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
