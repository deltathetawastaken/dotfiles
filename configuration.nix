# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, unstable, config, pkgs, ... }:

{
  nix.settings.experimental-features = [ "flakes" "nix-command" ];
  nix.settings.auto-optimise-store = true;

  environment.sessionVariables = { 
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1"; 
	NIXOS_OZONE_WL = "1"; 
  };

  environment.etc."wireplumber/main.lua.d/99-enable-soft-mixer.lua".text = ''
    -- alsa_monitor.rules[1].apply_properties["api.alsa.use-acp"] = true;
  '';

  programs.hyprland.enable = true;

  boot.kernel.sysctl."kernel.sysrq" = 1;

  users.users.socks = {
    group = "socks";
    isSystemUser = true;
  };  
  users.groups.socks = {};

  systemd.services.singboxaus = {
    enable = true;
    description = "avoid censorship";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = { Restart = "on-failure"; RestartSec = "15"; User = "socks"; Group = "socks"; };
    script = "sing-box run -c /etc/sing-box/config.json";
    path = with unstable; [ shadowsocks-libev shadowsocks-v2ray-plugin sing-box];
  };

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.extraInstallCommands = ''
    patch_slim7_ssdt=$(
      
      ${pkgs.coreutils}/bin/cp -f ${./slim7-ssdt} /boot/EFI/nixos/slim7-ssdt
      for file in /boot/loader/entries/nixos-generation-*.conf; do
        ${pkgs.gnused}/bin/sed -i '0,/^initrd\s/{s/^initrd\s/initrd \/efi\/nixos\/slim7-ssdt\n&/}' "$file"
      done
    )
  '';
  boot.kernelParams = [ "rtc_cmos.use_acpi_alarm=1" "ideapad_laptop.allow_v4_dytc=1" ];
  boot.loader.efi.canTouchEfiVariables = true;

  programs.firejail.enable = true;

  security.wrappers = {
    firejail = {
      source = "${pkgs.firejail.out}/bin/firejail";
    };
  };
   
  programs.command-not-found.enable = false;
  programs.fish.enable = true;
  programs.fish.promptInit = ''
    set TERM "xterm-256color"
    set fish_greeting
    any-nix-shell fish --info-right | source
  '';
  users.defaultUserShell = pkgs.fish;

  networking.hostName = "dlaptop"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Moscow";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver = {
    layout = "us";
    xkbVariant = "";
  };

  virtualisation = {
    podman = {
      enable = true;
      dockerCompat = true;
    };
    spiceUSBRedirection.enable = true;
    libvirtd.enable = true;
  };

  programs.steam.enable = true;
  programs.gamemode.enable = true;
  services.flatpak.enable = true;
 # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  sound.extraConfig = ''

  '';

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.delta = {
    isNormalUser = true;
    description = "delta";
    extraGroups = [ "networkmanager" "wheel" "libvirtd" ];
    #packages = with pkgs; [
    #   inputs.firefox.packages.${pkgs.system}.firefox-nightly-bin
    #];
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    linuxKernel.packages.linux_zen.acpi_call
    gnomeExtensions.appindicator
    gnomeExtensions.activate-window-by-title
    gnomeExtensions.unite
    gnomeExtensions.tailscale-qs
    gnomeExtensions.gsconnect
    gnomeExtensions.clipboard-indicator
    gnome.gnome-tweaks
    mojave-gtk-theme
    adw-gtk3
    any-nix-shell
    openconnect
    micro
    oath-toolkit
    expect
  ];

  systemd.services.NetworkManager-wait-online.enable = false; # Sometimes it stops the PC from shutdown :/ 

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
  networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?

}
