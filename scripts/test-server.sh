#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SERVER_DIR="$ROOT_DIR/Packages/DJSwiftServer"

"$ROOT_DIR/scripts/setup-local-services.sh"

test_namespace="djswift:test:$(date +%s):$$"
local_user=$(id -un)
echo "Running DJSwift server tests with djswift_test and Redis namespace '$test_namespace'."
(
    cd "$SERVER_DIR"
    DATABASE_URL="${DATABASE_URL:-postgres://$local_user@127.0.0.1/djswift_test?tlsmode=disable}" \
    REDIS_URL="${REDIS_URL:-redis://127.0.0.1:6379/0}" \
    REDIS_KEY_NAMESPACE="$test_namespace" \
    swift test
)
