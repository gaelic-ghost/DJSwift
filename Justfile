set shell := ["sh", "-eu", "-c"]

setup:
  sh .socket/managed/setup.sh

align:
  sh .socket/managed/align.sh

install-hooks:
  sh scripts/install-git-hooks.sh

format:
  git ls-files -z '*.swift' | xargs -0 swiftformat

format-check:
  git ls-files -z '*.swift' | xargs -0 swiftformat --lint

package-test:
  for manifest in Packages/*/Package.swift; do package_dir="$(dirname "$manifest")"; if find "$package_dir/Tests" -type f -name '*.swift' -print -quit 2>/dev/null | grep -q .; then (cd "$package_dir" && swift test); else (cd "$package_dir" && swift build); fi; done

server-test:
  sh scripts/test-server.sh

server-migrate:
  cd Packages/DJSwiftServer && swift run DJSwiftServer migrate

server-run:
  cd Packages/DJSwiftServer && swift run DJSwiftServer serve --hostname 127.0.0.1 --port 8080
