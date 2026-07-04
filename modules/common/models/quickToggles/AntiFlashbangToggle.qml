import QtQuick
import qs.services
import qs.modules.common
import qs.modules.common.functions
import qs.modules.common.widgets

QuickToggleModel {
    name: HyprlandAntiFlashbangShader.enabled ? (HyprlandAntiFlashbangShader.weak ? Translation.translate("Anti-flash: Weak") : Translation.translate("Anti-flash: Strong")) : Translation.translate("Anti-flashbang")
    tooltipText: `${Translation.translate("Anti-flashbang")}: ${HyprlandAntiFlashbangShader.enabled ? (HyprlandAntiFlashbangShader.weak ? Translation.translate("Weak") : Translation.translate("Strong")) : Translation.translate("Off")}`
    icon: HyprlandAntiFlashbangShader.enabled ? (!HyprlandAntiFlashbangShader.weak ? "flash_off" : "sunny_snowing") : "flash_on"
    toggled: HyprlandAntiFlashbangShader.enabled

    mainAction: () => {
        HyprlandAntiFlashbangShader.cycle()
    }
    hasMenu: true
}
