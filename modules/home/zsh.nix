{ ... }:
let
  flakeDir = "/etc/nixos";
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
      config = "$EDITOR ${flakeDir}";
      rebuild = "sudo nixos-rebuild switch --flake ${flakeDir}#zenbook";
      rollback = "sudo nixos-rebuild switch --rollback";
      update = "nix flake update ${flakeDir}";
      check = "nix flake check ${flakeDir}";
      cleanup = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations 30d && sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-collect-garbage";
    };
  };
}
