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
    mkdir -p $out/app
    cp _build/install/default/bin/otmui $out/app/otmui
  '';

  meta = {
    description = "The Text Message Universal Interface";
  };
}
