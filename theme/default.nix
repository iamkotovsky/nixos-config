# The active theme: shared tokens (base.nix), the active preset's colours and
# wallpaper, and the helpers every module uses with them (color.nix,
# template.nix, the code-highlighting theme from syntax.nix). Modules take it
# all from here, e.g. `inherit (theme) colors mix render;`.
#
# Change `active`, then run `rebuild` (nh os switch /etc/nixos). Each preset's
# wallpaper file lives in ./wallpapers.
{ lib }:
let
  active = "white-rose";

  presets = {
    white-rose = import ./presets/white-rose.nix;
    pink-cross = import ./presets/pink-cross.nix;
    moon = import ./presets/moon.nix;
  };

  tokens = import ./base.nix // presets.${active} // { inherit active; };
  color = import ./color.nix { inherit lib; };
in
tokens
// color
// import ./template.nix
// {
  # The .tmTheme for bat, delta and yazi's previews.
  syntaxTheme = import ./syntax.nix {
    inherit (tokens) colors;
    inherit (color) mix;
    selectionTint = tokens.tint.selection;
  };
}
