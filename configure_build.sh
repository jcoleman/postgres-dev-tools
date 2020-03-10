#!/bin/bash

SOURCE_DIR="$HOME/postgres"
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR="$HOME/Source/postgres"
fi

pushd "$SOURCE_DIR"
./configure --prefix=$HOME/postgresql-test \
  --enable-cassert \
  --enable-debug \
  --enable-depend \
  --enable-tap-test \
  CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer -DOPTIMIZER_DEBUG"
popd
