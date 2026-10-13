{ lib, pkgs, theme, ... }:
let
  c = theme.colors;

  # Telegram overlays these keys onto its built-in defaults, so this stays a
  # curated core set rather than the full ~300-key palette. Values come from the
  # active preset, so switching theme regenerates the file automatically.
  palette = {
    # Window chrome
    windowBg = c.background;
    windowBgOver = c.surface;
    windowBgRipple = c.surface;
    windowFg = c.foreground;
    windowFgOver = c.foreground;
    windowSubTextFg = c.muted;
    windowSubTextFgOver = c.muted;
    windowBoldFg = c.foreground;
    windowBoldFgOver = c.foreground;
    windowBgActive = c.accent;
    windowFgActive = c.background;
    windowActiveTextFg = c.accent;
    windowShadowFg = "#000000";
    shadowFg = "#00000033";
    layerBg = "#0000007f";

    # Buttons and links
    activeButtonBg = c.accent;
    activeButtonBgOver = c.accent;
    activeButtonFg = c.background;
    activeButtonFgOver = c.background;
    activeLineFg = c.accent;
    activeLineFgError = c.red;
    lightButtonBg = c.surface;
    lightButtonBgOver = c.background;
    lightButtonFg = c.accent;
    lightButtonFgOver = c.accent;
    outlineButtonBg = c.background;
    outlineButtonBgOver = c.surface;
    outlineButtonOutlineFg = c.accent;

    # Menus and scrollbars
    menuBg = c.background;
    menuBgOver = c.surface;
    menuBgRipple = c.surface;
    menuIconFg = c.muted;
    menuIconFgOver = c.foreground;
    menuSeparatorFg = c.surface;
    scrollBarBg = "#00000053";
    scrollBarBgOver = "#0000007a";
    scrollBg = "#0000001a";
    scrollBgOver = "#0000002c";

    # Inputs and controls
    inputBorderFg = c.surface;
    filterInputBorderFg = c.accent;
    filterInputInactiveBg = c.surface;
    checkboxFg = c.muted;
    sliderBgInactive = c.surface;
    sliderBgActive = c.accent;
    placeholderFg = c.muted;
    placeholderFgActive = c.muted;

    # Tooltips, titlebar and tray
    tooltipBg = c.surface;
    tooltipFg = c.foreground;
    tooltipBorderFg = c.background;
    titleBg = c.background;
    titleButtonFg = c.muted;
    titleButtonBgOver = c.surface;
    titleButtonFgOver = c.foreground;
    titleButtonCloseBgOver = c.red;
    titleButtonCloseFgOver = c.foreground;
    trayCounterBg = c.red;
    trayCounterFg = c.foreground;

    # Dialogs boxes
    boxBg = c.background;
    boxTextFg = c.foreground;
    boxTextFgGood = c.green;
    boxTextFgError = c.red;
    boxTitleFg = c.foreground;
    boxSearchBg = c.background;
    boxTitleCloseFg = c.muted;
    boxTitleCloseFgOver = c.foreground;

    # Contacts
    contactsBg = c.background;
    contactsBgOver = c.surface;
    contactsNameFg = c.foreground;
    contactsStatusFg = c.muted;
    contactsStatusFgOver = c.muted;
    contactsStatusFgOnline = c.accent;

    # Chat list
    dialogsBg = c.background;
    dialogsBgOver = c.surface;
    dialogsNameFg = c.foreground;
    dialogsDateFg = c.muted;
    dialogsTextFg = c.muted;
    dialogsTextFgService = c.accent;
    dialogsUnreadBg = c.accent;
    dialogsUnreadFg = c.background;
    dialogsBgActive = c.accent;
    dialogsNameFgActive = c.background;
    dialogsDateFgActive = c.background;
    dialogsTextFgActive = c.background;
    dialogsTextFgServiceActive = c.background;
    dialogsUnreadBgActive = c.background;
    dialogsUnreadFgActive = c.accent;
    dialogsForwardBg = c.accent;
    dialogsForwardFg = c.background;
    topBarBg = c.background;

    # Emoji / stickers
    emojiPanBg = c.background;
    emojiPanHeaderBg = c.surface;
    emojiPanHeaderFg = c.muted;

    # Message history
    historyTextInFg = c.foreground;
    historyTextOutFg = c.background;
    historyCaptionInFg = c.foreground;
    historyCaptionOutFg = c.background;
    historyOutIconFg = c.green;
    historySystemBg = c.surface;
    historySystemFg = c.foreground;
    historyUnreadBarBg = c.surface;
    historyUnreadBarFg = c.accent;
    historyPeer1UserpicBg = c.red;
    historyPeer2UserpicBg = c.green;
    historyPeer3UserpicBg = c.yellow;
    historyPeer4UserpicBg = c.blue;
    historyPeer5UserpicBg = c.magenta;
    historyPeer6UserpicBg = c.cyan;
    historyPeer7UserpicBg = c.red;
    historyPeer8UserpicBg = c.yellow;
    historyPeerUserpicFg = c.background;

    # Bubbles
    msgInBg = c.surface;
    msgInBgSelected = c.background;
    msgOutBg = c.accent;
    msgOutBgSelected = c.background;
    msgInServiceFg = c.accent;
    msgOutServiceFg = c.background;
    msgInDateFg = c.muted;
    msgOutDateFg = c.background;
    msgServiceBg = c.surface;
    msgServiceFg = c.foreground;
    msgInReplyBarColor = c.accent;
    msgOutReplyBarColor = c.background;
    msgFileInBg = c.accent;
    msgFileOutBg = c.background;
    msgFile1Bg = c.blue;
    msgFile2Bg = c.green;
    msgFile3Bg = c.red;
    msgFile4Bg = c.yellow;
    msgWaveformInActive = c.accent;
    msgWaveformOutActive = c.background;

    # Compose area
    historyComposeAreaBg = c.background;
    historyComposeAreaFg = c.foreground;
    historyComposeAreaFgService = c.muted;
    historyComposeIconFg = c.muted;
    historyComposeIconFgOver = c.foreground;
    historySendIconFg = c.accent;
    historySendIconFgOver = c.accent;
    historyReplyBg = c.background;
    historyReplyIconFg = c.accent;

    # Media viewer
    mediaviewBg = "#000000eb";
    mediaviewControlBg = "#0000003c";
    mediaviewControlFg = c.foreground;
    mediaviewCaptionBg = "#00000080";
    mediaviewCaptionFg = c.foreground;
    mediaviewFileNameFg = c.foreground;
    mediaviewFileSizeFg = c.muted;
  };

  colorsFile = lib.concatStringsSep "\n" (
    lib.mapAttrsToList (name: value: "${name}: ${value};") palette
  );

  themePackage = pkgs.runCommand "telegram-${theme.active}-theme" { } ''
    mkdir -p $out
    cat > colors.tdesktop-theme <<'EOF'
    ${colorsFile}
    EOF
    # Abstract blurred blobs from the active palette replace Telegram's default
    # pattern. Everything runs in one opaque pass to keep chroma intact.
    ${lib.getExe pkgs.imagemagick} \
      -size 1920x1080 gradient:"${c.background}-${c.surface}" \
      -fill "${c.accent}78" -draw "ellipse 1560,280 620,300 0,360" \
      -fill "${c.magenta}82" -draw "ellipse 420,920 420,540 0,360" \
      -fill "${c.blue}6a" -draw "circle 180,340 610,340" \
      -fill "${c.cyan}6a" -draw "ellipse 1750,860 560,340 0,360" \
      -fill "${c.green}5c" -draw "circle 1010,520 650,520" \
      -blur 0x40 \
      -strip -quality 92 background.jpg
    # Fixed mtime + -X keep the ZIP byte-identical across rebuilds.
    touch -t 198001010000 colors.tdesktop-theme background.jpg
    TZ=UTC ${pkgs.zip}/bin/zip -j -q -X $out/${theme.active}.tdesktop-theme \
      colors.tdesktop-theme background.jpg
  '';
in
{
  # Import once from Settings -> Chat Settings -> theme -> From file. Telegram
  # has no auto-discovered theme directory, so this only ships the artifact.
  xdg.dataFile."telegram-themes/${theme.active}.tdesktop-theme".source =
    "${themePackage}/${theme.active}.tdesktop-theme";
}
