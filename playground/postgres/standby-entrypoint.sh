#!/bin/bash
if [ ! -s "$PGDATA/PG_VERSION" ]; then
  echo "*:*:*:replica:replication" > ~/.pgpass
  chmod 0600 ~/.pgpass

  until pg_isready -h primary -p 5432 -U postgres
  do
    echo "Waiting for primary become ready..."
    sleep 2s
  done

  until su-exec postgres pg_basebackup -P -R -X stream -c fast -h primary -U replica -D ${PGDATA}
  do
    echo "Waiting for primary become ready for base backup..."
    sleep 3s
  done

  echo "primary_slot_name = 'standby'" >> ${PGDATA}/postgresql.auto.conf

  chmod 700 ${PGDATA}
fi

exec "$@"