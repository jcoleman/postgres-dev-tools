#!/usr/bin/env bash

# Intended to be run from right pane:
# - Run the script.
# - Run psql or other connection to PG manually.
# - Profiling will last the length of the backend.

BACKEND_PID_CMD="ps aux --sort +etimes -C postgres | grep -v grep | grep postgres: | head -n1 | awk '{print \$2}'"

OLD_PID="$(bash -c "$BACKEND_PID_CMD")"

echo "Waiting for you to launch a backend now..."

NEW_PID="$OLD_PID"

while [ "$NEW_PID" = "$OLD_PID" ]; do
  sleep 0.1
  NEW_PID="$(bash -c "$BACKEND_PID_CMD")"
done

perf record -g -p $NEW_PID
