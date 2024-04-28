{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2105.url = "github:NixOS/nixpkgs/nixos-21.05";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    anyrun.url = "github:Kirottu/anyrun";
    # anyrun.inputs.nixpkgs.follows = "nixpkgs";
    secrets.url = "git+ssh://git@github.com/deltathetawastaken/secrets.git";
    nixvim.url = "github:nix-community/nixvim";
    shwewo = {
      url = "github:shwewo/flake";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, anyrun, ... }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      stable = import inputs.nixpkgs-stable {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };
      unstable = import inputs.nixpkgs-unstable {
        system = "x86_64-linux";
        config = { allowUnfree = true; };
      };
      specialArgs = { inherit inputs self stable unstable homeSettings; };
      homeSettings = {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.delta = import ./home/home.nix;
        home-manager.extraSpecialArgs = specialArgs;
      };
    in {
      devShells."x86_64-linux".default = pkgs.mkShell {
        name = "delta";
        packages = with pkgs; [ gitleaks pre-commit ];
        shellHook = "pre-commit install &> /dev/null && gitleaks detect -v";
      };
      nixosConfigurations.dlaptop = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [ ./hosts/generic.nix ./hosts/dlaptop/system.nix ];
      };
      nixosConfigurations.intelnuc = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [ ./hosts/generic.nix ./hosts/intelnuc/system.nix ];
      };
      nixosConfigurations.huanan = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs;
        modules = [ ./hosts/generic.nix ./hosts/huanan/system.nix ];
      };
    };
}
