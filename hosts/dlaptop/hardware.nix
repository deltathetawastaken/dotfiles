# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{
  stable,
  unstable,
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}: {
  imports = [(modulesPath + "/installer/scan/not-detected.nix")];

  boot.initrd.prepend = lib.mkOrder 0 [
    "${pkgs.fetchurl {
      url = "https://gitlab.freedesktop.org/drm/amd/uploads/9fe228c7aa403b78c61fb1e29b3b35e3/slim7-ssdt";
      sha256 = "sha256-Ef4QTxdjt33OJEPLAPEChvvSIXx3Wd/10RGvLfG5JUs=";
      name = "slim7-ssdt";
    }}"
  ];

  hardware.firmware = [
    (pkgs.runCommandNoCC "subwoofer" {} ''
      mkdir -p $out/lib/firmware/
      cp ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/darinpp/yoga-slim-7/main/lib/firmware/TAS2XXX38BB.bin";
        sha256 = "sha256-qyZxBlnWEnrgbh0crgFf//pKZMTtCqh+CkA+pUNU/+E=";
        name = "TAS2XXX38BB.bin";
      }} $out/lib/firmware/TAS2XXX38BB.bin
      cp ${pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/darinpp/yoga-slim-7/main/lib/firmware/TIAS2781RCA4.bin";
        sha256 = "sha256-Zj7mwS8DsBinZ8BYvcySc753Aq/xid7vAeQOH/oir6Q=";
        name = "TIAS2781RCA4.bin";
      }} $out/lib/firmware/TIAS2781RCA4.bin
    '')
    pkgs.wireless-regdb
  ];

  console = {
    earlySetup = true;
    font = "${pkgs.spleen}/share/consolefonts/spleen-16x32.psfu";
    packages = with pkgs; [spleen];
    keyMap = "us";
  };
  boot.initrd = {
    preDeviceCommands = ''
            cat << "EOF"
                 ____
                /\   \
               /  \   \
              /    \   \
             /      \   \
            /   /\   \   \
           /   /  \   \   \
          /   /   /\   \   \
         /   /   /  \   \   \
        /   /   /____\___\   \
       /   /   /              \
      /   /   /________________\
      \  /                     /
       \/_____________________/
      EOF
      echo kernel: $(uname -a | tr -s ' ' ' ' | cut -d' ' -f3,8-12)
    '';
  };
  # boot.initrd = {
  #   preDeviceCommands = ''/bin/initrd.sh'';
  #   secrets."/bin/initrd.sh" = ./initrd.sh;
  # };

  # 5 GHZ wifi
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="RU"
  '';

  services.zfs.autoScrub.enable = true;
  # services.fstrim = {
  #   enable = true;
  #   interval = "weekly";
  # };
  
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-since 7d --keep 4";
  };

  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [
    "rtc_cmos.use_acpi_alarm=1"
    "ideapad_laptop.allow_v4_dytc=1"
    "amd_pstate=active"
    "initcall_blacklist=acpi_cpufreq_init"
    "nowatchdog"
    "amd_pstate.shared_mem=1"
    "zfs_arc_min=8589934592"
    "zfs.zfs_arc_max=25769803776"

    # # Disable all mitigations
    # "mitigations=off"
    # "nopti"
    # "tsx=on"

    # https://www.phoronix.com/news/Linux-Splitlock-Hurts-Gaming
    "split_lock_detect=off"
    "acpi_sleep=nonvs"
  ];

  boot.zfs.allowHibernation = true;
  boot.zfs.forceImportRoot = false;

  boot.kernelModules = ["amd-pstate" "acpi_call" "amdgpu" "kvm-amd" "vfat" "nls_cp437" "nls_iso8859-1" "tcp_bbr"];
  boot.initrd.availableKernelModules = ["nvme" "xhci_pci" "thunderbolt" "usb_storage" "usbhid" "sd_mod" "vfat" "nls_cp437" "nls_iso8859-1"];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.kernelModules = [];

  boot.kernel.sysctl."net.ipv4.tcp_congestion_control" = "bbr";
  boot.kernel.sysctl."net.core.default_qdisc" = "fq"; # see https://news.ycombinator.com/item?id=14814530
  boot.kernel.sysctl."net.core.wmem_max" = 1073741824; # 1 GiB
  boot.kernel.sysctl."net.core.rmem_max" = 1073741824; # 1 GiB
  boot.kernel.sysctl."net.ipv4.tcp_rmem" = "4096 87380 1073741824"; # 1 GiB max
  boot.kernel.sysctl."net.ipv4.tcp_wmem" = "4096 87380 1073741824"; # 1 GiB max
  boot.kernel.sysctl."net.ipv4.tcp_mtu_probing" = 1;
  boot.kernel.sysctl."net.ipv4.tcp_fastopen" = 3;
  # boot.extraModulePackages = with config.boot.kernelPackages; [ usbip.out acpi_call zfs];
  # boot.kernelPackages =
  #   with builtins; with lib; let
  #     latestCompatibleVersion = config.boot.zfs.package.latestCompatibleLinuxPackages.kernel.version;
  #     xanPackages = filterAttrs (name: packages: hasSuffix "_xanmod" name && (tryEval packages).success) pkgs.linuxKernel.packages;
  #     compatiblePackages = filter (packages: compareVersions packages.kernel.version latestCompatibleVersion <= 0) (attrValues xanPackages);
  #     orderedCompatiblePackages = sort (x: y: compareVersions x.kernel.version y.kernel.version > 0) compatiblePackages;
  #     selectedKernelPackage = head orderedCompatiblePackages;
  #   in selectedKernelPackage // {
  #     extraPackages = with selectedKernelPackage; [ acpi_call ];
  #   };

  boot.kernelPackages = lib.mkOverride 99 pkgs.linuxPackages_cachyos;
  boot.zfs.package = lib.mkOverride 99 pkgs.zfs_cachyos;
  chaotic.scx = {
    enable = true;
    scheduler = "scx_rusty";
  };
  environment.systemPackages = [pkgs.scx];
  boot.extraModulePackages = with config.boot.kernelPackages; [usbip acpi_call];

  boot.plymouth.enable = false;

  boot.supportedFilesystems = ["zfs"];

  # boot.initrd.extraUtilsCommands = ''
  #   copy_bin_and_libs ${pkgs.multipath-tools}/bin/kpartx
  # '';

  boot.initrd.luks = {
    yubikeySupport = true;
    devices."cryptroot0" = {
      device = "/dev/nvme0n1p2";
      # postOpenCommands = "
      #   kpartx -u /dev/mapper/cryptroot0
      #   kpartx -u /dev/mapper/cryptroot0p1
      #   kpartx -u /dev/mapper/cryptroot0p2
      #   ";
      yubikey = {
        slot = 2;
        gracePeriod = 3;
        keyLength = 64;
        saltLength = 16;
        twoFactor = false;
        storage = {
          device = "/dev/nvme0n1p1";
          fsType = "vfat";
          path = "/crypt-storage/default";
        };
      };
    };
  };

  sops.age.keyFile = lib.mkForce "/root/keys.txt";

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/4E0B-6C2F";
    fsType = "vfat";
  };

  fileSystems."/" = {
    device = "zroot/root";
    fsType = "zfs";
  };

  fileSystems."/home" = {
    device = "zroot/home";
    fsType = "zfs";
  };

  fileSystems."/home/delta/games" = {
    device = "zroot/home/games";
    fsType = "zfs";
  };

  fileSystems."/games" = {
    device = "zroot/games";
    fsType = "zfs";
  };

  fileSystems."/media" = {
    device = "zroot/media";
    fsType = "zfs";
  };

  fileSystems."/downloads" = {
    device = "zroot/downloads";
    fsType = "zfs";
  };

  fileSystems."/nix" = {
    device = "zroot/nix";
    fsType = "zfs";
  };

  fileSystems."/nix/store" = {
    device = "zroot/nix/store";
    fsType = "zfs";
  };

  fileSystems."/var" = {
    device = "zroot/var";
    fsType = "zfs";
  };

  fileSystems."/var/lib" = {
    device = "zroot/var/lib";
    fsType = "zfs";
  };

  fileSystems."/var/lib/docker" = {
    device = "zroot/var/lib/docker";
    fsType = "zfs";
  };

  fileSystems."/var/lib/libvirt" = {
    device = "zroot/var/lib/libvirt";
    fsType = "zfs";
  };

  fileSystems."/var/log" = {
    device = "zroot/var/log";
    fsType = "zfs";
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/9eff2a94-f3e7-416f-a533-2e1a3e7f75bc";
      randomEncryption.enable = true;
    }
  ];

  hardware.opengl = {
    enable = true;
    extraPackages = [pkgs.amdvlk];
    extraPackages32 = [pkgs.driversi686Linux.amdvlk];

    # package = inputs.hyprland.inputs.nixpkgs.legacyPackages."x86_64-linux".mesa.drivers;
    # package32 = inputs.hyprland.inputs.nixpkgs.legacyPackages."x86_64-linux".pkgsi686Linux.mesa.drivers;
  };

  chaotic.mesa-git.enable = true;
  # chaotic.mesa-git.extraPackages = [ pkgs.amdvlk ];
  # chaotic.mesa-git.extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];

  networking.useDHCP = lib.mkDefault true;
  networking.hostId = "11C0FFEE";
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";

  #hardware.enableAllFirmware = true;
  #hardware.enableRedistributableFirmware = true;
  #hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

      hardware = {
        cpu = {
            x86.msr.enable = true; #= MSR.
            amd.updateMicrocode = true; # Update Microcode
        };
        enableAllFirmware = true;
        enableRedistributableFirmware = lib.mkDefault true; # Lemme update my CPU Microcode, alr?!
        # firmware = with pkgs; [ 
        #     alsa-firmware
        #     linux-firmware
        # ];
    };

  # boot.tmp.useTmpfs = true;

  services.logind = {
    lidSwitch = "suspend";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    powerKey = "ignore";
    powerKeyLongPress = "suspend";
    extraConfig = ''
      IdleAction=suspend
    '';
  };

  services.upower.criticalPowerAction = "PowerOff";

  systemd.services.disable-usb-wakeup = {
    wantedBy = ["multi-user.target"];
    script = ''
      for usb in /sys/bus/usb/devices/*/power/wakeup; do
        echo 'disabled' > $usb
      done
    '';
  };
}
