#################### DevShell ####################
#
# Custom shell for bootstrapping on new hosts, modifying nix-config, and secrets management

{ pkgs ? # If pkgs is not defined, instantiate nixpkgs from locked commit
  let
    lock = (builtins.fromJSON (builtins.readFile ./flake.lock)).nodes.nixpkgs.locked;
    nixpkgs = fetchTarball {
      url = "https://github.com/nixos/nixpkgs/archive/${lock.rev}.tar.gz";
      sha256 = lock.narHash;
    };
  in
  import nixpkgs { overlays = [ ]; }
, ...
}: {
  default = pkgs.mkShell {
    NIX_CONFIG = "extra-experimental-features = nix-command flakes";
    name = "delta";
    shellHook = "pre-commit install &> /dev/null && gitleaks detect -v";
    nativeBuildInputs = builtins.attrValues {
      inherit (pkgs)
        nix
        git
        age
        ssh-to-age
        sops
        gitleaks pre-commit;
    };
  };
}