# Change this one value, then run `rebuild` (nh os switch /etc/nixos).
# Each preset's wallpaper file lives in ./wallpapers.
let
  active = "pink-cross";

  presets = {
    white-rose = import ./presets/white-rose.nix;
    pink-cross = import ./presets/pink-cross.nix;
    moon = import ./presets/moon.nix;
  };
in
(import ./base.nix) // presets.${active} // { inherit active; }
