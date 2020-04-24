#!/usr/bin/env bash

# Choose an unused port on your machine
export PGPORT=5444
PG_PATH="$HOME/postgresql-test"
PATH="$PG_PATH/bin:$PATH"

pg_ctl -D $HOME/postgresql-test-data -l $HOME/postgresql-test-data.log stop
