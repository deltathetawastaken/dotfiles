{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager-unstable.url = "github:nix-community/home-manager";
    home-manager-unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs-unstable";
    telegram-desktop-patched.url = "github:shwewo/telegram-desktop-patched";
    telegram-desktop-patched.inputs.nixpkgs.follows = "nixpkgs-unstable";
  };

  outputs = inputs @ { nixpkgs, nixpkgs-unstable, home-manager, home-manager-unstable, firefox, anyrun, ... }: {
    nixosConfigurations.dlaptop = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
      };
      modules = [
        ./hosts/generic.nix
        ./hosts/dlaptop/configuration.nix
        ./hosts/dlaptop/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.delta = import ./home/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
          };
        }
      ];
    };
    nixosConfigurations.intelnuc = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
      };
      modules = [
        ./hosts/generic.nix
        ./hosts/intelnuc/configuration.nix
        ./hosts/intelnuc/hardware-configuration.nix
      ];
    };
    nixosConfigurations.huanan = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
      };
      modules = [
        ./hosts/generic.nix
        ./hosts/huanan/configuration.nix
        ./hosts/huanan/hardware-configuration.nix
        home-manager-unstable.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.delta = import ./home/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
          };
        }
      ];
    };
  };
}
