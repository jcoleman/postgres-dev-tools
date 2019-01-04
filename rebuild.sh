#!/bin/bash

# saner programming env: these switches turn some bugs into errors
set -o errexit -o pipefail -o noclobber -o nounset

! getopt --test > /dev/null
if [[ ${PIPESTATUS[0]} -ne 4 ]]; then
  echo "`getopt --test` failed in this environment."
  exit 1
fi

OPTIONS=c
LONGOPTS=clean

# -use ! and PIPESTATUS to get exit code with errexit set
# -temporarily store output to be able to check for errors
# -activate quoting/enhanced mode (e.g. by writing out “--options”)
# -pass arguments only via   -- "$@"   to separate them correctly
! PARSED=$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")
if [[ ${PIPESTATUS[0]} -ne 0 ]]; then
  # e.g. return value is 1
  # then getopt has complained about wrong arguments to stdout
  exit 2
fi
# read getopt’s output this way to handle the quoting right:
eval set -- "$PARSED"

clean=0
while true; do
  case "$1" in
    -c|--clean)
      clean=1
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

export PATH=$HOME/postgresql-test/bin:$PATH

! pg_ctl status -D $HOME/postgresql-test-data
if [ $? -ne 0 ]; then
  ./stop.sh
fi


SOURCE_DIR=$HOME/postgres
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR=$HOME/Source/postgres
fi

pushd $SOURCE_DIR
if [ $clean -eq 1 ]; then
  make clean
fi
make && make install
BUILD_RESULT=$?
popd

if [ $BUILD_RESULT -eq 0 ]; then
  ./start.sh
fi
