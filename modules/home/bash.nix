# Not used as a login shell; only exists so tools that hardcode bash for their
# interactive shell (notably `nix develop`) still get the themed prompt.
{
  programs.bash.enable = true;
}
