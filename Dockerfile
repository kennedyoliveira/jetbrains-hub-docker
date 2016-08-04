FROM ubuntu:16.04
MAINTAINER Kennedy Oliveira <kennedy.oliveira@outlook.com>

ENV HUB_VERSION 2.0.314
ENV HUB_BASE_DIR /opt/jetbrains-hub
ENV HUB_HOME $HUB_BASE_DIR/hub-ring-bundle-$HUB_VERSION
ENV HUB_DATA_DIR /var/lib/jetbrains-hub
ENV HUB_PORT 8080

# Creates the dir to hold the persistent data
RUN mkdir -p $HUB_HOME $HUB_DATA_DIR

# Entrypoint script
COPY ["docker-entrypoint.sh", "/opt/jetbrains-hub/"]

# Fix permissions
RUN chmod 755 /opt/jetbrains-hub/docker-entrypoint.sh

RUN apt-get update && apt-get install -y \
            openjdk-8-jre-headless \
            wget \
            unzip && \
    wget https://download.jetbrains.com/hub/2.0/hub-ring-bundle-${HUB_VERSION}.zip -O /tmp/hub.zip && \
    unzip /tmp/hub.zip -d $HUB_BASE_DIR/ && \
    rm -rf /tmp/hub.zip && \
    rm -rf $HUB_HOME/internal/java

WORKDIR $HUB_HOME/

# Basic configuration for hub
RUN $HUB_HOME/bin/hub.sh configure \
            --backups-dir $HUB_DATA_DIR/backups \
            --data-dir $HUB_DATA_DIR/data/ \
            --logs-dir $HUB_DATA_DIR/logs \
            --temp-dir $HUB_DATA_DIR/temp \
            --listen-port $HUB_PORT \
            --base-url http://localhost:$HUB_PORT/

# Expose the port
EXPOSE $HUB_PORT

VOLUME ["$HUB_DATA_DIR/data/", "$HUB_DATA_DIR/backups", "$HUB_DATA_DIR/logs", "$HUB_DATA_DIR/temp"]

ENTRYPOINT ["/opt/jetbrains-hub/docker-entrypoint.sh"]