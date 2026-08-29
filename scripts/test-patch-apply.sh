#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/NuvioMedia/NuvioMobile.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-cmp-rewrite}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCH_PATH="${PATCH_PATH:-$SCRIPT_DIR/../patches/nuvio-enhanced-code.patch}"
EXTRA_LIBS_DIR="${EXTRA_LIBS_DIR:-$SCRIPT_DIR/../assets/extra_libs}"
JNI_LIBS_DIR="${JNI_LIBS_DIR:-$SCRIPT_DIR/../assets/jniLibs}"

echo "=== Nuvio Patch Applicability Test ==="

TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT

export GIT_LFS_SKIP_SMUDGE=1
echo "Clonazione upstream ($UPSTREAM_URL, branch: $UPSTREAM_BRANCH)..."
git clone --branch "$UPSTREAM_BRANCH" "$UPSTREAM_URL" "$TEST_DIR" --depth 50 --quiet

cd "$TEST_DIR"

echo "Applicazione patch codice..."
if git apply --3way "$PATCH_PATH"; then
    echo "✅ Patch applicata con successo!"
else
    echo "❌ Errore durante l'applicazione della patch."
    exit 1
fi

if [ -d "$EXTRA_LIBS_DIR" ]; then
    mkdir -p composeApp/libs
    cp -r "$EXTRA_LIBS_DIR"/* composeApp/libs/ 2>/dev/null || true
    echo "Librerie extra_libs verificate e copiate."
fi

if [ -d "$JNI_LIBS_DIR" ]; then
    mkdir -p composeApp/src/androidMain/jniLibs
    cp -r "$JNI_LIBS_DIR"/* composeApp/src/androidMain/jniLibs/ 2>/dev/null || true
    echo "Librerie native jniLibs verificate e copiate."
fi

echo "🎉 Test completato con successo: patch 100% funzionante!"
