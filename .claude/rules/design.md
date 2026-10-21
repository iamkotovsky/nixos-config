---
paths:
  - "config/quickshell/**"
  - "config/firefox/**"
  - "config/telegram/**"
  - "config/niri/**"
  - "theme/**"
  - "modules/home/quickshell.nix"
  - "modules/home/lockscreen.nix"
  - "modules/home/kitty.nix"
  - "modules/home/firefox.nix"
  - "modules/home/telegram.nix"
  - "modules/home/helix.nix"
  - "modules/home/yazi.nix"
  - "modules/home/starship.nix"
  - "modules/home/shell-tools.nix"
  - "modules/home/git.nix"
  - "modules/home/zsh.nix"
  - "modules/system/desktop.nix"
  - "modules/home/fastfetch.nix"
  - "modules/home/theme.nix"
  - "modules/home/session.nix"
---

# Desktop design system

These rules cover the visual language of the whole desktop: the Quickshell bar, control panel, OSD and notifications; the lock screen; the app launcher; niri; and every app themed from `theme/` (kitty, Helix, yazi, starship, Firefox, Telegram, GTK). Follow them for every UI change. When a rule and a request conflict, ask the user.

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
5. **One accent on a neutral palette, everywhere.** The user prefers a single accent colour (pink in the current presets) over a mostly neutral palette of greys, in every app, not just the shell. Pink marks on/active, focus, progress and links, never decoration; other hues appear only to signal status. See "The palette in apps" below.
6. **Everything is rounded, on one gap rhythm, and centred to the pixel.** Check vertical centring in a screenshot, nudging with `Translate` if a glyph sits off-centre.

## Tokens

The single source of truth is `theme/base.nix`, with colors in `theme/presets/*.nix`. Templates get the values through `@NAME@` substitutions:
- `config/quickshell/Theme.qml` via `modules/home/quickshell.nix`;
- `config/niri/config.kdl` via `modules/home/niri.nix`.
- `config/telegram/colors.tdesktop-theme` via `modules/home/telegram.nix`. Telegram lays a theme over its light default palette, so every key gets set (unset keys show light defaults). Hover/pressed/tint shades are mixed in Nix (`mix a b t`), and only keys that exist in the installed Telegram are allowed (check the binary). Outgoing bubbles use the soft accent tint, not solid accent; the selected chat and folder are the neutral selection grey.
- `config/firefox/userChrome.css` via `modules/home/firefox.nix`. Opacities become `color-mix` percentages; Firefox's own theme variables are mapped onto `--ds-*` tokens at the top of the file.

Component sizes that only QML uses live in the last section of `Theme.qml`.

| Group | Tokens (Theme.qml) | Values | Use |
|---|---|---|---|
| Gap | `gap` | 8 | Screen edges, between windows (niri `gaps`), around the bar, between stacked cards |
| Spacing | `spacingXs/Small/Medium/Large` | 4 / 8 / 12 / 16 | xs: icon↔label. small: items in a row. medium: inside tiles, between rows. large: card padding |
| Radius | `radiusSmall/Medium/Large`, full = `height / 2` | 6 / 10 / 16 | small: list rows, thumbnails. medium: windows, bar pills, tiles, OSD. large: panel, launcher, notifications. full: buttons, chips, sliders. Nested: inner = outer − padding |
| Type | `fontFamily` (Inter, `font.ui`), `fontCaption/Small/Size/Title` | 12 / 14 / 16 / 18 | Inter everywhere in the shell (bar, launcher, lock screen), with tabular digits (`BarText` sets `tnum`). JetBrains Mono (`font.mono`) only for the terminal, code and Nerd Font glyphs. caption: sublabels and status lines under a title (muted). small: tile and row titles, item names above sliders, section headings (`SectionLabel`: medium weight, muted), body text, buttons. body: bar text, values. title (bold): summaries, headline numbers |
| Icons | `iconSize`, `iconSizeLarge`, `iconWeight` | 18 / 24, 450 | Material Symbols Rounded only |
| Glass | `stripOpacity`, `raisedOpacity`, `overlayOpacity` | 0.55 / 0.62 / 0.55 | strip: bar backdrop (on `background`). raised: bar pills. overlay: panel, launcher, notifications, OSD (on `surface`). Kitty uses a separate `opacity.terminal` (0.84) |
| Rim | `rimOpacity`, `highlightOpacity` | 0.12 / 0.06 | 1px foreground border on glass (not the edge-to-edge bar strip, which has no border); a faint top gradient inside it |
| Fills | `fillRest/Hover/Pressed`, `fillRim` | 0.08 / 0.14 / 0.20, 0.08 | Foreground fills for chips, tiles, buttons and list rows, plus their own hairline |
| Other alphas | `trackOpacity`, `progressOpacity`, `subtleTextOpacity`, `disabledOpacity`, `focusRimOpacity` | 0.25 / 0.6 / 0.8 / 0.4 / 0.3 | Slider tracks, progress lines, secondary readable text, disabled, a neutral focus rim |
| Elevation | raised / floating shadow `Blur`, `Y`, `Opacity`; `shadowPad` | 6px, 2, 0.25 / 20px, 6, 0.35; 24 | flat: strip, chips at rest. raised: pills and tiles on hover, cards at rest. floating: panel, OSD, a card on hover |
| Motion | `durationFast/Normal/Slow`, `overshoot`, `exitDuration()` | 150 / 250 / 350 ms, 1.2, ×0.7 | fast + OutCubic: hover, color, press. normal + OutCubic: fades, values, reflow. slow: surfaces entering (OutBack only for real travel, see Windows and the compositor). Exits: `exitDuration(...)`, InCubic, no overshoot |
| Borders | — | 1px everywhere: rim, accent, red | Rim on all glass except the bar strip. Accent for focus (niri focus ring), except where focus never moves: the lock screen field is always focused, so it uses a neutral light rim (`PasswordField { neutral: true }`). Red (same 1px, colour only) for critical notifications |

## Color semantics

- `accent`: on/active, focus, progress and links only.
- `foreground`: content. `muted`: secondary text and inactive indicators.
- `red`: critical, errors, low battery. `green`, `yellow` and the others: status only.
- `background` / `surface`: the glass tints. Shadows use `Theme.shadow`.

### The palette in apps

The same rule holds in every themed app: one accent, everything else neutral. Colour is a signal, so when everything is coloured nothing stands out.
- **Code highlighting** (Helix, `bat`/`delta` if added, Firefox devtools, Telegram code blocks, anything else that highlights code) is mostly monochrome:
  - **Code:** foreground for identifiers, functions, types, variables, modules and attributes.
  - **Keywords:** the accent, including keyword-like syntax such as markup tags and headings.
  - **Literals:** each literal kind may have its own palette hue, and nothing else gets one. Strings and characters are green; numbers, booleans and built-in constants (`true`, `nil`) are yellow.
  - **Punctuation and operators:** slightly muted (`muted`).
  - **Comments:** `muted`, in italics.
  - No hue per token kind beyond that: functions, types and named constants stay foreground, not blue, yellow or cyan.
- **Status colours keep their meaning and stay rare:**
  - red: errors and deletions;
  - yellow: warnings and modifications;
  - green: success and additions.

  This covers diagnostics, diffs, git status, the prompt's exit status and file-manager marks. Blue, cyan and magenta have no status meaning, so use neutral or the accent instead.
- **Terminal ANSI colours** (kitty `color0–15`) stay a full set, since command-line tools need distinct colours to be readable. Keep them muted, not saturated, so tool output doesn't fight the neutral UI.
- **Selection is neutral:** selected text, hovered and selected rows (yazi, fzf, the selected chat in Telegram) use the selection grey (`mix background foreground tint.selection`), never the accent. **The text cursor stays neutral** too (foreground). The user wants neither in pink.
- **Current line, search matches and links** use the accent or a soft tint of it, never a second hue.
- **One highlighting theme:** `theme/syntax.nix` renders the code rule as a `.tmTheme`, shared by bat, delta (through bat's theme cache) and yazi's previews; Helix and zsh's command-line highlighting follow the same mapping. File listings (`LS_COLORS` via dircolors, `EZA_COLORS`) are neutral: folders bold, details muted, colour only for status (git, broken links, setuid). Solid tints come from `tint` in `theme/base.nix` through `mix` (`theme/color.nix`).
- **Outside the terminal:** the login screen uses the Linux console palette (`console.colors`, the same slots as kitty) with tuigreet naming slots (`modules/system/desktop.nix`): muted chrome, foreground text, the accent only on the action keys. GTK apps are dark and take the accent (`modules/home/theme.nix`): GTK 3 through `@define-color accent_*`, GTK 4 through the `--accent-*` CSS variables. GTK 4 only gets adw-gtk3 at all because `gtk.gtk4.theme` is set; without it plain GTK 4 apps (pavucontrol) are light Adwaita. Papirus folders are grey, not blue.
- A new app, or a theme for one, starts from the neutral greys plus the accent. Add another hue only for a status meaning above.

## Code layout (config/quickshell)

- `shell.qml`: the desktop shell, per screen one of each window. It is Quickshell's default config, run by the `quickshell` user service; reach it with plain `quickshell ipc call ...`. `Theme.qml` here is the template: the installed config leaves it out and gets the rendered copy in its place.
- `lock.qml` + `lock/`: the lock screen, a separate Quickshell process (the `lockscreen` unit from `modules/home/lockscreen.nix`) sharing `Theme` and `ui/`. `LockSurface` wraps `LockContent`, which can be previewed in an ordinary window. Never test it by locking before the PAM service (`quickshell-lock`) is deployed.
- `windows/`: the layer windows: `Bar`, `ControlPanel`, `AppLauncher`, `OsdPopup`, `NotificationPopups`. A window is never named like a service (`AppLauncher` vs `Launcher`): both folders are imported together and the names would clash.
- `widgets/`: bar applets: `Pill` and everything built on it (`Clock`, `Workspaces`, `Tray`, `Language`, `StatusButton`).
- `ui/`: reusable building blocks (below), not tied to any service.
- `pages/`: control panel pages: `MainPage`, `WifiPage`, `SoundPage`, `BluetoothPage`, `PowerPage`.
- `notifications/`: `NotificationCard` and its `NotificationHeader` / `NotificationActions`.
- `services/`: singletons for state (`Audio`, `AudioPorts`, `Network`, `BluetoothState`, `Brightness`, `Power`, `Caffeine`, `Notifications`, `NiriEvents`, `Osd`, `ControlCenter`, `Launcher`, `Session`, `Icons`). No visuals here.
- Subfolders import siblings relatively (`import "../ui"`) and `import ".."` for `Theme`. Keep files focused: a window file holds the window, a page holds its content, logic lives in services.
- Use the named constants, not strings: `ControlCenter.openPage(ControlCenter.wifiPage)`, `ControlCenter.showing(...)`, `Osd.show(Osd.volume)`.

## Building blocks (ui/)

Reuse these before writing new widgets:
- **`Glass`:** every surface. It has:
  - `level` (strip, raised or overlay) and `elevation` (flat, raised or floating); unknown values warn;
  - `lifted`, set on hover by `StateLayer`;
  - a `blurRegion` to hand to `BackgroundEffect.blurRegion` (only for surfaces that don't move).
  - Override `color` / `border.color` for chips and tiles (fill tokens). The shadow is cut out under the glass, so it never darkens the fill.
- **`PopupSurface`:** a `Glass` that appears and disappears (`shown`, `transformOrigin`, `slideFrom`). It eases in (slow OutCubic, no spring) and leaves quicker, and its `liveBlurRegion` follows the scale and slide, switches on once the surface is half faded in (the compositor applies blur ahead of the card's first frames) and empties as it starts hiding. Use it for any card that pops up.
- **`PageStack`:** a main page plus named sub-pages that slide in and out while its height animates (`main`, `pages`, `current`, `padding`).
- **`Anim` / `ColorFade`:** the motion tokens as one-liners: `Behavior on x { Anim {} }`, `Anim { speed: "fast" }`, `Anim { speed: "slow"; spring: true }`, `Anim { leaving: true }`, `Behavior on color { ColorFade {} }`. Write a raw `NumberAnimation` only for transitions with custom `from`/`to`.
- **`StateLayer`:** the hover/press tint, cursor, press scale and lift for anything clickable. Declare it before the content. Use `outset` for bare icons (tray).
- **`MaterialIcon`** and **`BarText`** fade colour changes themselves (never add another `Behavior on color` to them); `BarText { fadeText: true }` crossfades whole-word changes (clock, layout), not numbers.
- **`Pill`** (`widgets/`): a bar applet (`pillHeight` 30, radius medium, raised glass). Set `interactive` for click and scroll.
- **`IconButton`** (`buttonSize` 36, full), **`ToggleTile`** (`tileHeight` 56, medium), **`QuickSlider`** (track 6, knob 16 → 18 on hover or drag), **`Switch`**, **`PasswordField`**, **`SearchField`** (same chip with a search glyph; reports Up/Down/Tab/Ctrl+J/K as `moved`), **`PageHeader`**, **`SectionLabel`**, **`ScrollList`** (lists) and **`ScrollArea`** (a scrolling column for anything else), **`Spinner`**.
- **Scrolling is one behaviour everywhere: `SmoothScroll`.** Anything that scrolls is a `ScrollList` or `ScrollArea`, both built on it; a new scrollable Flickable gets `interactive: false` and a `SmoothScroll { parent: flick; anchors.fill: parent; flickable: flick }`. It does touchpads 1:1 then a decelerating glide at the release speed, a `step` per wheel notch with a glide, a rubber-band stretch past either end that springs back with `OutBack`, a bump when a notch or glide hits an end, `revealRange` for keyboard moves (never `positionViewAtIndex`, which snaps a highlight), and a thin `scrollbarWidth` thumb while scrolling that squashes while stretched and fades after `scrollbarLinger`. Controls that change a value by scrolling (bar pills: volume) count steps through **`WheelSteps`**: one per notch, one per `touchpadStep` of touchpad travel, never one per event.
- **List rows** (`ListRow`) have one status slot at the end, never a row of icons: use **`RowSlot`**. It shows one thing: a hover action (forget) in place of the status, else the state (a check when connected), else a hint (a lock only when a password is still needed). The glyphs cross-fade. Saved or connected things never show a lock.
- **App icons:** `Icons.resolve(icon, app)` (theme name, path or URL, else the desktop entry), so notifications and per-app volume agree.
- **Power page:** lock and suspend run at once; log out, restart and shut down count down in their row (red icon, cancel in the status slot, click again to go now), and leaving the page cancels. They run `sessionctl` (`modules/home/session.nix`), which closes windows first and stops the session through systemd. Never leave the session with niri's `quit`: it kills the compositor first and every client and service crashes (`Mod+Ctrl+Shift+E` keeps it as an emergency exit only). The rows are `pages/PowerActions` (`ids` picks which), shared with the lock screen's power pill, which offers only suspend, restart and shut down (no log out: it would close apps with unsaved work for whoever is at the keyboard). `sessionctl` exits 3 when a window stays open; `Session.failure` carries it, and the lock screen shows it in its status line because notifications are hidden under the lock.
- **Sound page:** list only outputs that can play (unplugged HDMI/DP ports are hidden), and one slider per app, not per stream.
- **Launcher** (`windows/AppLauncher` + `services/Launcher`, Mod+D): a card centred on the screen with a fixed size, so it never jumps while filtering: `launcherWidth` 680, a `launcherFieldHeight` 52 field with title-size text, and a results area of exactly `launcherRows` (5) rows of `launcherRowHeight` 56 with `launcherIconSize` 32 app icons ("No apps found" sits in the same area). The field's glyph and the rows' icons share one centre line and the typed text starts where the titles do; rows keep `rowPadding` between the highlight's edge and the icon (`SearchField` `glyphMargin`/`glyphGap`, `ListRow` `leftPadding`/`iconColumnWidth`, derived in the window, never hand-tuned). Apps rank by name match, then generic name/keywords, then comment, plus a usage boost from `launcher-usage.json` in the state dir. The current row is a ListView highlight (neutral fill, gliding); rows use `hoverTint: false`, and the pointer only moves the highlight once it really moves (not when the card opens under it).
- **Starting apps from the shell:** through `niri msg action spawn -- ...`, so they live in niri's scope; `Quickshell.execDetached` leaves them in the `quickshell` service, and the restart on every rebuild kills them. Terminal apps run in `kitty -e`. (`Audio.openMixer` still uses `execDetached`.)
- **Cards:** panel (`panelWidth` 360), notification (`notificationWidth` 380, bottom-right corner inset two gaps so it never sits on a window's border or focus ring, newest at the bottom, no visible countdown, rests raised and lifts to floating on hover), OSD (`osdWidth` 300 × `osdHeight` 44, radius medium like the bar pills).

## Windows and the compositor

- Every translucent layer surface needs blur. Either the surface requests it (`BackgroundEffect.blurRegion`, rounded) or niri blurs it with a layer-rule `background-effect { blur true }`. Every namespace also needs `xray false` in `config/niri/config.kdl`, so it frosts the windows behind it, not just the wallpaper. A translucent surface without blur is a bug.
- New layer namespaces are named `quickshell-<name>` and get a layer-rule.
- Windows that show shadowed shapes leave `shadowPad` of room where the shadow falls. Keep the input `mask`, exclusive zone and gap maths based on the visible shapes, not the padding.
- A `Region { item: ... }` ignores transforms (`scale`, `Translate`) and only re-maps on geometry changes. For a card that animates with transforms, build the blur `Region` from explicit `x/y/width/height` that include the transform, and switch to an empty region as soon as it starts hiding. Don't press-scale surfaces that carry their own blur region (`StateLayer { squash: false }`).
- Blur can't fade: a surface with its own blur region either drops the region when it starts leaving (panel, OSD) or leaves by sliding off-screen at full opacity (notifications). Never fade it with the frost still on, which leaves a ghost frost rectangle.
- A `ListView` destroys delegates that fall outside its bounds, even mid remove-transition. A list that animates items out must not shrink to its content; let it fill a fixed area, and take masks and blur from the items, not the list.
- Popup windows (panel, OSD, notifications) stay mapped all the time at a fixed size, transparent, with the input mask and blur covering only what is visible (and no keyboard focus while closed). Don't toggle `visible` or resize them: every unmap/remap or resize of a layer surface is a configure round-trip (and niri fades closing layers), which shows as stutter, cards vanishing mid-animation and flashing back, and a window mapped on demand draws its first frames about 0.4 s after the compositor's blur appears.
- Never resize an element that its parent positions by size (a slider knob, for example). Animate `scale` instead, so it doesn't shift.
- Enter animations: fade, a small translate and a scale from `pressScale`, slow. Use the spring (OutBack) only for real travel (notifications sliding in, the switch knob, scroll bumps): on tiny moves such as a 0.96 -> 1 scale or a few-pixel slide its overshoot is about a pixel, and Qt draws on whole pixels, so it shows as the whole surface twitching by a pixel right after it seemed to stop. Those ease out (OutCubic). Exits use `exitDuration`, InCubic. `PopupSurface` and `Anim` implement this.

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
  - run a scratch copy of the shell config with `quickshell -p <dir>`, under `timeout`, and check it has exited;
  - check centring, gaps and the animation end states;
  - the user rebuilds with `rebuild`; don't run it for them.
- After a token change, also run `nix flake check` (statix) and `nixos-rebuild build`.
- New files must be known to git (`git add -N <file>`) before building: the flake only sees tracked files, and a missing QML file only fails at runtime ("X is not defined"), not in `nix flake check` or the build. Check with `git status --short | grep "^??"` before reporting.
- Quickshell singletons are created lazily, on first read. A service that must work from start-up (signal handlers, `IpcHandler`, servers) has to be listed in `shell.qml`'s `services` property, or it stays dead until some UI happens to read it.
