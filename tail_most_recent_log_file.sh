#!/usr/bin/env bash

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

tail -f $(ls -td -1 "$HOME/postgresql-test-data/log/"* | head -n1) $@
