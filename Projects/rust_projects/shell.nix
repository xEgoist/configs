{ channel ? "stable", profile ? "default" }:
with import <nixpkgs> {};
mkShell {
  nativeBuildInputs = [
    (if channel == "nightly" then
      rust-bin.selectLatestNightlyWith (toolchain: toolchain.${profile}.override{
        extensions = ["rust-src" "rust-analyzer" ];
      })
    else
      (rust-bin.${channel}.latest.${profile}).override {
        extensions = ["rust-src" "rust-analyzer" ];
      })
    cargo-watch
    cargo-show-asm
    cargo-edit
    pkg-config
    openssl
    gdb
    dbus
  ];
}
