FROM postgres:16
LABEL Maintainer Babkum <developers@babkum.com>

# Source DockerHub / Github:
# https://hub.docker.com/r/babkum/postgres-essentials
# https://github.com/babkum/postgres_essentials

# Prepare ENVs
ENV PG_NET_VERSION '0.9.0'
ENV PG_CRON_VERSION '1.6.2'
ENV POSTGIS_VERSION '3.4.1'
ENV EXTENSION_INSTALLATION_DIR '/extenstions'
ENV INIT_DB_DIR '/docker-entrypoint-initdb.d/00-init-db.sh'

# Prepare the build requirements
RUN apt update && apt-get install -y --no-install-recommends \
  git \
  g++ \
  gcc \
  wget \
  make \
  libpq-dev \
  libgeos-dev \
  libgdal-dev \
  proj-bin \
  libproj-dev \
  libxml2-dev \
  libprotobuf-c-dev \
  protobuf-c-compiler \
  postgresql-server-dev-16 \
  ca-certificates

# Install pg_net
RUN mkdir ${EXTENSION_INSTALLATION_DIR} && \ 
  cd ${EXTENSION_INSTALLATION_DIR} && \
  wget https://github.com/supabase/pg_net/archive/v${PG_NET_VERSION}.tar.gz && \
  tar -xvzf v${PG_NET_VERSION}.tar.gz && \
  cd pg_net-${PG_NET_VERSION} && \
  make && \
  make install

# Install pg_cron
RUN cd ${EXTENSION_INSTALLATION_DIR} && \
  wget https://github.com/citusdata/pg_cron/archive/v${PG_CRON_VERSION}.tar.gz && \
  tar -xvzf v${PG_CRON_VERSION}.tar.gz && \
  cd pg_cron-${PG_CRON_VERSION} && \
  make && \
  make install

# Install postgis
RUN cd ${EXTENSION_INSTALLATION_DIR} && \
  wget http://postgis.net/stuff/postgis-${POSTGIS_VERSION}dev.tar.gz && \
  tar -xvzf postgis-${POSTGIS_VERSION}dev.tar.gz && \
  cd postgis-${POSTGIS_VERSION}dev && \
  ./configure && \
  make && \
  make install

# Clean up 1
RUN apt-get remove -y \
  git \
  wget \
  make \
  ca-certificates

# Clean up 2
RUN apt autoclean && \
  apt clean && \
  apt purge && \
  apt autoremove --purge -y && \
  rm -rf ${EXTENSION_INSTALLATION_DIR} /var/lib/apt/lists/*

# Configure extensions
RUN echo '#!/bin/bash' > ${INIT_DB_DIR} && \ 
  echo 'set -e' >> ${INIT_DB_DIR} && \ 
  echo 'export PGUSER=$POSTGRES_USER'  >> ${INIT_DB_DIR} && \ 
  echo 'export PGDATABASE=$POSTGRES_DB' >> ${INIT_DB_DIR} && \ 
  echo 'psql -v ON_ERROR_STOP=1 <<-EOSQL' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS postgis;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS pgcrypto;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS citext;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS tablefunc;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS pg_stat_statements;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS pg_trgm;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS pg_cron;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE USER postgres;' >> ${INIT_DB_DIR} && \ 
  echo 'ALTER ROLE postgres SUPERUSER;' >> ${INIT_DB_DIR} && \ 
  echo 'CREATE EXTENSION IF NOT EXISTS pg_net;' >> ${INIT_DB_DIR} && \ 
  echo 'EOSQL' >> ${INIT_DB_DIR} && \ 
  chmod +x ${INIT_DB_DIR}
