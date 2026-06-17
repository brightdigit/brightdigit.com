#!/bin/bash
#
# Regenerates the committed swift-openapi-generator output for a vendored API
# client. Run AHEAD OF TIME; the generated Client.swift/Types.swift are
# committed to the repo (the generator is a mise-managed CLI tool, not a
# SwiftPM build/command plugin).
#
# Usage:
#   Scripts/generate-openapi.sh <library>            # filter + generate
#   Scripts/generate-openapi.sh <library> --refresh  # re-fetch + convert spec first
#   Scripts/generate-openapi.sh <library> --check     # regenerate to a temp dir and diff
#
# Per-library layout (relative to the package root):
#   openapi/<spec>                       full committed OpenAPI document
#   openapi/openapi-filter.yaml          filter config (operations we use)
#   openapi/openapi-generator-config.yaml  generate config (types + client)
#   Sources/<Target>/Generated/          committed output
#
# Designed to generalise to Spinetail (#37) and ButtondownKit (#83): add a new
# `case` in the library table below.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# swift-openapi-generator version — keep in sync with .mise.toml.
GENERATOR="spm:apple/swift-openapi-generator@1.12.2"

library="${1:-}"
mode="${2:-}"

if [ -z "$library" ]; then
  echo "usage: $0 <library> [--refresh|--check]" >&2
  echo "libraries: SwiftTube" >&2
  exit 2
fi

# ---- Per-library configuration -------------------------------------------------
case "$library" in
  SwiftTube)
    PKG="$REPO_ROOT/Packages/BrightDigit/SwiftTube"
    TARGET="SwiftTube"
    # Full OpenAPI document committed under openapi/.
    SPEC="$PKG/openapi/youtube-openapi.json"
    # Optional --refresh inputs: a Google Discovery Document → OpenAPI.
    DISCOVERY_URL='https://youtube.googleapis.com/$discovery/rest?version=v3'
    DISCOVERY="$PKG/openapi/youtube-discovery.json"
    RENAME='{"youtube.playlistItems.list":"listPlaylistItems","youtube.videos.list":"listVideos"}'
    ;;
  *)
    echo "unknown library: $library" >&2
    exit 2
    ;;
esac

FILTER_CONFIG="$PKG/openapi/openapi-filter.yaml"
GEN_CONFIG="$PKG/openapi/openapi-generator-config.yaml"
OUT_DIR="$PKG/Sources/$TARGET/Generated"

run_generator() {
  command mise exec "$GENERATOR" -- swift-openapi-generator "$@"
}

# ---- Optional: refresh the full spec from the upstream discovery document -----
if [ "$mode" = "--refresh" ]; then
  echo "Refreshing $library spec from upstream discovery document..."
  curl -fsSL "$DISCOVERY_URL" -o "$DISCOVERY"
  # The converters are dev-only; install them on demand into a temp prefix.
  CONV_DIR="$(mktemp -d -t openapi-conv.XXXXXX)"
  ( cd "$CONV_DIR" && npm install --silent --no-save \
      google-discovery-to-swagger swagger2openapi )
  NODE_PATH="$CONV_DIR/node_modules" \
    OPENAPI_RENAME="$RENAME" node "$REPO_ROOT/Scripts/discovery-to-openapi.mjs" \
    "$DISCOVERY" "$SPEC"
  rm -rf "$CONV_DIR"
fi

# ---- Filter the full spec down to the operations we use -----------------------
FILTERED="$(mktemp -t openapi-filtered.XXXXXX.yaml)"
trap 'rm -f "$FILTERED"' EXIT
echo "Filtering $library spec..."
run_generator filter --config "$FILTER_CONFIG" "$SPEC" > "$FILTERED"

# ---- Generate -----------------------------------------------------------------
if [ "$mode" = "--check" ]; then
  TMP_OUT="$(mktemp -d -t openapi-gen.XXXXXX)"
  trap 'rm -f "$FILTERED"; rm -rf "$TMP_OUT"' EXIT
  echo "Generating $library client into a temp dir for drift check..."
  run_generator generate --config "$GEN_CONFIG" --output-directory "$TMP_OUT" "$FILTERED"
  if ! diff -ru "$OUT_DIR" "$TMP_OUT"; then
    echo "ERROR: committed generated code is out of date." >&2
    echo "Run Scripts/generate-openapi.sh $library and commit the result." >&2
    exit 1
  fi
  echo "Generated code is up to date."
  exit 0
fi

echo "Generating $library client into $OUT_DIR..."
mkdir -p "$OUT_DIR"
run_generator generate --config "$GEN_CONFIG" --output-directory "$OUT_DIR" "$FILTERED"
echo "Done. Review and commit $OUT_DIR/{Client,Types}.swift."
