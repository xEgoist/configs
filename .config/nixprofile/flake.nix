{
  description = "MacBook Env";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in rec
  {
    formatter = forAllSystems ({pkgs}: pkgs.alejandra);
    packages = forAllSystems ({pkgs}: {
      default = pkgs.buildEnv {
        name = "mac-env";
        paths = with pkgs; [
          bashInteractive
          btop
         # choose-gui
          bfs
          attic-client
          fd
          eza
          jujutsu
          fzf
          (mpc-cli.overrideAttrs(oldAttrs: {
            env = {
              NIX_LDFLAGS = "-liconv";
            };
          }))
          mpd
          ncmpc
          stunnel
          fish
          mpd-discord-rpc
          helix
          jq
          ripgrep
          skhd
          xcp
          zellij
        ];
      };
    });
  };
}
