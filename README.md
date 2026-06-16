# ![Image FulcrumLogo](https://raw.githubusercontent.com/cculianu/Fulcrum-art/master/F-circle2_grn_64.png) plm-fulcrum

A fast & nimble SPV server for **Palladium (PLM)** — a decentralized cryptocurrency built on Bitcoin's proven codebase, enhanced with modern features including Taproot support.

This is a fork of [Fulcrum](https://fulcrumserver.org/), adapted to speak the Electrum protocol against [`palladiumd`](https://github.com/palladium-coin/palladiumcore) instead of bitcoind/BCHN. For more on Palladium itself, see [palladiumblockchain.net](https://palladiumblockchain.net) / [palladium-coin.com](https://palladium-coin.com).

#### Copyright
(C) 2019-2026 Calin A. Culianu \<calin.culianu@gmail.com\> (original Fulcrum)
(C) 2025-2026 Davide Grilli \<davide.grilli@outlook.com\> (Palladium support)

See [AUTHORS](AUTHORS) for details on who did what.

#### License:
GPLv3, inherited unchanged from upstream Fulcrum. See the included `LICENSE.txt` file or [visit gnu.org and read the license](https://www.gnu.org/licenses/gpl-3.0.html).

![Image Fulcrum](https://raw.githubusercontent.com/cculianu/Fulcrum-art/master/F_bal_stylized_1_256.png)

### Highlights:

- *Fast:* Written in 100% modern `C++20` using multi-threaded and asynchronous programming techniques (inherited from upstream Fulcrum).
- *A drop-in replacement for ElectrumX, now for PLM:* Speaks the [Electrum Cash protocol](https://electrum-cash-protocol.readthedocs.io/en/latest/) against a `palladiumd` node.
- *Palladium-aware:* native `PLM` coin detection, address codec (`P...`/`3...` mainnet, Bech32 `plm1...`), and SegWit-correct serialization from height 29000 onward.
- *Dockerized:* a ready-to-run `docker-compose.yml` brings up `palladiumd` + `fulcrum-plm` together with TLS auto-provisioned.

### What was changed for PLM

- `Coin::PLM` added to the coin enum, with name mapping and RPC-based auto-detection in `BitcoinD`.
- PLM address codec: P2PKH (`0x37`, `P...`), P2SH (`0x05`, `3...`), WIF (`0x80`), Bech32 HRPs `plm`/`tplm`/`rplm`.
- SegWit serialization enabled for PLM in `Controller`.
- BCH-only features (DSProof, RPA, CashTokens) are not exposed for PLM.
- Unit tests for coin name mapping and PLM address encoding (`./Fulcrum --test`).

See the file headers in `src/` for exactly which files carry PLM modifications, and `git log` for the full history. The PLM consensus parameters this server needs to be aware of (coinbase maturity, fork heights, difficulty schedule) are documented in `coin_spec.md`.

### Requirements

- *For running*:
  - A [`palladiumd`](https://github.com/palladium-coin/palladiumcore) node with its JSON-RPC service enabled, preferably on the same machine, with `txindex=1` and not pruning.
  - *Optional*: ZMQ notifications (`zmqpubrawblock`/`zmqpubrawtx`/`zmqpubhashblock`) — auto-discovered via the `getzmqnotifications` RPC if configured in `palladium.conf`.
  - *Recommended hardware*: similar to Bitcoin Core — an SSD is strongly recommended.
- *For compiling*:
  - `Qt Core` & `Qt Networking` libraries `5.15.2` or above.
  - *Optional but recommended*: `libzmq3-dev` and `libminiupnpc-dev`.
  - A modern, 64-bit `C++20` compiler. `clang-17` or `g++-13` are recommended.

### Quickstart with Docker

The included `docker-compose.yml` runs `palladiumd` and `fulcrum-plm` together on a shared Docker network, with TLS auto-provisioned for the Electrum SSL listener.

```bash
cp .env.example .env        # set RPC_USER / RPC_PASSWORD
docker compose up -d
docker compose logs -f fulcrum-plm
```

- `palladiumd` data persists in `palladium-node/.palladium/` (bind-mounted).
- `fulcrum-plm` data persists in `fulcrum-db/` (bind-mounted).
- A self-signed TLS certificate is generated on first run into `ssl/`.
- Ports exposed on the host: `2333` (PLM P2P), `50001`/`50002` (Electrum TCP/SSL), `127.0.0.1:8000` (admin, host-only).

### Running palladiumd standalone (no Docker)

If you'd rather not use Docker, you can get `palladiumd`/`palladium-cli` directly:

```bash
./palladium-node/daemon/download-binaries.sh --outdir /usr/local/bin
```

This downloads the latest prebuilt release from [palladium-coin/palladiumcore](https://github.com/palladium-coin/palladiumcore) for your platform/architecture (`--platform`/`--arch`/`--repo` let you override the defaults; see `--help`). To build `palladiumd` from source instead, follow the instructions in that repository.

Minimal `~/.palladium/palladium.conf` to pair with `fulcrum-plm`:

```ini
txindex=1
server=1
rpcuser=palladiumrpc
rpcpassword=<strong-password>
rpcport=2332
rpcbind=127.0.0.1
rpcallowip=127.0.0.1
zmqpubrawblock=tcp://127.0.0.1:28332
zmqpubrawtx=tcp://127.0.0.1:28333
zmqpubhashblock=tcp://127.0.0.1:28334
listen=1
port=2333
```

```bash
palladiumd -conf=$HOME/.palladium/palladium.conf -daemon
```

Once it's running and synced, point `fulcrum-plm` at it as described below.

### How To Compile

To compile without Docker, you'll need a `palladiumd` node running separately. To compile Fulcrum itself:

1. Make sure you have `qmake` in your path and all the requisite Qt5/Qt6 dev libs installed.
2. `qmake` (to generate the Makefile)
3. `make -j$(nproc)`

**A note for Linux users**: you also need `libbz2-dev`, otherwise compilation will fail.

#### Linking against the system `librocksdb.so` (experimental, Linux only)

```bash
qmake LIBS+=-lrocksdb && make clean && make -j$(nproc)
```

---

### Running plm-fulcrum

Execute the binary with `-h` to see the built-in help, e.g. `./Fulcrum -h`. You can set most options from the CLI, but you can also specify a **config file** as an argument:

```bash
./Fulcrum doc/fulcrum-plm-config.conf
```

See:
- [`doc/fulcrum-plm-config.conf`](doc/fulcrum-plm-config.conf) — standalone (no Docker) setup against a local `palladiumd`.
- [`doc/fulcrum-plm-docker.conf.template`](doc/fulcrum-plm-docker.conf.template) — the template rendered automatically by the Docker setup.

As long as the server is still synchronizing, public-facing ports will not yet be bound. Once it finishes syncing, it behaves like an ElectrumX server and can receive requests from any Electrum-protocol-compatible PLM wallet.

#### Admin Script: FulcrumAdmin

`Fulcrum` ships with an admin script (`Python 3.6+` required). It requires an **admin port** (config var `admin=`, CLI arg `-a`). Run `./FulcrumAdmin -h` for the full list of subcommands (`getinfo`, `stop`, `peers`, `query`, etc.), e.g.:

```bash
./FulcrumAdmin -p 8000 getinfo
```

---

### Protocol Documentation

This server speaks the [Electrum Cash protocol](https://electrum-cash-protocol.readthedocs.io/en/latest/), inherited unchanged from upstream Fulcrum. BCH-only extensions (DSProof, RPA, CashTokens) are not active for PLM.

---

### Platform Notes

Inherited from upstream Fulcrum: Linux needs a C++20-capable `gcc`/`clang` (`gcc-13`+ recommended); Windows requires `MinGW G++` (MSVC unsupported); macOS should work out of the box. This fork has been developed and tested on Linux.

---

### F.A.Q.

**Q:** Why does this fork exist instead of using upstream Fulcrum directly?

**A:** Upstream Fulcrum supports BCH, BTC and LTC, but has no notion of Palladium's coin-specific rules (address prefixes, SegWit activation height, coinbase maturity, difficulty schedule). This fork teaches it about PLM while reusing all of Fulcrum's existing Electrum-protocol and storage machinery.

**Q:** Is this affiliated with the Palladium Core project?

**A:** No. This is an independent fork that adds client-side (SPV server) support for PLM; it does not modify or redistribute `palladiumd` itself, which is built from its own [upstream releases](https://github.com/palladium-coin/palladiumcore) in the Docker setup.

---

### Credits

This project is a fork of [**Fulcrum**](https://fulcrumserver.org/) by **Calin A. Culianu** ([cculianu/Fulcrum](https://github.com/cculianu/Fulcrum)) — all of the core Electrum-protocol server, RocksDB storage engine, and BCH/BTC/LTC support is his work. PLM support and the Docker deployment setup were added on top of it by **Davide Grilli**. See [AUTHORS](AUTHORS) for the full breakdown.

If you are looking for the original multi-coin (BCH/BTC/LTC) server, use the upstream project linked above. For the Palladium daemon (`palladiumd`) itself, see [palladium-coin/palladiumcore](https://github.com/palladium-coin/palladiumcore).
