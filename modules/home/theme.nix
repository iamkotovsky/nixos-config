{ pkgs, theme, ... }:
let
  inherit (theme) colors mix;
  # Selected text is the neutral selection grey, not the accent.
  selection = mix colors.background colors.foreground theme.tint.selection;

  gtkTheme = {
    name = "adw-gtk3-dark";
    package = pkgs.adw-gtk3;
  };

  accentCss = ''
    @define-color accent_color ${colors.accent};
    @define-color accent_bg_color ${colors.accent};
    @define-color accent_fg_color ${colors.background};

    selection {
      background-color: ${selection};
    }
  '';
  # GTK 4 (adw-gtk3's libadwaita sheet) reads the accent from CSS variables.
  accentCss4 = accentCss + ''
    :root {
      --accent-color: ${colors.accent};
      --accent-bg-color: ${colors.accent};
      --accent-fg-color: ${colors.background};
    }

    /* The theme's focused selection is more specific than plain `selection`. */
    selection:focus-within {
      background-color: ${selection};
    }
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
    # Dark in GTK 3 and 4 settings, not only through the portal.
    colorScheme = "dark";
    gtk3.extraCss = accentCss;
    theme = gtkTheme;
    gtk4 = {
      # GTK 4 ignores the theme name, so Home Manager imports the theme's
      # GTK 4 stylesheet into gtk-4.0/gtk.css, but only when it is set here.
      # Without it plain GTK 4 apps (pavucontrol) were light Adwaita.
      theme = gtkTheme;
      extraCss = accentCss4;
    };
    iconTheme = {
      name = "Papirus-Dark";
      # Grey folders instead of Papirus's blue: folders are neutral (bold in
      # file listings), not a colour.
      package = pkgs.papirus-icon-theme.override { color = "grey"; };
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
