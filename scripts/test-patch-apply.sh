#!/usr/bin/env bash
set -e

# Shell script to test applying all modular patches on top of upstream cmp-rewrite
UPSTREAM_URL="${1:-https://github.com/NuvioMedia/NuvioMobile.git}"
UPSTREAM_BRANCH="${2:-cmp-rewrite}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PATCHES_DIR="${SCRIPT_DIR}/../patches"
EXTRA_LIBS_DIR="${SCRIPT_DIR}/../assets/extra_libs"
JNI_LIBS_DIR="${SCRIPT_DIR}/../assets/jniLibs"

echo "========================================="
echo "   Nuvio Patch Applicability Test (SH)   "
echo "========================================="

TEST_DIR=$(mktemp -d -t nuvio_patch_test_XXXXXX)

cleanup() {
    rm -rf "$TEST_DIR"
    echo "Pulizia cartella temporanea completata."
}
trap cleanup EXIT

echo "Clonazione upstream ($UPSTREAM_URL, branch: $UPSTREAM_BRANCH)..."
export GIT_LFS_SKIP_SMUDGE=1
# Clone con storia completa: git apply --3way richiede i blobs degli antenati,
# che un clone shallow non contiene.
git clone --branch "$UPSTREAM_BRANCH" "$UPSTREAM_URL" "$TEST_DIR" --quiet

PIN_SHA=$(head -n 1 "${SCRIPT_DIR}/../.last_built_upstream_sha" 2>/dev/null | tr -d '[:space:]')
if [ -n "$PIN_SHA" ]; then
    echo "Pinning upstream allo SHA: $PIN_SHA (da .last_built_upstream_sha)..."
    git -C "$TEST_DIR" checkout "$PIN_SHA" --quiet
fi

cd "$TEST_DIR"

PATCH_FILES=$(find "$PATCHES_DIR" -maxdepth 1 -name "[0-9]*.patch" | sort)
if [ -z "$PATCH_FILES" ]; then
    PATCH_FILES=$(find "$PATCHES_DIR" -maxdepth 1 -name "*.patch" | sort)
fi

if [ -z "$PATCH_FILES" ]; then
    echo "❌ Nessuna patch trovata in $PATCHES_DIR!"
    exit 1
fi

echo "Trovate le seguenti patch da testare:"
for p in $PATCH_FILES; do
    echo "  - $(basename "$p")"
done

echo ""
for patch in $PATCH_FILES; do
    patch_name=$(basename "$patch")
    echo "Test applicazione patch: $patch_name..."
    if ! git apply --3way "$patch"; then
        echo "❌ Errore durante l'applicazione di '$patch_name'!"
        exit 1
    fi
    echo "✅ Patch '$patch_name' applicata con successo!"
done

# Copia asset
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

echo ""
echo "🎉 TEST SUPERATO: Tutte le patch sono 100% compatibili con l'upstream!"
