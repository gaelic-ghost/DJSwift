set shell := ["sh", "-eu", "-c"]

setup:
  sh .socket/managed/setup.sh

align:
  sh .socket/managed/align.sh

package-test:
  for manifest in Packages/*/Package.swift; do (cd "$(dirname "$manifest")" && swift test); done

server-test:
  sh scripts/test-server.sh

server-migrate:
  cd Packages/DJSwiftServer && swift run DJSwiftServer migrate

server-run:
  cd Packages/DJSwiftServer && swift run DJSwiftServer serve --hostname 127.0.0.1 --port 8080
