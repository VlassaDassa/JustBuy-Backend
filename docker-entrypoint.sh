#!/bin/sh
set -eu

mkdir -p /data
mkdir -p /app/test_api/media

if [ ! -f /data/db.sqlite3 ] && [ -f /seed/db.sqlite3 ]; then
    cp /seed/db.sqlite3 /data/db.sqlite3
fi

rm -f /app/test_api/db.sqlite3
ln -s /data/db.sqlite3 /app/test_api/db.sqlite3

if [ -d /seed/media ] && [ -z "$(ls -A /app/test_api/media 2>/dev/null)" ]; then
    cp -a /seed/media/. /app/test_api/media/
fi

python manage.py migrate --noinput

exec "$@"
