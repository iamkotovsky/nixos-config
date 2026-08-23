{ pkgs, ... }:
{
  home.packages = [ pkgs.devenv ];

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    icons = "auto";
    git = true;
  };

  programs.bat.enable = true;

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tealdeer = {
    enable = true;
    settings.updates.auto_update = true;
  };
}
