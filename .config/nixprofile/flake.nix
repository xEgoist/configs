{
  description = "MacBook Env";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );
    in
    rec {
      formatter = forAllSystems ({ pkgs }: pkgs.alejandra);
      packages = forAllSystems (
        { pkgs }:
        {
          default = pkgs.buildEnv {
            name = "mac-env";
            paths = with pkgs; [
              btop
              choose-gui
              fd
              fish
              fzf
              helix
              jq
              ripgrep
              skhd
              xcp
              zellij
            ];
          };
        }
      );
    };
}
