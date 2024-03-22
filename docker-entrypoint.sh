#!/bin/bash

# echo "* ENV"
# export

echo "* SQL MIGRATING"
bundle exec rake db:migrate

exec "$@"
