FROM --platform=linux/amd64 postgres:16
LABEL Maintainer Babkum <developers@babkum.com>

# Source DockerHub / Github:
# https://hub.docker.com/r/babkum/postgres-essentials
# https://github.com/babkum/postgres_essentials

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
RUN mkdir /extensions && \ 
  cd ./extensions && \
  wget https://github.com/supabase/pg_net/archive/v0.9.0.tar.gz && \
  tar -xvzf v0.9.0.tar.gz && \
  cd pg_net-0.9.0 && \
  make && \
  make install

# Install pg_cron
RUN cd ./extensions && \
  wget https://github.com/citusdata/pg_cron/archive/v1.6.2.tar.gz && \
  tar -xvzf v1.6.2.tar.gz && \
  cd pg_cron-1.6.2 && \
  make && \
  make install

# Install postgis
RUN cd ./extensions && \
  wget http://postgis.net/stuff/postgis-3.4.1dev.tar.gz && \
  tar -xvzf postgis-3.4.1dev.tar.gz && \
  cd postgis-3.4.1dev && \
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
  rm -rf /extensions /var/lib/apt/lists/*

# Move docker-entrypoint.sh into the container
COPY ./docker-entrypoint.sh /usr/local/bin/

# Make docker-entrypoint.sh executable
RUN chmod a+x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["postgres"]
