# Postgres Essentials

Dockerfile for building postgresql:16 with the following extension
| Extension | Description |
|--------------------|----------|
| postgis | PostGIS geometry and geography spatial types and functions |
| pgcrypto | Cryptographic functions |
| citext | Data type for case-insensitive character strings |
| tablefunc | Functions that manipulate whole tables, including crosstab |
| pg_stat_statements | Track planning and execution statistics of all SQL statements executed |
| pg_trgm | Text similarity measurement and index searching based on trigrams |
| pg_cron | Job scheduler for PostgreSQL |
| pg_net | Async HTTP |

This image is derived from official [postgres:16](https://hub.docker.com/_/postgres) docker image.

Dockerfile installs the above listed extensions for `postgres` database.

`Dockerfile` files reside in [https://github.com/babkum/postgres_essentials](https://github.com/babkum/postgres_essentials)

Build

```bash
git clone https://github.com/babkum/postgres_essentials
cd postgres_essentials
docker build -t babkum/postgres-essentials:0.0.0 .
# If you intend to use the image on Railway (https://railway.app), build with the command below because Railway only supports amd64 platform
docker buildx build -t babkum/postgres-essentials:0.0.0 --platform linux/amd64 .
```

Run

```bash
docker run -p 5432:5432 \
-e POSTGRES_PASSWORD=[POSTGRES_PASSWORD] \
babkum/postgres-essentials:0.0.0
```
