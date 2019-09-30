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

function create_databases_and_superusers {
    local database=$1
    local user=$2
    local password=$3
    echo "  Creating superuser '$user' with password '$password' and database '$database'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$password';
        ALTER USER $user WITH SUPERUSER;
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

function create_superuser {
    local user=$1
    local password=$2
    echo "  Creating superuser '$user' with password '$password'"
    psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
        CREATE USER $user WITH PASSWORD '$password';
        ALTER USER $user WITH SUPERUSER;
EOSQL
}

if [ -n "$PG_DATABASES" ]; then
    IFS=', ' read -r -a array_databases <<< "$PG_DATABASES"
    if [ -n "$PG_USERS" ]; then
        read -r -a array_users <<< "$PG_USERS"
        read -r -a array_passwords <<< "$PG_PASSWORDS"
        if [ "${#array_databases[@]}" -eq "${#array_users[@]}" ] && [ "${#array_databases[@]}" -eq "${#array_passwords[@]}" ]; then
            if [ -n "$PG_SUPERUSER" ] && [ "$PG_SUPERUSER" -eq "Y" ]; then
                for key in "${!array_databases[@]}"; do
                    create_databases_and_superusers "${array_databases[$key]}" "${array_users[$key]}" "${array_passwords[$key]}"
                done
            else
                for key in "${!array_databases[@]}"; do
                    create_databases_and_users "${array_databases[$key]}" "${array_users[$key]}" "${array_passwords[$key]}"
                done
            fi
        elif [ "${#array_users[@]}" -eq 1 ] && [ "${#array_passwords[@]}" -eq 1 ]; then
            if [ -n "$PG_SUPERUSER" ] && [ "$PG_SUPERUSER" -eq "Y" ]; then
                create_superuser "${array_users[0]}" "${array_passwords[0]}"
            else
                create_user "${array_users[0]}" "${array_passwords[0]}"
            fi
            for key in "${!array_databases[@]}"; do
                create_database "${array_databases[$key]}" "${array_users[0]}" "${array_passwords[0]}"
            done
        fi
    fi
    echo "All databases succesfully created."
fi