{ theme, ... }:
let
  inherit (theme) colors;
in
{
  xdg.configFile = {
    "opencode/tui.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/tui.json";
      theme = "zenbook";
    };

    "opencode/themes/zenbook.json".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/theme.json";

      defs = {
        inherit (colors) accent background blue cyan foreground green magenta muted red surface yellow;
      };

      theme = {
        primary = "accent";
        secondary = "blue";
        accent = "magenta";
        error = "red";
        warning = "yellow";
        success = "green";
        info = "cyan";

        text = "foreground";
        textMuted = "muted";
        # `none` inherits kitty's transparent terminal background.
        background = "none";
        backgroundPanel = "none";
        backgroundElement = "none";
        border = "muted";
        borderActive = "accent";
        borderSubtle = "surface";

        diffAdded = "green";
        diffRemoved = "red";
        diffContext = "muted";
        diffHunkHeader = "blue";
        diffHighlightAdded = "green";
        diffHighlightRemoved = "red";
        diffAddedBg = "none";
        diffRemovedBg = "none";
        diffContextBg = "none";
        diffLineNumber = "muted";
        diffAddedLineNumberBg = "none";
        diffRemovedLineNumberBg = "none";

        markdownText = "foreground";
        markdownHeading = "accent";
        markdownLink = "blue";
        markdownLinkText = "cyan";
        markdownCode = "green";
        markdownBlockQuote = "muted";
        markdownEmph = "yellow";
        markdownStrong = "accent";
        markdownHorizontalRule = "muted";
        markdownListItem = "accent";
        markdownListEnumeration = "cyan";
        markdownImage = "blue";
        markdownImageText = "cyan";
        markdownCodeBlock = "green";

        syntaxComment = "muted";
        syntaxKeyword = "magenta";
        syntaxFunction = "blue";
        syntaxVariable = "foreground";
        syntaxString = "green";
        syntaxNumber = "yellow";
        syntaxType = "cyan";
        syntaxOperator = "magenta";
        syntaxPunctuation = "muted";
      };
    };
  };
}
