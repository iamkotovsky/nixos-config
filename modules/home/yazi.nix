# TUI file manager: progress bars + confirmation prompts for copy/move/delete,
# and image previews via kitty's graphics protocol (same one icat uses).
{ pkgs, theme, ... }:
let
  colors = theme.colors;
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
    initLua = ''
      require("git"):setup { order = 1500 }
    '';
    settings = {
      mgr.linemode = "size";
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
      mgr.cwd = {
        fg = colors.accent;
      };
      mgr.border_style = {
        fg = colors.muted;
      };

      # Default folder icon uses a bright sky-blue (#03a9f4) baked into
      # yazi's preset theme, clashing with the palette's muted blue.
      # prepend_conds takes priority over the preset's own conds rules.
      icon.prepend_conds = [
        {
          "if" = "dir & hovered";
          text = "";
          fg = colors.accent;
        }
        {
          "if" = "dir";
          text = "";
          fg = colors.accent;
        }
      ];

      tabs = {
        active = {
          fg = colors.background;
          bg = colors.accent;
          bold = true;
        };
        inactive = {
          fg = colors.muted;
        };
      };

      mode = {
        normal_main = {
          fg = colors.background;
          bg = colors.accent;
          bold = true;
        };
        normal_alt = {
          fg = colors.accent;
          bg = colors.surface;
        };
        select_main = {
          fg = colors.background;
          bg = colors.red;
          bold = true;
        };
        select_alt = {
          fg = colors.red;
          bg = colors.surface;
        };
        unset_main = {
          fg = colors.background;
          bg = colors.yellow;
          bold = true;
        };
        unset_alt = {
          fg = colors.yellow;
          bg = colors.surface;
        };
      };

      status = {
        perm_type = {
          fg = colors.green;
        };
        perm_read = {
          fg = colors.yellow;
        };
        perm_write = {
          fg = colors.red;
        };
        perm_exec = {
          fg = colors.cyan;
        };
        progress_normal = {
          fg = colors.accent;
          bg = colors.surface;
        };
      };

      git = {
        modified = {
          fg = colors.yellow;
        };
        added = {
          fg = colors.green;
        };
        untracked = {
          fg = colors.cyan;
        };
        ignored = {
          fg = colors.muted;
        };
        deleted = {
          fg = colors.red;
        };
        updated = {
          fg = colors.yellow;
        };
      };
    };
  };
}
