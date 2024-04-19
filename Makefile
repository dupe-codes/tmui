define OPAM_SETUP
	opam switch && eval $$(opam env)
endef

# ----------------- #
# Development tasks #
# ----------------- #

.PHONY: setup
setup: ## Create initial project setup
	opam switch create . --no-install
	opam install -y
		dune \
		utop \
		ocamlformat \
		ocaml-lsp-server \
		odoc \
		ocaml-manual \
		odig

.PHONY: deps
deps: ## Install project dependencies
	$(OPAM_SETUP) && \
	dune build && \
	opam install . -y --deps-only --with-test

.PHONY: run
run: ## Run the TMUI
	$(OPAM_SETUP) && \
	source $(CURDIR)/project.env && \
	dune exec -w $$PROJECT_NAME

# ---------------- #
# Deployment tasks #
# ---------------- #

.PHONY: build
build: ## Build the project for deployment
	opam switch create . --no-install
	$(OPAM_SETUP) && \
	opam install . -y --deps-only && \
	dune build

# ------------------- #
# Docs & helper tasks #
# ------------------- #

.PHONY: docs
docs: ## Generate & project documentation
	dune build @doc && \
	xdg-open _build/default/_doc/_html/index.html

.PHONY: package-docs
package-docs: ## Generate & open package documentation
	$(OPAM_SETUP) && \
	odig doc

.PHONY: help
help: ## Show this help message
	@grep -E '^[a-z.A-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
