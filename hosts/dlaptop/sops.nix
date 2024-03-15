{ config, lib, ...}:

{
  sops = {
    defaultSopsFile = ../../secrets/generic.yaml;
    age.sshKeyPaths = [ "/home/delta/.ssh/id_ed25519" ];
    #age.keyFile = "/home/delta/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets.qqq = {
      mode = "0400"; owner = "delta"; group = "users";
    };

    secrets.cloudflared = {
      mode = "0400"; owner = "cloudflared"; group = "cloudflared";
    };
    

    secrets."myservice/my_subdir/my_secret" = {};

    secrets.singbox-aus = {
      sopsFile = ../../secrets/singbox-aus.bin;
      format = "binary";
      mode = "0400";
      owner = "socks";
      group = "socks";
    };
  };
}