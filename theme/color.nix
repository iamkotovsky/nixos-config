# Colour helpers for apps that need palette colours in other forms. Reached
# through the theme (`inherit (theme) mix hex ...`), never imported directly.
#   mix a b t   hex colour `a` moved a fraction `t` (0-1) towards `b`
#   rgb c       a hex colour split into { r, g, b }
#   sgr c       the ANSI truecolor foreground code ("38;2;r;g;b"), for
#               LS_COLORS-style variables
#   hex c       the colour without its "#" (rofi-style and console consumers)
#   alphaHex o  an opacity ("0.84") as a two-digit hex alpha suffix ("d6")
{ lib }:
let
  channels =
    color:
    map (i: lib.fromHexString (builtins.substring i 2 color)) [
      1
      3
      5
    ];
  toHex = n: lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString n));
in
{
  mix =
    a: b: t:
    "#"
    + lib.concatStrings (
      lib.zipListsWith (x: y: toHex (builtins.floor (x + (y - x) * t + 0.5))) (channels a) (channels b)
    );

  rgb =
    color:
    let
      c = channels color;
    in
    {
      r = builtins.elemAt c 0;
      g = builtins.elemAt c 1;
      b = builtins.elemAt c 2;
    };

  sgr = color: "38;2;" + lib.concatMapStringsSep ";" toString (channels color);

  hex = color: builtins.substring 1 6 color;

  alphaHex = opacity: toHex (builtins.floor (builtins.fromJSON opacity * 255 + 0.5));
}
