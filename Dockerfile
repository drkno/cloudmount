FROM ubuntu:latest

EXPOSE 5572

COPY src /install

RUN chmod a+x /install/install.sh && \
    bash /install/install.sh

VOLUME [ "/config" ]

WORKDIR /config
ENTRYPOINT ["/init"]
CMD cron -f