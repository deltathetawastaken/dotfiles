{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/intelnuc/main.yaml;
    sshKeyPaths = lib.mkForce [];
    age.sshKeyPaths = lib.mkForce [ "/home/delta/.ssh/id_ed25519" ];
    defaultSopsFormat = "yaml";

    secrets = {
      "myservice/my_subdir/my_secret" = {};
    #   "nginx/graf1" = { };
    #   "nginx/graf2" = { };
    #   "nginx/kibana" = { };

    };
  };
}
