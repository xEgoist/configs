{
  description = "Flake System Configuration for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    unstable.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "unstable";
    };
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pastel = {
      url = "git+https://codeberg.org/QuincePie/pastel";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      ...
    }@inputs:
    let
      inherit (self) outputs;
      forAllSystems =
        f:
        nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (
          system:
          f {
            pkgs = import nixpkgs { inherit system; };
          }
        );

      mkSystem =
        {
          hostname,
          system,
          extraModules ? [ ],
          ...
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs outputs system;
            defaultUser = nixpkgs.lib.toLower hostname;
          };
          modules = [
            agenix.nixosModules.default
            ./nixos/modules/common.nix
            (./nixos/hosts + "/${nixpkgs.lib.toLower hostname}/configuration.nix")
          ] ++ extraModules;
        };

      hosts = {
        cassini = {
          hostname = "cassini";
          system = "x86_64-linux";
          description = "All Purpose Server";
        };
        Egoist = {
          hostname = "Egoist";
          system = "x86_64-linux";
          description = "Main Computer";
        };
        huygens = {
          hostname = "huygens";
          system = "x86_64-linux";
          description = "NAS and Storage";
          extraModules = [
          ];
        };
      };

    in
    {
      formatter = forAllSystems ({ pkgs }: pkgs.nixfmt-rfc-style);
      overlays = import ./nixos/overlays { inherit inputs; };
      nixosConfigurations = nixpkgs.lib.mapAttrs (_: config: mkSystem config) hosts;
    };
}
