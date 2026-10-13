{ config, lib, pkgs, theme, ... }:
let
  setInitialWallpaper = pkgs.writeShellScript "awww-set-initial-wallpaper" ''
    if [[ ! -f ${builtins.toJSON config.wallpaper.path} ]]; then
      exit 0
    fi

    for _ in {1..20}; do
      if ${pkgs.awww}/bin/awww query >/dev/null 2>&1; then
        exec ${pkgs.awww}/bin/awww img ${builtins.toJSON config.wallpaper.path} \
          --transition-type ${theme.wallpaper.transition} \
          --transition-duration 1
      fi

      ${pkgs.coreutils}/bin/sleep 0.1
    done

    exit 1
  '';
in
{
  # Each declarative theme owns a wallpaper. This remains the single path that
  # both awww and hyprlock consume.
  options.wallpaper.path = lib.mkOption {
    type = lib.types.str;
    # Interpolating the path copies only the active wallpaper into the store.
    default = "${../../theme/wallpapers + "/${theme.wallpaper.file}"}";
    readOnly = true;
    description = "Store path of the active theme's wallpaper (from theme/wallpapers).";
  };

  config.home.packages = [ pkgs.awww ];

  config.systemd.user.services = {
    awww-daemon = {
      Unit = {
        Description = "Animated Wayland wallpaper daemon";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        Requisite = [ "graphical-session.target" ];
      };

      Service = {
        ExecStart = "${pkgs.awww}/bin/awww-daemon";
        Restart = "on-failure";
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };

    awww-wallpaper = {
      Unit = {
        Description = "Set the initial wallpaper";
        After = [ "awww-daemon.service" ];
        Requires = [ "awww-daemon.service" ];
        PartOf = [ "graphical-session.target" ];
      };

      Service = {
        Type = "oneshot";
        ExecStart = setInitialWallpaper;
      };

      Install.WantedBy = [ "graphical-session.target" ];
    };
  };
}
