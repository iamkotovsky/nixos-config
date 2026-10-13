{ pkgs, username, ... }:
{
  imports = [
    ./hardware.nix
    ../../modules/system
  ];

  networking.hostName = "zenbook";

  # Kept out of hardware.nix, which nixos-generate-config may overwrite.
  hardware.cpu.intel.npu.enable = true;

  # VA-API driver for the Arrow Lake iGPU, so browsers and mpv decode video on
  # the GPU instead of the CPU.
  hardware.graphics.extraPackages = [ pkgs.intel-media-driver ];
  environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";

  users.users.${username} = {
    isNormalUser = true;
    description = username;
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
