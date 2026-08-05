{ theme, ... }:
let
  colors = theme.colors;
in
{
  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 38;
      spacing = theme.spacing.small;

      modules-left = [
        "niri/workspaces"
        "niri/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "niri/language"
        "tray"
        "network"
        "wireplumber"
        "backlight"
        "battery"
      ];

      "niri/workspaces" = {
        format = "{icon}";
        format-icons = {
          active = "●";
          default = "○";
        };
      };

      "niri/window" = {
        format = "{title}";
        max-length = 56;
        separate-outputs = true;
      };

      clock = {
        format = "{:%H:%M}";
        format-alt = "{:%A, %d %B}";
        tooltip-format = "<tt><small>{calendar}</small></tt>";
      };

      "niri/language" = {
        format = "{}";
        format-en = "EN";
        format-ru = "RU";
      };

      tray = {
        icon-size = 17;
        spacing = theme.spacing.small;
      };

      network = {
        format-wifi = "󰤨  {signalStrength}%";
        format-ethernet = "󰈀";
        format-disconnected = "󰤭";
        tooltip-format = "{ifname}: {ipaddr}";
      };

      wireplumber = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 muted";
        format-icons = [ "󰕿" "󰖀" "󰕾" ];
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        on-click-right = "pavucontrol";
      };

      backlight = {
        format = "󰃠 {percent}%";
        on-scroll-up = "brightnessctl set 5%+";
        on-scroll-down = "brightnessctl set 5%-";
      };

      battery = {
        interval = 30;
        states = {
          warning = 25;
          critical = 10;
        };
        format = "{icon} {capacity}%";
        format-charging = "󰂄 {capacity}%";
        format-icons = [ "󰁺" "󰁼" "󰁾" "󰂀" "󰁹" ];
      };
    };

    style = ''
      * {
        border: none;
        min-height: 0;
        font-family: "${theme.font.mono}";
        font-size: ${toString theme.font.size}px;
      }

      window#waybar {
        background: alpha(${colors.background}, ${theme.opacity.surface});
        color: ${colors.foreground};
      }

      #workspaces,
      #window,
      #clock,
      #language,
      #tray,
      #network,
      #wireplumber,
      #backlight,
      #battery {
        margin: 4px 0;
        padding: 0 ${toString theme.spacing.medium}px;
        border-radius: ${toString theme.radius.small}px;
        background: alpha(${colors.surface}, 0.90);
      }

      #workspaces {
        padding: 0 3px;
      }

      #workspaces button {
        min-width: 28px;
        margin: 0 2px;
        padding: 0 5px;
        border-radius: ${toString theme.radius.small}px;
        color: ${colors.muted};
      }

      #workspaces button.active,
      #workspaces button:hover {
        color: ${colors.accent};
        background: alpha(${colors.accent}, 0.12);
      }

      #window {
        color: ${colors.muted};
      }

      /* niri/window sets .empty on the whole bar when the workspace has no
         window; collapse the pill instead of showing an empty background. */
      window#waybar.empty #window {
        margin: 0;
        padding: 0;
        background: transparent;
      }

      #battery.warning {
        color: ${colors.yellow};
      }

      #battery.critical {
        color: ${colors.red};
      }
    '';
  };
}
