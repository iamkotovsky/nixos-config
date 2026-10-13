{ pkgs, flakeDir, ... }:
{
  imports = [
    ./audio.nix
    ./boot.nix
    ./desktop.nix
    ./locale.nix
    ./networking.nix
    ./power.nix
  ];

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };

    # Hard-links identical store files on a weekly timer, rather than on every
    # build like auto-optimise-store, so rebuilds stay fast.
    optimise.automatic = true;
  };

  nixpkgs.config.allowUnfree = true;

  programs = {
    zsh.enable = true;

    # Rebuilds with a package diff, and replaces nix.gc: `nh clean all` also
    # prunes Home Manager and user-profile generations.
    nh = {
      enable = true;
      flake = flakeDir;
      clean = {
        enable = true;
        extraArgs = "--keep-since 30d --keep 5";
      };
    };
  };

  # Compressed swap in RAM; its higher priority means the disk swap partition
  # is only touched once zram is full.
  zramSwap.enable = true;

  # These tools are useful for inspecting hardware even before the user profile loads.
  environment.systemPackages = [
    pkgs.pciutils
    pkgs.usbutils
  ];
}
