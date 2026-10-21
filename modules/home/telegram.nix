{ lib, pkgs, theme, ... }:
let
  c = theme.colors;

  # Telegram needs solid shades: `mix a b t` moves `a` a fraction `t` towards `b`.
  inherit (import ../../theme/color.nix { inherit lib; }) mix;
  fraction = builtins.fromJSON;

  # Hover and pressed shades follow the design system's fill levels.
  rest = fraction theme.fill.rest;
  hover = fraction theme.fill.hover;
  pressed = fraction theme.fill.pressed;
  # The soft accent tint for outgoing bubbles (the selected chat is neutral,
  # SELECTED below).
  tint = 0.22;
  tintPressed = 0.32;
  tintBubble = mix c.surface c.accent tint;

  # Each attribute fills the matching @NAME@ placeholder in the template.
  substitutions = {
    BACKGROUND = c.background;
    SURFACE = c.surface;
    FOREGROUND = c.foreground;
    MUTED = c.muted;
    ACCENT = c.accent;
    RED = c.red;
    GREEN = c.green;
    YELLOW = c.yellow;
    BLUE = c.blue;
    MAGENTA = c.magenta;
    CYAN = c.cyan;
    HOVER = mix c.background c.foreground rest;
    PRESSED = mix c.background c.foreground hover;
    SURFACE_HOVER = mix c.surface c.foreground rest;
    SURFACE_PRESSED = mix c.surface c.foreground hover;
    ACCENT_HOVER = mix c.accent c.foreground hover;
    ACCENT_PRESSED = mix c.accent c.foreground pressed;
    RED_HOVER = mix c.background c.red rest;
    RED_PRESSED = mix c.background c.red hover;
    TINT = tintBubble;
    # The selected chat and folder: the neutral selection grey, never the
    # accent (that stays on outgoing bubbles).
    SELECTED = mix c.background c.foreground theme.tint.selection;
    SELECTED_PRESSED = mix c.background c.foreground (theme.tint.selection + rest);
    TINT_PRESSED = mix c.surface c.accent tintPressed;
    # Secondary text (dates, previews) on the tint: readable but quieter.
    TINT_TEXT = mix tintBubble c.foreground 0.6;
    DISABLED = mix c.background c.foreground 0.35;
    # Darker than the background: gaps between settings sections.
    DEEP = mix c.background "#000000" 0.4;
    RIM = mix c.background c.foreground (fraction theme.opacity.rim);
    FILL_REST = c.foreground + theme.alphaHex theme.fill.rest;
    SCROLL = c.foreground + theme.alphaHex "0.20";
    SCROLL_HOVER = c.foreground + theme.alphaHex "0.30";
  };

  colorsFile = builtins.replaceStrings
    (map (name: "@${name}@") (builtins.attrNames substitutions))
    (builtins.attrValues substitutions)
    (builtins.readFile ../../config/telegram/colors.tdesktop-theme);

  themePackage = pkgs.runCommand "telegram-${theme.active}-theme" { } ''
    mkdir -p $out
    cp ${pkgs.writeText "colors.tdesktop-theme" colorsFile} colors.tdesktop-theme
    # Chat background: a quiet vertical gradient, background to a step
    # towards the surface. No shapes or pattern.
    ${lib.getExe pkgs.imagemagick} \
      -size 1920x1080 gradient:"${c.background}-${mix c.background c.surface 0.6}" \
      -strip -quality 95 background.jpg
    # Fixed mtime + -X keep the ZIP byte-identical across rebuilds.
    touch -t 198001010000 colors.tdesktop-theme background.jpg
    TZ=UTC ${pkgs.zip}/bin/zip -j -q -X $out/${theme.active}.tdesktop-theme \
      colors.tdesktop-theme background.jpg
  '';
in
{
  # Import once from Settings -> Chat Settings -> theme -> From file. Telegram
  # has no auto-discovered theme directory, so this only ships the artifact.
  xdg.dataFile."telegram-themes/${theme.active}.tdesktop-theme".source =
    "${themePackage}/${theme.active}.tdesktop-theme";
}
