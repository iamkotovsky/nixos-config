# Template helpers, reached through the theme (`inherit (theme) render ...`).
#   render subs file  the native config template `file` (config/*: Theme.qml,
#                     config.kdl, userChrome.css...) with every @NAME@
#                     placeholder replaced by the matching attribute of `subs`
#   number o          an opacity or tint as a number: base.nix keeps values
#                     that go into templates verbatim as strings ("0.08"),
#                     since Nix prints floats as "0.080000"
#   percent o         an opacity as a CSS color-mix percentage ("8")
rec {
  render =
    substitutions: file:
    builtins.replaceStrings (map (name: "@${name}@") (
      builtins.attrNames substitutions
    )) (builtins.attrValues substitutions) (builtins.readFile file);

  number = value: if builtins.isString value then builtins.fromJSON value else value;

  percent = opacity: toString (builtins.floor (number opacity * 100 + 0.5));
}
