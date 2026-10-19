pragma Singleton

import QtQuick
import Quickshell

// Icons for apps (notifications, per-app volume).
Singleton {
    // `icon` may be a theme name, an absolute path or a URL; when it is empty
    // the app's desktop entry (looked up by `app`) supplies one. Returns ""
    // when there is none, so callers can fall back to a glyph.
    function resolve(icon, app) {
        const name = icon ?? "";
        if (name.startsWith("/"))
            return "file://" + name;
        if (name.startsWith("file://") || name.startsWith("image://"))
            return name;
        if (name !== "")
            return Quickshell.iconPath(name, true);
        const entry = DesktopEntries.heuristicLookup(app ?? "");
        return entry ? Quickshell.iconPath(entry.icon, true) : "";
    }
}
