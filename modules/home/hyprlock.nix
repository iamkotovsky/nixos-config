{ config, lib, pkgs, theme, ... }:
let
  colors = theme.colors;

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

  lockScreen = pkgs.writeShellScript "lock-screen" ''
    if ! ${pkgs.procps}/bin/pgrep -x hyprlock >/dev/null; then
      ${pkgs.systemd}/bin/systemd-run \
        --user \
        --unit=hyprlock \
        --collect \
        ${pkgs.hyprlock}/bin/hyprlock
    fi
  '';

  idleManager = pkgs.writeShellScript "niri-idle-manager" ''
    exec ${pkgs.swayidle}/bin/swayidle \
      timeout 300 ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-off-monitors"} \
        resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"} \
      timeout 600 ${lib.escapeShellArg "${pkgs.systemd}/bin/systemctl suspend"} \
      before-sleep ${lib.escapeShellArg (toString lockScreen)} \
      after-resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"}
  '';
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

  config.home.packages = [
    pkgs.hyprlock
    pkgs.swayidle
  ];

  config.systemd.user.services.swayidle = {
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

  config.xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
        hide_cursor = true
        immediate_render = true
        ignore_empty_input = true
    }

    background {
        monitor =
        path = ${config.wallpaper.path}
        color = rgb(${theme.hex colors.background})
        blur_passes = 3
        blur_size = 8
        noise = 0.02
        brightness = 0.58
        vibrancy = 0.12
    }

    label {
        monitor =
        text = cmd[update:1000] ${pkgs.coreutils}/bin/date +"%H:%M"
        color = rgb(${theme.hex colors.foreground})
        font_size = 104
        font_family = ${theme.font.mono}
        position = 0, 220
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:60000] ${pkgs.coreutils}/bin/date +"%A, %d %B"
        color = rgb(${theme.hex colors.muted})
        font_size = 23
        font_family = ${theme.font.mono}
        position = 0, 140
        halign = center
        valign = center
    }

    input-field {
        monitor =
        size = 520, 72
        outline_thickness = 3
        dots_size = 0.25
        dots_spacing = 0.18
        dots_center = true
        outer_color = rgb(${theme.hex colors.accent})
        inner_color = rgba(${theme.hex colors.surface}e6)
        font_color = rgb(${theme.hex colors.foreground})
        check_color = rgb(${theme.hex colors.blue})
        fail_color = rgb(${theme.hex colors.red})
        fade_on_empty = false
        placeholder_text = <span foreground="##${theme.hex colors.muted}">Password</span>
        fail_text = <span foreground="##${theme.hex colors.red}">$FAIL</span>
        rounding = 14
        position = 0, 20
        halign = center
        valign = center
    }

    label {
        monitor =
        text = cmd[update:500] ${keyboardLayout}
        color = rgb(${theme.hex colors.foreground})
        font_size = 22
        font_family = ${theme.font.mono}
        position = -170, -30
        halign = right
        valign = top
    }

    label {
        monitor =
        text = cmd[update:10000] ${batteryStatus}
        color = rgb(${theme.hex colors.foreground})
        font_size = 22
        font_family = ${theme.font.mono}
        position = -36, -30
        halign = right
        valign = top
    }
  '';
}
