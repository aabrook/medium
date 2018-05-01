#!/bin/bash

if [ ! -d "$PGDATA" ]; then
  mkdir "$PGDATA"
fi

initdb --no-locale -E UTF8
pg_ctl start
mix do deps.get, ecto.create, ecto.migrate
