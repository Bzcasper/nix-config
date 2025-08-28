{ config, pkgs, lib, ... }:
{
  imports = [ 
    # Note: This is Ubuntu 25.04, not NixOS
    # Configuration is primarily handled by Home Manager
  ];
  
  # Host identification
  networking.hostName = "trapstation";
  
  # Ubuntu 25.04 specific settings
  system.stateVersion = "24.11"; # Use latest stable Nix version
  
  # Enable nix-daemon and flakes for Ubuntu
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users = [ "admin_bobby" "root" ];
    };
    
    # Optimize for development workstation
    settings.max-jobs = 4; # Adjust based on CPU cores
    settings.cores = 2;
    
    # Garbage collection
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 30d";
    };
  };
  
  # Environment for Claude Code CLI integration
  environment.variables = {
    CLAUDE_CONFIG_PATH = "/home/admin_bobby/.claude";
  };
}