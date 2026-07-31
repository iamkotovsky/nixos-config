{ pkgs, ... }:
{
  imports = [
    ./helix.nix
    ./kitty.nix
    ./niri.nix
    ./quickshell.nix
    ./zsh.nix
  ];

  home = {
    username = "danil";
    homeDirectory = "/home/danil";
    stateVersion = "26.05";

    packages = [
      pkgs.brightnessctl
      pkgs.curl
      pkgs.fd
      pkgs.file
      pkgs.firefox
      pkgs.fuzzel
      pkgs.fzf
      pkgs.git
      pkgs.grim
      pkgs.jq
      pkgs.pavucontrol
      pkgs.playerctl
      pkgs.quickshell
      pkgs.ripgrep
      pkgs.slurp
      pkgs.swaylock
      pkgs.tree
      pkgs.unzip
      pkgs.wget
      pkgs.wl-clipboard
      pkgs.wireplumber
      pkgs.zip
    ];
  };

  xdg = {
    enable = true;
    userDirs = {
      enable = true;
      createDirectories = true;
    };
  };

  programs.home-manager.enable = true;
}
