# TUI file manager: progress bars + confirmation prompts for copy/move/delete,
# and image previews via kitty's graphics protocol (same one icat uses).
#
# Slimmed to the design system (.claude/rules/design.md): no column borders
# (spacing separates them), a quiet status line (size and position only), one
# muted glyph per kind instead of per-type coloured icons, and one accent on
# neutral greys. Red, yellow and green only mean status (cut, modified,
# added); the accent marks state (hovered row, selection, current tab).
{ lib, pkgs, theme, ... }:
let
  inherit (theme) colors;
  inherit (import ../../theme/color.nix { inherit lib; }) mix;

  # The hovered row: the background tinted toward the accent, as Helix's
  # selection.
  hovered = mix colors.background colors.accent theme.tint.selection;

  # Code previews (syntect) follow the same highlighting rule as Helix:
  # keywords accent, literals their own hue, punctuation and comments muted,
  # everything else foreground.
  scope = name: scopes: settings: ''
    <dict>
      <key>name</key><string>${name}</string>
      <key>scope</key><string>${scopes}</string>
      <key>settings</key><dict>${settings}</dict>
    </dict>'';
  fg = color: "<key>foreground</key><string>${color}</string>";
  italic = "<key>fontStyle</key><string>italic</string>";
  previewTheme = pkgs.writeText "zenbook.tmTheme" ''
    <?xml version="1.0" encoding="UTF-8"?>
    <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
    <plist version="1.0">
    <dict>
      <key>name</key><string>zenbook</string>
      <key>settings</key>
      <array>
        <dict>
          <key>settings</key>
          <dict>
            <key>background</key><string>${colors.background}</string>
            ${fg colors.foreground}
            <key>caret</key><string>${colors.accent}</string>
            <key>selection</key><string>${hovered}</string>
          </dict>
        </dict>
        ${scope "Comment" "comment, punctuation.definition.comment" "${fg colors.muted}${italic}"}
        ${scope "Keyword" "keyword, storage, keyword.control, markup.heading, entity.name.tag" (fg colors.accent)}
        ${scope "String" "string, constant.character, markup.raw" (fg colors.green)}
        ${scope "Number" "constant.numeric, constant.language" (fg colors.yellow)}
        ${scope "Punctuation" "punctuation, keyword.operator" (fg colors.muted)}
        ${scope "Invalid" "invalid" (fg colors.red)}
      </array>
    </dict>
    </plist>
  '';

  # A muted glyph for every entry of a kind; only broken entries are red.
  glyph = text: color: { inherit text; fg = color; };
in
{
  programs.yazi = {
    enable = true;
    # Adds the `y` shell function, which cd's the shell to yazi's last
    # directory on quit instead of leaving you where you started.
    enableZshIntegration = true;

    # `;` already opens an interactive shell prompt (type a shell name and
    # hit enter), but `!` drops straight into $SHELL in the hovered
    # directory with no typing required.
    keymap.mgr.prepend_keymap = [
      {
        on = [ "!" ];
        run = "shell '$SHELL' --block";
        desc = "Open shell here";
      }
    ];

    plugins = {
      git = pkgs.yaziPlugins.git;
    };

    # Registers the git plugin as a fetcher so file/dir status is looked up
    # in git repos; the plugin then renders it via [git] colors in theme.
    # The status line keeps only the hovered entry's size and the position:
    # the mode badge, name (already highlighted), permissions and percentage
    # are dropped.
    initLua = ''
      require("git"):setup { order = 1500 }

      Status:children_remove(1, Status.LEFT)
      Status:children_remove(3, Status.LEFT)
      Status:children_remove(4, Status.RIGHT)
      Status:children_remove(5, Status.RIGHT)

      -- The hovered bar gets one cell of padding at each end. The preset draws
      -- those cells reversed for rounded end glyphs, which leaves a plain
      -- space untinted; an ordinary space takes the row's tint instead.
      function Entity:padding() return " " end
      function Linemode:padding() return " " end
    '';
    settings = {
      mgr = {
        # A narrow parent column for context, the list, and a preview.
        ratio = [ 1 3 3 ];
        linemode = "none";
      };
      plugin.prepend_fetchers = [
        {
          url = "*";
          run = "git";
          group = "git";
        }
        {
          url = "*/";
          run = "git";
          group = "git";
        }
      ];
    };

    theme = {
      mgr = {
        cwd = { fg = colors.muted; };
        find_keyword = { fg = colors.accent; bold = true; underline = true; };
        find_position = { fg = colors.muted; italic = true; };
        symlink_target = { fg = colors.muted; italic = true; };

        # Copied and selected are state (accent); cut is a deletion (red).
        marker_copied = { fg = colors.accent; bg = colors.accent; };
        marker_cut = { fg = colors.red; bg = colors.red; };
        marker_marked = { fg = colors.muted; bg = colors.muted; };
        marker_selected = { fg = colors.accent; bg = colors.accent; };
        count_copied = { fg = colors.background; bg = colors.accent; };
        count_cut = { fg = colors.background; bg = colors.red; };
        count_selected = { fg = colors.background; bg = colors.accent; };

        # No column dividers: the gap between columns is enough.
        border_symbol = " ";
        border_style = { fg = colors.muted; };

        syntect_theme = "${previewTheme}";
      };

      indicator = {
        current = { bg = hovered; };
        parent = { bg = colors.surface; };
        preview = { bg = colors.surface; };
        # Unused: the end cells are plain spaces (see initLua).
        padding = { open = " "; close = " "; };
      };

      tabs = {
        active = { fg = colors.accent; bold = true; };
        inactive = { fg = colors.muted; };
        sep_inner = { open = ""; close = ""; };
        sep_outer = { open = ""; close = ""; };
      };

      # Shown only as the colour of the position on the status line; select
      # and unset modes are state, so they take the accent.
      mode = {
        normal_main = { fg = colors.muted; };
        normal_alt = { fg = colors.muted; };
        select_main = { fg = colors.accent; bold = true; };
        select_alt = { fg = colors.accent; };
        unset_main = { fg = colors.accent; bold = true; };
        unset_alt = { fg = colors.accent; };
      };

      status = {
        sep_left = { open = ""; close = ""; };
        sep_right = { open = ""; close = ""; };
        perm_sep = { fg = colors.muted; };
        perm_type = { fg = colors.muted; };
        perm_read = { fg = colors.muted; };
        perm_write = { fg = colors.muted; };
        perm_exec = { fg = colors.muted; };
        progress_label = { fg = colors.foreground; bold = true; };
        progress_normal = { fg = colors.accent; bg = colors.surface; };
        progress_error = { fg = colors.red; bg = colors.surface; };
      };

      # Pop-ups (which-key, confirm, input, completion, tasks, help, pickers):
      # muted rims, foreground titles, accent for the active row.
      which = {
        border = { fg = colors.muted; };
        cand = { fg = colors.accent; };
        rest = { fg = colors.muted; };
        desc = { fg = colors.foreground; };
        separator_style = { fg = colors.muted; };
      };
      confirm = {
        border = { fg = colors.muted; };
        title = { fg = colors.foreground; bold = true; };
        btn_yes = { fg = colors.background; bg = colors.accent; };
        btn_no = { fg = colors.muted; };
      };
      spot = {
        border = { fg = colors.muted; };
        title = { fg = colors.foreground; bold = true; };
        tbl_col = { fg = colors.muted; };
        tbl_cell = { fg = colors.foreground; bg = hovered; };
      };
      notify = {
        title_info = { fg = colors.foreground; };
        title_warn = { fg = colors.yellow; };
        title_error = { fg = colors.red; };
      };
      pick = {
        border = { fg = colors.muted; };
        active = { fg = colors.accent; bold = true; };
      };
      input = {
        border = { fg = colors.muted; };
        title = { fg = colors.foreground; };
        selected = { bg = hovered; };
      };
      cmp = {
        border = { fg = colors.muted; };
        active = { bg = hovered; };
      };
      tasks = {
        border = { fg = colors.muted; };
        title = { fg = colors.foreground; bold = true; };
        hovered = { fg = colors.accent; bold = true; };
      };
      help = {
        border = { fg = colors.muted; };
        chord = { fg = colors.accent; };
        hovered = { bg = hovered; bold = true; };
      };

      # Replaces the preset's per-type colours (images yellow, media magenta,
      # archives red, folders blue...): names are foreground, folders bold,
      # only broken entries red.
      filetype.rules = [
        { url = "*"; is = "orphan"; fg = colors.red; }
        { url = "*"; is = "dummy"; fg = colors.red; }
        { url = "*/"; is = "dummy"; fg = colors.red; }
        { url = "*/"; fg = colors.foreground; bold = true; }
      ];

      # Replaces the preset's hundreds of brand-coloured icons with one muted
      # glyph per kind.
      icon = {
        globs = [ ];
        dirs = [ ];
        files = [ ];
        exts = [ ];
        conds = [
          ({ "if" = "orphan"; } // glyph "" colors.red)
          ({ "if" = "dummy"; } // glyph "" colors.red)
          ({ "if" = "link"; } // glyph "" colors.muted)
          ({ "if" = "dir"; } // glyph "" colors.muted)
          ({ "if" = "!dir"; } // glyph "" colors.muted)
        ];
      };

      git = {
        modified = { fg = colors.yellow; };
        updated = { fg = colors.yellow; };
        added = { fg = colors.green; };
        untracked = { fg = colors.green; };
        deleted = { fg = colors.red; };
        ignored = { fg = colors.muted; };
      };
    };
  };
}
