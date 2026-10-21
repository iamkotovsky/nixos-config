# Values shared by every visual profile. Individual profiles provide colors and
# their wallpaper, keeping a theme switch to one declarative selection.
{
  # ui: the shell (bar, panel, launcher, notifications, lock screen); mono: terminal,
  # code, and Nerd Font glyphs.
  font = {
    ui = "Inter";
    mono = "JetBrainsMono Nerd Font";
    size = 16;
  };

  # Type scale; body is font.size. See .claude/rules/design.md for roles.
  fontSizes = {
    caption = 12;
    small = 14;
    title = 18;
  };

  # small: list rows, thumbnails; medium: windows, bar pills, tiles;
  # large: cards (panel, launcher, notifications). "Full" is height / 2.
  radius = {
    small = 6;
    medium = 10;
    large = 16;
  };

  # 4px grid: xs tight icon/label, small between items in a row, medium inside
  # tiles and between rows, large card padding.
  spacing = {
    xs = 4;
    small = 8;
    medium = 12;
    large = 16;
  };

  # One gap for the whole desktop: screen edges, between windows, and around
  # the floating bar (niri `gaps` and the quickshell bar both use it).
  gap = 8;

  # Durations in ms. fast: hover/color; normal: fades, values, reflow; slow:
  # surfaces entering (OutCubic; OutBack with this overshoot only for real
  # travel). Exits run at `exitScale` of the duration.
  motion = {
    fast = 150;
    normal = 250;
    slow = 350;
    overshoot = "1.2";
    exitScale = "0.7";
    # Scale of a pressed control.
    pressScale = "0.96";
  };

  # Material Symbols stroke weight: a touch heavier than regular so outlined
  # glyphs hold up next to the UI font.
  iconWeight = 450;

  # Soft shadows, only for elevation and hover lift (blur radius and y offset
  # in px). `pad` is the room layer windows reserve around a shadowed shape so
  # it is never clipped.
  elevation = {
    raised = {
      blur = 6;
      y = 2;
      opacity = "0.25";
    };
    floating = {
      blur = 20;
      y = 6;
      opacity = "0.35";
    };
    pad = 24;
  };

  cursor = {
    name = "phinger-cursors-dark";
    size = 28;
  };

  # Strings, so they drop into config text without float-formatting artifacts.
  opacity = {
    # Kitty: denser than the shell's glass, for reading.
    terminal = "0.84";
    # Frosted glass levels: strip is the bar backdrop (on `background`);
    # raised is bar pills, overlay is panel/launcher/notification/OSD cards
    # (both on `surface`).
    strip = "0.55";
    raised = "0.62";
    overlay = "0.55";
    # Light rim around glass, and the faint top highlight inside it.
    rim = "0.12";
    highlight = "0.06";
  };

  # Foreground fills on glass for chips, tiles, buttons and launcher rows, by
  # state; `rim` is their own hairline border.
  fill = {
    rest = "0.08";
    hover = "0.14";
    pressed = "0.20";
    rim = "0.08";
  };

  # Solid tints for apps that need opaque shades (`mix background colour t`,
  # theme/color.nix): selection is the neutral grey (towards the foreground,
  # never the accent) behind selected text, the selected chat and hovered
  # rows (Helix, yazi, kitty, bat, fzf, GTK, Telegram); diff and diffEmphasis are green
  # and red behind added and removed lines, and the changed words in them
  # (delta).
  tint = {
    selection = 0.25;
    diff = 0.15;
    diffEmphasis = 0.3;
  };

  # Strips the leading "#" for consumers that want bare hex (Telegram).
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
