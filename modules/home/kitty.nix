{ lib, theme, ... }:
let
  inherit (theme) colors;
  inherit (import ../../theme/color.nix { inherit lib; }) mix;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = theme.font.mono;
      size = theme.font.size;
    };

    settings = {
      inherit (colors) background foreground;
      # Enough translucency for Niri's blur and grain to read as frosted glass.
      background_opacity = theme.opacity.terminal;
      background_blur = 1;
      # Selection is a neutral grey that keeps the text's own colours, as in
      # Helix and yazi; links are the accent. The cursor stays neutral too.
      selection_background = mix colors.background colors.foreground theme.tint.selection;
      selection_foreground = "none";
      cursor = colors.foreground;
      cursor_text_color = colors.background;
      url_color = colors.accent;

      color0 = colors.background;
      color1 = colors.red;
      color2 = colors.green;
      color3 = colors.yellow;
      color4 = colors.blue;
      color5 = colors.magenta;
      color6 = colors.cyan;
      color7 = colors.foreground;
      color8 = colors.muted;
      color9 = colors.red;
      color10 = colors.green;
      color11 = colors.yellow;
      color12 = colors.blue;
      color13 = colors.magenta;
      color14 = colors.cyan;
      color15 = colors.foreground;

      window_padding_width = theme.spacing.small;
      tab_bar_style = "hidden";
      scrollback_lines = 10000;
      cursor_shape = "beam";
      cursor_trail = 20;
    };

    # Copilot key: xkeyboard-config >= 2.44 reports it as XF86Assistant; some
    # stacks emit the raw Super+Shift+F23 chord instead, hence both bindings.
    keybindings = {
      "XF86Assistant" = "launch --cwd=current --type=tab claude";
      "shift+super+f23" = "launch --cwd=current --type=tab claude";
    };
  };
}
