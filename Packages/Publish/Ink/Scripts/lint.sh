#!/bin/bash

# Lint script for a vendored Publish-stack package. Adapted from the BrightDigit
# template: SwiftLint (enforcing the no_unchecked_sendable rule) and the build
# are strict gates; swift-format and periphery run as advisory-only, since the
# upstream Sundell code is not formatted to the BrightDigit house style.

ERRORS=0

run_command() {
	"$@" || ERRORS=$((ERRORS + 1))
}

advisory() {
	"$@" || echo "  (advisory step reported issues; not failing the build)"
}

if [ "$LINT_MODE" = "INSTALL" ]; then
	exit
fi

echo "LintMode: $LINT_MODE"

if [ -z "$SRCROOT" ]; then
	SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
	PACKAGE_DIR="${SCRIPT_DIR}/.."
else
	PACKAGE_DIR="${SRCROOT}"
fi

MISE_PATHS=(
    "/opt/homebrew/bin/mise"
    "/usr/local/bin/mise"
    "$HOME/.local/bin/mise"
)

MISE_BIN=""
for mise_path in "${MISE_PATHS[@]}"; do
    if [ -x "$mise_path" ]; then
        MISE_BIN="$mise_path"
        break
    fi
done

if [ -z "$MISE_BIN" ] && command -v mise &> /dev/null; then
    MISE_BIN="mise"
fi

if [ -n "$MISE_BIN" ]; then
    TOOL_CMD="$MISE_BIN exec --"
else
    echo "Error: mise is not installed"
    echo "Install mise: https://mise.jdx.dev/getting-started.html"
    exit 1
fi

if [ "$LINT_MODE" = "NONE" ]; then
	exit
elif [ "$LINT_MODE" = "STRICT" ]; then
	SWIFTFORMAT_LINT_OPTIONS="--strict"
	SWIFTLINT_OPTIONS="--strict"
else
	SWIFTFORMAT_LINT_OPTIONS=""
	SWIFTLINT_OPTIONS=""
fi

pushd $PACKAGE_DIR

run_command "$MISE_BIN" install

if [ -z "$FORMAT_ONLY" ]; then
	# Strict gates: the no_unchecked_sendable rule and a clean build.
	run_command $TOOL_CMD swiftlint lint $SWIFTLINT_OPTIONS
	run_command swift build --build-tests
	# Advisory: house-style formatting is not enforced on vendored code.
	advisory $TOOL_CMD swift-format lint --configuration .swift-format --recursive --parallel $SWIFTFORMAT_LINT_OPTIONS Sources Tests
fi

if [ -z "$CI" ]; then
	advisory $TOOL_CMD periphery scan $PERIPHERY_OPTIONS --disable-update-check
fi

popd

if [ $ERRORS -gt 0 ]; then
	echo "Linting completed with $ERRORS error(s)"
	exit 1
else
	echo "Linting completed successfully"
	exit 0
fi
