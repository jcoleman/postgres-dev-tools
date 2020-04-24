#!/usr/bin/env ruby

require "benchmark/ips"
require "pg"

BRANCHES = [
  "master",
  "dev_saop_binary_search",
]

PG_DEV_TOOLS_PATH = File.expand_path("../..", __FILE__)

def run_command(command)
  system(command)
  unless $?.success?
    raise "Command: `#{command}` failed"
  end
end

array = 1000.times.map { (100000 * rand()).to_i.to_s }
sql = <<~SQL
  SELECT COUNT(*)
  FROM generate_series(1,100000) n(i)
  WHERE i IN (#{array.join(',')})
SQL

BRANCHES.each_with_index do |branch, index|
  pg_path = "$HOME/postgresql-test-#{branch}"

  # Configure install directory per-branch.
  run_command("#{PG_DEV_TOOLS_PATH}/configure_build.sh --build=performance --path=\"#{pg_path}\"")

  # Build and install.
  run_command("#{PG_DEV_TOOLS_PATH}/rebuild.sh --clean")

  # Start Postgres.
  run_command("PG_PATH=\"#{pg_path}\" #{PG_DEV_TOOLS_PATH}/start.sh")

  # Setup connection.
  connection = PG.connect(
    host: "localhost",
    port: 5444,
    database: "perf",
  )

  # Run tests.
  Benchmark.ips do |x|
    x.time = 5
    x.warmup = 2

    x.report(branch) do
      conn.exec(sql)
    end

    if index == BRANCHES.size - 1
      x.compare!
    end
  end

  # Stop Postgres.
  run_command("PG_PATH=\"#{pg_path}\" #{PG_DEV_TOOLS_PATH}/stop.sh")
end
