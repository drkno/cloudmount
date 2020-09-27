FROM ubuntu:latest

# User
ENV PGID=911 \
    PUID=911

# Plex
ENV PLEX_URL="" \
    PLEX_TOKEN=""

# S6 overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KEEP_ENV=1

# Rclone
ENV BUFFER_SIZE="500M" \
    MAX_READ_AHEAD="30G" \
    CHECKERS="16" \
    RCLONE_CLOUD_ENDPOINT="gd-crypt:" \
    RCLONE_LOCAL_ENDPOINT="local-crypt:"

# Plexdrive
ENV CHUNK_SIZE="10M" \
    MAX_NUM_CHUNKS="50" \
    CHUNK_CHECK_THREADS="4" \
    CHUNK_LOAD_AHEAD="4" \
    CHUNK_LOAD_THREADS="4"

# Local files removal
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB="100"

# Cron
ENV RMDELETETIME="0 6 * * *"

# rclone rcd gui
EXPOSE 5572

COPY src /install

RUN chmod a+x /install/install.sh && \
    bash /install/install.sh

VOLUME [ "/config" ]

WORKDIR /config
ENTRYPOINT ["/init"]
CMD cron -f
