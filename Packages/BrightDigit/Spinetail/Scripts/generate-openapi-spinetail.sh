#!/bin/bash
#
# Regenerates the committed swift-openapi-generator output for Spinetail.
#
# Pipeline:
#   1. Filter the full Mailchimp Marketing API spec (OpenAPI/openapi.yaml) down
#      to only the operations ContributeMailchimp uses, using the
#      `swift-openapi-generator filter` subcommand driven by the `filter:` key
#      in openapi-generator-config.yaml. The filtered document is written to
#      Sources/SpinetailOpenAPI/filtered-openapi.yaml (committed).
#   2. Generate Types.swift / Client.swift from the filtered document into
#      Sources/SpinetailOpenAPI/ (committed).
#
# The generator CLI is provided by mise (see .mise.toml). This script is
# reproducible: running it should produce no diff unless the spec, config, or
# generator version changed.
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "$0")" && pwd)
PACKAGE_DIR="${SCRIPT_DIR}/.."
OUTPUT_DIR="${PACKAGE_DIR}/Sources/SpinetailOpenAPI"
CONFIG="${OUTPUT_DIR}/openapi-generator-config.yaml"
FULL_SPEC="${PACKAGE_DIR}/OpenAPI/openapi.yaml"
FILTERED_SPEC="${OUTPUT_DIR}/filtered-openapi.yaml"

# Resolve mise so the pinned generator CLI is on PATH.
MISE_BIN=""
for mise_path in /opt/homebrew/bin/mise /usr/local/bin/mise "$HOME/.local/bin/mise"; do
	if [ -x "$mise_path" ]; then
		MISE_BIN="$mise_path"
		break
	fi
done
if [ -z "$MISE_BIN" ] && command -v mise &>/dev/null; then
	MISE_BIN="mise"
fi
if [ -z "$MISE_BIN" ]; then
	echo "Error: mise is not installed (see https://mise.jdx.dev)"
	exit 1
fi

GEN="$MISE_BIN exec -- swift-openapi-generator"

echo "Installing pinned tools via mise..."
"$MISE_BIN" install

echo "Filtering full spec -> ${FILTERED_SPEC}"
$GEN filter \
	--config "$CONFIG" \
	"$FULL_SPEC" >"$FILTERED_SPEC"

# The filter subcommand drops `components.securitySchemes` but leaves the
# root-level `security` requirement referencing `basicAuth`, producing an
# inconsistent document the generator rejects. Mailchimp authenticates via HTTP
# Basic (any username + the API key as password); we inject that through a
# client middleware (see MailchimpClient), so the declarative `security`
# requirement is not needed. Strip the dangling root `security:` block.
echo "Stripping dangling root security requirement from filtered spec"
python3 - "$FILTERED_SPEC" <<'PY'
import sys
path = sys.argv[1]
with open(path) as handle:
    lines = handle.readlines()
out, skip = [], False
for line in lines:
    if line.startswith("security:"):
        skip = True
        continue
    if skip:
        # security entries are list items indented under the key.
        if line.startswith(("- ", "  ")) and line.strip():
            continue
        skip = False
    out.append(line)
with open(path, "w") as handle:
    handle.writelines(out)
PY

echo "Generating Types.swift / Client.swift -> ${OUTPUT_DIR}"
$GEN generate \
	--config "$CONFIG" \
	--output-directory "$OUTPUT_DIR" \
	"$FILTERED_SPEC"

echo "Generation complete."
