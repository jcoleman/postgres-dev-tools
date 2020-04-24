#!/usr/bin/env bash

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

OPTIONS="c,r,f"
LONGOPTS="clean,re-initdb,reconfigure"

# Default options
clean=0
reinitdb=0
reconfigure=0

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
    -c|--clean)
      clean=1
      shift
      ;;
    -r|--re-initdb)
      reinitdb=1
      shift
      ;;
    -f|--reconfigure)
      reconfigure=1
      shift
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

export PATH="$HOME/postgresql-test/bin:$PATH"

! pg_ctl status -D "$HOME/postgresql-test-data"
if [ $? -ne 0 ]; then
  ./stop.sh
fi

# TODO: setup test db?

SOURCE_DIR="$HOME/postgres"
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR="$HOME/Source/postgres"
fi

pushd "$SOURCE_DIR"
if [ $clean -eq 1 ]; then
  make clean
fi
if [ $reconfigure -eq 1 ]; then
  "$DIR/configure_build.sh"
fi
make && make install
BUILD_RESULT=$?
popd

if [ $BUILD_RESULT -eq 0 ]; then
  if [ $reinitdb -eq 1 ]; then
    rm -rf "$HOME/postgresql-test-data"
  fi
  ./start.sh
fi
