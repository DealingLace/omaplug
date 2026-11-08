pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons

// The row toggle, shared by the global switch and the per-machine switches.
Item {
  id: toggle

  property bool checked: false
  property bool canToggle: true
  property real sizeFactor: 1.0
  required property color foreground

  signal toggleRequested(bool checked)

  readonly property int trackHeight: Math.max(14, Math.round(Math.max(22, Math.round(Style.spacing.controlHeight * 0.55)) * sizeFactor))
  readonly property int trackWidth: Math.round(trackHeight * 1.9)
  readonly property int knobSize: Math.max(6, Math.round(trackHeight * 0.72))
  readonly property int inset: Math.max(1, Math.round((trackHeight - knobSize) / 2))

  implicitWidth: trackWidth
  implicitHeight: trackHeight
  opacity: canToggle ? 1 : 0.4
  Layout.alignment: Qt.AlignVCenter

  Rectangle {
    width: toggle.trackWidth
    height: toggle.trackHeight
    radius: Style.cornerRadius > 0 ? height / 2 : 0
    color: toggle.checked
      ? Commons.Color.accent
      : Style.normalFillFor(toggle.foreground, Commons.Color.accent)
    Behavior on color { ColorAnimation { duration: 120 } }

    Rectangle {
      width: toggle.knobSize
      height: toggle.knobSize
      radius: Style.cornerRadius > 0 ? height / 2 : 0
      x: toggle.checked ? toggle.trackWidth - width - toggle.inset : toggle.inset
      anchors.verticalCenter: parent.verticalCenter
      color: toggle.checked ? Commons.Color.background : Qt.darker(toggle.foreground, 1.25)
      Behavior on x { NumberAnimation { duration: 120; easing.type: Easing.OutCubic } }
      Behavior on color { ColorAnimation { duration: 120 } }
    }
  }

  MouseArea {
    anchors.fill: parent
    cursorShape: toggle.canToggle ? Qt.PointingHandCursor : Qt.ArrowCursor
    onClicked: {
      if (!toggle.canToggle) return
      var next = !toggle.checked
      Qt.callLater(function() { toggle.toggleRequested(next) })
    }
  }
}
