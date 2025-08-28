{ config, pkgs, ... }:
{
  imports = [ ../../modules/common/nixos ];
  networking.hostName = "trapstation";
}