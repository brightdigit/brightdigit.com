#!/bin/bash
#
# tag-release.sh — cut the release tag for each de-vendored package repo.
#
# Companion to squash-release.sh. That script rewrites history; this one only ever
# ADDS a tag, so it is the reversible half of the release: a bad tag is deleted with
# `git push --delete origin <tag>`, no history is touched.
#
# For each package repo listed in Scripts/release-versions.tsv this:
#   1. refuses unless the repo was already squashed (a 'done' stamp in the table)
#   2. refuses unless main still matches the tip recorded in the table
#   3. refuses unless main's CI is green on exactly that tip
#   4. refuses if the tag already exists on a different commit
#   5. pushes an annotated tag at main
#
# Step 3 is the point of the script: the plan requires green CI before any tag, and
# checking it per-repo here is what stops a red build from being released. Sibling
# workflows are ignored — only the repo's own build workflow (<Repo>.yml) counts,
# because orphan-rewritten repos silently skip it via paths-ignore.
#
# Tag names are UNPREFIXED (1.0.0-alpha.1), matching every existing tag in these
# repos; commit messages carry the 'v' prefix. Do not "fix" this asymmetry.
#
# Usage:
#   Scripts/tag-release.sh --dry-run              # print planned actions, touch nothing
#   Scripts/tag-release.sh --repo Plot            # one repo
#   Scripts/tag-release.sh --wave 0               # every repo in a wave
#   Scripts/tag-release.sh --all                  # every squashed repo
#
#   --skip-ci-check   tag despite red/missing CI (requires typing the repo name; use
#                     only for a known-unrelated infra flake, never to rush a wave)
#
# Requires: RELEASE_PAT (fine-grained PAT, Contents: read+write on the package repos)
#           gh authenticated for the CI status check

set -uo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
TABLE="${SCRIPT_DIR}/release-versions.tsv"
WORKDIR="${WORKDIR:-/private/tmp/claude-501/-Users-leo-Documents-Projects-brightdigit-com-tidy-summit/932a31c0-f3ab-4fb0-8151-165ad97615cb/scratchpad/tag}"

DRY_RUN=0
FILTER_REPO=""
FILTER_WAVE=""
SELECT_ALL=0
SKIP_CI=0

die() { echo "ERROR: $*" >&2; exit 1; }
info() { echo "  $*"; }

usage() {
	sed -n '3,30p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
	exit "${1:-0}"
}

while [ $# -gt 0 ]; do
	case "$1" in
		--dry-run) DRY_RUN=1; shift ;;
		--repo) FILTER_REPO="${2:-}"; [ -n "$FILTER_REPO" ] || die "--repo needs a value"; shift 2 ;;
		--wave) FILTER_WAVE="${2:-}"; [ -n "$FILTER_WAVE" ] || die "--wave needs a value"; shift 2 ;;
		--all) SELECT_ALL=1; shift ;;
		--skip-ci-check) SKIP_CI=1; shift ;;
		-h|--help) usage 0 ;;
		*) die "unknown argument: $1 (try --help)" ;;
	esac
done

[ -f "$TABLE" ] || die "missing table: $TABLE"

if [ -z "$FILTER_REPO" ] && [ -z "$FILTER_WAVE" ] && [ "$SELECT_ALL" -eq 0 ]; then
	die "select work with --repo <name>, --wave <n>, or --all"
fi

if [ "$DRY_RUN" -eq 0 ]; then
	[ -n "${RELEASE_PAT:-}" ] || die "RELEASE_PAT is not set (see MERGE-AND-TAG.md); or use --dry-run"
fi

command -v gh >/dev/null 2>&1 || die "gh is required for the CI status check"

mkdir -p "$WORKDIR"

FAILED=()
SUCCEEDED=()
SKIPPED=()

# Green means: the repo's own build workflow completed successfully on THIS sha.
# A run on any other sha tells us nothing about the tip we are about to tag.
check_ci() {
	local repo=$1 sha=$2
	local run
	run=$(gh run list -R "brightdigit/${repo}" --branch main --workflow "${repo}.yml" \
		--limit 1 --json status,conclusion,headSha \
		--jq '.[] | "\(.headSha) \(.status) \(.conclusion // "-")"' 2>/dev/null)

	if [ -z "$run" ]; then
		echo "no run found for workflow ${repo}.yml"
		return 1
	fi

	local run_sha run_status run_concl
	read -r run_sha run_status run_concl <<<"$run"

	if [ "${run_sha:0:9}" != "${sha:0:9}" ]; then
		# The usual cause is an orphan rewrite: paths-ignore filtered the build
		# workflow out, so the newest run still points at pre-rewrite history.
		echo "latest run is on ${run_sha:0:9}, not ${sha:0:9} (workflow may have been skipped — dispatch it)"
		return 1
	fi
	if [ "$run_status" != "completed" ]; then
		echo "run on ${sha:0:9} is ${run_status}, not finished"
		return 1
	fi
	if [ "$run_concl" != "success" ]; then
		echo "run on ${sha:0:9} concluded '${run_concl}'"
		return 1
	fi
	return 0
}

process_repo() {
	local repo=$1 wave=$2 version=$4 expect_tip=$6 done_stamp=${7:-}
	local clone="${WORKDIR}/${repo}"

	echo
	echo "=== ${repo} (wave ${wave}) -> ${version} ==="

	# Tagging an un-squashed repo would pin the tag to phase-5 history that is
	# about to be rewritten out from under it.
	if [ -z "$done_stamp" ]; then
		echo "  SKIP: not squashed yet (no 'done' stamp in the table)"
		SKIPPED+=("$repo (not squashed)")
		return 0
	fi

	local url="https://github.com/brightdigit/${repo}.git"
	if [ "$DRY_RUN" -eq 0 ]; then
		url="https://x-access-token:${RELEASE_PAT}@github.com/brightdigit/${repo}.git"
	fi

	# ls-remote is enough to validate; only clone when actually tagging.
	local remote_main
	remote_main=$(git ls-remote "$url" refs/heads/main 2>/dev/null | cut -f1)
	if [ -z "$remote_main" ]; then
		echo "  FAIL: could not read remote main"
		FAILED+=("$repo (ls-remote)")
		return 1
	fi

	if [ "${remote_main:0:9}" != "${expect_tip:0:9}" ]; then
		echo "  FAIL: main has moved since the table was built"
		echo "        expected ${expect_tip:0:9}, found ${remote_main:0:9}"
		FAILED+=("$repo (tip moved)")
		return 1
	fi
	info "main ${remote_main:0:9} matches table"

	# An existing tag on the same commit is a completed run, not an error — that is
	# what makes this script safe to re-run after a partial failure.
	local existing
	existing=$(git ls-remote --tags "$url" "refs/tags/${version}" 2>/dev/null | cut -f1)
	if [ -n "$existing" ]; then
		local peeled
		peeled=$(git ls-remote --tags "$url" "refs/tags/${version}^{}" 2>/dev/null | cut -f1)
		local points_at="${peeled:-$existing}"
		if [ "${points_at:0:9}" = "${remote_main:0:9}" ]; then
			info "tag ${version} already exists at ${points_at:0:9} — nothing to do"
			SKIPPED+=("$repo (already tagged)")
			return 0
		fi
		echo "  FAIL: tag ${version} already exists at ${points_at:0:9}, not ${remote_main:0:9}"
		echo "        delete it deliberately before re-tagging:"
		echo "          git push --delete origin ${version}"
		FAILED+=("$repo (tag conflict)")
		return 1
	fi

	local ci_msg
	if ci_msg=$(check_ci "$repo" "$remote_main"); then
		info "CI green on ${remote_main:0:9}"
	else
		if [ "$SKIP_CI" -eq 1 ]; then
			info "CI NOT verified: ${ci_msg}"
			# An override this consequential should not be possible by muscle memory.
			printf '  type the repo name to tag anyway: '
			local confirm=""
			read -r confirm </dev/tty || true
			if [ "$confirm" != "$repo" ]; then
				echo "  aborted (got '${confirm}')"
				FAILED+=("$repo (ci override declined)")
				return 1
			fi
			info "override accepted"
		else
			echo "  FAIL: ${ci_msg}"
			FAILED+=("$repo (CI)")
			return 1
		fi
	fi

	if [ "$DRY_RUN" -eq 1 ]; then
		info "DRY RUN — would:"
		info "  git tag -a ${version} -m '${version}' ${remote_main:0:9}"
		info "  git push origin refs/tags/${version}"
		SUCCEEDED+=("$repo -> ${version} (dry-run)")
		return 0
	fi

	rm -rf "$clone"
	if ! git clone --quiet --depth 1 "$url" "$clone" 2>/dev/null; then
		echo "  FAIL: clone failed"
		FAILED+=("$repo (clone)")
		return 1
	fi
	cd "$clone" || { FAILED+=("$repo (cd)"); return 1; }

	# Paranoia: the shallow clone must be the same commit we validated above.
	local local_head
	local_head=$(git rev-parse HEAD)
	if [ "${local_head:0:9}" != "${remote_main:0:9}" ]; then
		echo "  FAIL: clone HEAD ${local_head:0:9} != validated ${remote_main:0:9}"
		FAILED+=("$repo (race)")
		return 1
	fi

	if ! git tag -a "$version" -m "$version" 2>/dev/null; then
		echo "  FAIL: could not create tag"
		FAILED+=("$repo (tag)")
		return 1
	fi

	if ! git push --quiet origin "refs/tags/${version}" 2>/dev/null; then
		echo "  FAIL: could not push tag"
		FAILED+=("$repo (push)")
		return 1
	fi

	info "tagged ${version} at ${local_head:0:9}"
	SUCCEEDED+=("$repo -> ${version} (${local_head:0:9})")
	return 0
}

echo "Table:  $TABLE"
echo "Work:   $WORKDIR"
[ "$DRY_RUN" -eq 1 ] && echo "Mode:   DRY RUN (nothing will be modified)"
[ "$SKIP_CI" -eq 1 ] && echo "Mode:   --skip-ci-check (per-repo confirmation required)"

while IFS=$'\t' read -r repo wave boundary version mode expect_tip done_stamp; do
	case "$repo" in ''|\#*) continue ;; esac
	[ -n "$FILTER_REPO" ] && [ "$repo" != "$FILTER_REPO" ] && continue
	[ -n "$FILTER_WAVE" ] && [ "$wave" != "$FILTER_WAVE" ] && continue
	process_repo "$repo" "$wave" "$boundary" "$version" "$mode" "$expect_tip" "$done_stamp"
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
	echo "Halting. Fix the listed repos before repinning the root."
	exit 1
fi
echo "================================================"
