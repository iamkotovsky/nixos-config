{ theme, username, ... }:
let
  inherit (theme) colors;
in
{
  programs.firefox = {
    enable = true;

    policies = {
      # Keep Mozilla's promotional, experimentation, and data-collection
      # surfaces out of the browser without restricting normal browsing or Sync.
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";
      UserMessaging = {
        ExtensionRecommendations = false;
        FeatureRecommendations = false;
        FirefoxLabs = false;
        Locked = true;
        MoreFromMozilla = false;
        SkipOnboarding = true;
        UrlbarInterventions = false;
      };
    };

    profiles.${username} = {
      id = 0;
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "ui.systemUsesDarkTheme" = 1;

        # Remove advertising, recommendation, and promo surfaces.
        "browser.discovery.enabled" = false;
        "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.system.topstories" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
        "browser.shell.checkDefaultBrowser" = false;
        "browser.toolbars.bookmarks.visibility" = "never";
        "browser.urlbar.quicksuggest.enabled" = false;
        "browser.urlbar.suggest.quicksuggest.nonsponsored" = false;
        "browser.urlbar.suggest.quicksuggest.sponsored" = false;
        "browser.urlbar.suggest.topsites" = false;
        "browser.vpn_promo.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "signon.firefoxRelay.feature" = "disabled";
      };

      # Keep ordinary web pages opaque while giving Firefox chrome and new tabs a
      # transparent, frosted appearance under Niri.
      userChrome = ''
        :root {
          --toolbar-bgcolor: transparent !important;
          --toolbar-color: ${colors.foreground} !important;
          --toolbar-field-background-color: color-mix(in srgb, ${colors.surface} 72%, transparent) !important;
          --toolbar-field-color: ${colors.foreground} !important;
          --toolbar-field-focus-background-color: color-mix(in srgb, ${colors.surface} 86%, transparent) !important;
          --toolbar-field-focus-color: ${colors.foreground} !important;
          --toolbar-field-border-color: ${colors.muted} !important;
          --lwt-accent-color: transparent !important;
          --lwt-text-color: ${colors.foreground} !important;
          --lwt-selected-tab-background-color: color-mix(in srgb, ${colors.surface} 58%, transparent) !important;
          --tab-selected-bgcolor: color-mix(in srgb, ${colors.surface} 58%, transparent) !important;
          --tab-selected-textcolor: ${colors.foreground} !important;
          --tab-hover-background-color: color-mix(in srgb, ${colors.surface} 45%, transparent) !important;
          --focus-outline-color: ${colors.accent} !important;
          --button-hover-bgcolor: color-mix(in srgb, ${colors.surface} 62%, transparent) !important;
          --button-active-bgcolor: color-mix(in srgb, ${colors.surface} 76%, transparent) !important;
        }

        #navigator-toolbox,
        #TabsToolbar,
        #nav-bar {
          background-color: transparent !important;
          color: ${colors.foreground} !important;
        }

        /* Keep the browser chrome focused on navigation rather than bookmarks.
           Saved bookmarks remain available in the profile if needed later. */
        #PersonalToolbar,
        #bookmarks-menu-button,
        #star-button-box {
          display: none !important;
        }

        .tab-background {
          border-radius: ${toString theme.radius.small}px !important;
          margin-block: 3px !important;
        }

        .tabbrowser-tab[selected] .tab-background {
          background: color-mix(in srgb, ${colors.surface} 58%, transparent) !important;
          outline: 2px solid ${colors.accent} !important;
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

      userContent = ''
        @-moz-document url("about:home"), url("about:newtab") {
          :root,
          body,
          #root,
          .activity-stream,
          .outer-wrapper {
            background: transparent !important;
          }
        }
      '';
    };
  };
}
