{ pkgs, ... }:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./desktop.nix
    ./locale.nix
    ./networking.nix
  ];

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true;
  };

  nixpkgs.config.allowUnfree = true;

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  programs.zsh.enable = true;
  services.openssh.enable = false;

  # These tools are useful for inspecting hardware even before the user profile loads.
  environment.systemPackages = [
    pkgs.pciutils
    pkgs.usbutils
  ];
}
