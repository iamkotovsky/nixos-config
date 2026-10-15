{ config, lib, pkgs, theme, ... }:
let
  inherit (theme) colors;

  keyboardLayout = pkgs.writeShellScript "hyprlock-keyboard-layout" ''
    layout="$(${pkgs.niri}/bin/niri msg keyboard-layouts | ${pkgs.gawk}/bin/awk '/^ \*/ { print $3; exit }')"

    case "$layout" in
      English) printf 'EN\n' ;;
      Russian) printf 'RU\n' ;;
      *) printf '%s\n' "$layout" ;;
    esac
  '';

  batteryStatus = pkgs.writeShellScript "hyprlock-battery-status" ''
    batteries=(/sys/class/power_supply/BAT*/capacity)
    if [[ -e "''${batteries[0]}" ]]; then
      capacity="$(<"''${batteries[0]}")"
      status_file="''${batteries[0]%/capacity}/status"

      if [[ -r "$status_file" && "$(<"$status_file")" == "Charging" ]]; then
        icon='󰂄'
      elif (( capacity <= 20 )); then
        icon='󰁺'
      elif (( capacity <= 40 )); then
        icon='󰁼'
      elif (( capacity <= 60 )); then
        icon='󰁾'
      elif (( capacity <= 80 )); then
        icon='󰂀'
      else
        icon='󰁹'
      fi

      printf '%s %s%%\n' "$icon" "$capacity"
    fi
  '';

  # hyprlock is launched through the profile, not a pinned store path: PAM
  # modules come from the current /etc/pam.d, so a hyprlock baked into a
  # not-yet-restarted swayidle after a glibc bump can't load them and never
  # unlocks. The profile always matches the active generation.
  lockScreen = pkgs.writeShellScript "lock-screen" ''
    if ! ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null; then
      ${pkgs.systemd}/bin/systemd-run \
        --user \
        --unit=hyprlock \
        --collect \
        ${config.home.profileDirectory}/bin/hyprlock
    fi
  '';

  # lockScreen returns as soon as hyprlock is launched; before suspending, wait
  # until it is actually running and has drawn its first frame, so the desktop
  # never flashes on resume.
  lockBeforeSleep = pkgs.writeShellScript "lock-before-sleep" ''
    ${lockScreen}

    for _ in {1..20}; do
      if ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null; then
        break
      fi

      ${pkgs.coreutils}/bin/sleep 0.1
    done

    ${pkgs.coreutils}/bin/sleep 0.5
  '';

  # -w makes swayidle wait for before-sleep to finish while holding logind's
  # sleep delay lock.
  idleManager = pkgs.writeShellScript "niri-idle-manager" ''
    exec ${pkgs.swayidle}/bin/swayidle -w \
      timeout 270 ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-off-monitors"} \
        resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"} \
      timeout 300 ${lib.escapeShellArg (toString lockScreen)} \
      timeout 600 ${lib.escapeShellArg "${pkgs.systemd}/bin/systemctl suspend"} \
      before-sleep ${lib.escapeShellArg (toString lockBeforeSleep)} \
      after-resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"}
  '';

  # Each attribute fills the matching @NAME@ placeholder in hyprlock.conf.
  substitutions = {
    WALLPAPER = config.wallpaper.path;
    DATE = "${pkgs.coreutils}/bin/date";
    KEYBOARD_LAYOUT = toString keyboardLayout;
    BATTERY_STATUS = toString batteryStatus;
    FONT = theme.font.mono;
    BACKGROUND_HEX = theme.hex colors.background;
    SURFACE_HEX = theme.hex colors.surface;
    FOREGROUND_HEX = theme.hex colors.foreground;
    MUTED_HEX = theme.hex colors.muted;
    ACCENT_HEX = theme.hex colors.accent;
    BLUE_HEX = theme.hex colors.blue;
    RED_HEX = theme.hex colors.red;
    RADIUS_LARGE = toString theme.radius.large;
    RAISED_ALPHA = theme.alphaHex theme.opacity.raised;
  };
in
{
  # Exposed so the niri keybind can call the same idle-safe launcher instead
  # of spawning hyprlock directly and risking a duplicate instance.
  options.lockScreen.script = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    default = toString lockScreen;
    description = "Path to the pgrep-guarded hyprlock launcher script.";
  };

  config = {
    home.packages = [
      pkgs.hyprlock
      pkgs.swayidle
    ];

    systemd.user.services.swayidle = {
      Unit = {
        Description = "Idle manager for Niri";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = idleManager;
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    # Layout lives in its native format; only theme values and script paths
    # are injected here.
    xdg.configFile."hypr/hyprlock.conf".text = builtins.replaceStrings
      (map (name: "@${name}@") (builtins.attrNames substitutions))
      (builtins.attrValues substitutions)
      (builtins.readFile ../../config/hypr/hyprlock.conf);
  };
}
