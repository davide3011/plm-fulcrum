# ---- download stage ----
FROM debian:bookworm-slim AS downloader

RUN apt-get update && apt-get install -y --no-install-recommends \
        bash curl ca-certificates tar \
    && rm -rf /var/lib/apt/lists/*

COPY daemon/download-binaries.sh /tmp/download-binaries.sh
RUN chmod +x /tmp/download-binaries.sh && \
    mkdir -p /tmp/bins && \
    /tmp/download-binaries.sh --outdir /tmp/bins

# ---- runtime stage ----
FROM ubuntu:22.04

RUN apt-get update && apt-get install -y --no-install-recommends \
        libboost-system1.74.0 \
        libboost-filesystem1.74.0 \
        libboost-thread1.74.0 \
        libboost-chrono1.74.0 \
        libevent-2.1-7 \
        libevent-pthreads-2.1-7 \
        libzmq5 \
        libminiupnpc17 \
        libnatpmp1 \
        libsqlite3-0 \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY --from=downloader /tmp/bins/palladiumd    /usr/local/bin/palladiumd
COPY --from=downloader /tmp/bins/palladium-cli /usr/local/bin/palladium-cli
RUN chmod +x /usr/local/bin/palladiumd /usr/local/bin/palladium-cli

COPY config/     /palladium-node/config/
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 2333

ENTRYPOINT ["/entrypoint.sh"]
CMD ["palladiumd", \
     "-conf=/root/.palladium/palladium.conf", \
     "-datadir=/root/.palladium", \
     "-daemon=0", \
     "-printtoconsole=1"]
