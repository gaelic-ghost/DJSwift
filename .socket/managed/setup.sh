#!/bin/sh
set -eu
sh scripts/install-git-hooks.sh
sh scripts/setup-local-services.sh
sh .socket/managed/align.sh
