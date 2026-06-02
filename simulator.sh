#!/usr/bin/env bash
# Conservatio launcher
# Run from anywhere: ~/git/personal/conservatio/simulator.sh
# Or via alias: conservatio

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IOS_PROJECT="$ROOT_DIR/iosApp/Conservatio.xcodeproj"
ANDROID_SDK="${ANDROID_SDK_ROOT:-/opt/homebrew/share/android-commandlinetools}"

# If a platform flag was passed, skip the prompt
case "${1:-}" in
    ios|--ios)
        shift
        exec ~/git/personal/kujto/simulator.sh --project "$IOS_PROJECT" "$@"
        ;;
    android|--android)
        shift
        echo ""
        echo "  Conservatio Android"
        echo ""
        # Check emulator
        if ! "$ANDROID_SDK/emulator/emulator" -list-avds 2>/dev/null | grep -q .; then
            echo "  No Android AVD found. Create one first:"
            echo "    avdmanager create avd -n Pixel_8 -k 'system-images;android-35;google_apis;arm64-v8a' -d pixel_8"
            exit 1
        fi
        AVD=$("$ANDROID_SDK/emulator/emulator" -list-avds 2>/dev/null | head -1)
        echo "  Starting emulator: $AVD"
        "$ANDROID_SDK/emulator/emulator" -avd "$AVD" -no-audio "$@" &
        echo "  Emulator launching in background."
        echo "  To build and install: cd $ROOT_DIR && ./gradlew :androidApp:installDebug"
        exit 0
        ;;
esac

# Interactive prompt
echo ""
echo "  ┌─────────────────────────────┐"
echo "  │       Conservatio           │"
echo "  │  Document heritage.         │"
echo "  │  Protect history.           │"
echo "  └─────────────────────────────┘"
echo ""
echo "  Which platform?"
echo ""
echo "    1) iOS      (iPhone Simulator)"
echo "    2) Android  (Android Emulator)"
echo ""
printf "  Choose [1/2]: "
read -r choice

case "$choice" in
    1|ios)
        exec ~/git/personal/kujto/simulator.sh --project "$IOS_PROJECT" "$@"
        ;;
    2|android)
        echo ""
        echo "  Conservatio Android"
        echo ""
        if ! "$ANDROID_SDK/emulator/emulator" -list-avds 2>/dev/null | grep -q .; then
            echo "  No Android AVD found."
            exit 1
        fi
        AVD=$("$ANDROID_SDK/emulator/emulator" -list-avds 2>/dev/null | head -1)
        echo "  Starting emulator: $AVD"
        "$ANDROID_SDK/emulator/emulator" -avd "$AVD" -no-audio &
        echo "  Emulator launching in background."
        echo "  To build: cd $ROOT_DIR && ./gradlew :androidApp:installDebug"
        exit 0
        ;;
    *)
        echo "  Invalid choice."
        exit 1
        ;;
esac
