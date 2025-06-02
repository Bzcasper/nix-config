{ lib, writeScriptBin, bash, symlinkJoin, devspace-context, devspace-setup, devspace-worktree, devspace-restore }:

let
  theme = import ./theme.nix;
  
  # Create a versatile shortcut script for each devspace
  makeShortcut = space: writeScriptBin space.name ''
    #!${bash}/bin/bash
    # ${space.icon} ${space.name} - ${space.description}
    
    # Handle different operations based on arguments
    case "''${1:-}" in
      # Setup/link operations
      setup|link)
        shift
        exec ${devspace-setup}/bin/devspace-setup ${space.name} "$@"
        ;;
      
      # Status operation
      status|info)
        echo "${space.icon} ${space.name} status:"
        ${devspace-setup}/bin/devspace-setup ${space.name}
        ;;
      
      # Worktree operations
      worktree|wt)
        shift
        exec ${devspace-worktree}/bin/devspace-worktree "$@" ${space.name}
        ;;
      
      # Connect operation (explicit)
      connect|attach|tmux)
        # Ensure tmux server is started
        tmux start-server 2>/dev/null || true
        
        # If session doesn't exist, try to restore first
        if ! tmux has-session -t devspace-${space.name} 2>/dev/null; then
          echo "🔄 Session not found, attempting to restore..."
          ${devspace-restore}/bin/devspace-restore 2>&1 || echo "❌ Restore failed: $?"
        fi
        
        if tmux has-session -t devspace-${space.name} 2>/dev/null; then
          exec tmux attach-session -t devspace-${space.name}
        else
          echo "${space.icon} ${space.name} could not be initialized."
          exit 1
        fi
        ;;
      
      # Default behavior
      "")
        # If no arguments and we're in a remote session, connect to tmux
        if [ -z "$TMUX" ] && { [ -n "$SSH_TTY" ] || [ -n "$SSH_CONNECTION" ]; }; then
          # Ensure tmux server is started
          tmux start-server 2>/dev/null || true
          
          # If session doesn't exist, try to restore first
          if ! tmux has-session -t devspace-${space.name} 2>/dev/null; then
            echo "🔄 Session not found, attempting to restore..."
            ${devspace-restore}/bin/devspace-restore 2>&1 || echo "❌ Restore failed: $?"
          fi
          
          if tmux has-session -t devspace-${space.name} 2>/dev/null; then
            exec tmux attach-session -t devspace-${space.name}
          else
            echo "${space.icon} ${space.name} could not be initialized."
            exit 1
          fi
        else
          # Otherwise show status
          exec $0 status
        fi
        ;;
      
      # Path argument - treat as setup
      *)
        # If first arg looks like a path, treat as setup
        if [ -d "$1" ] || [ "$1" = "." ] || [[ "$1" == /* ]] || [[ "$1" == ~/* ]]; then
          exec ${devspace-setup}/bin/devspace-setup ${space.name} "$@"
        else
          # Show help
          echo "Usage: ${space.name} [command] [options]"
          echo ""
          echo "Commands:"
          echo "  <path>           Link ${space.name} to a project directory"
          echo "  status           Show ${space.name} status and configuration"
          echo "  connect          Connect to ${space.name} tmux session"
          echo "  worktree <cmd>   Manage git worktrees for ${space.name}"
          echo ""
          echo "Examples:"
          echo "  ${space.name} ~/projects/myapp     # Link to project"
          echo "  ${space.name} .                    # Link to current directory"
          echo "  ${space.name} status               # Show current setup"
          echo "  ${space.name} worktree create feature-branch"
          echo ""
          echo "When connected via SSH/ET, running '${space.name}' attaches to the tmux session."
          exit 1
        fi
        ;;
    esac
  '';
  
  shortcuts = map makeShortcut theme.spaces;
in
symlinkJoin {
  name = "devspace-shortcuts";
  paths = shortcuts;
}