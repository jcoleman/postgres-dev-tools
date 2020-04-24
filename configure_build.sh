#!/bin/bash

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

GETOPT_CMD="$(which getopt)"
! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
  ! BREW_GETOPT="$(brew --prefix gnu-getopt)"
  if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
    # then we don't have brew or user hasn't install gnu-getopt
    echo "'getopt --test' failed in this environment; if this is macOS please install gnu-getopt with homebrew."
    exit 1
  else
    GETOPT_CMD="$BREW_GETOPT/bin/getopt"
  fi
fi

OPTIONS="b:p:"
LONGOPTS="build:,path:"

# Default options
debug=0
performance=0
build_type=debug
pg_path="$HOME/postgresql-test"

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$($GETOPT_CMD --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  # e.g. return value is 1
  # then getopt has complained about wrong arguments to stdout
  exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

while true; do
  case "$1" in
    -b|--build)
      build_type="$2"
      shift 2
      ;;
    -p|--path)
      pg_path="$2"
      shift 2
      ;;
    --)
      shift
      break
      ;;
    *)
      echo "Programming error"
      exit 3
      ;;
  esac
done

SOURCE_DIR="$HOME/postgres"
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR="$HOME/Source/postgres"
fi

pushd "$SOURCE_DIR"
if [[ "$build_type" -eq "debug" ]]; then
  ./configure --prefix="$pg_path" \
    --enable-cassert \
    --enable-debug \
    --enable-depend \
    --enable-tap-tests \
    CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer -DOPTIMIZER_DEBUG"
elif [[ "$build_type" -eq "performance" ]]; then
  ./configure --prefix="$pg_path"
else
  echo "Unknown --build=#{$build_type}"
fi
popd
