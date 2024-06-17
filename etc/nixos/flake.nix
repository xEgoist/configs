{
  description = "Flake System Configuration for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    sops-nix.url = "github:Mic92/sops-nix";
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    unstable,
    sops-nix,
    ...
  } @ inputs: let
    mkPkgs = name: system: let
      input = inputs.${name};
    in
      import input {
        inherit system;
        config.allowUnfree = true;
      };

    combPkgs = system: builtins.foldl' (acc: name: acc // {${name} = mkPkgs name system;}) {} (builtins.attrNames inputs);
  in {
    formatter = nixpkgs.lib.genAttrs nixpkgs.lib.platforms.unix (
      system:
        nixpkgs.legacyPackages.${system}.alejandra
    );
    nixosConfigurations = {
      Egoist = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            inherit inputs;
            defaultUser = "egoist";
          }
          // combPkgs "x86_64-linux";
        modules = [
          ./modules/common.nix
          ./hosts/egoist/configuration.nix
        ];
      };
      cassini = nixpkgs.lib.nixosSystem {
        specialArgs =
          {
            inherit inputs;
            defaultUser = "cassini";
          }
          // combPkgs "x86_64-linux";
        modules = [
          ./modules/common.nix
          ./hosts/cassini/configuration.nix
        ];
      };
    };
  };
}
