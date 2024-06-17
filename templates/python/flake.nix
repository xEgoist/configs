{
  description = "A Nix Dev Env for Python3";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = {
    self,
    nixpkgs,
  }: let
    supportedSystems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forEachSupportedSystem = f:
      nixpkgs.lib.genAttrs supportedSystems (system:
        f {
          pkgs = import nixpkgs {inherit system;};
        });
  in {
    formatter = forEachSupportedSystem ({pkgs}: pkgs.nixpkgs-fmt);
    devShells = forEachSupportedSystem ({pkgs}: {
      default = pkgs.mkShell {
        packages = with pkgs;
          [
            (python3.withPackages (python-pkgs: [
              python-pkgs.python-lsp-black
              python-pkgs.python-lsp-server
              python-pkgs.python-lsp-ruff
            ]))
          ]
          ++ [
          ];
      };
    });
  };
}
