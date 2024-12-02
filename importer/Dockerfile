FROM debian:bookworm-backports
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y \
    osm2pgsql/bookworm-backports postgresql-client && \
    rm -rf /var/lib/apt/lists
RUN mkdir /work
WORKDIR /work
ADD . /work/
RUN chmod 755 go.sh
