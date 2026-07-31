{ ... }:
let
  flakeDir = "$HOME/nixos-config";
in
{
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;

    history = {
      path = "$HOME/.zsh_history";
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreAllDups = true;
      expireDuplicatesFirst = true;
      share = true;
    };

    shellAliases = {
      ll = "ls -lh";
      la = "ls -lah";
      rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}#zenbook";
      update = "nix flake update ${flakeDir}";
      cleanup = "sudo nix-collect-garbage --delete-older-than 30d";
    };

    # The prompt uses Kitty's ANSI palette, so it follows the shared theme indirectly.
    initContent = ''
      PROMPT='%F{blue}%n@%m%f %F{cyan}%~%f %# '
    '';
  };
}
