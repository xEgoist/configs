{
  description = "A Flexible C Development Environment with LLVM16 and GCC 13";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };


        # ---- MAIN SWITCHES ----

        useLLVM = false;
        useMold = false;

        # ----               ----

        mkShell = (if useLLVM then
          (pkgs.mkShell.override { stdenv = (if useMold then pkgs.stdenvAdapters.useMoldLinker pkgs.llvmPackages_16.stdenv else pkgs.llvmPackages_16.stdenv); })
        else
          (pkgs.mkShell.override { stdenv = (if useMold then pkgs.stdenvAdapters.useMoldLinker pkgs.gcc13Stdenv else pkgs.gcc13Stdenv); })
        );
        # mkShell = (pkgs.mkShell.override { stdenv = pkgs.pkgsCross.mingwW64.stdenv; });
      in
      {
        devShells.default = mkShell {
          name = "C Flake";
          packages = with pkgs;

            (if useLLVM then
              [
                llvmPackages_16.lldb
                llvmPackages_16.llvm
                llvmPackages_16.bintools
              ]
            else
              [ gdb ]
            ) ++
            (if useMold then [ mold ] else [ ]) ++
            [
              ccache
              clang-tools_16
              cmocka
              cmake
              fmt
              gf
              meson
              ninja
              python3
              # if pkgconf bugs occur, use pkg-config instead of these
              libffi
              pkgconf
              # 


              # pkgsCross.mingwW64.stdenv.cc
              # pkgsCross.mingwW64.windows.pthreads
            ];

          CC_LD = (if useMold then "mold" else if useLLVM then "lld" else "gold");
          CXX_LD = (if useMold then "mold" else if useLLVM then "lld" else "gold");

        };
      }
    );
}
