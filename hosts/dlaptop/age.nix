{ stable, inputs, config, pkgs, lib, ... }:

{
  age.secrets = {
    singbox-aus = { file = ../../secrets/singbox-aus.age; owner = "socks"; group = "socks"; };
    qqq = { file = ../../secrets/qqq.age; owner = "delta"; group = "users"; };
    cloudflared = { file = ../../secrets/cloudflared.age; owner = "cloudflared"; group = "cloudflared"; };
  };

  age.identityPaths = [ "/home/delta/.ssh/id_ed25519" ];
}