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
    telegram-desktop-patched.url = "github:shwewo/telegram-desktop-patched";
    secrets.url = "git+ssh://git@github.com/deltathetawastaken/secrets";
    #agenix.url = "github:ryantm/agenix";
    #agenix.inputs.darwin.follows = "";
    #ragenix = {
    #  url = "github:yaxitech/ragenix";
    #  inputs.flake-utils.follows = "flake-utils";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
  };

  outputs = inputs @ { self, nixpkgs, nixpkgs-stable, nixpkgs-unstable, home-manager, firefox, anyrun, ... }: 
  let
    pkgs = nixpkgs.legacyPackages."x86_64-linux";
  in {
    devShells."x86_64-linux".default = pkgs.mkShell {
      name = "delta";
      packages = with pkgs; [ gitleaks pre-commit ];
      shellHook = ''
        gitleaks detect -v
        pre-commit install &> /dev/null
      '';
    };
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
        inputs.secrets.nixosModules.dlaptop
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
        inputs.secrets.nixosModules.intelnuc
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
