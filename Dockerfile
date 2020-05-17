FROM ubuntu:latest

# Time format
ENV DATE_FORMAT="+%F@%T"

# Plex
ENV PLEX_URL="" \
    PLEX_TOKEN=""

# S6 overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2 \
    S6_KEEP_ENV=1

# Encryption
ENV ENCRYPT_MEDIA="1" \
    READ_ONLY="1"

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
ENV REMOVE_LOCAL_FILES_BASED_ON="space" \
    REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB="100" \
    FREEUP_ATLEAST_GB="80" \
    REMOVE_LOCAL_FILES_AFTER_DAYS="30"

# Cron
ENV CLOUDUPLOADTIME="0 1 * * *" \
    RMDELETETIME="0 6 * * *"

COPY src /install

RUN chmod a+x /install/install.sh && \
    bash /install/install.sh

VOLUME /data/db /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /log
WORKDIR /data
ENTRYPOINT ["/init"]
CMD cron -f
