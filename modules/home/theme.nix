{ pkgs, theme, ... }:
let
  colors = theme.colors;
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.phinger-cursors;
    name = theme.cursor.name;
    size = theme.cursor.size;
    gtk.enable = true;
  };

  # Native applications and portal dialogs use the same dark appearance.
  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
    icon-theme = "Papirus-Dark";
  };

  qt = {
    enable = true;
    platformTheme.name = "gtk3";
  };
}
