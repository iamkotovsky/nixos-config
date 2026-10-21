{ lib, theme, ... }:
let
  inherit (theme) colors;
  inherit (import ../../theme/color.nix { inherit lib; }) mix;

  # Added and removed lines on a faint green / red, the changed words in
  # them on a stronger one; the code keeps its syntax colours.
  tinted = color: t: "syntax ${mix colors.background color t}";
in
{
  programs = {
    git = {
      enable = true;
      settings.user = {
        name = "iamkotovsky";
        email = "danilerem@gmail.com";
      };
    };

    delta = {
      enable = true;
      enableGitIntegration = true;
      # Code uses the shared highlighting theme (bat's `zenbook`, see
      # shell-tools.nix); everything around it is muted.
      options = {
        navigate = true;
        line-numbers = true;
        syntax-theme = "zenbook";
        plus-style = tinted colors.green theme.tint.diff;
        plus-emph-style = tinted colors.green theme.tint.diffEmphasis;
        minus-style = tinted colors.red theme.tint.diff;
        minus-emph-style = tinted colors.red theme.tint.diffEmphasis;
        line-numbers-plus-style = colors.green;
        line-numbers-minus-style = colors.red;
        line-numbers-zero-style = colors.muted;
        line-numbers-left-style = colors.muted;
        line-numbers-right-style = colors.muted;
        file-style = "bold ${colors.foreground}";
        file-decoration-style = "${colors.muted} ul";
        hunk-header-style = "file line-number syntax";
        hunk-header-file-style = colors.foreground;
        hunk-header-line-number-style = colors.muted;
        hunk-header-decoration-style = "${colors.muted} box";
        commit-decoration-style = "${colors.muted} box";
      };
    };

    # gitCredentialHelper.enable defaults to true: wires `gh auth git-credential`
    # into git so HTTPS push/pull/clone work after a one-time `gh auth login`.
    gh.enable = true;
  };
}
