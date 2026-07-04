import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.translate("Audio input")
    statusText: toggled ? Translation.translate("Enabled") : Translation.translate("Muted")
    toggled: !Audio.source?.audio?.muted
    icon: Audio.source?.audio?.muted ? "mic_off" : "mic"
    mainAction: () => {
        Audio.toggleMicMute()
    }
    hasMenu: true

    tooltipText: Translation.translate("Audio input | Right-click for volume mixer & device selector")
}
