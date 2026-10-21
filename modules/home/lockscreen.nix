{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The lock screen is a Quickshell process of its own (config/quickshell/
  # lock.qml), separate from the shell, run as the `lockscreen` user unit:
  # the unit also guards against a second locker. It touches the marker below
  # once the session is securely locked, and removes it on unlock.
  #
  # Quickshell is launched through the profile, not a pinned store path: PAM
  # modules come from the current /etc/pam.d, so a locker baked into a
  # not-yet-restarted swayidle after a glibc bump can't load them and never
  # unlocks. The profile always matches the active generation.
  #
  # If the locker ever dies, niri keeps the session locked. From a TTY, run
  # `systemctl --user stop lockscreen; lock-screen` to start a fresh one.
  lockMarker = "$XDG_RUNTIME_DIR/quickshell-lock.secure";
  lockScreen = pkgs.writeShellScriptBin "lock-screen" ''
    if ! ${pkgs.systemd}/bin/systemctl --user is-active --quiet lockscreen; then
      rm -f "${lockMarker}"
      ${pkgs.systemd}/bin/systemd-run \
        --user \
        --unit=lockscreen \
        --collect \
        ${config.home.profileDirectory}/bin/quickshell \
        -p ${config.xdg.configHome}/quickshell/lock.qml
    fi
  '';
  lockScreenExe = "${lockScreen}/bin/lock-screen";

  # lock-screen returns as soon as the locker is started; before suspending,
  # wait until the session is securely locked (the marker), so the desktop
  # never flashes on resume.
  lockBeforeSleep = pkgs.writeShellScript "lock-before-sleep" ''
    ${lockScreenExe}

    for _ in $(${pkgs.coreutils}/bin/seq 30); do
      [ -e "${lockMarker}" ] && break
      ${pkgs.coreutils}/bin/sleep 0.1
    done

    ${pkgs.coreutils}/bin/sleep 0.2
  '';

  # Caffeine (a toggle in the quickshell control panel) creates this file;
  # while it exists, idle only turns the display off: no idle lock, no idle
  # suspend. Manual locking and locking before sleep (lid, suspend key) are
  # unaffected. It lives in the runtime dir, so it resets on logout.
  idleLock = pkgs.writeShellScript "idle-lock" ''
    [ -e "$XDG_RUNTIME_DIR/caffeine" ] || exec ${lockScreenExe}
  '';

  idleSuspend = pkgs.writeShellScript "idle-suspend" ''
    [ -e "$XDG_RUNTIME_DIR/caffeine" ] || exec ${pkgs.systemd}/bin/systemctl suspend
  '';

  # -w makes swayidle wait for before-sleep to finish while holding logind's
  # sleep delay lock.
  idleManager = pkgs.writeShellScript "niri-idle-manager" ''
    exec ${pkgs.swayidle}/bin/swayidle -w \
      timeout 270 ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-off-monitors"} \
        resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"} \
      timeout 300 ${lib.escapeShellArg (toString idleLock)} \
      timeout 600 ${lib.escapeShellArg (toString idleSuspend)} \
      before-sleep ${lib.escapeShellArg (toString lockBeforeSleep)} \
      after-resume ${lib.escapeShellArg "${pkgs.niri}/bin/niri msg action power-on-monitors"}
  '';
in
{
  # Exposed so the niri keybind can call the same guarded launcher instead of
  # starting a second locker.
  options.lockScreen.script = lib.mkOption {
    type = lib.types.str;
    readOnly = true;
    default = lockScreenExe;
    description = "Path to the guarded lock screen launcher (Quickshell lock).";
  };

  config = {
    home.packages = [
      # `lock-screen` on PATH, e.g. to re-lock from a TTY.
      lockScreen
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
  };
}
