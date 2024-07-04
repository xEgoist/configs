{
  description = "Flake System Configuration for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ inputs: let
    inherit (self) outputs;
    mkSystem = hostname: extraModules:
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
          defaultUser = hostname;
        };
        modules =
          [
            ./nixos/modules/common.nix
            (./nixos/hosts + "/${hostname}/configuration.nix")
          ]
          ++ extraModules;
      };
  in {
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
    overlays = import ./nixos/overlays {inherit inputs;};
    nixosConfigurations = {
      cassini = mkSystem "cassini" [];
      Egoist = mkSystem "egoist" [];
      huygens = mkSystem "huygens" [];
    };
  };
}
