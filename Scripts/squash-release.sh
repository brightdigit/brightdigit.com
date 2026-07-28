#!/bin/bash
#
# squash-release.sh — collapse phase-5 de-vendoring history into one release commit.
#
# For each package repo listed in Scripts/release-versions.tsv this:
#   1. pushes a backup ref (backup/pre-squash-<DATE>) so the rewrite is reversible
#   2. squashes every phase-5 commit into ONE commit named for the release
#   3. drops the prepared RELEASE_NOTES.md into that same commit
#   4. verifies RELEASE_NOTES.md is the ONLY changed path, then force-pushes
#
# Step 4 is the data-loss guard: a wrong boundary SHA would silently drop upstream
# history, and the diff would show it. It is a hard failure, never a warning.
#
# This script does NOT tag. Tagging happens per-wave after CI is green (MERGE-AND-TAG.md).
#
# Usage:
#   Scripts/squash-release.sh --dry-run              # print planned actions, touch nothing
#   Scripts/squash-release.sh --repo Plot            # one repo
#   Scripts/squash-release.sh --wave 0               # every repo in a wave
#   Scripts/squash-release.sh --all                  # all 20
#
# Requires: RELEASE_PAT (fine-grained PAT, Contents: read+write on the package repos)
#           NOTES_DIR   (directory of prepared <Repo>.md release notes; default Scripts/release-notes)

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PACKAGE_DIR="${SCRIPT_DIR}/.."
TABLE="${SCRIPT_DIR}/release-versions.tsv"
NOTES_DIR="${NOTES_DIR:-${SCRIPT_DIR}/release-notes}"
BACKUP_PREFIX="backup/pre-squash-260727"
WORKDIR="${WORKDIR:-/private/tmp/claude-501/-Users-leo-Documents-Projects-brightdigit-com-tidy-summit/932a31c0-f3ab-4fb0-8151-165ad97615cb/scratchpad/squash}"

DRY_RUN=0
FILTER_REPO=""
FILTER_WAVE=""
SELECT_ALL=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

usage() {
	sed -n '3,20p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
	exit "${1:-0}"
}

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

if [ -z "$FILTER_REPO" ] && [ -z "$FILTER_WAVE" ] && [ "$SELECT_ALL" -eq 0 ]; then
	die "select work with --repo <name>, --wave <n>, or --all"
fi

# A real run needs a token; --dry-run deliberately does not, so the plan can be
# reviewed before the credential is ever minted.
if [ "$DRY_RUN" -eq 0 ]; then
	[ -n "${RELEASE_PAT:-}" ] || die "RELEASE_PAT is not set (see MERGE-AND-TAG.md); or use --dry-run"
fi

mkdir -p "$WORKDIR"

FAILED=()
SUCCEEDED=()
SKIPPED=()

SWIFT=$(command -v xcrun >/dev/null 2>&1 && echo "xcrun swift" || echo "swift")

# Rewrites this repo's own first-party `branch:`/`revision:` pins to the released tags.
# Versions come from the table, so an earlier wave's tag is never hard-coded twice.
# Handles both manifest shapes in this fleet: the multi-line `.package(\n url:...\n branch:...)`
# form and the single-line form.
rewrite_deps() {
	DEP_VERSIONS="$DEP_VERSIONS" python3 - <<'PYEOF'
import os, re, pathlib, sys

versions = dict(
    pair.split('=', 1)
    for pair in os.environ['DEP_VERSIONS'].split(',')
    if pair
)

p = pathlib.Path('Package.swift')
s = orig = p.read_text()

for dep, ver in versions.items():
    # multi-line: .package(\n  url: ".../Dep.git",\n  branch: "main"\n)
    s = re.sub(
        r'(\.package\(\s*\n?\s*url:\s*"https://github\.com/brightdigit/%s\.git",\s*\n?\s*)'
        r'(?:branch|revision):\s*"[^"]*"' % re.escape(dep),
        lambda m: m.group(1) + 'from: "%s"' % ver,
        s,
    )
    # single-line: .package(url: ".../Dep.git", branch: "main")
    s = re.sub(
        r'(\.package\(url:\s*"https://github\.com/brightdigit/%s\.git",\s*)'
        r'(?:branch|revision):\s*"[^"]*"' % re.escape(dep),
        lambda m: m.group(1) + 'from: "%s"' % ver,
        s,
    )

if s == orig:
    sys.exit("no dependency pins were rewritten (manifest shape unexpected?)")
p.write_text(s)
PYEOF
}

# Builds DEP_VERSIONS ("Dep=version,Dep=version") for a repo by looking each of its
# first-party deps up in the table. Empty when the repo has no first-party deps.
deps_for_repo() {
	local repo=$1
	local manifest="${WORKDIR}/${repo}/Package.swift"
	local out=""
	[ -f "$manifest" ] || { echo ""; return 0; }
	local dep ver
	while read -r dep; do
		[ -n "$dep" ] || continue
		ver=$(awk -F'\t' -v R="$dep" '$1==R{print $4}' "$TABLE")
		[ -n "$ver" ] || continue
		out="${out}${dep}=${ver},"
	done < <(grep -o 'github\.com/brightdigit/[A-Za-z]*\.git' "$manifest" \
		| sed 's|.*brightdigit/||; s|\.git||' | sort -u)
	echo "$out"
}

process_repo() {
	local repo=$1 wave=$2 boundary=$3 version=$4 mode=$5 expect_tip=$6
	local notes="${NOTES_DIR}/${repo}.md"
	local clone="${WORKDIR}/${repo}"

	echo
	echo "=== ${repo} (wave ${wave}, ${mode} -> v${version}) ==="

	if [ ! -f "$notes" ]; then
		echo "  SKIP: no prepared release notes at ${notes}"
		SKIPPED+=("$repo (no notes)")
		return 0
	fi

	# Clone fresh every time so a half-finished previous run can never be reused.
	rm -rf "$clone"
	local url="https://github.com/brightdigit/${repo}.git"
	if [ "$DRY_RUN" -eq 0 ]; then
		url="https://x-access-token:${RELEASE_PAT}@github.com/brightdigit/${repo}.git"
	fi
	# Never let the token reach the log.
	if ! git clone --quiet "$url" "$clone" 2>/dev/null; then
		echo "  FAIL: clone failed"
		FAILED+=("$repo (clone)")
		return 1
	fi

	cd "$clone" || { FAILED+=("$repo (cd)"); return 1; }

	local tip
	tip=$(git rev-parse HEAD)

	# The table records the tip observed when boundaries were derived. If the remote
	# moved since, the boundary may no longer mean what it did — refuse rather than guess.
	if [ "${tip:0:9}" != "${expect_tip:0:9}" ]; then
		echo "  FAIL: main has moved since the table was built"
		echo "        expected tip ${expect_tip:0:9}, found ${tip:0:9}"
		echo "        re-derive the boundary before running again"
		FAILED+=("$repo (tip moved)")
		return 1
	fi
	info "tip ${tip:0:9} matches table"

	if [ "$mode" = "soft" ]; then
		if ! git merge-base --is-ancestor "$boundary" HEAD 2>/dev/null; then
			echo "  FAIL: boundary ${boundary:0:9} is not an ancestor of main"
			FAILED+=("$repo (bad boundary)")
			return 1
		fi
		info "boundary ${boundary:0:9} is an ancestor ($(git rev-list --count "${boundary}..HEAD") commits above)"
	fi

	# Which first-party deps does this repo pin, and at what released version?
	DEP_VERSIONS=$(deps_for_repo "$repo")
	if [ -n "$DEP_VERSIONS" ]; then
		info "will repin: ${DEP_VERSIONS%,}"
		# Every dep must already be tagged, or this package's own release would point at
		# a version that does not exist yet. Wave order exists precisely to prevent this.
		local dep ver missing=""
		while IFS='=' read -r dep ver; do
			[ -n "$dep" ] || continue
			if ! git ls-remote --tags "https://github.com/brightdigit/${dep}.git" \
				"refs/tags/${ver}" 2>/dev/null | grep -q .; then
				missing="${missing}${dep}@${ver} "
			fi
		done < <(echo "$DEP_VERSIONS" | tr ',' '\n')
		if [ -n "$missing" ]; then
			echo "  FAIL: dependency not tagged yet: ${missing}"
			echo "        release the earlier wave first"
			FAILED+=("$repo (untagged dep)")
			return 1
		fi
		info "all dependency tags exist"
	fi

	if [ "$DRY_RUN" -eq 1 ]; then
		info "DRY RUN — would:"
		info "  push ${BACKUP_PREFIX} -> ${tip:0:9}"
		case "$mode" in
			soft)   info "  git reset --soft ${boundary:0:9}" ;;
			orphan) info "  git checkout --orphan (replace entire history)" ;;
			amend)  info "  git commit --amend (single existing commit)" ;;
		esac
		info "  install RELEASE_NOTES.md from ${notes}"
		if [ -n "$DEP_VERSIONS" ]; then
			info "  repin deps -> ${DEP_VERSIONS%,}"
			info "  swift package resolve (regenerate lockfile)"
		fi
		info "  git commit -m 'v${version}'"
		if [ -n "$DEP_VERSIONS" ]; then
			info "  verify diff shows Package.swift + Package.resolved + RELEASE_NOTES.md"
		else
			info "  verify diff shows only RELEASE_NOTES.md"
		fi
		info "  git push --force-with-lease origin main"
		SUCCEEDED+=("$repo (dry-run)")
		return 0
	fi

	# 1. BACKUP FIRST — unconditional, and fatal if it fails.
	if ! git push --quiet origin "HEAD:refs/heads/${BACKUP_PREFIX}" 2>/dev/null; then
		echo "  FAIL: could not push backup ref — refusing to rewrite"
		FAILED+=("$repo (backup)")
		return 1
	fi
	info "backup ref pushed: ${BACKUP_PREFIX}"

	# 2. Reshape history. Nothing is committed yet in soft/orphan modes, so the
	#    release notes land inside the very same commit.
	case "$mode" in
		soft)   git reset --soft "$boundary" || { FAILED+=("$repo (reset)"); return 1; } ;;
		orphan) git checkout --quiet --orphan release-tmp || { FAILED+=("$repo (orphan)"); return 1; } ;;
		amend)  : ;;
		*)      echo "  FAIL: unknown mode '$mode'"; FAILED+=("$repo (mode)"); return 1 ;;
	esac

	# 3. Release notes go INTO the release commit, never a separate one.
	cp "$notes" RELEASE_NOTES.md

	# 3b. Rewrite this package's own first-party deps from `branch: "main"` to the tags
	#     cut in earlier waves — in the SAME commit, so the tag never points at a commit
	#     whose dependencies are about to change. Mandatory, not cosmetic: SwiftPM only
	#     lets a version-resolved package depend on other version-resolved packages, so a
	#     surviving branch pin makes THIS package unconsumable via `from:` downstream.
	if [ -n "${DEP_VERSIONS:-}" ]; then
		local before_deps after_deps
		# `grep -c` exits 1 on zero matches, so a `|| echo 0` fallback would APPEND a second
		# line to a legitimate "0" and produce "0\n0". Count lines instead — always exit 0.
		before_deps=$(grep -E '^\s*(branch|revision):' Package.swift 2>/dev/null | wc -l | tr -d ' ')
		if ! rewrite_deps; then
			echo "  FAIL: dependency rewrite failed"
			FAILED+=("$repo (dep rewrite)")
			return 1
		fi
		after_deps=$(grep -E '^\s*(branch|revision):' Package.swift 2>/dev/null | wc -l | tr -d ' ')
		info "deps repinned to tags (${before_deps} branch pins -> ${after_deps})"

		# A leftover branch pin would silently produce an unconsumable release.
		if [ "$after_deps" != "0" ]; then
			echo "  FAIL: ${after_deps} branch/revision pin(s) still present after rewrite:"
			grep -nE '^\s*(branch|revision):' Package.swift | sed 's/^/        /'
			FAILED+=("$repo (branch pin survived)")
			return 1
		fi

		# Regenerate the lockfile so manifest and Package.resolved agree in one commit.
		if ! $SWIFT package resolve >/dev/null 2>&1; then
			echo "  FAIL: swift package resolve failed after repinning"
			$SWIFT package resolve 2>&1 | tail -5 | sed 's/^/        /'
			FAILED+=("$repo (resolve)")
			return 1
		fi
		info "lockfile regenerated"
	fi

	git add -A

	if [ "$mode" = "amend" ]; then
		git commit --quiet --amend -m "v${version}" || { FAILED+=("$repo (amend)"); return 1; }
	else
		git commit --quiet -m "v${version}" || { FAILED+=("$repo (commit)"); return 1; }
	fi

	if [ "$mode" = "orphan" ]; then
		git branch --quiet -M main || { FAILED+=("$repo (branch -M)"); return 1; }
	fi

	# 4. THE GATE. The rewrite must change history shape plus RELEASE_NOTES.md — and, when
	#    repinning, the two manifest files. Nothing else: any other path means the boundary
	#    SHA was wrong and real source is being dropped.
	local changed allowed
	changed=$(git diff --name-only "$tip" HEAD | sort | tr '\n' ' ')
	if [ -n "${DEP_VERSIONS:-}" ]; then
		allowed="Package.resolved Package.swift RELEASE_NOTES.md "
	else
		allowed="RELEASE_NOTES.md "
	fi
	if [ -n "$changed" ] && [ "$changed" != "$allowed" ]; then
		echo "  FAIL: content changed beyond the expected paths — boundary is wrong."
		echo "        expected: ${allowed}"
		echo "        actual:   ${changed}"
		echo "        NOT pushed. Restore with:"
		echo "          git push --force origin refs/heads/${BACKUP_PREFIX}:main"
		FAILED+=("$repo (DIFF GATE)")
		return 1
	fi
	info "diff gate passed (${allowed% })"

	local newsha
	newsha=$(git rev-parse --short HEAD)

	# 5. Publish. --force-with-lease still guards against a race between clone and push.
	if ! git push --quiet --force-with-lease origin main 2>/dev/null; then
		echo "  FAIL: force-push rejected (remote moved?) — local rewrite discarded"
		FAILED+=("$repo (push)")
		return 1
	fi

	info "pushed ${newsha} as 'v${version}'"
	SUCCEEDED+=("$repo -> v${version} (${newsha})")
	return 0
}

echo "Table:  $TABLE"
echo "Notes:  $NOTES_DIR"
echo "Work:   $WORKDIR"
[ "$DRY_RUN" -eq 1 ] && echo "Mode:   DRY RUN (nothing will be modified)"

while IFS=$'\t' read -r repo wave boundary version mode expect_tip done_stamp; do
	case "$repo" in ''|\#*) continue ;; esac
	[ -n "$FILTER_REPO" ] && [ "$repo" != "$FILTER_REPO" ] && continue
	[ -n "$FILTER_WAVE" ] && [ "$wave" != "$FILTER_WAVE" ] && continue
	# Already squashed. The tip check alone would NOT catch this: `expect_tip` is updated
	# to the post-squash SHA once a repo is done, so re-running would squash the squash.
	# An explicit --repo is treated as deliberate (e.g. a recut) and still refuses unless
	# the operator clears the stamp.
	if [ -n "$done_stamp" ]; then
		echo
		echo "=== ${repo} ==="
		echo "  SKIP: already squashed on ${done_stamp} — clear the 'done' column to redo"
		SKIPPED+=("$repo (done ${done_stamp})")
		continue
	fi
	process_repo "$repo" "$wave" "$boundary" "$version" "$mode" "$expect_tip"
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
	echo
	echo "Halting. Do not proceed to tagging until every repo succeeds."
	exit 1
fi
echo "================================================"
