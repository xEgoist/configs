{
  description = "Flake System Configuration for x86_64-linux";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    matcha = {
      url = "git+https://codeberg.org/QuincePie/matcha";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... } @ inputs:
    let
      # inherit (self) outputs;
      mkPkgs = name:
        let
          input = inputs.${name};
        in
        import input {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };

      combPkgs = builtins.foldl' (acc: name: acc // { ${name} = mkPkgs name; }) { } (builtins.attrNames inputs);
    in
    {
      nixosConfigurations = {
        Egoist = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit inputs;
          } // combPkgs;
          modules = [
            ./configuration.nix
          ];
        };
      };
    };
}
