{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs-unstable";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    chaotic.inputs.nixpkgs.follows = "nixpkgs-unstable";
    more-waita = {
      url = "https://github.com/somepaulo/MoreWaita/archive/refs/heads/main.zip";
      flake = false;
    };
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, firefox, anyrun, chaotic, ... }: {
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
        chaotic.nixosModules.default
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
