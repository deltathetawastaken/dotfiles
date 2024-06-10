{ inputs, ... }:
{
  services.nginx.enable = true;
  services.nginx.virtualHosts."grafana" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
    '';

    serverName = "graf1.local";
    serverAliases = [ "${inputs.secrets.work.graf-url}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.graf-url};
      proxy_pass https://${inputs.secrets.work.graf-url};
    '';
    locations."/api/live/ws".extraConfig = ''
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_pass https://${inputs.secrets.work.graf-url};
    '';
  };

  services.nginx.virtualHosts."keycloak" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
    '';
    serverName = "${inputs.secrets.work.keycloak}";
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.keycloak};
      proxy_pass https://${inputs.secrets.work.keycloak};
    '';
  };

  services.nginx.virtualHosts."kibana" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
    '';
    serverName = "kibana.local ${inputs.secrets.work.kibana}";
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.kibana};
      proxy_pass http://${inputs.secrets.work.kibana};
    '';
  };
  services.nginx.virtualHosts."zabbix" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
    '';
    serverName = "zabbix.local";
    serverAliases = [ "${inputs.secrets.work.zabbix-url}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.zabbix-url};
      proxy_pass https://${inputs.secrets.work.zabbix};
    '';
  };
  services.nginx.virtualHosts."prox-1" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
      proxy_ssl_verify off;
    '';
    serverName = "prox-1.local";
    serverAliases = [ "${inputs.secrets.work.prox-1.name}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.prox-1.ip};
      proxy_pass https://${inputs.secrets.work.prox-1.ip};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_read_timeout 86400;
      proxy_send_timeout 86400;
      proxy_connect_timeout 86400;
    '';
  };
  services.nginx.virtualHosts."prox-2" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
      proxy_ssl_verify off;
    '';
    serverName = "prox-2.local";
    serverAliases = [ "${inputs.secrets.work.prox-2.name}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.prox-2.ip};
      proxy_pass https://${inputs.secrets.work.prox-2.ip};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_read_timeout 86400;
      proxy_send_timeout 86400;
      proxy_connect_timeout 86400;
    '';
  };
  services.nginx.virtualHosts."prox-3" = {
    forceSSL = false;
    listen = [
      {port = 80; addr = "100.92.15.128"; ssl = false;} # Listen on port 80 for HTTP
      {port = 443; addr = "100.92.15.128"; ssl = true;} # Listen on port 443 for HTTPS
    ];
    extraConfig = ''
      ssl_certificate /run/secrets/cert;
      ssl_certificate_key /run/secrets/key;
      ssl_protocols TLSv1.2 TLSv1.3;
      ssl_ciphers HIGH:!aNULL:!MD5;
      proxy_ssl_verify off;
    '';
    serverName = "prox-3.local";
    serverAliases = [ "${inputs.secrets.work.prox-3.name}" ];
    locations."/".extraConfig = ''
      proxy_set_header        Host ${inputs.secrets.work.prox-3.ip};
      proxy_pass https://${inputs.secrets.work.prox-3.ip};
      proxy_http_version 1.1;
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection "upgrade";
      proxy_read_timeout 86400;
      proxy_send_timeout 86400;
      proxy_connect_timeout 86400;
    '';
  };
}