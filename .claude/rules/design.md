---
paths:
  - "config/quickshell/**"
  - "config/rofi/**"
  - "config/hypr/**"
  - "config/niri/**"
  - "theme/**"
  - "modules/home/quickshell.nix"
  - "modules/home/rofi.nix"
  - "modules/home/hyprlock.nix"
  - "modules/home/kitty.nix"
---

# Desktop design system

These rules cover the visual language of the whole desktop: the Quickshell bar, control panel, OSD and notifications; rofi; hyprlock; niri. Follow them for every UI change. When a rule and a request conflict, ask the user.

## Principles (in priority order)

1. **Minimal visuals.**
   - Show only what's needed, and add nothing purely decorative.
   - Use spacing and grouping instead of dividers, extra lines or labels.
   - Prefer an icon to text when its meaning is clear.
   - Show exact numbers only on demand: the bar shows icons, and percentages live in the panel and OSD.
2. **Smooth motion everywhere.**
   - Every visible state change animates: color, opacity, size, position, and appearing or disappearing.
   - The one exception is a value following the pointer directly, such as a dragged slider; it must not lag.
   - Layout changes animate too: `Behavior` on size, and `displaced` transitions in lists.
3. **Clear interactivity.** Anything clickable looks alive:
   - **Hover:** the item lifts (fill 0.08 → 0.14, the shadow grows one level) and the cursor becomes a pointing hand.
   - **Press:** the item scales to 0.96, the fill goes to 0.20 and the shadow drops back.
   - **Active / on:** accent fill.
   - **Disabled:** 0.4 opacity and no hover.
   - Never add hover effects to things that can't be clicked. A hover effect always means "you can click this".
4. **Frosted glass.** Surfaces are translucent and neutral, sit over real compositor blur, and have a thin light rim.
5. **Accent means state.** Pink marks on/active, focus, progress and links, never decoration.
6. **Everything is rounded, on one gap rhythm, and centred to the pixel.** Check vertical centring in a screenshot, nudging with `Translate` if a glyph sits off-centre.

## Tokens

The single source of truth is `theme/base.nix`, with colors in `theme/presets/*.nix`. Templates get the values through `@NAME@` substitutions:
- `config/quickshell/Theme.qml` via `modules/home/quickshell.nix`;
- `config/rofi/config.rasi` via `modules/home/rofi.nix`;
- `config/hypr/hyprlock.conf` via `modules/home/hyprlock.nix`;
- `config/niri/config.kdl` via `modules/home/niri.nix`.

Component sizes that only QML uses live in the last section of `Theme.qml`.

| Group | Tokens (Theme.qml) | Values | Use |
|---|---|---|---|
| Gap | `gap` | 8 | Screen edges, between windows (niri `gaps`), around the bar, between stacked cards |
| Spacing | `spacingXs/Small/Medium/Large` | 4 / 8 / 12 / 16 | xs: icon↔label. small: items in a row. medium: inside tiles, between rows. large: card padding |
| Radius | `radiusSmall/Medium/Large`, full = `height / 2` | 6 / 10 / 16 | small: list rows, thumbnails. medium: windows, bar pills, tiles, OSD. large: panel, notifications, rofi. full: buttons, chips, sliders. Nested: inner = outer − padding |
| Type | `fontFamily` (Inter, `font.ui`), `fontCaption/Small/Size/Title` | 12 / 14 / 16 / 18 | Inter everywhere in the shell, rofi and hyprlock, with tabular digits (`BarText` sets `tnum`). JetBrains Mono (`font.mono`) only for the terminal, code and Nerd Font glyphs. caption: app names, sublabels (muted). small: tile titles, body text, buttons. body: bar text, values. title (bold): summaries, headline numbers |
| Icons | `iconSize`, `iconSizeLarge`, `iconWeight` | 18 / 24, 450 | Material Symbols Rounded only |
| Glass | `stripOpacity`, `raisedOpacity`, `overlayOpacity` | 0.55 / 0.62 / 0.55 | strip: bar backdrop (on `background`). raised: bar pills, rofi. overlay: panel, notifications, OSD (on `surface`). Kitty uses a separate `opacity.terminal` (0.84) |
| Rim | `rimOpacity`, `highlightOpacity` | 0.12 / 0.06 | 1px foreground border on glass (not the edge-to-edge bar strip, which has no border); a faint top gradient inside it |
| Fills | `fillRest/Hover/Pressed`, `fillRim` | 0.08 / 0.14 / 0.20, 0.08 | Foreground fills for chips, tiles, buttons and rofi rows, plus their own hairline |
| Other alphas | `trackOpacity`, `progressOpacity`, `subtleTextOpacity`, `disabledOpacity` | 0.25 / 0.6 / 0.8 / 0.4 | Slider tracks, progress lines, secondary readable text, disabled |
| Elevation | raised / floating shadow `Blur`, `Y`, `Opacity`; `shadowPad` | 6px, 2, 0.25 / 20px, 6, 0.35; 24 | flat: strip, chips at rest. raised: pills and tiles on hover, cards at rest. floating: panel, OSD, a card on hover |
| Motion | `durationFast/Normal/Slow`, `overshoot`, `exitDuration()` | 150 / 250 / 350 ms, 1.2, ×0.7 | fast + OutCubic: hover, color, press. normal + OutCubic: fades, values, reflow. slow + OutBack: surfaces entering. Exits: `exitDuration(...)`, InCubic, no overshoot |
| Borders | — | 1px rim; 1px accent; `criticalBorder` 2px red | Rim on all glass except the bar strip. Accent for focus (niri focus ring, rofi selected row). Red for critical notifications |

## Color semantics

- `accent`: on/active, focus, progress and links only.
- `foreground`: content. `muted`: secondary text and inactive indicators.
- `red`: critical, errors, low battery. `green`, `yellow` and the others: status only.
- `background` / `surface`: the glass tints. Shadows use `Theme.shadow`.

## Building blocks (config/quickshell/bar)

Reuse these before writing new widgets:
- **`Glass`:** every surface. It has:
  - `level` (strip, raised or overlay) and `elevation` (flat, raised or floating);
  - `lifted`, set on hover by `StateLayer`;
  - a `blurRegion` to hand to `BackgroundEffect.blurRegion`.
  - Override `color` / `border.color` for chips and tiles (fill tokens). The shadow is cut out under the glass, so it never darkens the fill.
- **`controls/StateLayer`:** the hover/press tint, cursor, press scale and lift for anything clickable. Declare it before the content. Use `outset` for bare icons (tray).
- **`Pill`:** a bar applet (`pillHeight` 30, radius medium, raised glass). Set `interactive` for click and scroll.
- **`controls/IconButton`** (`buttonSize` 36, full), **`ToggleTile`** (`tileHeight` 56, medium), **`QuickSlider`** (track 6, knob 16 → 18 on hover or drag), **`MaterialIcon`**, **`BarText`**.
- **List rows** (`controls/ListRow`) have one status slot at the end, never a row of icons. It shows one thing: a hover action (forget) in place of the status, else the state (a check when connected), else a hint (a lock only when a password is still needed). The glyphs cross-fade. Saved or connected things never show a lock.
- **Sound page:** list only outputs that can play (unplugged HDMI/DP ports are hidden), and one slider per app, not per stream.
- **Cards:** panel (`panelWidth` 360), notification (`notificationWidth` 380, rests raised and lifts to floating on hover), OSD (`osdWidth` 300 × `osdHeight` 44, radius medium like the bar pills).

## Windows and the compositor

- Every translucent layer surface needs blur. Either the surface requests it (`BackgroundEffect.blurRegion`, rounded) or niri blurs it with a layer-rule `background-effect { blur true }`. Every namespace also needs `xray false` in `config/niri/config.kdl`, so it frosts the windows behind it, not just the wallpaper. A translucent surface without blur is a bug.
- New layer namespaces are named `quickshell-<name>` and get a layer-rule.
- Windows that show shadowed shapes leave `shadowPad` of room where the shadow falls. Keep the input `mask`, exclusive zone and gap maths based on the visible shapes, not the padding.
- A `Region { item: ... }` ignores transforms (`scale`, `Translate`) and only re-maps on geometry changes. For a card that animates with transforms, build the blur `Region` from explicit `x/y/width/height` that include the transform, and switch to an empty region as soon as it starts hiding. Don't press-scale surfaces that carry their own blur region (`StateLayer { squash: false }`).
- Never resize an element that its parent positions by size (a slider knob, for example). Animate `scale` instead, so it doesn't shift.
- Enter animations: fade, a small translate and a scale from `pressScale`, using slow OutBack. Exits use `exitDuration`, InCubic. Keep the window mapped (`visible: shown || card.opacity > 0`) until the exit finishes.

## Icons

- Material Symbols Rounded, by ligature name, through `MaterialIcon`. Set its `size`, never `font.pixelSize`, so the optical size follows it.
- **Outlined by default.** Solid status glyphs are filled: Wi-Fi, Bluetooth, battery, volume, brightness, wired, and the check mark (see the `filled` pattern in `MaterialIcon`). Line icons such as lock, delete and monitor stay outlined, because filling them turns them into blobs.
- Prefer the clearest glyph over the literal one: `volume_up` for the laptop speaker, not the box `speaker`. Show an app's own icon when it has one (notifications, per-app volume), with a glyph only as the fallback.
- Symbolic tray icons are tinted `foreground`. No Nerd Font glyphs in the shell UI.

## Working rules

- **Never hardcode a size, color, opacity or duration in a component.** If a value is missing:
  1. add it to `theme/base.nix` (or the component-size section of `Theme.qml` if only QML uses it);
  2. wire its `@NAME@` substitution;
  3. then use it.

  The only literal numbers allowed are 0 spacing and the font's variable axes.
- **Verify every visual change with a screenshot** (`grim`, then read the PNG) before reporting:
  - run a scratch copy of the bar config with `quickshell -p <dir>`;
  - check centring, gaps and the animation end states;
  - the user rebuilds with `rebuild`; don't run it for them.
- After a token change, also run `nix flake check` (statix) and `nixos-rebuild build`.
- New files must be known to git (`git add -N <file>`) before building: the flake only sees tracked files, and a missing QML file only fails at runtime ("X is not defined"), not in `nix flake check` or the build. Check with `git status --short | grep "^??"` before reporting.
