{ inputs, lib, config, pkgs, ... }: {
  # Ubuntu 25.04 specific development environment packages
  
  home.packages = with pkgs; [
    # Development environments
    python311
    python311Packages.pip
    python311Packages.virtualenv
    nodejs_20
    yarn
    go
    rustc
    cargo
    
    # Claude Code CLI development stack
    shellcheck
    shfmt
    ripgrep
    fd
    bat
    eza
    zoxide
    fzf
    
    # Network and system debugging
    inetutils
    tcpdump
    wireshark-cli
    strace
    lsof
    
    # Development utilities  
    jq
    yq-go
    tree
    htop
    btop
    neofetch
    
    # Security and privacy tools
    gnupg
    age
    openssh
    
    # Archive and compression
    unzip
    zip
    gzip
    xz
    
    # Version control extras
    git-lfs
    gh
    
    # Container tools (for Ubuntu compatibility)
    podman
    buildah
    
    # Text processing
    grep
    sed
    awk
    
    # File system tools
    rsync
    rclone
  ];

  # Ubuntu-specific program configurations
  programs = {
    # Enhanced bash for Ubuntu compatibility
    bash = {
      enable = true;
      historyControl = [ "ignoreboth" ];
      historySize = 10000;
      shellAliases = {
        ll = "ls -alF";
        la = "ls -A"; 
        l = "ls -CF";
        ".." = "cd ..";
        "..." = "cd ../..";
      };
    };
    
    # Git configuration for development
    git = {
      enable = true;
      userName = "admin_bobby";
      userEmail = "admin_bobby@trapstation";
      extraConfig = {
        init.defaultBranch = "main";
        pull.rebase = false;
        core.editor = "vim";
      };
    };
    
    # SSH client configuration
    ssh = {
      enable = true;
      controlMaster = "auto";
      controlPath = "/tmp/ssh_mux_%h_%p_%r";
      controlPersist = "1h";
    };
  };

  # Ubuntu-specific services
  services = {
    # GPG agent for key management
    gpg-agent = {
      enable = true;
      defaultCacheTtl = 1800;
      enableSshSupport = true;
    };
  };

  # Environment variables for Ubuntu development
  home.sessionVariables = {
    EDITOR = "vim";
    BROWSER = "firefox";
    CLAUDE_CONFIG_PATH = "/home/admin_bobby/.claude";
    # Python development
    PYTHONPATH = "$HOME/.local/lib/python3.11/site-packages:$PYTHONPATH";
    # Node.js development  
    NODE_PATH = "$HOME/.npm-global/lib/node_modules";
    NPM_CONFIG_PREFIX = "$HOME/.npm-global";
    # Go development
    GOPATH = "$HOME/go";
    GOBIN = "$HOME/go/bin";
    # Rust development
    CARGO_HOME = "$HOME/.cargo";
    RUSTUP_HOME = "$HOME/.rustup";
  };
}