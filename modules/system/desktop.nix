{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
    # Use the lightweight GTK portal chooser instead of pulling in Nautilus.
    useNautilus = false;
  };

  # Niri ships with XWayland disabled; X11-only apps (e.g. zoom-us) need this
  # to display a window at all. Spawned via config.kdl's spawn-at-startup,
  # which niri has explicit support for waiting on.
  environment.systemPackages = [ pkgs.xwayland-satellite ];

  services = {
    greetd = {
      enable = true;
      useTextGreeter = true;
      settings.default_session = {
        command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
        user = "greeter";
      };
    };

    # Lets udiskie (see home/udiskie.nix) mount/unmount removable drives without root.
    udisks2.enable = true;
  };

  security = {
    polkit.enable = true;
    pam.services.hyprlock = { };

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
