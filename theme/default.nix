# One explicit palette feeds terminal, editor and QML configuration.
{
  colors = {
    background = "#000000";
    surface = "#0a0a0a";
    foreground = "#d8d8d8";
    muted = "#8c8c8c";
    accent = "#9aafc2";
    red = "#c9959a";
    green = "#9ebc98";
    yellow = "#c8b78f";
    blue = "#9aafc2";
    magenta = "#b3a0c1";
    cyan = "#91b8b0";
  };

  font = {
    mono = "JetBrainsMono Nerd Font";
    size = 16;
  };

  radius = {
    small = 6;
    medium = 10;
  };

  spacing = {
    small = 6;
    medium = 10;
  };

  cursor = {
    name = "phinger-cursors-dark";
    size = 28;
  };

  opacity = {
    # Shared translucency for kitty, waybar, rofi and mako backgrounds; kept as a
    # string so it drops into config text without float-formatting artifacts.
    surface = "0.84";
  };

  # Strips the leading "#" for consumers that want bare hex (hyprlock, rofi, mako).
  hex = color: builtins.substring 1 6 color;

  # Renders an opacity string like "0.84" as a two-digit hex alpha suffix ("d6").
  alphaHex =
    opacity:
    let
      digits = "0123456789abcdef";
      n = builtins.floor (builtins.fromJSON opacity * 255 + 0.5);
      hi = n / 16;
      lo = n - hi * 16;
    in
    "${builtins.substring hi 1 digits}${builtins.substring lo 1 digits}";
}
