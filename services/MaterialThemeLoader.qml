pragma Singleton
pragma ComponentBehavior: Bound

import qs.modules.common
import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Hyprland

/**
 * Automatically reloads generated material colors.
 * It is necessary to run reapplyTheme() on startup because Singletons are lazily loaded.
 */
Singleton {
    id: root
    property string filePath: Directories.generatedMaterialThemePath

    function reapplyTheme() {
        // ponytail: FileView.reload() is async and onLoadedChanged doesn't fire if already loaded.
        // Force reload then read text after a delay to let async read complete.
        themeFileView.reload()
        reapplyTimer.restart()
    }

    function applyColors(fileContent) {
        if (!fileContent || fileContent.length === 0) {
            console.warn("[MaterialThemeLoader] applyColors: empty content")
            return
        }
        try {
            const json = JSON.parse(fileContent)
            for (const key in json) {
                if (json.hasOwnProperty(key)) {
                    const camelCaseKey = key.replace(/_([a-z])/g, (g) => g[1].toUpperCase())
                    const m3Key = `m3${camelCaseKey}`
                    Appearance.m3colors[m3Key] = json[key]
                }
            }
            Appearance.m3colors.darkmode = (Appearance.m3colors.m3background.hslLightness < 0.5)
            console.log(`[MaterialThemeLoader] applyColors: darkmode=${Appearance.m3colors.darkmode} bg=${Appearance.m3colors.m3background}`)
        } catch (e) {
            console.warn(`[MaterialThemeLoader] applyColors: parse error: ${e}`)
        }
    }

    function resetFilePathNextTime() {
        resetFilePathNextWallpaperChange.enabled = true
    }

    Connections {
        id: resetFilePathNextWallpaperChange
        enabled: false
        target: Config.options.background
        function onWallpaperPathChanged() {
            root.filePath = ""
            root.filePath = Directories.generatedMaterialThemePath
            resetFilePathNextWallpaperChange.enabled = false
        }
    }

    // ponytail: delay reading text() after reload() to let async read complete
    Timer {
        id: reapplyTimer
        interval: 200
        repeat: false
        onTriggered: {
            root.applyColors(themeFileView.text())
        }
    }

    Timer {
        id: delayedFileRead
        interval: Config.options?.hacks?.arbitraryRaceConditionDelay ?? 100
        repeat: false
        running: false
        onTriggered: {
            root.applyColors(themeFileView.text())
        }
    }

    FileView { 
        id: themeFileView
        path: Qt.resolvedUrl(root.filePath)
        watchChanges: true
        onFileChanged: {
            this.reload()
            delayedFileRead.start()
        }
        onLoadedChanged: {
            root.applyColors(themeFileView.text())
        }
        onLoadFailed: {
            console.warn("[MaterialThemeLoader] load failed, will retry on wallpaper change")
            root.resetFilePathNextTime()
        }
    }

    function toggleLightDark() {
        const currentlyDark = Appearance.m3colors.darkmode;
        Quickshell.execDetached([Directories.wallpaperSwitchScriptPath, "--mode", currentlyDark ? "light" : "dark", "--noswitch"]);
        // ponytail: reapply after switchwall has time to regenerate colors.json
        toggleReapplyTimer.restart()
    }

    // ponytail: reapply theme after dark/light toggle (switchwall needs ~1s to regenerate)
    Timer {
        id: toggleReapplyTimer
        interval: 1500
        repeat: true
        property int count: 0
        onTriggered: {
            count++
            themeFileView.reload()
            root.applyColors(themeFileView.text())
            if (count >= 3) {
                count = 0
                running = false
            }
        }
    }

    GlobalShortcut {
        name: "toggleLightDark"
        description: "Toggles between dark theme and light theme"

        onPressed: {
            root.toggleLightDark();
        }
    }

    IpcHandler {
        target: "theme"

        function toggleLightDark(): void {
            root.toggleLightDark();
        }
    }
}
