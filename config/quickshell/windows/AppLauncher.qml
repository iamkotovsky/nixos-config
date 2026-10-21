pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import ".."
import "../ui"
import "../services"

// The app launcher window for one screen (Mod+D; state in services/Launcher):
// a search field and the matching apps on a centred card of fixed size.
// Typing filters, Up/Down (Tab, Ctrl+J/K) moves the highlight, Enter or a
// click launches, Esc clears the search and then closes, a click outside
// closes. Like the control panel, the window stays mapped and only takes
// input and focus while open.
PanelWindow {
    id: window

    required property string screenName

    readonly property bool open: Launcher.openOn === screenName
    // Room between the highlight's edge and a row's app icon.
    readonly property int rowPadding: Theme.spacingMedium

    anchors {
        top: true
        bottom: true
        left: true
        right: true
    }
    exclusionMode: ExclusionMode.Ignore
    color: "transparent"
    visible: true
    mask: open ? null : passThrough

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.namespace: "quickshell-launcher"
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

    BackgroundEffect.blurRegion: card.liveBlurRegion

    Region {
        id: passThrough
    }

    MouseArea {
        anchors.fill: parent
        onClicked: Launcher.close()
    }

    PopupSurface {
        id: card

        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        width: Theme.launcherWidth
        height: content.implicitHeight + Theme.spacingLarge * 2
        radius: Theme.radiusLarge
        level: "overlay"
        elevation: "floating"
        shown: window.open
        transformOrigin: Item.Center
        slideFrom: -Theme.spacingSmall

        // A fresh search, with the keyboard in the field, every time it opens.
        onShownChanged: {
            if (shown) {
                field.text = "";
                list.currentIndex = 0;
                pointer.last = Qt.point(-1, -1);
                field.focusInput();
            }
        }

        // Swallow clicks so they don't reach the close area behind the card.
        MouseArea {
            anchors.fill: parent
        }

        ColumnLayout {
            id: content

            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Theme.spacingLarge
            }
            spacing: Theme.spacingSmall

            SearchField {
                id: field

                Layout.fillWidth: true
                Layout.preferredHeight: Theme.launcherFieldHeight
                textSize: Theme.fontTitle
                glyphSize: Theme.iconSizeLarge
                // The glyph centred over the rows' icons, and the typed text
                // starting where their titles do.
                glyphMargin: window.rowPadding + (Theme.launcherIconSize - glyphSize) / 2
                glyphGap: window.rowPadding + Theme.launcherIconSize + Theme.spacingMedium - glyphMargin - glyphSize
                onTextChanged: {
                    Launcher.query = text;
                    list.currentIndex = 0;
                    list.positionViewAtBeginning();
                }
                onMoved: delta => {
                    const last = list.count - 1;
                    list.currentIndex = Math.max(0, Math.min(last, list.currentIndex + delta));
                    list.reveal(list.currentIndex);
                }
                onAccepted: Launcher.launch(Launcher.results[list.currentIndex])
                onCanceled: {
                    if (text !== "")
                        text = "";
                    else
                        Launcher.close();
                }
            }

            // A fixed area for the results, so the centred card keeps its size
            // while the search narrows them; "No apps found" sits in it too.
            Item {
                Layout.fillWidth: true
                Layout.preferredHeight: Theme.launcherRowHeight * Theme.launcherRows

                ScrollList {
                    id: list

                    anchors.fill: parent
                    visible: count > 0
                    rowHeight: Theme.launcherRowHeight
                    maxRows: Theme.launcherRows

                    model: ScriptModel {
                        values: Launcher.results
                        objectProp: "id"
                    }

                    // The current row: the neutral selection fill, gliding
                    // between rows.
                    highlightFollowsCurrentItem: true
                    highlightMoveDuration: Theme.durationFast
                    // Duration only: the default speed cap would override it.
                    highlightMoveVelocity: -1
                    highlightResizeDuration: 0
                    highlight: Rectangle {
                        radius: Theme.radiusMedium
                        color: Qt.alpha(Theme.foreground, Theme.fillHover)
                    }

                    delegate: ListRow {
                        required property var modelData

                        width: ListView.view.width
                        height: Theme.launcherRowHeight
                        image: Icons.resolve(modelData.icon, modelData.name)
                        imageSize: Theme.launcherIconSize
                        leftPadding: window.rowPadding
                        iconColumnWidth: Theme.launcherIconSize
                        titleSize: Theme.fontSize
                        icon: "apps"
                        title: modelData.name
                        subtitle: modelData.genericName && modelData.genericName !== modelData.name ? modelData.genericName : ""
                        hoverTint: false
                        onClicked: Launcher.launch(modelData)
                    }

                    // The pointer moves the highlight, but only when the pointer
                    // itself moves: not when the card opens under it (Enter must
                    // launch the top result), and not when rows scroll under a
                    // still pointer. Qt re-sends hover every frame while content
                    // moves; following those would move the highlight, and
                    // ListView scrolls to keep the highlight in view, fighting
                    // the scroll.
                    HoverHandler {
                        id: pointer

                        // The pointer's last position in the window (-1: not
                        // seen since opening).
                        property point last: Qt.point(-1, -1)

                        onPointChanged: {
                            const pos = point.scenePosition;
                            const moved = last.x >= 0 && (pos.x !== last.x || pos.y !== last.y);
                            last = pos;
                            if (!moved)
                                return;
                            const index = list.indexAt(point.position.x, point.position.y + list.contentY);
                            if (index >= 0)
                                list.currentIndex = index;
                        }
                    }
                }

                BarText {
                    anchors.centerIn: parent
                    visible: list.count === 0
                    text: "No apps found"
                    color: Theme.muted
                    font.pixelSize: Theme.fontSmall
                    horizontalAlignment: Text.AlignHCenter
                }
            }
        }
    }
}
