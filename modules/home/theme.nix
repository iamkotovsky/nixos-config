{ pkgs, theme, ... }:
let
  accentCss = ''
    @define-color accent_color ${theme.colors.accent};
    @define-color accent_bg_color ${theme.colors.accent};
    @define-color accent_fg_color ${theme.colors.background};
  '';
in
{
  home.pointerCursor = {
    enable = true;
    package = pkgs.phinger-cursors;
    name = theme.cursor.name;
    size = theme.cursor.size;
    gtk.enable = true;
  };

  # Native applications and portal dialogs use the same dark appearance, with
  # the theme's accent instead of adw-gtk3's blue (switches, selection,
  # suggested buttons, links).
  gtk = {
    enable = true;
    gtk3.extraCss = accentCss;
    gtk4.extraCss = accentCss;
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
