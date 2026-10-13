# Minimal single-line prompt: folded path, git branch and status.
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
        success_symbol = "[>](${colors.green})";
        error_symbol = "[>](${colors.red})";
        vimcmd_symbol = "[:](${colors.green})";
      };

      directory = {
        style = colors.blue;
        format = "[$path]($style)[$read_only]($read_only_style) ";
        # Keeps the nearest 2 segments, folding everything above into "...".
        truncation_length = 2;
        truncation_symbol = ".../";
        truncate_to_repo = true;
        read_only = " ";
        read_only_style = colors.red;
      };

      git_branch = {
        style = colors.magenta;
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
