#!/usr/bin/env bash
# Conservatio iOS simulator launcher
# Always builds and runs the Conservatio iOS app regardless of current directory.

set -euo pipefail

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/iosApp" && pwd)"

exec ~/git/personal/kujto/simulator.sh --project "$PROJECT_DIR/Conservatio.xcodeproj" "$@"
