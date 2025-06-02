{ lib, writeScriptBin, bash, tmux, devspace-welcome }:

let
  theme = import ./theme.nix;
  spaceMap = lib.listToAttrs (map (s: { name = s.name; value = s; }) theme.spaces);
in
writeScriptBin "devspace-init-single" ''
  #!${bash}/bin/bash
  # 🚀 Initialize a single minimal devspace tmux session
  
  set -euo pipefail
  
  if [ $# -lt 1 ]; then
    echo "Usage: devspace-init-single <devspace-name>"
    exit 1
  fi
  
  devspace="$1"
  
  # Validate devspace name and get its config
  case "$devspace" in
    ${lib.concatStringsSep "\n    " (map (s: ''
    ${s.name})
      color="${s.color}"
      icon="${s.icon}"
      description="${s.description}"
      ;;'') theme.spaces)}
    *)
      echo "❌ Unknown devspace: $devspace"
      echo "Valid devspaces: ${lib.concatStringsSep ", " (map (s: s.name) theme.spaces)}"
      exit 1
      ;;
  esac
  
  session="devspace-$devspace"
  
  if ${tmux}/bin/tmux has-session -t "$session" 2>/dev/null; then
    echo "✅ Devspace '$devspace' already exists"
    exit 0
  fi
  
  echo "🪐 Creating minimal devspace '$devspace'..."
  
  # Create session and start user's default shell
  ${tmux}/bin/tmux new-session -d -s "$session" -n setup
  
  # Set environment for the session - these need to be available to shells
  ${tmux}/bin/tmux set-environment -t "$session" TMUX_DEVSPACE "$devspace"
  ${tmux}/bin/tmux set-environment -t "$session" TMUX_DEVSPACE_COLOR "$color"
  ${tmux}/bin/tmux set-environment -t "$session" TMUX_DEVSPACE_INITIALIZED "false"
  
  # Send commands to export the variables in the shell
  ${tmux}/bin/tmux send-keys -t "$session:1" "export TMUX_DEVSPACE='$devspace'" Enter
  ${tmux}/bin/tmux send-keys -t "$session:1" "export TMUX_DEVSPACE_COLOR='$color'" Enter
  ${tmux}/bin/tmux send-keys -t "$session:1" "export TMUX_DEVSPACE_INITIALIZED='false'" Enter
  
  # Wait a moment for shell to start
  sleep 0.1
  
  # Run the welcome script to show a nice display
  ${tmux}/bin/tmux send-keys -t "$session:1" "${devspace-welcome}/bin/devspace-welcome $devspace" Enter
  
  echo "✅ Created minimal devspace '$devspace'"
''