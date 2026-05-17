pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import qs.components.misc
import qs.services

Scope {
    id: root

    property alias lock: lock
    property bool wasLocked

    WlSessionLock {
        id: lock

        signal unlock

        onLockedChanged: {
            if (locked) {
                root.wasLocked = true;
                unlockRestoreTimer.stop();
            } else if (root.wasLocked) {
                root.wasLocked = false;
                unlockRestoreTimer.restart();
            }
        }

        LockSurface {
            lock: lock
            pam: pam
        }
    }

    Pam {
        id: pam

        lock: lock
    }

    Timer {
        id: unlockRestoreTimer

        interval: 500
        repeat: false
        onTriggered: {
            if (!lock.locked && WallpaperEngine.enabled)
                WallpaperEngine.restoreCurrent();
        }
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "lock"
        description: "Lock the current session"
        onPressed: lock.locked = true
    }

    // qmllint disable unresolved-type
    CustomShortcut {
        // qmllint enable unresolved-type
        name: "unlock"
        description: "Unlock the current session"
        onPressed: lock.unlock()
    }

    IpcHandler {
        function lock(): void {
            lock.locked = true;
        }

        function unlock(): void {
            lock.unlock();
        }

        function isLocked(): bool {
            return lock.locked;
        }

        target: "lock"
    }
}
