{ config, lib, ... }:

{
  sops = {
    defaultSopsFile = ../../secrets/intelnuc/main.yaml;
    age.sshKeyPaths = [ "/home/delta/.ssh/id_ed25519" ];
    defaultSopsFormat = "yaml";

    secrets = {
      "nginx/graf1" = { };
      "nginx/graf2" = { };
      "nginx/kibana" = { };
    };

    templates ={
      "nginx-graf1.conf"= {
        content = '' proxy_pass ${config.sops.placeholder."nginx/graf1"}; '';
        owner = "root";
        mode = "0444";
      };
      "nginx-graf2.conf"= {
        content = '' proxy_pass ${config.sops.placeholder."nginx/graf2"}; '';
        owner = "root";
        mode = "0444";
      };
      "nginx-kibana.conf"= {
        content = '' proxy_pass ${config.sops.placeholder."nginx/kibana"}; '';
        owner = "root";
        mode = "0444";
      };
      
    };

  };
}
