{
  description = "GCC13 C development environment";
  inputs = {
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        mkShell = (pkgs.mkShell.override{ stdenv = pkgs.gcc13Stdenv; });
      in
      {
        devShells.default = mkShell {
          name = "C Flake";
          packages = with pkgs; [
            ccache
            clang-tools_16
            gdb
            cmake
            criterion
            fmt
            gf
            meson
            ninja
            pkg-config
            python3
          ];
        };
      }
    );
}
