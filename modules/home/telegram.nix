{
  lib,
  pkgs,
  theme,
  ...
}:
let
  # Telegram needs solid shades: `mix a b t` moves `a` a fraction `t` towards `b`.
  inherit (theme)
    colors
    mix
    render
    number
    ;

  # Hover and pressed shades follow the design system's fill levels.
  rest = number theme.fill.rest;
  hover = number theme.fill.hover;
  pressed = number theme.fill.pressed;
  # The soft accent tint for outgoing bubbles (the selected chat is neutral,
  # SELECTED below).
  tintBubble = mix colors.surface colors.accent theme.tint.bubble;

  # Each attribute fills the matching @NAME@ placeholder in the template.
  substitutions = {
    BACKGROUND = colors.background;
    SURFACE = colors.surface;
    FOREGROUND = colors.foreground;
    MUTED = colors.muted;
    ACCENT = colors.accent;
    RED = colors.red;
    GREEN = colors.green;
    YELLOW = colors.yellow;
    BLUE = colors.blue;
    MAGENTA = colors.magenta;
    CYAN = colors.cyan;
    HOVER = mix colors.background colors.foreground rest;
    PRESSED = mix colors.background colors.foreground hover;
    SURFACE_HOVER = mix colors.surface colors.foreground rest;
    SURFACE_PRESSED = mix colors.surface colors.foreground hover;
    ACCENT_HOVER = mix colors.accent colors.foreground hover;
    ACCENT_PRESSED = mix colors.accent colors.foreground pressed;
    RED_HOVER = mix colors.background colors.red rest;
    RED_PRESSED = mix colors.background colors.red hover;
    TINT = tintBubble;
    # The selected chat and folder: the neutral selection grey, never the
    # accent (that stays on outgoing bubbles).
    SELECTED = mix colors.background colors.foreground theme.tint.selection;
    SELECTED_PRESSED = mix colors.background colors.foreground (theme.tint.selection + rest);
    TINT_PRESSED = mix colors.surface colors.accent theme.tint.bubblePressed;
    # Secondary text (dates, previews) on the tint: readable but quieter.
    TINT_TEXT = mix tintBubble colors.foreground 0.6;
    DISABLED = mix colors.background colors.foreground 0.35;
    # Darker than the background: gaps between settings sections.
    DEEP = mix colors.background "#000000" 0.4;
    RIM = mix colors.background colors.foreground (number theme.opacity.rim);
    FILL_REST = colors.foreground + theme.alphaHex theme.fill.rest;
    SCROLL = colors.foreground + theme.alphaHex theme.scrollbar.rest;
    SCROLL_HOVER = colors.foreground + theme.alphaHex theme.scrollbar.hover;
  };

  colorsFile = render substitutions ../../config/telegram/colors.tdesktop-theme;

  themePackage = pkgs.runCommand "telegram-${theme.active}-theme" { } ''
    mkdir -p $out
    cp ${pkgs.writeText "colors.tdesktop-theme" colorsFile} colors.tdesktop-theme
    # Chat background: a quiet vertical gradient, background to a step
    # towards the surface. No shapes or pattern.
    ${lib.getExe pkgs.imagemagick} \
      -size 1920x1080 gradient:"${colors.background}-${mix colors.background colors.surface 0.6}" \
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
