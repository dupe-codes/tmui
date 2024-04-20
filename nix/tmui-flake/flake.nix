{

  description = "Nix flake for building the TMUI server application";

  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nix-filter.url = "github:numtide/nix-filter";
    nixpkgs.url = "github:NixOS/nixpkgs";

    # include ocaml overlay for access to Dream and related packages
    ocaml-overlay.url = "github:nix-ocaml/nix-overlays";
    ocaml-overlay.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, flake-utils, nix-filter, ocaml-overlay }:
    flake-utils.lib.eachDefaultSystem(system:
    let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [ ocaml-overlay.overlays.default ];
      };
      ocamlPackages = pkgs.ocamlPackages;
      lib = pkgs.lib;
      # filtered sources (prevents unecessary rebuilds)
      sources = {
        ocaml = nix-filter.lib {
          root = ../../.;
          include = [
            ".ocamlformat"
            "dune-project"
            (nix-filter.lib.inDirectory "bin")
            (nix-filter.lib.inDirectory "lib")
            (nix-filter.lib.inDirectory "test")
          ];
        };

        nix = nix-filter.lib {
          root = ../.;
          include = [
            (nix-filter.lib.matchExt "nix")
          ];
        };
      };
    in
    {
      packages = {
        # The package that will be built or run by default. For example:
        #
        #     $ nix build
        #     $ nix run -- <args?>
        #
        default = self.packages.${system}.tmui;

        tmui = ocamlPackages.buildDunePackage {
          pname = "tmui";
          version = "0.1.0";
          duneVersion = "3";
          src = sources.ocaml;
          root = ../../.;

          buildInputs = [
            ocamlPackages.dream
            ocamlPackages.ppx_yojson_conv
          ];

          strictDeps = true;

          preBuild = ''
            export PATH=$PATH:${ocamlPackages.dream}/bin
            dune build
          '';
      };

      # TODO: experiment with this for local development
      devShells = {
        default = pkgs.mkShell {
          packages = [
            pkgs.nixpkgs-fmt              # source file formatting
            ocamlPackages.ocamlformat
            pkgs.fswatch                  # for `dune build --watch ...`
            ocamlPackages.odoc
            ocamlPackages.ocaml-lsp
            ocamlPackages.utop
          ];

          # tools from packages
          inputsFrom = [
            self.packages.${system}.tmui
          ];
        };
      };
    };
  });
}
