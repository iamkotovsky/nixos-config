# Values shared by every visual profile. Individual profiles provide colors and
# their wallpaper, keeping a theme switch to one declarative selection.
{
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
