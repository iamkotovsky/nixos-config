{
  lib,
  pkgs,
  theme,
  ...
}:
let
  inherit (theme) colors;

  # The login screen in the design system's colours. The Linux console only
  # has its 16-colour palette, so the palette itself is the theme (the same
  # slots as kitty's) and tuigreet names slots: darkgray is muted, white the
  # foreground, magenta the accent (only the action keys), black the
  # background.
  greeterTheme = lib.concatStringsSep ";" [
    "container=black"
    "border=darkgray"
    "title=white"
    "text=white"
    "greet=darkgray"
    "time=darkgray"
    "prompt=darkgray"
    "input=white"
    "action=darkgray"
    "button=magenta"
  ];
in
{
  console.colors = map theme.hex [
    colors.background
    colors.red
    colors.green
    colors.yellow
    colors.blue
    colors.accent
    colors.cyan
    colors.foreground
    colors.muted
    colors.red
    colors.green
    colors.yellow
    colors.blue
    colors.accent
    colors.cyan
    colors.foreground
  ];

  programs.niri = {
    enable = true;
    # Use the lightweight GTK portal chooser instead of pulling in Nautilus.
    useNautilus = false;
  };

  # X11 support: niri has no built-in XWayland, and starts this from PATH on
  # demand when an X11 app connects (it also exports DISPLAY).
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services = {
    greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --theme '${greeterTheme}' --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };

    # Lets udiskie (see home/udiskie.nix) mount/unmount removable drives without root.
    udisks2.enable = true;
  };

  security = {
    polkit.enable = true;
    # The Quickshell lock screen (config/quickshell/lock.qml).
    pam.services.quickshell-lock = { };

    # Show asterisk feedback while typing the sudo password.
    sudo.extraConfig = ''
      Defaults pwfeedback
    '';
  };

  # Niri integrates screencasting with the GNOME portal; GTK supplies file pickers.
  xdg.portal = {
    enable = true;
    # The Niri module adds the GNOME backend used for screencasting.
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = [
    pkgs.nerd-fonts.jetbrains-mono
    # UI font for the shell; see theme/base.nix.
    pkgs.inter
    # Rounded icon font for the quickshell bar.
    pkgs.material-symbols
  ];
}
