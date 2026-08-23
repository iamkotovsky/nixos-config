{ pkgs, ... }:
{
  imports = [
    ./bash.nix
    ./helix.nix
    ./fastfetch.nix
    ./firefox.nix
    ./git.nix
    ./hyprlock.nix
    ./kitty.nix
    ./mako.nix
    ./niri.nix
    ./rofi.nix
    ./shell-tools.nix
    ./ssh.nix
    ./starship.nix
    ./theme.nix
    ./udiskie.nix
    ./waybar.nix
    ./wallpaper.nix
    ./yazi.nix
    ./zsh.nix
  ];

  home = {
    username = "danil";
    homeDirectory = "/home/danil";
    stateVersion = "26.05";

    packages = [
      pkgs.bitwig-studio
      pkgs.zoom-us
      pkgs.claude-code
      pkgs.codex
      pkgs.brightnessctl
      pkgs.btop
      pkgs.curl
      pkgs.dust
      pkgs.fd
      pkgs.file
      pkgs.fzf
      pkgs.grim
      pkgs.jq
      pkgs.ncdu
      pkgs.pavucontrol
      pkgs.playerctl
      pkgs.ripgrep
      pkgs.slurp
      pkgs.telegram-desktop
      pkgs.tree
      pkgs.unzip
      pkgs.vesktop
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
