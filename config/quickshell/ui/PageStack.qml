import QtQuick

// A main page and one sub-page side by side: opening a sub-page slides the
// main page out to the left and the sub-page in from the right, while the
// stack's height animates to fit. The last sub-page stays loaded while it
// slides back out. Clipped at its own edge, so place it to fill a card and
// give it the card's `padding`: hover shadows inside then stay whole.
Item {
    id: stack

    // The main page, and sub-pages by name.
    property Component main
    property var pages: ({})
    // The sub-page shown ("" = main).
    property string current: ""
    property real padding: 0

    readonly property bool sub: current !== ""
    readonly property real contentWidth: width - padding * 2
    property string loaded: ""

    height: (sub ? subPage.implicitHeight : mainPage.implicitHeight) + padding * 2
    clip: true

    onCurrentChanged: {
        if (current !== "")
            loaded = current;
    }
    Component.onCompleted: loaded = current

    Behavior on height {
        Anim {}
    }

    Loader {
        id: mainPage

        x: stack.padding - (stack.sub ? stack.width : 0)
        y: stack.padding
        width: stack.contentWidth
        opacity: stack.sub ? 0 : 1
        sourceComponent: stack.main

        Behavior on x {
            Anim {}
        }
        Behavior on opacity {
            Anim {}
        }
    }

    Loader {
        id: subPage

        x: stack.padding + (stack.sub ? 0 : stack.width)
        y: stack.padding
        width: stack.contentWidth
        opacity: stack.sub ? 1 : 0
        active: stack.loaded !== ""
        sourceComponent: stack.pages[stack.loaded] ?? null

        Behavior on x {
            Anim {}
        }
        Behavior on opacity {
            Anim {}
        }
    }
}
