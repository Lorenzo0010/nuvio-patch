#!/usr/bin/env bash
set -euo pipefail

UPSTREAM_URL="${UPSTREAM_URL:-https://github.com/NuvioMedia/NuvioMobile.git}"
UPSTREAM_BRANCH="${UPSTREAM_BRANCH:-cmp-rewrite}"
FORK_URL="${FORK_URL:-https://github.com/albyalex96/NuvioMobile.git}"
FORK_BRANCH="${FORK_BRANCH:-app/enhanced}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OUTPUT_DIR="${OUTPUT_DIR:-$SCRIPT_DIR/../patches}"
EXTRA_LIBS_DIR="${EXTRA_LIBS_DIR:-$SCRIPT_DIR/../assets/extra_libs}"
JNI_LIBS_DIR="${JNI_LIBS_DIR:-$SCRIPT_DIR/../assets/jniLibs}"

echo "=== Nuvio Enhanced Patch Extractor ==="

TEMP_DIR=$(mktemp -d)
trap 'rm -rf "$TEMP_DIR"' EXIT

export GIT_LFS_SKIP_SMUDGE=1
echo "Clonazione fork Enhanced ($FORK_BRANCH)..."
git clone --branch "$FORK_BRANCH" "$FORK_URL" "$TEMP_DIR" --quiet

cd "$TEMP_DIR"
echo "Configurazione remote upstream ($UPSTREAM_URL)..."
git remote add upstream "$UPSTREAM_URL"
git fetch upstream "$UPSTREAM_BRANCH" --depth 100 --quiet

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_DIR"/* 2>/dev/null || true

echo "Copia librerie binarie e native..."
if [ -d "composeApp/libs" ]; then
    mkdir -p "$EXTRA_LIBS_DIR"
    cp -r composeApp/libs/* "$EXTRA_LIBS_DIR/" 2>/dev/null || true
    echo "Librerie .aar/.jar copiate in $EXTRA_LIBS_DIR"
fi

if [ -d "composeApp/src/androidMain/jniLibs" ]; then
    mkdir -p "$JNI_LIBS_DIR"
    cp -r composeApp/src/androidMain/jniLibs/* "$JNI_LIBS_DIR/" 2>/dev/null || true
    echo "Librerie native .so copiate in $JNI_LIBS_DIR"
fi

echo "Generazione patch unificata del codice..."
git diff --binary --output="$OUTPUT_DIR/nuvio-enhanced-code.patch" "upstream/$UPSTREAM_BRANCH..HEAD" -- ":(exclude)composeApp/src/androidMain/jniLibs" ":(exclude)composeApp/libs" ":(exclude)composeApp/src/desktopMain/native" ":(exclude)*.dll"

echo "Operazione completata con successo!"
