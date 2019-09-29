FROM postgres:12-alpine
COPY docker-entrypoint.sh /docker-entrypoint-initdb.d/