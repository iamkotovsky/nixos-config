{ pkgs, ... }:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/system
  ];

  networking.hostName = "zenbook";

  users.users.danil = {
    isNormalUser = true;
    description = "Danil";
    shell = pkgs.zsh;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
    ];
  };

  # Keep this at the release first installed; it is not the package version.
  system.stateVersion = "26.05";
}
