#!/bin/sh
set -eu
sh scripts/setup-local-services.sh
sh .socket/managed/align.sh
