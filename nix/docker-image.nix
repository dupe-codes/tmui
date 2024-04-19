{ pkgs ? import <nixpkgs> {} }:

# TODO: This is a WIP, not yet functional. Basically
#       just a skeleton

pkgs.dockerTools.buildImage {
  name = "tmui-server";
  tag = "latest";

  copyToRoot = pkgs.buildEnv {
    name = "image-root";
    paths = [ pkgs.ocamlPackages.myocamlapp ];
    pathsToLink = [ "/bin" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    mkdir -p /app/data
  '';

  config = {
    Cmd = [ "/bin/tmui" ];
    WorkingDir = "/app";
    Volumes = { "/app/data" = {}; };
  };

  diskSize = 1024;          # MB
  buildVMMemorySize = 512;  # MB
}
