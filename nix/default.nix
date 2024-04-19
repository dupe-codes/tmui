{ pkgs ? import <nixpkgs> {} }:

# TODO: This is a wip, not yet functional

pkgs.stdenv.mkDerivation {
  name = "tmui";
  buildInputs = [
    pkgs.ocaml
    pkgs.opam
    pkgs.make
    # add any other dependencies
  ];

  src = ./.; # current directory

  buildPhase = ''
    make build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp path/to/your/executable $out/bin/
  '';

  meta = {
    description = "The Text Message Universal Interface";
    maintainers = with pkgs.stdenv.lib.maintainers; [ pkgs.stdenv.lib.maintainers.example ];
  };
}
