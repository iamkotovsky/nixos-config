{ pkgs, ... }:
{
  home.packages = [ pkgs.devenv ];

  programs = {
    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    bat.enable = true;

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer = {
      enable = true;
      settings.updates.auto_update = true;
    };
  };
}
