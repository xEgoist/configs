{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    rust-overlay,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          rust-overlay.overlays.default
        ];
      };
      toolchainExists = builtins.pathExists ./rust-toolchain.toml;
      rustToolchain =
        if toolchainExists
        then pkgs.pkgsBuildHost.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml
        else {};
      useNightly = false;
    in {
      devShell = pkgs.mkShell {
        packages = with pkgs;
          [
            (
              if rustToolchain != {}
              then rustToolchain
              else
                (
                  if useNightly
                  then
                    (rust-bin.selectLatestNightlyWith (toolchain:
                      toolchain.default.override {
                        extensions = ["rust-src" "rust-analyzer"];
                      }))
                  else
                    (rust-bin.stable.latest.default.override {
                      extensions = ["rust-src" "rust-analyzer"];
                    })
                )
            )
          ]
          ++ [
            cargo-watch
            cargo-show-asm
            cargo-edit
            pkg-config
            zlib
          ];
      };
    });
}
