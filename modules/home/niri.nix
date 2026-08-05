{ config, theme, ... }:
let
  rawConfig = builtins.readFile ../../config/niri/config.kdl;
  themedConfig = builtins.replaceStrings
    [ "@BACKGROUND@" "@SURFACE@" "@ACCENT@" "@RADIUS@" "@LOCK_SCRIPT@" "@CURSOR_THEME@" "@CURSOR_SIZE@" ]
    [
      theme.colors.background
      theme.colors.surface
      theme.colors.accent
      (toString theme.radius.medium)
      config.lockScreen.script
      theme.cursor.name
      (toString theme.cursor.size)
    ]
    rawConfig;
in
{
  # Keep compositor configuration in its native format for easy live editing.
  xdg.configFile."niri/config.kdl".text = themedConfig;
}
