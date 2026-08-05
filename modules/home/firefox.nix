{ theme, ... }:
let
  colors = theme.colors;
in
{
  programs.firefox = {
    enable = true;

    profiles.danil = {
      id = 0;
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "ui.systemUsesDarkTheme" = 1;
      };

      # userChrome.css affects Firefox's controls only; web page colors are untouched.
      userChrome = ''
        :root {
          --toolbar-bgcolor: ${colors.background} !important;
          --toolbar-color: ${colors.foreground} !important;
          --toolbar-field-background-color: ${colors.surface} !important;
          --toolbar-field-color: ${colors.foreground} !important;
          --toolbar-field-focus-background-color: ${colors.surface} !important;
          --toolbar-field-focus-color: ${colors.foreground} !important;
          --toolbar-field-border-color: ${colors.muted} !important;
          --lwt-accent-color: ${colors.background} !important;
          --lwt-text-color: ${colors.foreground} !important;
          --lwt-selected-tab-background-color: ${colors.surface} !important;
          --tab-selected-bgcolor: ${colors.surface} !important;
          --tab-selected-textcolor: ${colors.foreground} !important;
          --tab-hover-background-color: color-mix(in srgb, ${colors.surface} 78%, ${colors.accent}) !important;
          --focus-outline-color: ${colors.accent} !important;
          --button-hover-bgcolor: color-mix(in srgb, ${colors.surface} 82%, ${colors.accent}) !important;
          --button-active-bgcolor: color-mix(in srgb, ${colors.surface} 68%, ${colors.accent}) !important;
        }

        #navigator-toolbox,
        #TabsToolbar,
        #nav-bar {
          background-color: ${colors.background} !important;
          color: ${colors.foreground} !important;
        }

        .tab-background {
          border-radius: ${toString theme.radius.small}px !important;
          margin-block: 3px !important;
        }

        .tabbrowser-tab[selected] .tab-background {
          background: ${colors.surface} !important;
          outline: 1px solid color-mix(in srgb, ${colors.accent} 55%, transparent) !important;
        }

        .tabbrowser-tab[selected] .tab-label {
          color: ${colors.foreground} !important;
        }

        .tabbrowser-tab[attention] .tab-label,
        .tabbrowser-tab[pinned][titlechanged] .tab-label {
          color: ${colors.accent} !important;
        }

        #urlbar-background,
        #searchbar {
          border-radius: ${toString theme.radius.small}px !important;
        }
      '';
    };
  };
}
