#!/usr/bin/env bash

set -e

function create_databases {
    local database=$1
    local user=$2
    local password=$3
    echo "  Creating user '$user' with password '$password' and database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$password';
        CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
}


if [ -n "$PG_DATABASES" ]; then
    IFS=,
    array_databases=("$PG_DATABASES")
    if [ -n "$PG_USERS" ]; then
        array_users=("$PG_USERS")
        array_passwords=("$PG_PASSWORDS")
        if [ "${#array_databases[@]}" -eq "${#array_users[@]}" ] && [ "${#array_databases[@]}" -eq "${#array_passwords[@]}" ]; then
            for key in "${!array_databases[@]}"; do
                create_databases "${array_databases[$key]}" "${array_users[$key]}" "${array_passwords[$key]}"
            done
        elif [ "${#array_users[@]}" -eq 1 ] && [ "${#array_passwords[@]}" -eq 1 ]; then
            for key in "${!array_databases[@]}"; do
                create_databases "${array_databases[$key]}" "${array_users[0]}" "${array_passwords[0]}"
            done
        fi
    fi
    echo "All databases succesfully created."
fi