# Command-line tools, coloured by the design system (.claude/rules/design.md,
# "The palette in apps"): neutral greys and one accent, with red, yellow and
# green only for status (and green/yellow for string/number literals in code).
{ lib, pkgs, theme, ... }:
let
  inherit (theme) colors;
  inherit (import ../../theme/color.nix { inherit lib; }) rgb sgr;

  # LS_COLORS-style codes: no colour, bold, a palette colour.
  plain = "00";
  bold = "01";
  muted = sgr colors.muted;
  red = sgr colors.red;
  yellow = sgr colors.yellow;
  green = sgr colors.green;

  # eza's own colour keys, on top of LS_COLORS: `reset` drops its built-in
  # per-file-type colours (images, archives, documents...), then names stay
  # foreground, folders bold, and the detail columns muted.
  ezaColors = lib.concatStringsSep ":" ([ "reset" ] ++ lib.mapAttrsToList (k: v: "${k}=${v}") {
    # File kinds.
    fi = plain;
    di = bold;
    ex = plain;
    ln = muted;
    lp = muted;
    or = red;
    bO = red;
    pi = muted;
    so = muted;
    bd = muted;
    cd = muted;
    mp = "01;04";
    # Permissions, size, owner, links, dates and the rest of the details.
    ur = muted;
    uw = muted;
    ux = muted;
    ue = muted;
    gr = muted;
    gw = muted;
    gx = muted;
    tr = muted;
    tw = muted;
    tx = muted;
    xa = muted;
    # setuid / setgid: worth a warning.
    su = yellow;
    sf = yellow;
    sn = plain;
    sb = muted;
    uu = muted;
    un = muted;
    gu = muted;
    gn = muted;
    uR = yellow;
    gR = yellow;
    lc = muted;
    lm = muted;
    da = muted;
    "in" = muted;
    bl = muted;
    xx = muted;
    hd = "01;04";
    cc = red;
    # Git status: added green, modified yellow, deleted or conflicted red.
    ga = green;
    gm = yellow;
    gv = yellow;
    gt = yellow;
    gd = red;
    gc = red;
    gi = muted;
    Gm = muted;
    Go = muted;
    Gc = green;
    Gd = yellow;
  });

  # Code highlighting for bat and delta (theme/syntax.nix).
  syntaxTheme = import ../../theme/syntax.nix {
    inherit colors;
    inherit (import ../../theme/color.nix { inherit lib; }) mix;
    selectionTint = theme.tint.selection;
  };

  # tealdeer wants { rgb = { r, g, b }; } colours.
  tldrColor = color: { rgb = rgb color; };
in
{
  home.packages = [ pkgs.devenv ];

  # eza reads EZA_COLORS on every run; zsh's env file reaches new shells
  # without a re-login.
  programs.zsh.sessionVariables.EZA_COLORS = ezaColors;

  programs = {
    # LS_COLORS for ls, tree, fd and zsh's completion lists. Forced: Home
    # Manager's defaults colour a long list of file extensions.
    dircolors = {
      enable = true;
      enableZshIntegration = true;
      settings = lib.mkForce {
        RESET = "0";
        NORMAL = plain;
        FILE = plain;
        DIR = bold;
        LINK = muted;
        MULTIHARDLINK = plain;
        FIFO = muted;
        SOCK = muted;
        DOOR = muted;
        BLK = muted;
        CHR = muted;
        ORPHAN = red;
        MISSING = red;
        SETUID = yellow;
        SETGID = yellow;
        CAPABILITY = plain;
        # The defaults put a green background behind world-writable folders
        # (/tmp and friends); plain bold, like any folder.
        STICKY_OTHER_WRITABLE = bold;
        OTHER_WRITABLE = bold;
        STICKY = bold;
        EXEC = plain;
      };
    };

    eza = {
      enable = true;
      enableZshIntegration = true;
      icons = "auto";
      git = true;
    };

    bat = {
      enable = true;
      config = {
        theme = "zenbook";
        italic-text = "always";
      };
      themes.zenbook = syntaxTheme;
    };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    tealdeer = {
      enable = true;
      settings = {
        updates.auto_update = true;
        style = {
          description.foreground = tldrColor colors.foreground;
          command_name = {
            foreground = tldrColor colors.accent;
            bold = true;
          };
          example_text.foreground = tldrColor colors.muted;
          example_code.foreground = tldrColor colors.foreground;
          example_variable = {
            foreground = tldrColor colors.foreground;
            underline = true;
          };
        };
      };
    };

    # Meters and graphs are progress (the accent, from muted up); temperatures
    # are status (green, yellow, red).
    btop = {
      enable = true;
      settings = {
        color_theme = "zenbook";
        # Kitty's translucent background shows through.
        theme_background = false;
      };
      themes.zenbook = ''
        theme[main_bg]="${colors.background}"
        theme[main_fg]="${colors.foreground}"
        theme[title]="${colors.foreground}"
        theme[hi_fg]="${colors.accent}"
        theme[selected_bg]="${colors.surface}"
        theme[selected_fg]="${colors.foreground}"
        theme[inactive_fg]="${colors.muted}"
        theme[graph_text]="${colors.muted}"
        theme[meter_bg]="${colors.surface}"
        theme[proc_misc]="${colors.muted}"
        theme[cpu_box]="${colors.muted}"
        theme[mem_box]="${colors.muted}"
        theme[net_box]="${colors.muted}"
        theme[proc_box]="${colors.muted}"
        theme[div_line]="${colors.surface}"
        theme[temp_start]="${colors.green}"
        theme[temp_mid]="${colors.yellow}"
        theme[temp_end]="${colors.red}"
        theme[cpu_start]="${colors.muted}"
        theme[cpu_mid]="${colors.accent}"
        theme[cpu_end]="${colors.accent}"
        theme[free_start]="${colors.muted}"
        theme[free_mid]="${colors.muted}"
        theme[free_end]="${colors.foreground}"
        theme[cached_start]="${colors.muted}"
        theme[cached_mid]="${colors.muted}"
        theme[cached_end]="${colors.foreground}"
        theme[available_start]="${colors.muted}"
        theme[available_mid]="${colors.muted}"
        theme[available_end]="${colors.foreground}"
        theme[used_start]="${colors.muted}"
        theme[used_mid]="${colors.accent}"
        theme[used_end]="${colors.accent}"
        theme[download_start]="${colors.muted}"
        theme[download_mid]="${colors.accent}"
        theme[download_end]="${colors.accent}"
        theme[upload_start]="${colors.muted}"
        theme[upload_mid]="${colors.accent}"
        theme[upload_end]="${colors.accent}"
        theme[process_start]="${colors.muted}"
        theme[process_mid]="${colors.accent}"
        theme[process_end]="${colors.accent}"
      '';
    };
  };
}
