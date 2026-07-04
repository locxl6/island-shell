import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    toggled: SongRec.running
    property bool sourceIsMonitor: SongRec.monitorSource === SongRec.MonitorSource.Monitor

    name: Translation.translate("Identify Music")
    statusText: toggled ? Translation.translate("Listening...") : sourceIsMonitor ? Translation.translate("System sound") : Translation.translate("Microphone")
    icon: toggled ? "music_cast" : (sourceIsMonitor ? "music_note" : "frame_person_mic")

    tooltipText: Translation.translate("Recognize music | Right-click to toggle source")

    mainAction: () => {
        SongRec.toggleRunning()
    }
    altAction: () => {
        SongRec.toggleMonitorSource()
    }
}
