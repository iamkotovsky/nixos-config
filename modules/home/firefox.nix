{ lib, pkgs, theme, username, ... }:
let
  inherit (theme) colors;

  # Opacity strings ("0.08") as CSS color-mix percentages ("8").
  percent = opacity: toString (builtins.floor (builtins.fromJSON opacity * 100 + 0.5));

  render = substitutions: file: builtins.replaceStrings
    (map (name: "@${name}@") (builtins.attrNames substitutions))
    (builtins.attrValues substitutions)
    (builtins.readFile file);

  # Design tokens shared by userChrome.css and the start page; each attribute
  # fills the matching @NAME@ placeholder.
  tokens = {
    BACKGROUND = colors.background;
    FOREGROUND = colors.foreground;
    MUTED = colors.muted;
    ACCENT = colors.accent;
    SURFACE = colors.surface;
    FILL_REST = percent theme.fill.rest;
    FILL_HOVER = percent theme.fill.hover;
    FILL_PRESSED = percent theme.fill.pressed;
    FILL_RIM = percent theme.fill.rim;
    RIM = percent theme.opacity.rim;
    RAISED = percent theme.opacity.raised;
    RAISED_SHADOW_BLUR = toString theme.elevation.raised.blur;
    RAISED_SHADOW_Y = toString theme.elevation.raised.y;
    RAISED_SHADOW_OPACITY = percent theme.elevation.raised.opacity;
    RADIUS_SMALL = toString theme.radius.small;
    RADIUS_MEDIUM = toString theme.radius.medium;
    RADIUS_LARGE = toString theme.radius.large;
    SPACING_XS = toString theme.spacing.xs;
    SPACING_SMALL = toString theme.spacing.small;
    SPACING_MEDIUM = toString theme.spacing.medium;
    SPACING_LARGE = toString theme.spacing.large;
    DURATION_FAST = toString theme.motion.fast;
    DURATION_SLOW = toString theme.motion.slow;
    PRESS_SCALE = theme.motion.pressScale;
    ICON_WEIGHT = toString theme.iconWeight;
    FONT = theme.font.ui;
    FONT_CAPTION = toString theme.fontSizes.caption;
    FONT_SIZE = toString theme.font.size;
    FONT_TITLE = toString theme.fontSizes.title;
  };

  # Quick links on the start page, in order.
  links = [
    {
      name = "GitHub";
      url = "https://github.com";
      # The light logo, for a dark background.
      icon = "https://github.githubassets.com/favicons/favicon-dark.svg";
    }
    {
      name = "YouTube";
      url = "https://www.youtube.com";
      icon = "https://www.youtube.com/favicon.ico";
    }
    {
      name = "Gmail";
      url = "https://mail.google.com";
      icon = "https://ssl.gstatic.com/ui/v1/icons/mail/rfr/gmail.ico";
    }
    {
      name = "NixOS";
      url = "https://search.nixos.org/packages";
      icon = "https://nixos.org/favicon.ico";
    }
  ];

  # New tab and home page: clock, date, search and the links above.
  startpage = pkgs.writeText "firefox-startpage.html" (render
    (tokens // {
      SEARCH_URL = "https://www.google.com/search?q=";
      LINKS = lib.concatMapStrings
        (link: ''<a class="tile" href="${link.url}"><img src="${link.icon}" alt="">${link.name}</a>'')
        links;
    })
    ../../config/firefox/startpage.html);
  startpageUrl = "file://${startpage}";
in
{
  programs.firefox = {
    enable = true;

    # Firefox dropped the new-tab URL pref, so the start page is set through
    # autoconfig (mozilla.cfg, which the nixpkgs wrapper writes from
    # extraPrefs). Its first line must be a comment.
    package = pkgs.firefox.override {
      extraPrefs = ''
        // New tab: the themed start page.
        try {
          const { AboutNewTab } = ChromeUtils.importESModule("resource:///modules/AboutNewTab.sys.mjs");
          AboutNewTab.newTabURL = "${startpageUrl}";
        } catch (e) {
          Components.utils.reportError(e);
        }
      '';
    };

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
        "browser.startup.homepage" = startpageUrl;
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
        # Plain suggestions only: no trending searches or image/"rich" cards.
        "browser.urlbar.suggest.trending" = false;
        "browser.urlbar.trending.featureGate" = false;
        "browser.urlbar.richSuggestions.featureGate" = false;
        "browser.vpn_promo.enabled" = false;
        "extensions.htmlaboutaddons.recommendations.enabled" = false;
        "signon.firefoxRelay.feature" = "disabled";
      };

      # Chrome and new-tab styling live in their native format; only design
      # tokens are injected here.
      userChrome = render tokens ../../config/firefox/userChrome.css;

      userContent = builtins.readFile ../../config/firefox/userContent.css;
    };
  };
}
