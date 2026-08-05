{ ... }:
{
  # No user.name/user.email set here: home-manager only writes
  # ~/.config/git/config, so `git config --global` still works normally
  # and takes precedence via ~/.gitconfig.
  programs.git.enable = true;

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;
      line-numbers = true;
    };
  };

  # gitCredentialHelper.enable defaults to true: wires `gh auth git-credential`
  # into git so HTTPS push/pull/clone work after a one-time `gh auth login`.
  programs.gh.enable = true;
}
