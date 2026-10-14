{
  config,
  pkgs,
  theme,
  ...
}:
let
  # Cycles power-saver -> balanced -> performance and confirms via mako.
  cyclePowerProfile = pkgs.writeShellScript "cycle-power-profile" ''
    ppc=${pkgs.power-profiles-daemon}/bin/powerprofilesctl

    case "$($ppc get)" in
      power-saver) next=balanced ;;
      balanced) next=performance ;;
      *) next=power-saver ;;
    esac

    $ppc set "$next" &&
      ${pkgs.libnotify}/bin/notify-send -a Power -t 1500 "Power profile" "$next"
  '';

  rawConfig = builtins.readFile ../../config/niri/config.kdl;
  themedConfig = builtins.replaceStrings
    [ "@BACKGROUND@" "@SURFACE@" "@ACCENT@" "@RADIUS@" "@LOCK_SCRIPT@" "@POWER_PROFILE_SCRIPT@" "@CURSOR_THEME@" "@CURSOR_SIZE@" "@GAP@" ]
    [
      theme.colors.background
      theme.colors.surface
      theme.colors.accent
      (toString theme.radius.medium)
      config.lockScreen.script
      (toString cyclePowerProfile)
      theme.cursor.name
      (toString theme.cursor.size)
      (toString theme.gap)
    ]
    rawConfig;
in
{
  # Keep compositor configuration in its native format for easy live editing.
  xdg.configFile."niri/config.kdl".text = themedConfig;
}
