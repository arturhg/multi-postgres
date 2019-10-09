#!/usr/bin/env bash

set -e

function create_databases_and_users {
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

function create_database {
    local database=$1
    local user=$2
    local password=$3
    echo "  Creating database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE DATABASE $database;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $user;
        GRANT ALL PRIVILEGES ON DATABASE $database TO $POSTGRES_USER;
EOSQL
}

function create_user {
    local user=$1
    local password=$2
    echo "  Creating user '$user' with password '$password'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$password';
EOSQL
}

function install_extensions {
    local database=$1
    local extension=$2
    echo "  Installing extension '$extension' on database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        \c $database
        CREATE EXTENSION $extension;
EOSQL
}

if [ -n "$PG_DATABASES" ]; then
    array_databases=($(echo "$PG_DATABASES" | tr  ',' '\n'))
    if [ -n "$PG_USERS" ]; then
        array_users=($(echo "$PG_USERS" | tr  ',' '\n'))
        array_passwords=($(echo "$PG_PASSWORDS" | tr  ',' '\n'))
        if [ "${#array_databases[@]}" -eq "${#array_users[@]}" ] && [ "${#array_databases[@]}" -eq "${#array_passwords[@]}" ]; then
            for key in "${!array_databases[@]}"; do
                create_databases_and_users "${array_databases[$key]}" "${array_users[$key]}" "${array_passwords[$key]}"
            done
        elif [ "${#array_users[@]}" -eq 1 ] && [ "${#array_passwords[@]}" -eq 1 ]; then
            create_user "${array_users[0]}" "${array_passwords[0]}"
            for key in "${!array_databases[@]}"; do
                create_database "${array_databases[$key]}" "${array_users[0]}" "${array_passwords[0]}"
            done
        fi
    fi
    if [ -n "$PG_EXTENSIONS" ]; then
        array_extensions=($(echo "$PG_EXTENSIONS" | tr  ',' '\n'))
        for key in "${!array_databases[@]}"; do
            for key2 in "${!array_extensions[@]}"; do
                install_extensions "${array_databases[$key]}" "${array_extensions[$key2]}"
            done
        done
    fi
    echo "All databases succesfully created."
fi