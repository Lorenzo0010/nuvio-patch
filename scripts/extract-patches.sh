#!/usr/bin/env bash
set -e

SOURCE_DIR="${1:-$(pwd)}"
UPSTREAM_REF="${2:-HEAD~1}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${SCRIPT_DIR}/../patches"
EXTRA_LIBS_DIR="${SCRIPT_DIR}/../assets/extra_libs"
JNI_LIBS_DIR="${SCRIPT_DIR}/../assets/jniLibs"

echo "=== Nuvio Modular Patch Extractor (SH) ==="
cd "$SOURCE_DIR"
mkdir -p "$OUTPUT_DIR"

echo "Estrazione 01-branding-and-config.patch..."
git diff --binary "$UPSTREAM_REF" -- "androidApp/build.gradle.kts" "composeApp/build.gradle.kts" "androidApp/src/main/res/values/strings.xml" "*strings.xml" > "$OUTPUT_DIR/01-branding-and-config.patch"

echo "Estrazione 02-app-updater.patch..."
git diff --binary "$UPSTREAM_REF" -- "*AppUpdater.kt*" > "$OUTPUT_DIR/02-app-updater.patch"

echo "Estrazione 03-live-tv.patch..."
git diff --binary "$UPSTREAM_REF" -- "*livetv*" "*LiveTv*" "composeApp/src/commonMain/kotlin/com/nuvio/app/AppScreenTab.kt" "composeApp/src/commonMain/kotlin/com/nuvio/app/AppShellComponents.kt" "composeApp/src/commonMain/composeResources/values/strings.xml" > "$OUTPUT_DIR/03-live-tv.patch"

if [ -d "composeApp/libs" ]; then
    mkdir -p "$EXTRA_LIBS_DIR"
    cp -r composeApp/libs/* "$EXTRA_LIBS_DIR/" 2>/dev/null || true
fi

if [ -d "composeApp/src/androidMain/jniLibs" ]; then
    mkdir -p "$JNI_LIBS_DIR"
    cp -r composeApp/src/androidMain/jniLibs/* "$JNI_LIBS_DIR/" 2>/dev/null || true
fi

echo "🎉 Patch modulari estratte con successo in $OUTPUT_DIR"
