{ pkgs ? import <nixpkgs> {}}:

pkgs.mkShell {
  name = "delta";
  packages = with pkgs; [ gitleaks pre-commit ];
  shellHook = "pre-commit install &> /dev/null && gitleaks detect -v";
}