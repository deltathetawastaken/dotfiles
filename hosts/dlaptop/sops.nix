{ config, lib, ...}:

let
  # Get the list of all secret files
  secretsDir = ../../secrets/wifi;
  secretFiles = builtins.attrNames (builtins.readDir secretsDir);

  # Generate an attribute set where each attribute corresponds to a secret file
  wifiSecrets = lib.genAttrs secretFiles (secret: {
    sopsFile = ../../secrets/wifi/${secret};
    format = "ini";
    path = "/etc/NetworkManager/system-connections/${builtins.replaceStrings [".ini"] [""] secret}.nmconnection";
    mode = "0400";
  });
in
{
  sops = {
    defaultSopsFile = ../../secrets/generic.yaml;
    age.sshKeyPaths = [ "/home/delta/.ssh/id_ed25519" ];
    #age.keyFile = "/home/delta/.config/sops/age/keys.txt";
    defaultSopsFormat = "yaml";

    secrets = {
      qqq = {
        mode = "0400"; owner = "delta"; group = "users";
      };

      cloudflared = {
        mode = "0400"; owner = "cloudflared"; group = "cloudflared";
      };

      "myservice/my_subdir/my_secret" = {};

      singbox-aus = {
        sopsFile = ../../secrets/singbox-aus.bin;
        format = "binary";
        mode = "0400";
        owner = "socks";
        group = "socks";
      };

      #HomeNet = {
      #  sopsFile = ../../secrets/wifi/HomeNet.ini;
      #  format = "ini";
      #  path = "/etc/NetworkManager/system-connections/HomeNet.nmconnection";
      #  mode = "0400";
      #};

    } // wifiSecrets;
  };
}