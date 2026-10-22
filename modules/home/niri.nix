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

  inherit (theme) colors render;

  # Each attribute fills the matching @NAME@ placeholder in config.kdl.
  themedConfig = render {
    BACKGROUND = colors.background;
    SURFACE = colors.surface;
    ACCENT = colors.accent;
    RADIUS = toString theme.radius.medium;
    LOCK_SCRIPT = config.lockScreen.script;
    POWER_PROFILE_SCRIPT = toString cyclePowerProfile;
    CURSOR_THEME = theme.cursor.name;
    CURSOR_SIZE = toString theme.cursor.size;
    GAP = toString theme.gap;
  } ../../config/niri/config.kdl;
in
{
  # Keep compositor configuration in its native format for easy live editing.
  xdg.configFile."niri/config.kdl".text = themedConfig;
}
