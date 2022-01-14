#!/bin/bash

SOURCE_DIR="$HOME/postgres"
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR="$HOME/Source/postgres"
fi

pushd "$SOURCE_DIR"
# Using lld for linking is apparently much faster than the default:
# https://www.postgresql.org/message-id/CAH2-Wz=5MX0v9kEzSom9T7JNNW4AzPFFkCuY=e19KDP-=+z9Fg@mail.gmail.com
./configure --prefix=$HOME/postgresql-test \
  --enable-cassert \
  --enable-debug \
  --enable-depend \
  --enable-tap-tests \
  CFLAGS="-ggdb -Og -g3 -fno-omit-frame-pointer -DOPTIMIZER_DEBUG -fuse-ld=lld"
popd
