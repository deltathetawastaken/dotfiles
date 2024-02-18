{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox.url = "github:nix-community/flake-firefox-nightly";
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, firefox, ... }: {
    nixosConfigurations.dlaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { 
        inherit inputs;
        unstable = import nixpkgs-unstable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
      };
      modules = [
        ./configuration.nix
        ./hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.delta = import ./home.nix;
          home-manager.extraSpecialArgs = { 
            inherit inputs;
            unstable = import nixpkgs-unstable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
          }; 
        }  
      ];
    };
  };
}
