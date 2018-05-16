#!/bin/sh
docker-compose build
docker-compose run --rm app mix deps.get
docker-compose run --rm webpack yarn install
docker-compose run --rm app mix ecto.setup
docker-compose run --rm aida-backend mix ecto.setup
