#!/usr/bin/env bash
set -e
host="${DB_HOST:-db}"
port="${DB_PORT:-5432}"
echo "Esperando a que Postgres esté listo en $host:$port ..."
until nc -z "$host" "$port"; do
  sleep 1
done
echo "Postgres OK"
exec "$@"
