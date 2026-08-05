{ theme, ... }:
let
  colors = theme.colors;
in
{
  programs.kitty = {
    enable = true;
    font = {
      name = theme.font.mono;
      size = theme.font.size;
    };

    settings = {
      background = colors.background;
      # Enough translucency for Niri's blur and grain to read as frosted glass.
      background_opacity = theme.opacity.surface;
      background_blur = 1;
      foreground = colors.foreground;
      selection_background = colors.accent;
      selection_foreground = colors.background;
      cursor = colors.accent;
      cursor_text_color = colors.background;

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
  };
}
