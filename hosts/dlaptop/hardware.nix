# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ unstable, config, lib, pkgs, modulesPath, self, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  boot.initrd.prepend = lib.mkOrder 0 [ "${pkgs.fetchurl {
    url = "https://gitlab.freedesktop.org/drm/amd/uploads/9fe228c7aa403b78c61fb1e29b3b35e3/slim7-ssdt";
    sha256 = "sha256-Ef4QTxdjt33OJEPLAPEChvvSIXx3Wd/10RGvLfG5JUs=";
    name = "slim7-ssdt";
  }}" ];

  hardware.firmware = [
    (pkgs.runCommandNoCC "subwoofer" { } ''
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

  # 5 GHZ wifi
  boot.extraModprobeConfig = ''
    options cfg80211 ieee80211_regdom="RU"
  '';

  boot.loader.systemd-boot.enable = true;

  boot.kernelParams = [
    "rtc_cmos.use_acpi_alarm=1"
    "ideapad_laptop.allow_v4_dytc=1"
    "amd_pstate=active"
    "initcall_blacklist=acpi_cpufreq_init"
    "nowatchdog"
    "amd_pstate.shared_mem=1"
  ];

  boot.kernelModules = [ "amd-pstate" "acpi_call" "amdgpu" "kvm-amd" "vfat" "nls_cp437" "nls_iso8859-1" ];
  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "thunderbolt" "usb_storage" "sd_mod" "vfat" "nls_cp437" "nls_iso8859-1" ];
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot";
  boot.initrd.kernelModules = [ ];
  boot.kernelPackages = unstable.linuxPackages_zen;
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call cpupower ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/6b2d5c46-92de-42d0-a272-16b7ef7f30af";
    fsType = "ext4";
  };

  boot.initrd.luks = {
    yubikeySupport = true;
    devices."cryptroot" = {
      device = "/dev/nvme0n1p2";
      yubikey = {
        slot = 2;
        gracePeriod = 7;
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

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/6770-34DC";
    fsType = "vfat";
  };

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 32 * 1024;
  }];
  
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
    extraPackages = [ pkgs.amdvlk ];
    extraPackages32 = [ pkgs.driversi686Linux.amdvlk ];
  };

  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
