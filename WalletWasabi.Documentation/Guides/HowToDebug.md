# Developers' Guide for debugging abw

This repository is daemon-only. The main debugging target is `WalletWasabi.Daemon`, optionally connected to a local Bitcoin Core node over RPC.

## Before starting

Before debugging:

- read the repo `README.md`
- install the `.NET 10` SDK
- make sure `dotnet build WalletWasabi.Daemon/WalletWasabi.Daemon.csproj` succeeds once

## Debugging from the terminal

The fastest way to start is:

```sh
dotnet run --project WalletWasabi.Daemon -- --help
```

A typical local RPC or regtest session looks like this:

```sh
dotnet run --project WalletWasabi.Daemon -- \
  --network=regtest \
  --usetor=disabled \
  --jsonrpcserverenabled=true \
  --bitcoinrpcuri=http://127.0.0.1:18443/ \
  --bitcoinrpccredentialstring=rpcuser:rpcpassword
```

## VS Code launch configuration

Example `launch.json` entry:

```json
{
  "name": "abw daemon",
  "type": "coreclr",
  "request": "launch",
  "preLaunchTask": "build-daemon",
  "program": "${workspaceFolder}/WalletWasabi.Daemon/bin/Debug/net10.0/WalletWasabi.Daemon.dll",
  "args": [
    "--network=regtest",
    "--usetor=disabled",
    "--jsonrpcserverenabled=true"
  ],
  "cwd": "${workspaceFolder}/WalletWasabi.Daemon",
  "stopAtEntry": false,
  "console": "internalConsole"
}
```

Example `tasks.json` entry:

```json
{
  "label": "build-daemon",
  "command": "dotnet",
  "type": "process",
  "args": [
    "build",
    "${workspaceFolder}/WalletWasabi.Daemon/WalletWasabi.Daemon.csproj"
  ],
  "problemMatcher": "$msCompile"
}
```

## Debugging with tests

The daemon-only repo still keeps a reduced test suite. A focused smoke run is usually the best starting point:

```sh
dotnet test WalletWasabi.Tests/WalletWasabi.Tests.csproj --filter "FullyQualifiedName~PersistentConfigManagerTests|FullyQualifiedName~SingleInstanceCheckerTests"
```

## Useful companion processes

For realistic debugging sessions you will often also want:

- `bitcoind` on `regtest`
- the local scripts under `Contrib/CLI`
- daemon logs and JSON-RPC calls side by side in separate terminals
