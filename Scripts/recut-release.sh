#!/bin/bash
#
# recut-release.sh — move an already-tagged release commit onto fixed dependency pins.
#
# Why this exists: SwiftPM only lets a version-resolved package depend on OTHER
# version-resolved packages. A `branch:` or `revision:` pin inside a tagged release makes
# that release unconsumable via `from:` — resolution fails with
#   "package X is required using a stable-version but X depends on an unstable-version package Y"
# Ink and Contribute shipped their first tags with such pins, so both must be recut.
#
# For each repo listed below this:
#   1. clones fresh and checks the release commit is still where the table says
#   2. rewrites the offending dependency pins
#   3. builds AND tests — release configuration too, where a repo needs it
#   4. amends the release commit (history stays one commit)
#   5. force-pushes main, then moves the tag atomically
#
# Step 5 moves the tag with `push --force`, NOT delete-then-create: the delete/create pair
# leaves a window where the tag does not exist, and a consumer resolving in that window
# fails confusingly.
#
# Idempotent: if the remote already carries the rewritten manifest, the repo is skipped.
#
# Usage:
#   Scripts/recut-release.sh --dry-run          # show planned actions, touch nothing
#   Scripts/recut-release.sh --repo Ink
#   Scripts/recut-release.sh --all
#
# Requires: a git credential able to push to the package repos (RELEASE_PAT, or your own
#           ambient credentials — this script uses RELEASE_PAT only when it is set).

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WORKDIR="${WORKDIR:-/private/tmp/claude-501/-Users-leo-Documents-Projects-brightdigit-com-tidy-summit/932a31c0-f3ab-4fb0-8151-165ad97615cb/scratchpad/recut-run}"

# repo|tag|expected release commit|test release config?
TARGETS=(
	"Ink|1.0.0-alpha.1|ad5427a3c|no"
	"Contribute|1.0.0-beta.1|525844fc8|yes"
)

DRY_RUN=0
FILTER_REPO=""
SELECT_ALL=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

usage() { sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
	case "$1" in
		--dry-run) DRY_RUN=1; shift ;;
		--repo) FILTER_REPO="${2:-}"; [ -n "$FILTER_REPO" ] || die "--repo needs a value"; shift 2 ;;
		--all) SELECT_ALL=1; shift ;;
		-h|--help) usage 0 ;;
		*) die "unknown argument: $1 (try --help)" ;;
	esac
done

[ -n "$FILTER_REPO" ] || [ "$SELECT_ALL" -eq 1 ] || die "select work with --repo <name> or --all"

SWIFT=$(command -v xcrun >/dev/null 2>&1 && echo "xcrun swift" || echo "swift")

mkdir -p "$WORKDIR"
FAILED=(); SUCCEEDED=(); SKIPPED=()

# Rewrites are expressed as exact string replacements so an unexpected manifest shape
# fails loudly (no pins changed) rather than silently half-applying.
rewrite_manifest() {
	local repo=$1
	python3 - "$repo" <<'PYEOF'
import sys, pathlib
repo = sys.argv[1]
p = pathlib.Path("Package.swift")
s = orig = p.read_text()

if repo == "Ink":
    s = s.replace(
        '''        // Pinned to `branch: "main"` to match the top-level manifest: swift-markdown
        // has no semver tags compatible with the pre-release Swift 6.4 toolchain.
        .package(url: "https://github.com/swiftlang/swift-markdown.git", branch: "main")''',
        '''        // Pinned by version, not branch: SwiftPM only lets a version-resolved package
        // depend on other version-resolved packages, so a `branch:`/`revision:` pin here
        // would make Ink itself unconsumable via `from:` by Publish and the root.
        .package(url: "https://github.com/swiftlang/swift-markdown.git", from: "0.8.0")''')

elif repo == "Contribute":
    s = s.replace(
        '''    // brightdigit fork of scinfu/SwiftSoup (upstream f474b11) with one patch: dropped
    // `@inline(__always)` from `StringUtil.appendNormalisedWhitespaceBytes`, whose forced inlining
    // into `Element.appendNormalisedText` crashes the Swift 6.4 nightly optimizer in
    // `swift build -c release`. Pin to a tagged release once the toolchain stabilises / the fix
    // lands upstream (then switch back to scinfu/SwiftSoup). See CI run 27729200662.
    .package(
      url: "https://github.com/brightdigit/SwiftSoup.git",
      branch: "fix/swift-6.4-inline-crash"
    ),
    // Tracks `main` to match the swift-cmark `gfm` branch used across this
    // monorepo and the Swift 6.4 toolchain; pin to a tagged release once the
    // toolchain stabilises. URL standardised on `swiftlang` (matches the root
    // package) so SPM resolves a single `swift-markdown` identity.
    .package(
      url: "https://github.com/swiftlang/swift-markdown.git",
      branch: "main"
    ),''',
        '''    // Back on upstream scinfu/SwiftSoup as of 2.13.7. This previously used a brightdigit
    // fork carrying one patch — dropping `@inline(__always)` from
    // `StringUtil.appendNormalisedWhitespaceBytes`, whose forced inlining into
    // `Element.appendNormalisedText` crashed the Swift 6.4 optimizer under
    // `swift build -c release` (CI run 27729200662). 2.13.7 still declares that
    // attribute, but the surrounding code was rewritten upstream and the crash no longer
    // reproduces: `swift build -c release` + `swift test -c release` both pass. A version
    // pin is required regardless — SwiftPM only lets a version-resolved package depend on
    // other version-resolved packages, so a `branch:` pin here would make Contribute
    // unconsumable via `from:` by the Contribute* packages and the root.
    .package(
      url: "https://github.com/scinfu/SwiftSoup.git",
      from: "2.13.7"
    ),
    // Version-pinned for the same reason as SwiftSoup above. 0.8.0 is the newest
    // semver release and pulls swift-cmark 0.8.0 transitively. URL standardised on
    // `swiftlang` (matches the root package) so SPM resolves a single
    // `swift-markdown` identity.
    .package(
      url: "https://github.com/swiftlang/swift-markdown.git",
      from: "0.8.0"
    ),''')
else:
    sys.exit(f"no rewrite rule for {repo}")

if s == orig:
    sys.exit("manifest did not change — expected text not found")
p.write_text(s)
PYEOF
}

process_repo() {
	local repo=$1 tag=$2 expect=$3 test_release=$4
	local clone="${WORKDIR}/${repo}"

	echo
	echo "=== ${repo} (${tag}) ==="

	local url="https://github.com/brightdigit/${repo}.git"
	[ -n "${RELEASE_PAT:-}" ] && url="https://x-access-token:${RELEASE_PAT}@github.com/brightdigit/${repo}.git"

	rm -rf "$clone"
	git clone --quiet "$url" "$clone" 2>/dev/null || { echo "  FAIL: clone"; FAILED+=("$repo (clone)"); return 1; }
	cd "$clone" || { FAILED+=("$repo (cd)"); return 1; }

	# Already recut? Then this is a re-run, not a mistake.
	if ! grep -q 'branch: "main"\|branch: "fix/swift-6.4-inline-crash"' Package.swift; then
		info "manifest already free of branch pins — nothing to do"
		SKIPPED+=("$repo (already recut)")
		return 0
	fi

	local head; head=$(git rev-parse HEAD)
	if [ "${head:0:9}" != "${expect:0:9}" ]; then
		echo "  FAIL: main is ${head:0:9}, expected ${expect:0:9} — re-derive before recutting"
		FAILED+=("$repo (tip moved)")
		return 1
	fi
	info "main ${head:0:9} matches expected release commit"

	if [ "$DRY_RUN" -eq 1 ]; then
		info "DRY RUN — would: rewrite pins, build/test$([ "$test_release" = yes ] && echo ' (+release)'), amend, force-push, move tag ${tag}"
		SUCCEEDED+=("$repo (dry-run)")
		return 0
	fi

	rewrite_manifest "$repo" || { echo "  FAIL: manifest rewrite"; FAILED+=("$repo (rewrite)"); return 1; }
	info "pins rewritten"

	if ! $SWIFT build >/dev/null 2>&1; then
		echo "  FAIL: debug build"; FAILED+=("$repo (build)"); return 1
	fi
	if ! $SWIFT test >/dev/null 2>&1; then
		echo "  FAIL: debug tests"; FAILED+=("$repo (test)"); return 1
	fi
	info "debug build + tests pass"

	# Contribute's whole reason for forking SwiftSoup was a release-only optimizer crash,
	# so a debug-only pass would not prove anything for it.
	if [ "$test_release" = "yes" ]; then
		if ! $SWIFT build -c release >/dev/null 2>&1; then
			echo "  FAIL: release build"; FAILED+=("$repo (release build)"); return 1
		fi
		if ! $SWIFT test -c release >/dev/null 2>&1; then
			echo "  FAIL: release tests"; FAILED+=("$repo (release test)"); return 1
		fi
		info "release build + tests pass"
	fi

	git add -A
	git commit --quiet --amend --no-edit || { FAILED+=("$repo (amend)"); return 1; }
	local newsha; newsha=$(git rev-parse --short HEAD)

	# Only the two manifest files may differ from the previous release commit.
	local changed; changed=$(git diff --name-only "$expect" HEAD | sort | tr '\n' ' ')
	if [ "$changed" != "Package.resolved Package.swift " ]; then
		echo "  FAIL: unexpected changes vs ${expect:0:9}: ${changed}"
		echo "        NOT pushed."
		FAILED+=("$repo (DIFF GATE)")
		return 1
	fi
	info "diff gate passed (Package.swift + Package.resolved only)"

	if ! git push --quiet --force-with-lease origin main 2>/dev/null; then
		echo "  FAIL: force-push rejected"; FAILED+=("$repo (push)"); return 1
	fi
	info "pushed main -> ${newsha}"

	git tag -a "$tag" -m "$tag" -f >/dev/null 2>&1 || { FAILED+=("$repo (tag)"); return 1; }
	# Atomic move: no window where the tag is absent.
	if ! git push --quiet --force origin "refs/tags/${tag}" 2>/dev/null; then
		echo "  FAIL: tag push rejected"; FAILED+=("$repo (tag push)"); return 1
	fi
	info "tag ${tag} moved to ${newsha}"

	SUCCEEDED+=("$repo -> ${tag} (${newsha})")
	return 0
}

echo "Work:   $WORKDIR"
[ "$DRY_RUN" -eq 1 ] && echo "Mode:   DRY RUN (nothing will be modified)"

for entry in "${TARGETS[@]}"; do
	IFS='|' read -r repo tag expect test_release <<<"$entry"
	[ -n "$FILTER_REPO" ] && [ "$repo" != "$FILTER_REPO" ] && continue
	process_repo "$repo" "$tag" "$expect" "$test_release"
done

echo
echo "==================== SUMMARY ===================="
echo "ok:      ${#SUCCEEDED[@]}"
for s in ${SUCCEEDED+"${SUCCEEDED[@]}"}; do echo "    $s"; done
if [ ${#SKIPPED[@]} -gt 0 ]; then
	echo "skipped: ${#SKIPPED[@]}"
	for s in "${SKIPPED[@]}"; do echo "    $s"; done
fi
if [ ${#FAILED[@]} -gt 0 ]; then
	echo "FAILED:  ${#FAILED[@]}"
	for f in "${FAILED[@]}"; do echo "    $f"; done
	exit 1
fi
echo "================================================"
