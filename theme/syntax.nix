# The code-highlighting theme as a TextMate .tmTheme, for everything that
# uses syntect: bat, delta (through bat's theme cache) and yazi's previews.
# It follows .claude/rules/design.md ("The palette in apps"): code is
# foreground, keywords the accent, literals their own hue (strings green,
# numbers and constants yellow), punctuation and comments muted.
{ colors, mix, selectionTint }:
let
  scope = name: scopes: settings: ''
    <dict>
      <key>name</key><string>${name}</string>
      <key>scope</key><string>${scopes}</string>
      <key>settings</key><dict>${settings}</dict>
    </dict>'';
  fg = color: "<key>foreground</key><string>${color}</string>";
  italic = "<key>fontStyle</key><string>italic</string>";
in
''
  <?xml version="1.0" encoding="UTF-8"?>
  <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
  <plist version="1.0">
  <dict>
    <key>name</key><string>zenbook</string>
    <key>settings</key>
    <array>
      <dict>
        <key>settings</key>
        <dict>
          <key>background</key><string>${colors.background}</string>
          ${fg colors.foreground}
          <key>caret</key><string>${colors.foreground}</string>
          <key>selection</key><string>${mix colors.background colors.foreground selectionTint}</string>
          <key>lineHighlight</key><string>${colors.surface}</string>
          <key>gutter</key><string>${colors.background}</string>
          <key>gutterForeground</key><string>${colors.muted}</string>
        </dict>
      </dict>
      ${scope "Comment" "comment, punctuation.definition.comment" "${fg colors.muted}${italic}"}
      ${scope "Keyword" "keyword, storage, keyword.control, markup.heading, entity.name.tag" (fg colors.accent)}
      ${scope "String" "string, constant.character, markup.raw" (fg colors.green)}
      ${scope "Number" "constant.numeric, constant.language" (fg colors.yellow)}
      ${scope "Punctuation" "punctuation, keyword.operator" (fg colors.muted)}
      ${scope "Link" "markup.underline.link" (fg colors.accent)}
      ${scope "Inserted" "markup.inserted" (fg colors.green)}
      ${scope "Deleted" "markup.deleted" (fg colors.red)}
      ${scope "Changed" "markup.changed" (fg colors.yellow)}
      ${scope "Invalid" "invalid" (fg colors.red)}
    </array>
  </dict>
  </plist>
''
