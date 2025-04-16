# credits/sources:
# - https://nixos-and-flakes.thiscute.world/development/kernel-development

{
  description = "NixOS helper Flakes for Development";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    inputs@{ self
    , nixpkgs
    , ...
    }:
    let
      pkgsKernel = import nixpkgs {
        localSystem = "x86_64-linux";
        # crossSystem = {
        #   config = "aarch64-unknown-linux-gnu";
        # };
      };
    in
    {
      devShells.x86_64-linux = {
        esdm =
          let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          in
          pkgs.mkShell {
            buildInputs = with pkgs; [
              (esdm.overrideAttrs (prev: {
                # src = LOCAL_PATH;
                src = fetchFromGitHub {
                  owner = "smuellerDD";
                  repo = "esdm";
                  rev = "master";
                  sha256 = "sha256-1/Nlj4aU/8CIqpael7Xq10HFyj0S8H3K3m7xfiVpDXY=";
                };
                #mesonBuildType = "debug";
                #dontStrip = true;
                #mesonFlags = prev.mesonFlags ++ [
                #    "-Dstrip=false"
                #    "-Ddebug=true"
                #];
              }))
              protobufc
              openssl
              botan3
              libkcapi
            ];
            nativeBuildInputs = with pkgs; [ pkg-config rustPlatform.bindgenHook meson ninja cmake ];
          };

        # use `nix develop .#kernel` to enter the environment with the custom kernel build environment available.
        # and then use `unpackPhase` to unpack the kernel source code and cd into it.
        # then you can use `make menuconfig` to configure the kernel.
        #
        # problem
        #   - using `make menuconfig` - Unable to find the ncurses package.
        kernel = pkgsKernel.linuxPackages_latest.kernel.dev;

        # use `nix develop .#fhs` to enter the fhs test environment defined here.
        fhs =
          let
            pkgs = import nixpkgs {
              system = "x86_64-linux";
            };
          in
          # the code here is mainly copied from:
            #   https://wiki.nixos.org/wiki/Linux_kernel#Embedded_Linux_Cross-compile_xconfig_and_menuconfig
          (pkgs.buildFHSEnv {
            name = "kernel-build-env";
            targetPkgs = pkgs_: (with pkgs_;
              [
                # we need theses packages to run `make menuconfig` successfully.
                pkg-config
                ncurses

                pkgsKernel.stdenv.cc
                gcc
              ]
              ++ pkgs.linux.nativeBuildInputs);
            runScript = pkgs.writeScript "init.sh" ''
              # set the cross-compilation environment variables.
              # export CROSS_COMPILE=aarch64-unknown-linux-gnu-
              # export ARCH=arm64
              export PKG_CONFIG_PATH="${pkgs.ncurses.dev}/lib/pkgconfig:"
              exec bash
            '';
          }).env;
      };
    };
}
