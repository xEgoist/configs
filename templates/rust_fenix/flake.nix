{
  description = "Rust Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    fenix.url = "github:nix-community/fenix";
  };

  outputs = { self, nixpkgs, fenix }:
    let

      # -------KNOBS-------
      toolchain = "latest";
      # -------     -------

      overlays = [
        fenix.overlays.default
      ];

      supportedSystems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];

      # TODO: Add Toolchain logic here similar to oxalica/rust-overlay
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system:
        let
          channel = fenix.packages.${system}.${toolchain};
        in
        f rec {
          pkgs = import nixpkgs { inherit overlays system; };

          rustPkg = with fenix.packages.${system}; combine [
            latest.miri
            targets.aarch64-unknown-linux-gnu.latest.rust-std
            channel.cargo
            channel.clippy
            channel.rust-src
            channel.rustc
            channel.rust-analyzer
            channel.rustfmt
          ];
        });
    in
    {
      devShells = forEachSupportedSystem ({ pkgs, rustPkg }:
        {
          default = pkgs.mkShell {
            packages = with pkgs; [
              rustPkg
              cargo-watch
              cargo-show-asm
              cargo-edit
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
    };
}
