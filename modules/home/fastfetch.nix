{ theme, pkgs, ... }:
let
  colors = theme.colors;
in
{
  programs.fastfetch = {
    enable = true;

    settings = {
      # Rendered via kitty's graphics protocol (same as icat) instead of
      # blocky ASCII art; only displays correctly in kitty or other
      # terminals that support the kitty image protocol.
      # kitty-direct (not kitty) because file-based transmission fails to
      # display here even though the path is readable.
      logo = {
        type = "kitty-direct";
        source = "${pkgs.nixos-icons}/share/icons/hicolor/512x512/apps/nix-snowflake.png";
        width = 24;
        height = 12;
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
