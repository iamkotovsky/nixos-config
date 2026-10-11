# Change this one value, then run `sudo nixos-rebuild switch --flake /etc/nixos#zenbook`.
let
  active = "pink-cross";

  presets = {
    white-rose = import ./presets/white-rose.nix;
    pink-cross = import ./presets/pink-cross.nix;
    moon = import ./presets/moon.nix;
  };
in
(import ./base.nix) // presets.${active} // { inherit active; }
