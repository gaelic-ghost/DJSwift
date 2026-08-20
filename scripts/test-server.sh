#!/bin/sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SERVER_DIR="$ROOT_DIR/Server"
COMPOSE_FILE="$SERVER_DIR/docker-compose.yml"
COMPOSE_PROJECT_NAME="${COMPOSE_PROJECT_NAME:-djswift-test}"
DB_SERVICE="db"
DB_NAME="${DATABASE_NAME:-vapor_database}"
DB_USERNAME="${DATABASE_USERNAME:-vapor_username}"
DB_PASSWORD="${DATABASE_PASSWORD:-vapor_password}"
DB_HOST="${DATABASE_HOST:-127.0.0.1}"
DB_PORT="${DJ_SWIFT_TEST_DB_PORT:-55432}"

if ! command -v docker >/dev/null 2>&1; then
    echo "DJSwift server tests require Docker, but no docker executable was found on PATH." >&2
    echo "Install a Docker-compatible runtime, then retry scripts/test-server.sh." >&2
    exit 127
fi

if docker compose version >/dev/null 2>&1; then
    COMPOSE="docker compose"
elif command -v docker-compose >/dev/null 2>&1 && docker-compose version >/dev/null 2>&1; then
    COMPOSE="docker-compose"
else
    echo "DJSwift server tests require Docker Compose, but neither 'docker compose' nor 'docker-compose' is available." >&2
    echo "Install docker-compose or configure Docker so the compose command is visible." >&2
    exit 127
fi

if ! docker info >/dev/null 2>&1; then
    if command -v colima >/dev/null 2>&1; then
        echo "Docker is installed but not running; starting Colima for DJSwift server tests."
        colima start
    else
        echo "Docker is installed, but the Docker daemon is not running and Colima is unavailable." >&2
        echo "Start Docker Desktop or another Docker-compatible runtime, then retry scripts/test-server.sh." >&2
        exit 69
    fi
fi

if ! docker info >/dev/null 2>&1; then
    echo "Docker still is not reachable after attempting to start the runtime for DJSwift server tests." >&2
    echo "Run 'docker info' for the underlying Docker connection error." >&2
    exit 69
fi

if [ ! -f "$COMPOSE_FILE" ]; then
    echo "DJSwift server tests expected $COMPOSE_FILE, but it does not exist." >&2
    echo "Run this script from a complete DJSwift checkout." >&2
    exit 66
fi

cleanup() {
    if [ "${DJ_SWIFT_KEEP_TEST_DB:-0}" = "1" ]; then
        echo "Leaving the DJSwift test database running because DJ_SWIFT_KEEP_TEST_DB=1."
        return
    fi

    echo "Stopping the DJSwift test database container and removing its test volume."
    if ! (cd "$SERVER_DIR" && DATABASE_HOST_PORT="$DB_PORT" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" $COMPOSE down -v); then
        echo "Docker Compose cleanup failed for the DJSwift test database; inspect Docker state with: docker ps -a" >&2
    fi
}

finish() {
    status=$?
    trap - EXIT INT TERM
    cleanup
    exit "$status"
}

trap finish EXIT INT TERM

echo "Starting the DJSwift test database with Docker Compose project '$COMPOSE_PROJECT_NAME' on $DB_HOST:$DB_PORT."
(cd "$SERVER_DIR" && DATABASE_HOST_PORT="$DB_PORT" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" $COMPOSE up -d "$DB_SERVICE")

echo "Waiting for PostgreSQL to accept connections."
attempt=1
while [ "$attempt" -le 30 ]; do
    if (cd "$SERVER_DIR" && DATABASE_HOST_PORT="$DB_PORT" COMPOSE_PROJECT_NAME="$COMPOSE_PROJECT_NAME" $COMPOSE exec -T "$DB_SERVICE" pg_isready -U "$DB_USERNAME" -d "$DB_NAME" >/dev/null 2>&1); then
        echo "PostgreSQL is ready for DJSwift server tests."
        break
    fi

    if [ "$attempt" -eq 30 ]; then
        echo "PostgreSQL did not become ready after 30 seconds for DJSwift server tests." >&2
        echo "Inspect the database logs with: cd Server && COMPOSE_PROJECT_NAME=$COMPOSE_PROJECT_NAME $COMPOSE logs db" >&2
        exit 75
    fi

    attempt=$((attempt + 1))
    sleep 1
done

echo "Running DJSwift server tests."
(cd "$SERVER_DIR" && \
    DATABASE_HOST="$DB_HOST" \
    DATABASE_PORT="$DB_PORT" \
    DATABASE_NAME="$DB_NAME" \
    DATABASE_USERNAME="$DB_USERNAME" \
    DATABASE_PASSWORD="$DB_PASSWORD" \
    swift test)
