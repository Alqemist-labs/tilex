#!/bin/bash

set -e

host="$1"
shift
cmd="$@"

until nc -vz postgres 5432; do
  echo "Postgresql is not ready, sleeping..."
  sleep 3
done
echo "Postgresql is ready, starting Rails."

>&2 echo "cmd arg: ${cmd}"
>&2 echo "Postgres is up - entering app"

exec $cmd
