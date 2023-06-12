#!/bin/bash

set -e

psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
  CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
  CREATE EXTENSION IF NOT EXISTS pg_buffercache;
  CREATE EXTENSION IF NOT EXISTS pg_walinspect;
  CREATE EXTENSION IF NOT EXISTS pgstattuple;
  CREATE ROLE replica WITH LOGIN REPLICATION PASSWORD 'replication';
  CREATE ROLE stats WITH LOGIN PASSWORD 'stats' IN ROLE pg_monitor;
  CREATE ROLE pgbench WITH LOGIN PASSWORD 'pgbench';
  CREATE ROLE serral WITH LOGIN PASSWORD 'serral' ROLE pgbench;
  CREATE ROLE maru WITH LOGIN PASSWORD 'maru' ROLE pgbench;
  CREATE ROLE classic WITH LOGIN PASSWORD 'classic' ROLE pgbench;
  CREATE DATABASE pgbench OWNER pgbench;
  \c pgbench
  CREATE EXTENSION IF NOT EXISTS pg_buffercache;
  CREATE EXTENSION IF NOT EXISTS pgstattuple;
  \c pgbench pgbench
  ALTER DEFAULT PRIVILEGES GRANT ALL ON TABLES TO public;
  ALTER DEFAULT PRIVILEGES GRANT ALL ON SEQUENCES TO public;
EOSQL

cat >> ${PGDATA}/postgresql.conf <<EOF
listen_addresses = '*'
shared_preload_libraries = 'pg_stat_statements'
wal_level = logical
hot_standby = on
max_wal_senders = 10
max_replication_slots = 10
archive_mode = on
archive_command = '/bin/true'
logging_collector = on
log_directory = '/var/log/postgresql'
log_filename = 'postgresql-%a.log'
log_min_duration_statement = 500
log_autovacuum_min_duration = 10s
log_line_prefix = '%m %p %u@%d from %h [vxid:%v txid:%x] [%i] %Q '
log_lock_waits = on
log_recovery_conflict_waits = on
log_replication_commands = on
log_temp_files = 4MB
track_io_timing = on
track_wal_io_timing = on
track_functions = all
pg_stat_statements.track = all
pg_stat_statements.track_utility = on
pg_stat_statements.track_planning = on
EOF

cat >> ${PGDATA}/pg_hba.conf <<EOF
host all         all 0.0.0.0/0 trust
host replication all 0.0.0.0/0 trust
EOF

chmod 600 ${PGDATA}/pg_hba.conf

pgbench -i -s 20 -U pgbench -d pgbench

psql -v ON_ERROR_STOP=1 -U postgres -d postgres <<-EOSQL
  SELECT pg_create_physical_replication_slot('standby');
EOSQL