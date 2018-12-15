#!/bin/bash

pg_ctl status -D $HOME/postgresql-test-data
if [ $? -eq 0 ]; then
  ./stop.sh
fi


SOURCE_DIR=$HOME/postgres
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR=$HOME/Source/postgres
fi

pushd $SOURCE_DIR
make && make install
BUILD_RESULT=$?
popd

if [ $BUILD_RESULT -eq 0 ]; then
  ./start.sh
fi
