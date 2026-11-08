pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import qs.Commons
import qs.Commons as Commons
import qs.Ui

ColumnLayout {
  id: actions

  required property var plugin
  required property bool pluginEnabled
  required property bool repoKnown
  required property string updateState
  required property bool updateRunning
  required property string updatingId
  required property color foreground
  required property string fontFamily
  // omarchy-sync per-machine switches: [{ host, label }] and the hosts this plugin is off for.
  property var machineHosts: []
  property var machineOff: []

  signal enabledChangeRequested(bool enabled)
  signal machineChangeRequested(string host, bool on)
  signal openPanelRequested(string pluginId)
  signal sourceRequested(string sourceKey)
  signal updateRequested(string sourceKey)
  signal menuRequested(var sourceItem, real x, real y)

  readonly property bool showSourceRow: plugin.updatable && repoKnown
  readonly property int menuWidth: toggle.trackHeight
  readonly property int sourceWidth: toggle.implicitWidth + Style.space(6) + actions.menuWidth

  Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
  spacing: Style.space(4)

  RowLayout {
    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
    spacing: Style.space(6)

    // Active bar options cannot be disabled directly. Their reduced opacity
    // mirrors the native-toggle guard while still allowing disabled plugins
    // to be enabled from this row.
    RowSwitch {
      id: toggle

      checked: actions.pluginEnabled
      canToggle: actions.plugin.canDisable || !checked
      foreground: actions.foreground
      onToggleRequested: function(next) { actions.enabledChangeRequested(next) }
    }

    Button {
      id: openButton

      readonly property bool hasPanel: {
        var kinds = actions.plugin.kinds
        if (!kinds) return false
        if (typeof kinds === "string") return kinds.indexOf("panel") !== -1
        for (var i = 0; i < kinds.length; i++) {
          if (kinds[i] === "panel") return true
        }
        return false
      }

      visible: actions.pluginEnabled && hasPanel
      tooltipText: "Open plugin panel"
      text: "OPEN"
      bordered: true
      borderSpec: openButton.hot ? Border.none()
        : Border.controlSpec("normal", openButton.foreground, Commons.Color.accent)
      foreground: actions.foreground
      accent: Commons.Color.accent
      fontFamily: actions.fontFamily
      fontSize: Style.font.caption
      iconSize: Style.font.caption
      horizontalPadding: Style.space(4)
      verticalPadding: Style.space(3)
      Layout.preferredWidth: actions.menuWidth * 2.5
      Layout.minimumWidth: actions.menuWidth * 2.5
      Layout.maximumWidth: actions.menuWidth * 2.5
      Layout.preferredHeight: actions.menuWidth
      Layout.minimumHeight: actions.menuWidth
      Layout.maximumHeight: actions.menuWidth
      Layout.alignment: Qt.AlignVCenter
      onClicked: actions.openPanelRequested(actions.plugin.id)
    }

    Button {
      id: menuButton

      iconText: "\uf142"
      tooltipText: "More actions"
      visible: !actions.plugin.firstParty
      bordered: true
      borderSpec: menuButton.hot ? Border.none()
        : Border.controlSpec("normal", menuButton.foreground, Commons.Color.accent)
      foreground: actions.foreground
      accent: Commons.Color.accent
      fontFamily: actions.fontFamily
      fontSize: Style.font.bodySmall
      horizontalPadding: 0
      verticalPadding: Style.space(3)
      Layout.preferredWidth: actions.menuWidth
      Layout.minimumWidth: actions.menuWidth
      Layout.maximumWidth: actions.menuWidth
      Layout.preferredHeight: actions.menuWidth
      Layout.minimumHeight: actions.menuWidth
      Layout.maximumHeight: actions.menuWidth
      Layout.alignment: Qt.AlignVCenter
      onClicked: actions.menuRequested(menuButton, 0, menuButton.height)
    }
  }

  RowLayout {
    visible: actions.showSourceRow
    Layout.preferredWidth: actions.sourceWidth
    Layout.minimumWidth: actions.sourceWidth
    Layout.maximumWidth: actions.sourceWidth
    Layout.alignment: Qt.AlignRight
    spacing: Style.space(6)

    Button {
      id: sourceButton

      visible: actions.plugin.updatable && actions.repoKnown
      tooltipText: "Open plugin repository"
      text: "SOURCE \uDB85\uDD94"
      bordered: true
      borderSpec: sourceButton.hot ? Border.none()
        : Border.controlSpec("normal", sourceButton.foreground, Commons.Color.accent)
      foreground: actions.foreground
      accent: Commons.Color.accent
      fontFamily: actions.fontFamily
      fontSize: Style.font.caption
      iconSize: Style.font.caption
      horizontalPadding: 0
      verticalPadding: Style.space(3)
      Layout.fillWidth: true
      onClicked: actions.sourceRequested(actions.plugin.sourceKey)
    }
  }

  // One switch per machine (omarchy-sync). Off = that machine doesn't get the plugin;
  // the switch above stays the global one.
  RowLayout {
    visible: actions.machineHosts.length > 1 && !actions.plugin.firstParty
    Layout.alignment: Qt.AlignRight
    spacing: Style.space(4)

    Repeater {
      model: actions.machineHosts

      RowLayout {
        id: machine

        required property var modelData
        readonly property bool on: actions.machineOff.indexOf(modelData.host) === -1

        spacing: Style.space(2)

        Label {
          text: String(machine.modelData.label)
          color: actions.foreground
          opacity: machine.on ? 0.85 : 0.45
          font.family: actions.fontFamily
          font.pixelSize: Style.font.caption
          Layout.alignment: Qt.AlignVCenter
        }

        RowSwitch {
          checked: machine.on
          sizeFactor: 0.7
          foreground: actions.foreground
          onToggleRequested: function(next) { actions.machineChangeRequested(machine.modelData.host, next) }
        }
      }
    }
  }
}
