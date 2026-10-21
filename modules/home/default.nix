{ pkgs, username, ... }:
{
  imports = [
    ./bash.nix
    ./helix.nix
    ./fastfetch.nix
    ./firefox.nix
    ./git.nix
    ./lockscreen.nix
    ./kitty.nix
    ./niri.nix
    ./opencode.nix
    ./quickshell.nix
    ./rofi.nix
    ./session.nix
    ./shell-tools.nix
    ./ssh.nix
    ./starship.nix
    ./telegram.nix
    ./theme.nix
    ./udiskie.nix
    ./wallpaper.nix
    ./yazi.nix
    ./zsh.nix
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    stateVersion = "26.05";

    packages = [
      pkgs.claude-code
      pkgs.bitwig-studio
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
