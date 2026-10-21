# Minimal single-line prompt: folded path, git branch and status. Neutral
# (.claude/rules/design.md): the path is plain text, the branch muted, the
# prompt sign the accent (input focus) and red after a failed command; git
# changes yellow.
{ theme, ... }:
let
  inherit (theme) colors;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;

    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$character";

      character = {
        success_symbol = "[>](${colors.accent})";
        error_symbol = "[>](${colors.red})";
        vimcmd_symbol = "[:](${colors.muted})";
      };

      directory = {
        style = colors.foreground;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        # Keeps the nearest 2 segments, folding everything above into "...".
        truncation_length = 2;
        truncation_symbol = ".../";
        truncate_to_repo = true;
        read_only = " ";
        read_only_style = colors.muted;
      };

      git_branch = {
        style = colors.muted;
        format = "[$symbol$branch]($style) ";
        symbol = "";
      };

      git_status = {
        style = colors.yellow;
        format = "([$all_status$ahead_behind]($style) )";
        ahead = ">";
        behind = "<";
        conflicted = "=";
        deleted = "x";
        diverged = "<>";
        modified = "!";
        renamed = "r";
        staged = "+";
        stashed = "$";
        untracked = "?";
        up_to_date = "";
      };

    };
  };
}
