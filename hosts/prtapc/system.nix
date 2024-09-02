# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:
let 
  nixpkgs2305 = import inputs.nixpkgs2305 { system = "${pkgs.system}"; config = { allowUnfree = true; }; };
    update-iptables = pkgs.writeScriptBin "update-iptables" ''
      #!/usr/bin/env bash

      #!/usr/bin/env bash

      # Define your target domain and port for redirection
      TARGET_DOMAIN="catgirl.cloud"
      REDIRECT_PORT="12345"

      # Resolve the IP address of the target domain
      TARGET_IP=$(dig +short $TARGET_DOMAIN | tail -n 1)

      # Exit if no IP address is found
      if [ -z "$TARGET_IP" ]; then
        echo "Failed to resolve IP address for $TARGET_DOMAIN"
        exit 1
      fi

      # Add the new iptables rule for the resolved IP
      sudo iptables -t nat -A OUTPUT -p tcp -d "$TARGET_IP" -j REDIRECT --to-ports "$REDIRECT_PORT"

      echo "iptables rule added for $TARGET_DOMAIN ($TARGET_IP) redirecting to port $REDIRECT_PORT"
  '';
  
in 
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the GRUB 2 boot loader.
  # boot.loader.grub.enable = true;
  # boot.loader.grub.device = "/dev/";
  boot.loader.systemd-boot.enable = true;
  # boot.loader.grub.efiSupport = true;
  # boot.loader.grub.efiInstallAsRemovable = true;
  # boot.loader.efi.efiSysMountPoint = "/boot/efi";
  # Define on which hard drive you want to install Grub.
  # boot.loader.grub.device = "/dev/sda"; # or "nodev" for efi only

  # networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  # time.timeZone = "Europe/Amsterdam";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;

  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop"
  ];
  users.users.root.hashedPassword = ""; # i'll setup pass with passwd after boot
  users.users.delta = {
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGGL2UD0frl9F2OPBiPlSQqxDsuACbAVgwH24F0KT14L delta@dlaptop" ];
  };
  services.openssh.enable = true;
  networking = {
    firewall.enable = false;
    hostName = "prtapc";
    networkmanager.enable = true;
  };

  documentation.man.enable = false;
  services.xserver.desktopManager.xfce.enable = true;
  services.matrix-conduit = {
    enable = true;
    package = inputs.conduwuit.packages.x86_64-linux.default;
    settings = {
      global = {
        allow_registration = true;
        # database_backend = "rocksdb";
        server_name = "${inputs.secrets.home.matrix.url}";
        registration_token = "${inputs.secrets.home.matrix.regword}";
        allow_federation = true;
        address = "0.0.0.0";
        well_known = {
          client = "https://${inputs.secrets.home.matrix.url}";
          server = "${inputs.secrets.home.matrix.url}:443";
        };
        max_request_size = 1073741824;
      };
      misc = {
        new_user_displayname_suffix = "";
        media_compat_file_link = false;
      };
    };
  };
  services.cloudflared.enable = true;
  services.cloudflared.tunnels = {
    "02c42e31-a1b6-49c4-b470-faca3a66f938" = {
      default = "http_status:404";
      credentialsFile = "/home/cloudflared/.cloudflared/02c42e31-a1b6-49c4-b470-faca3a66f938.json";
    };
  };
  users.groups.cloudflared = { };
  users.users.cloudflared = {
    group = "cloudflared";
    isSystemUser = true;
  };
  services.tailscale = {
    enable = true;
    extraUpFlags = "--accept-dns=false";
  };
  
    environment.systemPackages = with pkgs; [
      (pkgs.writeScriptBin "warp-cli" "${nixpkgs2305.cloudflare-warp}/bin/warp-cli $@")
    ];

    systemd.services.warp-svc = {
      enable = true;
      description = "Cloudflare Zero Trust Client Daemon";
      wantedBy = [ "multi-user.target" ];
      after = [ "pre-network.target" ];

      serviceConfig = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = "15";
        DynamicUser = "no";
        # ReadOnlyPaths = "/etc/resolv.conf";
        CapabilityBoundingSet = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE";
        AmbientCapabilities = "CAP_NET_ADMIN CAP_NET_BIND_SERVICE CAP_SYS_PTRACE";
        StateDirectory = "cloudflare-warp";
        RuntimeDirectory = "cloudflare-warp";
        LogsDirectory = "cloudflare-warp";
        ExecStart = "${nixpkgs2305.cloudflare-warp}/bin/warp-svc";
      };

      postStart = ''
        while true; do
          set -e
          status=$(${nixpkgs2305.cloudflare-warp}/bin/warp-cli status || true)
          set +e

          if [[ "$status" != *"Unable to connect to CloudflareWARP daemon"* ]]; then
            ${nixpkgs2305.cloudflare-warp}/bin/warp-cli set-custom-endpoint 162.159.193.1:2408
            exit 0
          fi
          sleep 1
        done
      '';
    };

  systemd.services.updateIptables = {
    description = "Update iptables rules for dynamic DNS target (proxy for matrix)";
    serviceConfig = {
      ExecStart = "${update-iptables}/bin/update-iptables";
      Type = "oneshot";
    };
    path = with pkgs; [ 
          bash
          iproute2 
          iptables 
          sing-box
          dig
    ];
  };

  systemd.timers.updateIptables = {
    description = "Timer to update iptables rules for dynamic DNS target";
    timerConfig = {
      OnBootSec = "2min";
      OnUnitActiveSec = "30min";
    };
    wantedBy = [ "timers.target" ];
  };

  systemd.services.updateIptables.wantedBy = [ "network-online.target" ];

  systemd.services.sing-box = {
    description = "Sing-Box Service";
    after = [ "network.target" ];  # Ensure the service starts after the network is available

    serviceConfig = {
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c /etc/sing-box/config.json";
      Restart = "always";
      RestartSec = 5;
      User = "root";
    };

    wantedBy = [ "multi-user.target" ];  # Ensure the service starts at boot
  };


  services.redsocks = {
    enable = true;
    redsocks = [
      {
        port = 12345;
        proxy = "127.0.0.1:4000";
        type = "socks5";
        redirectCondition = "--dst 148.251.41.235";
      }
    ];
  };

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  # services.pipewire = {
  #   enable = true;
  #   pulse.enable = true;
  # };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.11"; # Did you read the comment?

}

