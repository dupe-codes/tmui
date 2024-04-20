{

  description = "Nix flake for building the TMUI server application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter }:
    flake-utils.lib.eachDefaultSystem(system:
    let
      legacyPackages = nixpkgs.legacyPackages.${system};
      ocamlPackages = legacyPackages.ocamlPackages;
      lib = legacyPackages.lib;
      # filtered sources (prevents unecessary rebuilds)
      sources = {
        ocaml = nix-filter.lib {
          root = ../.;
          include = [
            ".ocamlformat"
            "dune-project"
            (nix-filter.lib.inDirectory "bin")
            (nix-filter.lib.inDirectory "lib")
            (nix-filter.lib.inDirectory "test")
          ];
        };

        nix = nix-filter.lib {
          root = ./.;
          include = [
            (nix-filter.lib.matchExt "nix")
          ];
        };
      };
    in
      packages = {
        # The package that will be built or run by default. For example:
        #
        #     $ nix build
        #     $ nix run -- <args?>
        #
        default = self.packages.${system}.tmui-server;

        tmui-server = ocamlPackages.buildDunePackage {
          pname = "tmui-server";
          version = "0.1.0";
          duneVersion = "3.14.2";
          src = sources.ocaml;

          buildInputs = [
              # Ocaml package dependencies needed to build go here.
          ];

          strictDeps = true;

          preBuild = ''
            dune build tmui.opam
          '';
      };

      devShells = {
        default = legacyPackages.mkShell {
          packages = [
            legacyPackages.nixpkgs-fmt    # source file formatting
            legacyPackages.ocamlformat
            legacyPackages.fswatch        # for `dune build --watch ...`
            ocamlPackages.odoc
            ocamlPackages.ocaml-lsp
            ocamlPackages.utop
          ];

          # tools from packages
          inputsFrom = [
            self.packages.${system}.tmui-server
          ];
        };
      };
    };
  )
}
