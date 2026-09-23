#!/bin/bash
# Update the Go toolchain installed in /usr/local/go to the latest release

set -euo pipefail

if [ ! -d /usr/local/go ]; then
    echo "No Go toolchain in /usr/local/go, nothing to do."
    exit 0
fi

current="$(/usr/local/go/bin/go version | awk '{print $3}')"
latest="$(curl -fsSL 'https://go.dev/VERSION?m=text' | head -n1)"

if [ "$current" = "$latest" ]; then
    echo "Go already up to date ($current)"
    exit 0
fi

case "$(uname -m)" in
    x86_64) arch="amd64" ;;
    aarch64) arch="arm64" ;;
    *) arch="$(uname -m)" ;;
esac

echo "Updating Go: $current -> $latest"
tarball="$(mktemp --suffix=.tar.gz)"
trap 'rm -f "$tarball"' EXIT
curl -fsSL "https://go.dev/dl/${latest}.linux-${arch}.tar.gz" -o "$tarball"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf "$tarball"
echo "Go updated to $latest"
