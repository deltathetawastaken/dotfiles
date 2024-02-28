{ stable, inputs, config, pkgs, lib, ... }:

{
  age.secrets = {
    socks_v2ray_sweden = { file = ../../secrets/singboxaus.age; owner = "socks"; group = "socks"; };
  };

  age.identityPaths = [ "/home/delta/.ssh/id_ed25519" ];
}