#!/usr/bin/env bash
set -e

# Shell script to apply all modular patches sequentially
TARGET_DIR="${1:-$(pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="${SCRIPT_DIR}/../patches"
EXTRA_LIBS_DIR="${SCRIPT_DIR}/../assets/extra_libs"
JNI_LIBS_DIR="${SCRIPT_DIR}/../assets/jniLibs"

echo "========================================="
echo "   Nuvio Modular Patch Applicator (SH)   "
echo "========================================="
echo "Target Directory: $TARGET_DIR"
echo "Patches Directory: $PATCHES_DIR"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Target directory does not exist: $TARGET_DIR"
    exit 1
fi

cd "$TARGET_DIR"

# Get all numbered patches sorted
PATCH_FILES=$(find "$PATCHES_DIR" -maxdepth 1 -name "[0-9]*.patch" | sort)

if [ -z "$PATCH_FILES" ]; then
    PATCH_FILES=$(find "$PATCHES_DIR" -maxdepth 1 -name "*.patch" | sort)
fi

if [ -z "$PATCH_FILES" ]; then
    echo "Error: No .patch files found in $PATCHES_DIR"
    exit 1
fi

echo ""
echo "Trovate le seguenti patch da applicare:"
for p in $PATCH_FILES; do
    echo "  - $(basename "$p")"
done

echo ""
for patch in $PATCH_FILES; do
    patch_name=$(basename "$patch")
    echo "Applicazione patch: $patch_name..."
    if ! git apply --3way "$patch"; then
        echo "❌ ERRORE: Fallita applicazione della patch '$patch_name'!"
        exit 1
    fi
    echo "✅ Patch '$patch_name' applicata con successo!"
done

# Copia assets
if [ -d "$EXTRA_LIBS_DIR" ]; then
    mkdir -p composeApp/libs
    cp -r "$EXTRA_LIBS_DIR"/* composeApp/libs/ 2>/dev/null || true
    echo "📦 Librerie extra_libs verificate e copiate."
fi

if [ -d "$JNI_LIBS_DIR" ]; then
    mkdir -p composeApp/src/androidMain/jniLibs
    cp -r "$JNI_LIBS_DIR"/* composeApp/src/androidMain/jniLibs/ 2>/dev/null || true
    echo "📦 Librerie native jniLibs verificate e copiate."
fi

echo ""
echo "🎉 Tutte le patch sono state applicate con successo!"
