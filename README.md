Tooling for Hacking on PostgreSQL
---

# Helpful GDB Notes

- Postgres uses `SIGUSR1` to set latches on backends, so GDB's default breaking on this signal can be frustrating. Disable this behavior with `handle SIGUSR1 noprint pass`.
- Many Postgres errors go through `errfinish`, so `br errfinish` is helpful. To only break on messages with level `ERROR`, `FATAL`, or `PANIC`, use `br errfinish if errordata[errordata_stack_depth].elevel >= 20`.

# Source Formatting

Postgres uses pgindent ([README](https://github.com/postgres/postgres/tree/master/src/tools/pgindent)) to format source code. Assuming the requisite tooling is installed, run `src/tools/pgindent/pgindent` to format your code.

# References

- https://wiki.postgresql.org/wiki/Developer_FAQ
