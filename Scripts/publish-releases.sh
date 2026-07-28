#!/bin/bash
#
# publish-releases.sh — create the GitHub release object for each tagged package.
#
# Last step of the de-vendoring release: the tags already exist (tag-release.sh) and this
# attaches the prepared notes to them. Purely additive — a release is deleted with
# `gh release delete <VERSION> -R brightdigit/<repo>`, and the tag survives.
#
# For each repo in Scripts/release-versions.tsv this:
#   1. skips unless the repo has a 'done' stamp (i.e. was squashed and tagged)
#   2. skips if the release already exists (idempotent: safe to re-run after a failure)
#   3. verifies the tag exists on the remote and points at the recorded tip
#   4. creates the release from Scripts/release-notes/<Repo>.md
#
# Every version in this pass is a prerelease (alpha/beta), so --prerelease is set on all
# of them. If a future run releases a stable version, gate that flag on the version string.
#
# The notes file starts with a "# Release Notes" heading plus a "## <VERSION>" section.
# GitHub release bodies should not repeat the title, so the file's leading heading lines
# are stripped and only that version's section body is posted.
#
# Usage:
#   Scripts/publish-releases.sh --dry-run          # print what would be created
#   Scripts/publish-releases.sh --repo Plot
#   Scripts/publish-releases.sh --wave 0
#   Scripts/publish-releases.sh --all
#
# Requires: gh authenticated with permission to create releases on brightdigit/*.

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TABLE="${SCRIPT_DIR}/release-versions.tsv"
NOTES_DIR="${NOTES_DIR:-${SCRIPT_DIR}/release-notes}"
BODY_DIR="${TMPDIR:-/tmp}/release-bodies-$$"

DRY_RUN=0
FILTER_REPO=""
FILTER_WAVE=""
SELECT_ALL=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

usage() { sed -n '3,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit "${1:-0}"; }

while [ $# -gt 0 ]; do
	case "$1" in
		--dry-run) DRY_RUN=1; shift ;;
		--repo) FILTER_REPO="${2:-}"; [ -n "$FILTER_REPO" ] || die "--repo needs a value"; shift 2 ;;
		--wave) FILTER_WAVE="${2:-}"; [ -n "$FILTER_WAVE" ] || die "--wave needs a value"; shift 2 ;;
		--all) SELECT_ALL=1; shift ;;
		-h|--help) usage 0 ;;
		*) die "unknown argument: $1 (try --help)" ;;
	esac
done

[ -f "$TABLE" ] || die "missing table: $TABLE"
[ -n "$FILTER_REPO" ] || [ -n "$FILTER_WAVE" ] || [ "$SELECT_ALL" -eq 1 ] \
	|| die "select work with --repo <name>, --wave <n>, or --all"
command -v gh >/dev/null 2>&1 || die "gh is required"

mkdir -p "$BODY_DIR"
trap 'rm -rf "$BODY_DIR"' EXIT

FAILED=(); SUCCEEDED=(); SKIPPED=()

# Extracts just the "## <version>" section, dropping the file-level "# Release Notes"
# title so the release body does not duplicate the release name.
extract_body() {
	local notes=$1 version=$2 out=$3
	python3 - "$notes" "$version" "$out" <<'PYEOF'
import sys, pathlib
notes, version, out = sys.argv[1], sys.argv[2], sys.argv[3]
lines = pathlib.Path(notes).read_text().splitlines()

start = None
for i, line in enumerate(lines):
    if line.strip().startswith('## ') and line.strip()[3:].strip() == version:
        start = i + 1
        break
if start is None:
    sys.exit(f"no '## {version}' section in {notes}")

end = len(lines)
for j in range(start, len(lines)):
    if lines[j].strip().startswith('## '):
        end = j
        break

body = '\n'.join(lines[start:end]).strip()
if not body:
    sys.exit(f"'## {version}' section is empty in {notes}")
pathlib.Path(out).write_text(body + '\n')
PYEOF
}

process_repo() {
	local repo=$1 version=$4 expect_tip=$5 done_stamp=$6
	local notes="${NOTES_DIR}/${repo}.md"
	local body="${BODY_DIR}/${repo}.md"

	echo
	echo "=== ${repo} -> ${version} ==="

	if [ -z "$done_stamp" ]; then
		echo "  SKIP: not squashed/tagged yet"
		SKIPPED+=("$repo (not released)")
		return 0
	fi

	if [ ! -f "$notes" ]; then
		echo "  FAIL: no notes at ${notes}"
		FAILED+=("$repo (no notes)")
		return 1
	fi

	# Already published is a completed run, not an error.
	if gh release view "$version" -R "brightdigit/${repo}" >/dev/null 2>&1; then
		info "release ${version} already exists — nothing to do"
		SKIPPED+=("$repo (already published)")
		return 0
	fi

	# The tag must exist and point where the table says, or the release would be
	# attached to unexpected history.
	local url="https://github.com/brightdigit/${repo}.git"
	local peel lw target
	peel=$(git ls-remote --tags "$url" "refs/tags/${version}^{}" 2>/dev/null | cut -f1)
	lw=$(git ls-remote --tags "$url" "refs/tags/${version}" 2>/dev/null | cut -f1)
	target="${peel:-$lw}"
	if [ -z "$target" ]; then
		echo "  FAIL: tag ${version} does not exist on the remote"
		FAILED+=("$repo (no tag)")
		return 1
	fi
	if [ "${target:0:9}" != "${expect_tip:0:9}" ]; then
		echo "  FAIL: tag ${version} points at ${target:0:9}, table says ${expect_tip:0:9}"
		FAILED+=("$repo (tag mismatch)")
		return 1
	fi
	info "tag ${version} -> ${target:0:9} matches table"

	if ! extract_body "$notes" "$version" "$body"; then
		echo "  FAIL: could not extract the ${version} section from the notes"
		FAILED+=("$repo (notes section)")
		return 1
	fi
	info "notes: $(wc -l <"$body" | tr -d ' ') lines"

	if [ "$DRY_RUN" -eq 1 ]; then
		info "DRY RUN — would: gh release create ${version} -R brightdigit/${repo} --prerelease"
		info "  title: ${version}"
		sed -n '1,3p' "$body" | sed 's/^/        | /'
		SUCCEEDED+=("$repo -> ${version} (dry-run)")
		return 0
	fi

	if ! gh release create "$version" -R "brightdigit/${repo}" \
		--title "$version" --notes-file "$body" --prerelease --verify-tag >/dev/null 2>&1; then
		echo "  FAIL: gh release create failed"
		gh release create "$version" -R "brightdigit/${repo}" \
			--title "$version" --notes-file "$body" --prerelease --verify-tag 2>&1 | sed 's/^/        /' | head -5
		FAILED+=("$repo (create)")
		return 1
	fi

	info "published: https://github.com/brightdigit/${repo}/releases/tag/${version}"
	SUCCEEDED+=("$repo -> ${version}")
	return 0
}

echo "Table:  $TABLE"
echo "Notes:  $NOTES_DIR"
[ "$DRY_RUN" -eq 1 ] && echo "Mode:   DRY RUN (nothing will be created)"

while IFS=$'\t' read -r repo wave boundary version mode expect_tip done_stamp; do
	case "$repo" in ''|\#*) continue ;; esac
	[ -n "$FILTER_REPO" ] && [ "$repo" != "$FILTER_REPO" ] && continue
	[ -n "$FILTER_WAVE" ] && [ "$wave" != "$FILTER_WAVE" ] && continue
	process_repo "$repo" "$wave" "$boundary" "$version" "$expect_tip" "${done_stamp:-}"
done < "$TABLE"

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
