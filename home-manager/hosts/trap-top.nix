{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ../headless-x86_64-linux.nix
  ];

  home = {
    homeDirectory = "/home/joshsymonds";

    packages = with pkgs; [
      # Laptop-specific packages
      brightnessctl
      acpi
      powertop
      
      # Business/productivity tools
      firefox
      thunderbird
      libreoffice
      
      # Development tools specific to laptop use
      code-server
      
      # Network/VPN tools for business use
      wireguard-tools
      networkmanager
    ];
  };

  # Laptop-specific shell aliases
  programs.zsh.shellAliases = {
    update = "sudo nixos-rebuild switch --flake \".#$(hostname)\"";
    battery = "acpi -b";
    brightness = "brightnessctl";
    powersave = "sudo powertop --auto-tune";
  };

  # Enable systemd user services
  systemd.user.startServices = "sd-switch";
}