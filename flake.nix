{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    firefox.url = "github:nix-community/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs-unstable";
    telegram-desktop-patched-unstable.url = "github:shwewo/telegram-desktop-patched";
    #agenix.url = "github:ryantm/agenix";
    #agenix.inputs.darwin.follows = "";
    #ragenix = {
    #  url = "github:yaxitech/ragenix";
    #  inputs.flake-utils.follows = "flake-utils";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, firefox, anyrun, sops-nix, ... }: {
    nixosConfigurations.dlaptop = nixpkgs-unstable.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {
        inherit inputs;
        stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
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
        sops-nix.nixosModules.sops
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.delta = import ./home/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
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
        stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
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
        stable = import nixpkgs-stable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
        unstable = import nixpkgs-unstable {
          system = "x86_64-linux";
          config = { allowUnfree = true; };
        };
      };
      modules = [
        ./hosts/generic.nix
        ./hosts/huanan/configuration.nix
        ./hosts/huanan/hardware-configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.delta = import ./home/home.nix;
          home-manager.extraSpecialArgs = {
            inherit inputs;
            stable = import nixpkgs-stable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
            unstable = import nixpkgs-unstable {
              system = "x86_64-linux";
              config = { allowUnfree = true; };
            };
          };
        }
      ];
    };
    
  #  devShells = flake-utils.lib.eachDefaultSystem (system: rec {
  #  pkgs = import nixpkgs {
  #    inherit system;
  #    overlays = [  ];
  #  };
  #  default = pkgs.mkShell {
  #    packages = [  ];
  #    # ...
  #  };
  #});


  };
}
