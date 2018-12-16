#!/bin/bash

# Intended to be run from right pane:
# - Opens psql (with args) in left pane.
# - Runs gdb attached to pg backend in the right pane.

BACKEND_PID_CMD="ps aux --sort +etimes -C postgres | grep -v grep | grep postgres: | head -n1 | awk '{print \$2}'"
PSQL_CMD="psql $@"

OLD_PID="$(bash -c "$BACKEND_PID_CMD")"

tmux send-keys -t 0 "$PSQL_CMD" C-m

NEW_PID="$OLD_PID"

while [ "$NEW_PID" = "$OLD_PID" ]; do
  sleep 0.1
  NEW_PID="$(bash -c "$BACKEND_PID_CMD")"
done

gdb -p $NEW_PID
