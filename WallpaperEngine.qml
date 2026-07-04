import QtQml
import Quickshell
import Quickshell.Io
import qs.modules.common

Scope {
    id: root

    property bool active: process.running
    property string lastCommandLine: ""

    function settings() {
        return Config.options?.wallpaperEngine ?? null
    }

    function shouldRun() {
        const cfg = settings()
        if (!cfg) return false
        if (!cfg.enabled) return false
        if (!cfg.background || cfg.background.length === 0) return false
        return true
    }

    function command() {
        const cfg = settings()
        const binary = cfg.binary || "linux-wallpaperengine"
        const args = [binary]

        if (cfg.silent) args.push("--silent")
        if (cfg.volume !== undefined) args.push("--volume", String(cfg.volume))
        if (cfg.fps > 0) args.push("--fps", String(cfg.fps))
        if (cfg.scaling?.length > 0) args.push("--scaling", cfg.scaling)
        if (cfg.clamping?.length > 0) args.push("--clamping", cfg.clamping)
        if (cfg.assetsDir?.length > 0) args.push("--assets-dir", cfg.assetsDir)
        if (cfg.disableMouse) args.push("--disable-mouse")
        if (cfg.disableParallax) args.push("--disable-parallax")
        if (cfg.noFullscreenPause) args.push("--no-fullscreen-pause")

        const props = cfg.properties ?? ({})
        for (const name in props)
            args.push("--set-property", `${name}=${props[name]}`)

        args.push(cfg.background)
        return args
    }

    function refresh(reason) {
        if (!shouldRun()) {
            if (process.running) {
                console.log(`[WallpaperEngine] stopping: ${reason}`)
                process.running = false
            }
            return
        }

        const args = command()
        lastCommandLine = args.join(" ")
        console.log(`[WallpaperEngine] starting: ${reason} → ${lastCommandLine}`)
        process.exec(args)
    }

    function restart() { refresh("manual-restart") }
    function stop() { process.running = false }

    Process {
        id: process

        stdout: SplitParser {
            onRead: data => console.log(`[WallpaperEngine] stdout: ${data}`)
        }

        stderr: SplitParser {
            onRead: data => console.warn(`[WallpaperEngine] stderr: ${data}`)
        }

        onExited: (exitCode, exitStatus) => {
            console.warn(`[WallpaperEngine] exited: code=${exitCode} status=${exitStatus}`)
        }
    }

    Component.onCompleted: refresh("component-completed")
}
