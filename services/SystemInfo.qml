pragma Singleton
pragma ComponentBehavior: Bound
import QtQuick
import Quickshell
import Quickshell.Io

// ponytail: SystemInfo service — provides username, distro info.
// Uses Process to call whoami since Qt.env() doesn't exist in QML.
Singleton {
    id: root
    property string username: ""
    property string distro: ""
    property string distroIcon: "linux"

    Component.onCompleted: {
        whoamiProcess.running = true
        osReleaseProcess.running = true
    }

    Process {
        id: whoamiProcess
        running: false
        command: ["whoami"]
        stdout: StdioCollector {
            onStreamFinished: root.username = this.text.trim()
        }
    }

    Process {
        id: osReleaseProcess
        running: false
        command: ["sh", "-c", ". /etc/os-release 2>/dev/null && echo \"$ID\""]
        stdout: StdioCollector {
            onStreamFinished: {
                var id = this.text.trim()
                root.distro = id
                // Map distro IDs to icon names
                var iconMap = {
                    "arch": "arch",
                    "ubuntu": "ubuntu",
                    "fedora": "fedora",
                    "debian": "debian",
                    "endeavouros": "endeavouros",
                    "cachyos": "cachyos",
                    "gentoo": "gentoo",
                    "nixos": "nixos"
                }
                root.distroIcon = iconMap[id] || "linux"
            }
        }
    }
}
