#!/bin/sh
set -eu

repository_root=$(git rev-parse --show-toplevel)

if ! command -v swiftformat >/dev/null 2>&1; then
    echo "DJSwift setup requires SwiftFormat. Install it with 'brew install swiftformat', then rerun setup." >&2
    exit 1
fi

git -C "$repository_root" config --local core.hooksPath .githooks
echo "DJSwift Git hooks use $repository_root/.githooks."
