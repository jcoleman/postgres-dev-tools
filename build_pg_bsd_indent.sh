#!/bin/bash

SOURCE_DIR="$HOME/postgres"
if [ ! -d "$SOURCE_DIR" ]; then
  SOURCE_DIR="$HOME/Source/postgres"
fi

pushd "$SOURCE_DIR/src/tools/pg_bsd_indent"

sudo make install prefix=/opt

popd
