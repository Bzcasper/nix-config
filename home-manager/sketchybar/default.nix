{ inputs, lib, config, pkgs, ... }: {
  xdg.configFile."sketchybar" = {
    source = ./sketchybar;
    recursive = true;
  };
}
