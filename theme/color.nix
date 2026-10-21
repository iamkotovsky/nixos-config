# Colour helpers for apps that need palette colours in other forms:
# `mix a b t` is hex colour `a` moved a fraction `t` (0-1) towards `b`;
# `rgb` splits a hex colour into { r, g, b }; `sgr` is the ANSI truecolor
# foreground code ("38;2;r;g;b") for LS_COLORS-style variables.
{ lib }:
let
  channels = color: map (i: lib.fromHexString (builtins.substring i 2 color)) [ 1 3 5 ];
  toHex = n: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString n));
in
{
  mix = a: b: t: "#" + lib.concatStrings (lib.zipListsWith
    (x: y: toHex (builtins.floor (x + (y - x) * t + 0.5)))
    (channels a)
    (channels b));

  rgb = color:
    let c = channels color;
    in { r = builtins.elemAt c 0; g = builtins.elemAt c 1; b = builtins.elemAt c 2; };

  sgr = color: "38;2;" + lib.concatMapStringsSep ";" toString (channels color);
}
