#!/bin/bash
# Report whether a reboot is needed to apply kernel/library updates

needs_reboot() {
    # Debian/Ubuntu
    [ -f /var/run/reboot-required ] && return 0
    # openSUSE
    [ -f /run/reboot-needed ] && return 0
    # Fedora: exit code 1 means a reboot is needed
    if command -v dnf >/dev/null; then
        dnf needs-restarting -r >/dev/null 2>&1
        [ $? -eq 1 ] && return 0
    fi
    # Arch family: the running kernel's modules were removed by an upgrade
    if command -v pacman >/dev/null && [ ! -d "/usr/lib/modules/$(uname -r)" ]; then
        return 0
    fi
    return 1
}

if needs_reboot; then
    echo '!!! REBOOT REQUIRED !!!'
else
    echo 'No reboot required.'
fi
