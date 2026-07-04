pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

// ponytail: stub SystemInfo service — Icons.qml needs username for avatar path.
Singleton {
    property string username: ""
    property string distro: ""
    Component.onCompleted: {
        // Try to get username from environment
        username = Qt.environmentVariable("USER") || ""
    }
}
