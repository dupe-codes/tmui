{ pkgs ? import <nixpkgs> {} }:

# TODO: This is a WIP, not yet functional. Basically
#       just a skeleton

let
  tmui-build = import ./tmui-server.nix { inherit pkgs; };
in
pkgs.dockerTools.buildImage {
  name = "tmui-server";
  tag = "latest";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ tmui-build ];
    pathsToLink = [ "/app" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /app/data
  '';

  config = {
    Cmd = [ "/app/otmui" ];
    WorkingDir = "/app";
    Volumes = { "/app/data" = {}; };
  };

  diskSize = 1024;          # MB
  buildVMMemorySize = 512;  # MB
}
