{
  inputs = {
    secrets.url = "git+ssh://git@github.com/deltathetawastaken/secrets.git";

    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-23.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs2105.url = "github:NixOS/nixpkgs/nixos-21.05";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    shwewo = {
      url = "github:shwewo/flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };
    nixvim.url = "github:nix-community/nixvim";
    anyrun.url = "github:anyrun-org/anyrun";
    anyrun.inputs.nixpkgs.follows = "nixpkgs";
    hyprland.url = "git+https://github.com/hyprwm/Hyprland?submodules=1";
    hyprland-contrib = {
      url = "github:hyprwm/contrib";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #hyprland-plugins = {
    #  url = "github:hyprwm/hyprland-plugins";
    #  inputs.hyprland.follows = "hyprland";
    #};

  };

  outputs = inputs@{ self, nixpkgs, home-manager, ... }:
    let
      pkgs = nixpkgs.legacyPackages."x86_64-linux";
      stable = import inputs.nixpkgs-stable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
      unstable = import inputs.nixpkgs-unstable { system = "x86_64-linux"; config = { allowUnfree = true; }; };
      
      specialArgs = { inherit inputs self stable unstable homeSettings; };
      homeSettings.home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.delta = import ./home/home.nix;
        extraSpecialArgs = specialArgs;
      };

      makeSystem = name: pkgsVersion: systemModules: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = specialArgs // { inherit pkgsVersion; };
        modules = [ ./hosts/generic.nix ] ++ systemModules;
      };

    in {
      
      devShells = { "x86_64-linux" = import ./shell.nix { inherit pkgs; }; };

      nixosConfigurations = {
        dlaptop = makeSystem "dlaptop" unstable [ ./hosts/dlaptop/system.nix ];
        intelnuc = makeSystem "intelnuc" stable [ ./hosts/intelnuc/system.nix ];
        huanan = makeSystem "huanan" pkgs [ ./hosts/huanan/system.nix ];
      };
    };
}

