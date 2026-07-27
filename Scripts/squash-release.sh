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

	if [ "$DRY_RUN" -eq 1 ]; then
		info "DRY RUN — would:"
		info "  push ${BACKUP_PREFIX} -> ${tip:0:9}"
		case "$mode" in
			soft)   info "  git reset --soft ${boundary:0:9}" ;;
			orphan) info "  git checkout --orphan (replace entire history)" ;;
			amend)  info "  git commit --amend (single existing commit)" ;;
		esac
		info "  install RELEASE_NOTES.md from ${notes}"
		info "  git commit -m 'v${version}'"
		info "  verify diff shows only RELEASE_NOTES.md"
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
	git add -A

	if [ "$mode" = "amend" ]; then
		git commit --quiet --amend -m "v${version}" || { FAILED+=("$repo (amend)"); return 1; }
	else
		git commit --quiet -m "v${version}" || { FAILED+=("$repo (commit)"); return 1; }
	fi

	if [ "$mode" = "orphan" ]; then
		git branch --quiet -M main || { FAILED+=("$repo (branch -M)"); return 1; }
	fi

	# 4. THE GATE. The rewrite must change history shape and RELEASE_NOTES.md, nothing else.
	local changed
	changed=$(git diff --name-only "$tip" HEAD)
	if [ -n "$changed" ] && [ "$changed" != "RELEASE_NOTES.md" ]; then
		echo "  FAIL: content changed beyond RELEASE_NOTES.md — boundary is wrong."
		echo "$changed" | sed 's/^/        /'
		echo "        NOT pushed. Restore with:"
		echo "          git push --force origin refs/heads/${BACKUP_PREFIX}:main"
		FAILED+=("$repo (DIFF GATE)")
		return 1
	fi
	info "diff gate passed (only RELEASE_NOTES.md changed)"

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

while IFS=$'\t' read -r repo wave boundary version mode expect_tip; do
	case "$repo" in ''|\#*) continue ;; esac
	[ -n "$FILTER_REPO" ] && [ "$repo" != "$FILTER_REPO" ] && continue
	[ -n "$FILTER_WAVE" ] && [ "$wave" != "$FILTER_WAVE" ] && continue
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
