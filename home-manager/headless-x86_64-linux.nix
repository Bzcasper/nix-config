{ inputs, lib, config, pkgs, ... }: {
  imports = [
    ./common.nix
    ./ubuntu-dev-env.nix  # Ubuntu 25.04 specific development environment
    ./tmux
    ./devspaces-host
    ./linkpearl
    ./security-tools
    ./gmailctl
  ];

  home = {
    homeDirectory = "/home/admin_bobby";

    packages = with pkgs; [
      # Core utilities for Ubuntu development environment
      file
      unzip
      dmidecode
      gcc
      git
      curl
      wget
      htop
      tree
      jq
      python3
      nodejs
      # Claude Code CLI development tools
      shellcheck
      ripgrep
      fd
      bat
      # System administration tools
      lsof
      netstat
      tcpdump
    ];
  };

  programs.zsh.shellAliases.update = "home-manager switch --flake \".#admin_bobby@trapstation\"";

  systemd.user.startServices = "sd-switch";
}
