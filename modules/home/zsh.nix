{ lib, flakeDir, ... }:
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

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
