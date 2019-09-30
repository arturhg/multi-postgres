# multi-postgres
A docker image based on postgres:alpine that allows multiple databases in one container. Inspired by  [daniseijo/multi-postgres](https://github.com/daniseijo/multi-postgres).

Based on [postgres:12-alpine](https://github.com/docker-library/postgres/blob/662b2e6eb359221f132b5879e3cf65a4805ce428/12/alpine/Dockerfile).

Either provide the same number of databases, users and passwords or only one user and one password for all databases.

To create superuser(s) instead of user(s), set ```PG_SUPERUSER=Y``` environment variable.

To use this image add the following environment variables (for different users and passwords):

```
PG_DATABASES=database1,database2,database3
PG_USERS=user1,user2,user3
PG_PASSWORDS=password1,password2,password3
```
For single user and password for all databases

```
PG_DATABASES=database1,database2,database3
PG_USERS=user1
PG_PASSWORDS=password1
```

docker-compose.yml example with different users and passwords:

```yml
version: "3.5"
services:
  multi-db:
    image: artur/multi-postgres
    ports:
      - 5432:5432
    environment:
      PG_DATABASES: database1,database2,database3
      PG_USERS: user1,user2,user3
      PG_PASSWORDS: password1,password2,password3
```

docker-compose.yml example with single user and password for all databases:

```yml
version: "3.5"
services:
  multi-db:
    image: artur/multi-postgres
    ports:
      - 5432:5432
    environment:
      PG_DATABASES: database1,database2,database3
      PG_USERS: user1
      PG_PASSWORDS: password1
```
