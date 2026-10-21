{
  lib,
  pkgs,
  theme,
  ...
}:
let
  inherit (theme) colors;
  inherit (import ../../theme/color.nix { inherit lib; }) mix;

  # Selected text: the neutral selection grey (background towards foreground).
  selection = mix colors.background colors.foreground theme.tint.selection;
in
{
  programs.helix = {
    enable = true;
    defaultEditor = true;

    settings = {
      theme = "zenbook";
      editor = {
        line-number = "relative";
        cursorline = true;
        auto-format = true;
        true-color = true;
        bufferline = "multiple";
        idle-timeout = 250;
        cursor-shape = {
          insert = "bar";
          normal = "block";
          select = "underline";
        };
      };
    };

    # One accent on a neutral palette (.claude/rules/design.md, "The palette
    # in apps"): code is foreground, keywords are the accent, only literals
    # get their own hues, punctuation and comments are muted. Red, yellow and
    # green otherwise mean error, warning and success.
    themes.zenbook = {
      "ui.background" = {
        bg = colors.background;
      };
      "ui.text" = {
        fg = colors.foreground;
      };
      "ui.text.focus" = {
        fg = colors.background;
        bg = colors.accent;
      };
      # The cursor stays neutral; the accent is for the matching bracket.
      "ui.cursor" = {
        fg = colors.background;
        bg = colors.foreground;
      };
      "ui.cursor.match" = {
        fg = colors.accent;
        modifiers = [
          "bold"
          "underlined"
        ];
      };
      "ui.cursorline.primary" = {
        bg = colors.surface;
      };
      # Neutral grey, never the accent.
      "ui.selection" = {
        bg = selection;
      };
      "ui.selection.primary" = {
        bg = selection;
      };
      "ui.linenr" = {
        fg = colors.muted;
      };
      "ui.linenr.selected" = {
        fg = colors.accent;
      };
      "ui.statusline" = {
        fg = colors.foreground;
        bg = colors.surface;
      };
      "ui.statusline.inactive" = {
        fg = colors.muted;
        bg = colors.surface;
      };
      "ui.popup" = {
        bg = colors.surface;
      };
      "ui.menu" = {
        bg = colors.surface;
      };
      "ui.menu.selected" = {
        fg = colors.background;
        bg = colors.accent;
      };
      "ui.virtual" = {
        fg = colors.muted;
      };
      "ui.virtual.jump-label" = {
        fg = colors.accent;
        modifiers = [ "bold" ];
      };
      special = colors.accent;

      "diagnostic.error" = {
        underline = {
          color = colors.red;
          style = "curl";
        };
      };
      "diagnostic.warning" = {
        underline = {
          color = colors.yellow;
          style = "curl";
        };
      };
      "diagnostic.info" = {
        underline = {
          color = colors.muted;
          style = "curl";
        };
      };
      "diagnostic.hint" = {
        underline = {
          color = colors.muted;
          style = "dotted";
        };
      };
      error = colors.red;
      warning = colors.yellow;
      info = colors.foreground;
      hint = colors.muted;

      "diff.plus" = colors.green;
      "diff.minus" = colors.red;
      "diff.delta" = colors.yellow;

      # Code: foreground, with the accent for keywords only.
      variable = colors.foreground;
      function = colors.foreground;
      type = colors.foreground;
      constructor = colors.foreground;
      namespace = colors.foreground;
      attribute = colors.foreground;
      label = colors.foreground;
      constant = colors.foreground;
      keyword = colors.accent;
      tag = colors.accent;

      # Literals: strings and characters green; numbers, booleans and
      # built-in constants yellow.
      string = colors.green;
      "constant.character" = colors.green;
      "constant.numeric" = colors.yellow;
      "constant.builtin" = colors.yellow;

      # Slightly muted structure.
      punctuation = colors.muted;
      operator = colors.muted;
      comment = {
        fg = colors.muted;
        modifiers = [ "italic" ];
      };

      "markup.heading" = {
        fg = colors.accent;
        modifiers = [ "bold" ];
      };
      "markup.bold" = {
        modifiers = [ "bold" ];
      };
      "markup.italic" = {
        modifiers = [ "italic" ];
      };
      "markup.strikethrough" = {
        modifiers = [ "crossed_out" ];
      };
      "markup.link.url" = {
        fg = colors.accent;
        modifiers = [ "underlined" ];
      };
      "markup.link.text" = colors.foreground;
      "markup.raw" = colors.green;
      "markup.list" = colors.muted;
      "markup.quote" = {
        fg = colors.muted;
        modifiers = [ "italic" ];
      };
    };

    languages.language = [
      {
        name = "rust";
        auto-format = true;
        formatter = {
          command = "rustfmt";
          args = [
            "--emit"
            "stdout"
          ];
        };
      }
      {
        name = "go";
        auto-format = true;
      }
      {
        name = "c";
        auto-format = true;
        formatter.command = "clang-format";
      }
      {
        name = "cpp";
        auto-format = true;
        formatter.command = "clang-format";
      }
      {
        name = "nix";
        auto-format = true;
        formatter.command = "nixfmt";
      }
    ];

    extraPackages = [
      pkgs.clang-tools
      pkgs.gopls
      pkgs.nil
      pkgs.nixfmt
      pkgs.rust-analyzer
      pkgs.rustfmt
    ];
  };
}
