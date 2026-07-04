pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell

// ponytail: stub Translation service — Battery.qml needs tr() for one string.
// Real i18n + translator deferred to later stage.
Singleton {
    function tr(sourceText) { return sourceText }
    function qsTr(sourceText) { return sourceText }
}
