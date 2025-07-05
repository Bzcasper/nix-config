# Hardware configuration for Dell Lenovo 5022 (Trap-Top)
# Business laptop - x86_64-linux, 40GB RAM, no discrete GPU
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [ (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/PLACEHOLDER-ROOT-UUID";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/PLACEHOLDER-BOOT-UUID";
      fsType = "vfat";
    };

  # Enable swap for 40GB RAM system - moderate swap for hibernation support
  swapDevices = [
    { device = "/dev/disk/by-uuid/PLACEHOLDER-SWAP-UUID"; }
  ];

  # Networking
  networking.useDHCP = lib.mkDefault true;
  # Business laptop typically uses WiFi and Ethernet
  # networking.interfaces.wlp0s20f3.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s31f6.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  
  # Intel CPU microcode updates
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  # Power management for laptop
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  
  # Enable laptop-specific hardware
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;
}