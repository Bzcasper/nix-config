# Ubuntu 25.04 trapstation optimization configuration
{ config, pkgs, lib, ... }:

{
  # Ubuntu-specific Nix configuration optimizations
  nix = {
    # Build settings optimized for development workstation
    settings = {
      # CPU optimization - adjust based on system
      max-jobs = lib.mkDefault 4;
      cores = lib.mkDefault 2;
      
      # Build optimization
      keep-outputs = true;
      keep-derivations = true;
      
      # Ubuntu-specific paths
      extra-sandbox-paths = [
        "/usr/bin/env"
        "/bin/sh"
      ];
      
      # Development-friendly settings
      keep-failed = true; # Keep failed builds for debugging
      log-lines = 50;     # Show more log lines on failure
      
      # Network settings for Ubuntu
      connect-timeout = 5;
      download-attempts = 3;
    };
    
    # Garbage collection optimized for development
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d --delete-generations +10";
    };
    
    # Binary cache configuration
    settings.substituters = [
      "https://cache.nixos.org/"
      "https://nix-community.cache.nixos.org"
    ];
    
    settings.trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cache.nixos.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };
  
  # Environment optimizations for Claude Code CLI
  environment = {
    variables = {
      # Nix-related
      NIX_PATH = "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";
      
      # Claude Code CLI
      CLAUDE_CONFIG_PATH = "/home/admin_bobby/.claude";
      CLAUDE_HOOKS_PATH = "/home/admin_bobby/.claude/hooks";
      
      # Development paths
      PATH = [
        "/home/admin_bobby/.local/bin"
        "/home/admin_bobby/.npm-global/bin" 
        "/home/admin_bobby/go/bin"
        "/home/admin_bobby/.cargo/bin"
      ];
    };
    
    # System packages that complement Nix
    systemPackages = with pkgs; [
      # Essential system tools
      coreutils
      findutils
      util-linux
      
      # Network tools for Ubuntu compatibility
      iproute2
      iputils
      
      # Build essentials
      gcc
      gnumake
      
      # Nix tools
      nix-index
      nix-tree
      nixpkgs-fmt
    ];
  };
  
  # Ubuntu system integration
  system = {
    # User and group management
    activationScripts.setupClaudeEnv = ''
      # Ensure Claude directories exist with proper permissions
      mkdir -p /home/admin_bobby/.claude/{hooks,bin,logs}
      chown -R admin_bobby:admin_bobby /home/admin_bobby/.claude
      chmod -R 755 /home/admin_bobby/.claude
      
      # Ensure development directories exist
      mkdir -p /home/admin_bobby/{go/bin,.npm-global/bin,.cargo/bin}
      chown -R admin_bobby:admin_bobby /home/admin_bobby/{go,.npm-global,.cargo}
    '';
  };
}