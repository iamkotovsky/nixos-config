{
  config,
  pkgs,
  theme,
  ...
}:
let
  # Mod+P fallback when the bar (its `powerprofile` IPC) isn't running: cycles
  # power-saver -> balanced -> performance and confirms with a notification.
  cyclePowerProfile = pkgs.writeShellScript "cycle-power-profile" ''
    ppc=${pkgs.power-profiles-daemon}/bin/powerprofilesctl

    case "$($ppc get)" in
      power-saver) next=balanced name=Balanced ;;
      balanced) next=performance name=Performance ;;
      *) next=power-saver name="Power saver" ;;
    esac

    $ppc set "$next" &&
      ${pkgs.libnotify}/bin/notify-send -a Power -t 1500 "Power mode" "$name"
  '';

  rawConfig = builtins.readFile ../../config/niri/config.kdl;
  themedConfig =
    builtins.replaceStrings
      [
        "@BACKGROUND@"
        "@SURFACE@"
        "@ACCENT@"
        "@RADIUS@"
        "@LOCK_SCRIPT@"
        "@POWER_PROFILE_SCRIPT@"
        "@CURSOR_THEME@"
        "@CURSOR_SIZE@"
        "@GAP@"
      ]
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
