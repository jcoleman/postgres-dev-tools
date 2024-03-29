#!/usr/bin/env bash

# Choose an unused port on your machine
export PGPORT=5444
PG_PATH="$HOME/postgresql-test"
PATH="$PG_PATH/bin:$PATH"

if [ ! -d "$HOME/postgresql-test-data" ]; then
  initdb -D $HOME/postgresql-test-data
  newline=$'\n'
  sed -i "" -e "s/#logging_collector = off/logging_collector = on${newline}#logging_collector = off/g" "$HOME/postgresql-test-data/postgresql.conf"
fi
pg_ctl -D $HOME/postgresql-test-data -l $HOME/postgresql-test-data.log start
