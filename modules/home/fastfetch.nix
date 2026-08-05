{ theme, ... }:
let
  colors = theme.colors;
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        type = "small";
        padding.top = 1;
      };

      display = {
        separator = "  ";
        color = {
          keys = colors.accent;
          title = colors.accent;
          output = colors.foreground;
          separator = colors.muted;
        };
      };

      modules = [
        "title"
        "separator"
        "os"
        "kernel"
        "uptime"
        "packages"
        "shell"
        "wm"
        "terminal"
        { type = "cpu"; }
        { type = "gpu"; }
        "memory"
        "disk"
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
