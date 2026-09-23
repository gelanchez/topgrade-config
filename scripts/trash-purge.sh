#!/bin/bash
# Permanently delete trashed items older than N days (default 30),
# based on the deletion date recorded by the desktop in the .trashinfo files

set -uo pipefail

days="${1:-30}"
info_dir="$HOME/.local/share/Trash/info"
files_dir="$HOME/.local/share/Trash/files"

[ -d "$info_dir" ] || exit 0

cutoff="$(date -d "$days days ago" +%s)"
removed=0
for info in "$info_dir"/*.trashinfo; do
    [ -f "$info" ] || continue
    deleted_at="$(grep -m1 '^DeletionDate=' "$info" | cut -d= -f2)"
    [ -n "$deleted_at" ] || continue
    deleted_epoch="$(date -d "$deleted_at" +%s 2>/dev/null)" || continue
    if [ "$deleted_epoch" -lt "$cutoff" ]; then
        name="$(basename "$info" .trashinfo)"
        rm -rf "${files_dir:?}/$name"
        rm -f "$info"
        removed=$((removed + 1))
    fi
done
echo "Removed $removed trash item(s) older than $days days"
