#!/bin/sh
set -eu
if ! command -v xcodegen >/dev/null 2>&1; then
    echo "DJSwift alignment requires XcodeGen 2.46 or newer." >&2
    exit 127
fi
xcodegen generate --spec project.yml
xcodebuild -list -workspace DJSwift.xcworkspace
