{ stable, inputs, config, pkgs, lib, ... }:

{
  age.secrets = {
    singboxaus = { file = ../../secrets/singboxaus.age; owner = "socks"; group = "socks"; };
  };

  age.identityPaths = [ "/home/delta/.ssh/id_ed25519" ];
}