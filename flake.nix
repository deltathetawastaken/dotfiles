{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, ... }: {
    nixosConfigurations.dlaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs;
        unstable = import nixpkgs-unstable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
      };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
      ];
    };
  };
}
