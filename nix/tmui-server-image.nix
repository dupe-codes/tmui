{ pkgs ? import <nixpkgs> {} }:

# TODO: This is a WIP, not yet functional. Basically
#       just a skeleton

let
  tmui-build = ../app;
in
pkgs.dockerTools.buildImage {
  name = "tmui-server";
  tag = "latest";

  copyToRoot = pkgs.buildEnv {
    name = "tmui-build";
    paths = [
      tmui-build
      pkgs.bash
      pkgs.coreutils
      pkgs.file
      pkgs.findutils
      pkgs.glibc
      pkgs.libev
      pkgs.openssl
    ];
    pathsToLink = [ "/app" "/bin" "/lib64" "/usr/lib" "/lib" ];
  };

  runAsRoot = ''
    #!${pkgs.runtimeShell}
    cp -r ${tmui-build}/* /app/
    mkdir -p /app/data
  '';

  config = {
    Cmd = [ "/app/tmui-server" ];
    WorkingDir = "/app";
    Volumes = { "/app/data" = {}; };
    Env = [
      "PATH=/bin:/usr/bin:/sbin:/usr/sbin"
      "LD_LIBRARY_PATH=/lib:/usr/lib:/lib64"
    ];
  };

  diskSize = 1024;          # MB
  buildVMMemorySize = 512;  # MB
}
