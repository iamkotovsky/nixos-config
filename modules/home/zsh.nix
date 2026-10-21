{ lib, flakeDir, theme, ... }:
let
  inherit (theme) colors;
  fg = color: "fg=${color}";
  code = fg colors.foreground;
  string = fg colors.green;
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = fg colors.muted;
    };

    # The command line is code too (.claude/rules/design.md): commands and
    # arguments foreground, keywords the accent, strings green, separators,
    # globs and comments muted, an unknown command red.
    syntaxHighlighting = {
      enable = true;
      styles = {
        default = "none";
        unknown-token = fg colors.red;
        reserved-word = fg colors.accent;
        alias = code;
        suffix-alias = code;
        global-alias = code;
        builtin = code;
        function = code;
        command = code;
        precommand = code;
        hashed-command = code;
        autodirectory = code;
        arg0 = code;
        path = "underline";
        path_prefix = "underline";
        commandseparator = fg colors.muted;
        redirection = fg colors.muted;
        globbing = fg colors.muted;
        history-expansion = fg colors.muted;
        single-hyphen-option = code;
        double-hyphen-option = code;
        single-quoted-argument = string;
        double-quoted-argument = string;
        dollar-quoted-argument = string;
        rc-quote = string;
        dollar-double-quoted-argument = string;
        back-double-quoted-argument = string;
        back-dollar-quoted-argument = string;
        back-quoted-argument = code;
        assign = code;
        comment = fg colors.muted;
      };
    };

    # https://devenv.sh/auto-activation/ - auto-activates devenv shells on cd,
    # no direnv/.envrc needed.
    initContent = lib.mkAfter ''
      eval "$(devenv hook zsh)"

      # Transfers kitty's terminfo + shell integration to the remote on
      # connect, so `clear`/tput/full-screen apps don't break over SSH.
      # Only inside kitty: the kitten fails in a TTY or other terminals.
      [[ $TERM == xterm-kitty ]] && alias ssh="kitty +kitten ssh"
    '';

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    shellAliases = {
      config = "$EDITOR ${flakeDir}";
      # nh shows a package diff and asks for sudo itself; the flake path is
      # explicit so these work before NH_FLAKE reaches the session.
      rebuild = "nh os switch ${flakeDir}";
      rollback = "nh os rollback";
      update = "nix flake update --flake ${flakeDir}";
      check = "nix flake check ${flakeDir}";
      cleanup = "nh clean all --keep-since 30d --keep 5";
      # `nix develop` always drops into bash by design (it needs bash to
      # source stdenv setup); this lands in zsh instead.
      develop = "nix develop --command zsh";
      icat = "kitty +kitten icat";
    };
  };
}
