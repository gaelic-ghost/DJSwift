#!/bin/sh
set -eu

for command in pg_isready psql createdb redis-cli; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "DJSwift local setup requires '$command' from Homebrew PostgreSQL and Redis." >&2
        echo "Install and start postgresql@18 and redis, then retry." >&2
        exit 127
    fi
done

if ! pg_isready -h 127.0.0.1 >/dev/null 2>&1; then
    echo "DJSwift cannot reach Homebrew PostgreSQL on 127.0.0.1:5432." >&2
    echo "Start it with: brew services start postgresql@18" >&2
    exit 69
fi

if [ "$(redis-cli -h 127.0.0.1 ping 2>/dev/null)" != "PONG" ]; then
    echo "DJSwift cannot reach Homebrew Redis on 127.0.0.1:6379." >&2
    echo "Start it with: brew services start redis" >&2
    exit 69
fi

for database in djswift_development djswift_test; do
    exists=$(psql -h 127.0.0.1 -d postgres -Atqc "SELECT 1 FROM pg_database WHERE datname = '$database'")
    if [ "$exists" != "1" ]; then
        echo "Creating PostgreSQL database '$database'."
        createdb -h 127.0.0.1 "$database"
    else
        echo "PostgreSQL database '$database' already exists."
    fi
done

echo "DJSwift local PostgreSQL and Redis dependencies are ready."
