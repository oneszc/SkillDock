#!/bin/zsh
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
APP_DIR="$ROOT_DIR/dist/SkillDock.app"

"$ROOT_DIR/scripts/package-app.sh"

pkill -x SkillDockApp 2>/dev/null || true
pkill -x SkillDock 2>/dev/null || true

open -n "$APP_DIR"
