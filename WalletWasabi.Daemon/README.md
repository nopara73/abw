abw daemon
==========

abw daemon is a _headless_ bitcoin wallet for agents designed to minimize resource usage (CPU, GPU, memory, bandwidth) so it can run continuously in the background.

## Configuration

All configuration options available via `Config.json` file are also available as command line arguments and environment variables:

### Command Line and Environment variables

* Command line switches have the form `--switch_name=value` where _switch_name_ is the same name that is used in the config file (case insensitive).
* Environment variables have the form `WASABI_SWITCHNAME` where _SWITCHNAME_ is the same name that is used in the config file.

A few examples:

| Config file                | Command line                | Environment variable             |
|----------------------------|-----------------------------|----------------------------------|
| Network: "TestNet"         | --network=testnet           | WASABI_NETWORK=testnet           |
| JsonRpcServerEnabled: true | --jsonrpcserverenabled=true | WASABI_JSONRPCSERVERENABLED=true |
| UseTor: true               | --usetor=true               | WASABI_USETOR=true               |
| DustThreshold: "0.00005"   | --dustthreshold=0.00005     | WASABI_DUSTTHRESHOLD=0.00005     |

### Values precedence

* **Values passed by command line arguments** have the highest precedence and override values in environment variables and those specified in config files.
* **Values stored in environment variables** have higher precedence than those in config file and lower precedence than the ones pass by command line.
* **Values stored in config file** have the lower precedence.

### Special values

There are a few special switches that are not present in the `Config.json` file and are only available using command line and/or variable environment:

* **LogLevel** to specify the level of detail used during logging
* **DataDir** to specify the path to the directory used during runtime.
* **BlockOnly** to instruct abw to ignore p2p transactions
* **Wallet** to instruct abw to open a wallet automatically after startup.

### Examples

Run `abw daemon` on testnet with Tor disabled and JSON RPC enabled. Store everything in `$HOME/temp/abw-1`.

```bash
$ dotnet run -- --usetor=false --datadir="$HOME/temp/abw-1" --network=testnet --jsonrpcserverenabled=true --blockonly=true
```

Run `abw daemon` and connect to the testnet Bitcoin network.

```bash
$ WASABI_NETWORK=testnet dotnet run --
```

Run `abw daemon` and open two wallets: `AliceWallet` and `BobWallet`.

```bash
$ dotnet run -- --wallet=AliceWallet --wallet=BobWallet
```

### Version

```bash
$ dotnet run -- --version
abw daemon 2.0.3.0
```

### Usage

To interact with the daemon, use the JSON-RPC server or the local [`Contrib/CLI`](../Contrib/CLI/README.md) helper scripts.
