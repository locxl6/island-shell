import QtQuick
import Quickshell
import qs
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: Translation.translate("Dark Mode")
    statusText: Appearance.m3colors.darkmode ? Translation.translate("Dark") : Translation.translate("Light")

    toggled: Appearance.m3colors.darkmode
    icon: "contrast"
    
    mainAction: () => {
        // ponytail: share the bar button path so shell colors are regenerated
        // even when full app/shell wallpaper theming is disabled in settings.
        MaterialThemeLoader.toggleLightDark()
    }

    tooltipText: Translation.translate("Dark Mode")
}
