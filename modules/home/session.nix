{ config, lib, pkgs, ... }:
let
  niri = "${pkgs.niri}/bin/niri";
  jq = lib.getExe pkgs.jq;
  systemctl = "${pkgs.systemd}/bin/systemctl";
  notify = "${pkgs.libnotify}/bin/notify-send";

  # `sessionctl lock|suspend|logout|reboot|poweroff`, used by the control
  # panel's Power page. Leaving the session goes in an order that doesn't
  # break anything (niri's plain `quit` kills the compositor first, so every
  # client and service loses its display at once and crashes):
  #   1. ask every window to close, as its X button would, so apps save state;
  #      if one stays open (unsaved work, a confirm dialog) stop and say so;
  #   2. log out: stop graphical-session.target, so systemd stops the bar,
  #      wallpaper, portals and the rest while niri still runs, then niri;
  #      reboot / power off: systemd stops the session in the same order.
  # It re-runs itself in a transient unit first: started from the bar, it
  # would otherwise be stopped along with the bar halfway through. The caller
  # waits for the unit (the unit carries on if the caller dies) and gets its
  # exit code: 3 means a window stayed open, which the lock screen shows, as
  # it hides the notification.
  sessionctl = pkgs.writeShellScriptBin "sessionctl" ''
    set -u
    action=''${1:-}

    windows() {
      ${niri} msg -j windows 2>/dev/null || echo '[]'
    }

    close_windows() {
      for id in $(windows | ${jq} -r '.[].id'); do
        ${niri} msg action close-window --id "$id"
      done

      for _ in $(${pkgs.coreutils}/bin/seq 50); do
        [ "$(windows | ${jq} length)" -eq 0 ] && return 0
        ${pkgs.coreutils}/bin/sleep 0.1
      done

      left=$(windows | ${jq} -r '[.[] | .app_id // .title] | unique | join(", ")')
      ${notify} -a Session -u critical "$1 stopped" "Still open: $left"
      return 1
    }

    case "$action" in
      lock)
        exec ${config.lockScreen.script}
        ;;
      suspend)
        exec ${systemctl} suspend
        ;;
      logout | reboot | poweroff)
        if [ "''${SESSIONCTL_DETACHED:-}" != 1 ]; then
          exec ${pkgs.systemd}/bin/systemd-run --user --collect --quiet --wait \
            --unit=sessionctl --setenv=SESSIONCTL_DETACHED=1 \
            --setenv=WAYLAND_DISPLAY="''${WAYLAND_DISPLAY:-}" \
            --setenv=NIRI_SOCKET="''${NIRI_SOCKET:-}" \
            "$0" "$action"
        fi
        ;;
      *)
        echo "usage: sessionctl lock|suspend|logout|reboot|poweroff" >&2
        exit 2
        ;;
    esac

    case "$action" in
      logout)
        close_windows "Log out" || exit 3
        exec ${systemctl} --user stop graphical-session.target
        ;;
      reboot)
        close_windows "Restart" || exit 3
        exec ${systemctl} reboot
        ;;
      poweroff)
        close_windows "Shut down" || exit 3
        exec ${systemctl} poweroff
        ;;
    esac
  '';
in
{
  home.packages = [ sessionctl ];
}
