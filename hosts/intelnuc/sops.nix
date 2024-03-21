{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/generic.yaml;
    age.sshKeyPaths = [ "/home/delta/.ssh/id_ed25519" ];
    defaultSopsFormat = "yaml";

    secrets = {

      "nginx/graf1" = { };
      "nginx/graf2" = { };
      "nginx/kibana" = { };

    };
  };
}
