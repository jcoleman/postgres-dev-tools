Tooling for Hacking on PostgreSQL
---

# Helpful GDB Notes

- Postgres uses `SIGUSR1` to set latches on backends, so GDB's default breaking on this signal can be frustrating. Disable this behavior with `handle SIGUSR1 noprint pass`.
- Many Postgres errors go through `errfinish`, so `br errfinish` is helpful. To only break on messages with level `ERROR`, `FATAL`, or `PANIC`, use `br errfinish if errordata[errordata_stack_depth].elevel >= 20`.

# References

- https://wiki.postgresql.org/wiki/Developer_FAQ
