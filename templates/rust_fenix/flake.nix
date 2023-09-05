{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    fenix.url = "github:nix-community/fenix";
  };
  outputs = { self, nixpkgs, flake-utils, fenix }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ fenix.overlays.default ];
        };

        # -------KNOBS-------
        toolchain = "latest";
        # -------------------

        channel = fenix.packages.${system}.${toolchain};
        rustPkg = with fenix.packages.${system}; combine [
            channel.cargo
            channel.clippy
            channel.rust-src
            channel.rustc
            channel.rust-analyzer
            channel.rustfmt
            latest.miri
            targets.aarch64-unknown-linux-gnu.latest.rust-std
          ];
      in
      {
        devShell = pkgs.mkShell {

          packages = with pkgs; [
            rustPkg
            cargo-watch
            cargo-show-asm
            cargo-edit
            cargo-cross
            cargo-nextest
            pkg-config
            zlib
            # LLDB 15 and 16 are shitting the bed currently
            lldb_14
          ];
          CARGO_TARGET_AARCH64_UNKNOWN_LINUX_GNU_LINKER =
            let
              inherit (pkgs.pkgsCross.aarch64-multiplatform.stdenv) cc;
            in
            "${cc}/bin/${cc.targetPrefix}cc";
        };
      });
}
