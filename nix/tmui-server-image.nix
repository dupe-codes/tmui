{ pkgs ? import <nixpkgs> {} }:

# TODO: This is a WIP, not yet functional. Basically
#       just a skeleton
#       OKAY this is whack
#       open issues:
#         - docker run tmui-server complains about not finding
#           /app/tmui-server
#         - when running bash in the docker container, executing
#           tmui-server directly complains about missing required files
#             - this is a dynamic linking problem. we either need to
#               get the dependencies in the right places or compile
#               statically

let
  tmui-build = ../app;
in
pkgs.dockerTools.buildImage {
  name = "tmui-server";
  tag = "latest";

  # TODO: Learn how this works. What is pathsToLink? What is
  #       its relationship with paths?
  copyToRoot = pkgs.buildEnv {
    name = "tmui-build";
    paths = [
      # main application
      tmui-build

      # useful tools for working within the container
      pkgs.bash
      pkgs.coreutils
      pkgs.file
      pkgs.findutils

      # TODO: these are all dependencies of the application
      #       they are installed by nix but are not accessible
      #       within the running container. Why aren't they being
      #       correctly linked? Figure it out, and simplify
      pkgs.glibc
      pkgs.libev
      pkgs.openssl
    ];
    pathsToLink = [ "/app" "/bin" "/lib64" "/usr/lib" "/lib" ];
  };

  # TODO: Why did I have to cp tmui-build directly? Is there no way
  #       to use copyToRoot to do it?
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
      # TODO: Do I actually need all these?
      "PATH=/bin:/usr/bin:/sbin:/usr/sbin"
      "LD_LIBRARY_PATH=/lib:/usr/lib:/lib64"
    ];
  };

  diskSize = 1024;          # MB
  buildVMMemorySize = 512;  # MB
}
