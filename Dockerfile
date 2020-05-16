FROM ubuntu:latest

# S6 overlay
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2
ENV S6_KEEP_ENV=1

# Encryption
ENV ENCRYPT_MEDIA "1"
ENV READ_ONLY "1"

# Rclone
ENV BUFFER_SIZE "500M"
ENV MAX_READ_AHEAD "30G"
ENV CHECKERS "16"
ENV RCLONE_CLOUD_ENDPOINT "gd-crypt:"
ENV RCLONE_LOCAL_ENDPOINT "local-crypt:"

# Plexdrive
ENV CHUNK_SIZE "10M"
ENV MAX_NUM_CHUNKS "50"
ENV CHUNK_CHECK_THREADS "4"
ENV CHUNK_LOAD_AHEAD="4"
ENV CHUNK_LOAD_THREADS="4"

# Time format
ENV DATE_FORMAT "+%F@%T"

# Local files removal
ENV REMOVE_LOCAL_FILES_BASED_ON "space"
ENV REMOVE_LOCAL_FILES_WHEN_SPACE_EXCEEDS_GB "100"
ENV FREEUP_ATLEAST_GB "80"
ENV REMOVE_LOCAL_FILES_AFTER_DAYS "30"

# Plex
ENV PLEX_URL ""
ENV PLEX_TOKEN ""

# Cron
ENV CLOUDUPLOADTIME "0 1 * * *"
ENV RMDELETETIME "0 6 * * *"

COPY install.sh /
COPY setup/* /usr/bin/
COPY scripts/* /usr/bin/
COPY root /

RUN chmod a+x /install.sh && \
    sh /install.sh

VOLUME /data/db /cloud-encrypt /cloud-decrypt /local-decrypt /local-media /log
WORKDIR /data
ENTRYPOINT ["/init"]
CMD cron -f
