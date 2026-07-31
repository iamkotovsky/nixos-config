{ pkgs, ... }:
{
  programs.niri = {
    enable = true;
    # Use the lightweight GTK portal chooser instead of pulling in Nautilus.
    useNautilus = false;
  };

  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd ${pkgs.niri}/bin/niri-session";
      user = "greeter";
    };
  };

  security.polkit.enable = true;
  security.pam.services.swaylock = { };

  # Niri integrates screencasting with the GNOME portal; GTK supplies file pickers.
  xdg.portal = {
    enable = true;
    # The Niri module adds the GNOME backend used for screencasting.
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  fonts.packages = [ pkgs.nerd-fonts.jetbrains-mono ];
}
