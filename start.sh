# Choose an unused port on your machine
export PGPORT=5444
export PATH=$HOME/postgresql-test/bin:$PATH
if [ ! -d "$HOME/postgresql-test-data" ]; then
  initdb -D $HOME/postgresql-test-data
fi
pg_ctl -D $HOME/postgresql-test-data -l $HOME/postgresql-test-data.log start
