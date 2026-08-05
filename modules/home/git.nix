{ ... }:
{
  programs.git = {
    enable = true;
    settings.user = {
      name = "iamkotovsky";
      email = "danilerem@gmail.com";
    };
  };

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
