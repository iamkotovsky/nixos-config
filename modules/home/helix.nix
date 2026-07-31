{ pkgs, theme, ... }:
let
  colors = theme.colors;
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
      };
    };

    themes.zenbook = {
      "ui.background" = { bg = colors.background; };
      "ui.text" = { fg = colors.foreground; };
      "ui.text.focus" = {
        fg = colors.background;
        bg = colors.accent;
      };
      "ui.cursor" = {
        fg = colors.background;
        bg = colors.accent;
      };
      "ui.cursorline.primary" = { bg = colors.surface; };
      "ui.selection" = { bg = colors.surface; };
      "ui.linenr" = { fg = colors.muted; };
      "ui.linenr.selected" = { fg = colors.accent; };
      "ui.statusline" = {
        fg = colors.foreground;
        bg = colors.surface;
      };
      "ui.statusline.inactive" = {
        fg = colors.muted;
        bg = colors.surface;
      };
      "ui.popup" = { bg = colors.surface; };
      "ui.menu" = { bg = colors.surface; };
      "ui.menu.selected" = {
        fg = colors.background;
        bg = colors.accent;
      };

      "diagnostic.error" = { underline = { color = colors.red; style = "curl"; }; };
      "diagnostic.warning" = { underline = { color = colors.yellow; style = "curl"; }; };
      "diagnostic.info" = { underline = { color = colors.blue; style = "curl"; }; };
      "diagnostic.hint" = { underline = { color = colors.cyan; style = "curl"; }; };
      error = colors.red;
      warning = colors.yellow;
      info = colors.blue;
      hint = colors.cyan;

      comment = { fg = colors.muted; modifiers = [ "italic" ]; };
      string = colors.green;
      keyword = colors.magenta;
      function = colors.blue;
      type = colors.yellow;
      constant = colors.cyan;
      variable = colors.foreground;
      operator = colors.accent;
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
      pkgs.nixfmt-rfc-style
      pkgs.rust-analyzer
      pkgs.rustfmt
    ];
  };
}
