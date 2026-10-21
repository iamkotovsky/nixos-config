# Colour helpers for apps that need solid shades of the palette:
# `mix a b t` is hex colour `a` moved a fraction `t` (0-1) towards `b`.
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
}
