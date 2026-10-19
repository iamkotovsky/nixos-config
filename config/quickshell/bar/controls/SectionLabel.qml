import QtQuick
import QtQuick.Layouts
import ".."

// Heading for a group of rows on a sub-page ("Output", "Apps"): row-title
// size, medium weight, muted, starting where row titles start.
BarText {
    Layout.fillWidth: true
    Layout.leftMargin: Theme.buttonSize + Theme.spacingMedium
    color: Theme.muted
    font.pixelSize: Theme.fontSmall
    font.weight: Font.Medium
}
