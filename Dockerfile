# ---- build stage ----
FROM debian:bookworm-slim AS builder

RUN apt-get update && apt-get install -y --no-install-recommends \
        build-essential \
        qt5-qmake \
        qtbase5-dev \
        libbz2-dev \
        zlib1g-dev \
        libzmq3-dev \
        libminiupnpc-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
COPY . .
RUN qmake && make -j$(nproc)

# ---- runtime stage ----
FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
        libqt5core5a \
        libqt5network5 \
        libbz2-1.0 \
        libzmq5 \
        libminiupnpc17 \
        gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY --from=builder /build/Fulcrum /usr/local/bin/Fulcrum
COPY fulcrum-entrypoint.sh /entrypoint.sh
COPY doc/fulcrum-plm-docker.conf.template /fulcrum-tpl/fulcrum-plm-docker.conf.template

EXPOSE 50001 50002 8000

ENTRYPOINT ["/entrypoint.sh"]
CMD ["Fulcrum", "/data/fulcrum.conf"]
