{
  description = "C development environment with LLVM 16, Criterion, and Clang Tools 16";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkShell = (pkgs.mkShell.override { stdenv = pkgs.llvmPackages_16.stdenv;});
        # mkShell = (pkgs.mkShell.override { stdenv = pkgs.pkgsCross.mingwW64.stdenv; });
      in
      {
        devShells.default = mkShell {
          name = "C Flake";
          packages = with pkgs; [
            ccache
            llvmPackages_16.lldb
            llvmPackages_16.llvm
            llvmPackages_16.bintools
            clang-tools_16
            cmocka
            cmake
            criterion
            fmt
            gf
            meson
            ninja
            pkg-config
            python3
            # pkgsCross.mingwW64.stdenv.cc
            # pkgsCross.mingwW64.windows.pthreads
          ];
          CC_LD = "lld";
        };
      }
    );
}
