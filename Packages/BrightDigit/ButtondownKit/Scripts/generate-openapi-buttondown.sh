#!/bin/bash
#
# Regenerates the committed ButtondownKit client from the vendored Buttondown
# OpenAPI spec.
#
# The swift-openapi-generator is run AHEAD OF TIME (pinned in .mise.toml via the
# spm backend) and the generated Types.swift/Client.swift are committed under
# Sources/ButtondownKit/Generated. The generator is intentionally NOT a
# Package.swift dependency and the build-tool plugin is NOT used.
#
# Steps:
#   1. Filter the full upstream spec down to the operations ButtondownKit needs
#      (see `filter:` in openapi-generator-config.yaml), writing a focused
#      openapi.filtered.yaml.
#   2. Generate `types` + `client` from the focused doc into Generated/.
#
# Usage: Scripts/generate-openapi-buttondown.sh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PACKAGE_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"

OPENAPI_DIR="${PACKAGE_DIR}/Sources/ButtondownKit/OpenAPI"
GENERATED_DIR="${PACKAGE_DIR}/Sources/ButtondownKit/Generated"
SPEC="${OPENAPI_DIR}/openapi.json"
CONFIG="${OPENAPI_DIR}/openapi-generator-config.yaml"
FILTERED="${OPENAPI_DIR}/openapi.filtered.json"

# Resolve the generator through mise so the pinned version is used.
if command -v mise &> /dev/null; then
  GEN="mise exec -- swift-openapi-generator"
elif command -v swift-openapi-generator &> /dev/null; then
  GEN="swift-openapi-generator"
else
  echo "Error: swift-openapi-generator not found. Install it with 'mise install'." >&2
  exit 1
fi

echo "Filtering spec -> ${FILTERED}"
$GEN filter --config "${CONFIG}" --output-format json "${SPEC}" > "${FILTERED}"

# Post-process the filtered document so it is both valid and deterministic:
#   1. The `filter` subcommand prunes components.securitySchemes even though the
#      kept operations still reference `ApiKeyAuth` in their `security` lists,
#      which makes the document fail validation at generate time — re-inject the
#      scheme from the original spec.
#   2. The filter keeps the top-level `webhooks` object, whose request bodies
#      reference schemas the filter prunes (webhooks are out of scope) — drop it.
#   3. The filter emits dictionary keys (notably `paths`) in a process-dependent
#      order, which makes the generated code vary run-to-run. Sort every object's
#      keys so the committed Generated/ output is reproducible (and the optional
#      drift check is stable).
echo "Normalizing filtered spec (security scheme, webhooks, key order)"
python3 - "${SPEC}" "${FILTERED}" <<'PY'
import json, sys, collections
orig_path, filtered_path = sys.argv[1], sys.argv[2]
orig = json.load(open(orig_path))
doc = json.load(open(filtered_path))
schemes = orig.get("components", {}).get("securitySchemes")
if schemes:
    doc.setdefault("components", {})["securitySchemes"] = schemes
doc.pop("webhooks", None)

def sort_keys(value):
    if isinstance(value, dict):
        return collections.OrderedDict(
            (k, sort_keys(value[k])) for k in sorted(value)
        )
    if isinstance(value, list):
        return [sort_keys(v) for v in value]
    return value

doc = sort_keys(doc)
with open(filtered_path, "w") as f:
    json.dump(doc, f, indent=2)
PY

echo "Generating client -> ${GENERATED_DIR}"
mkdir -p "${GENERATED_DIR}"
$GEN generate \
  --config "${CONFIG}" \
  --output-directory "${GENERATED_DIR}" \
  "${FILTERED}"

echo "Done. Generated files:"
ls -1 "${GENERATED_DIR}"
