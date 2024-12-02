FROM ghcr.io/osgeo/gdal:ubuntu-small-3.10.0
RUN apt-get update && apt-get upgrade -y && \
    apt-get install -y postgresql-client && \
    rm -rf /var/lib/apt/lists
RUN mkdir /work
ADD . /work/
RUN chmod 755 /work/convert.sh