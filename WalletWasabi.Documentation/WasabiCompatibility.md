# Abstract

This document lists the target environments for the daemon-only `abw` repository. It does not promise desktop UI support or installer support. The focus here is the daemon runtime, its Bitcoin/Tor dependencies, and command-line or RPC-based usage.

# Target Operating Systems

- Windows 10 1607+
- Windows 11 23H2+
- macOS 14+
- Ubuntu 22.04+
- Fedora 42+
- Debian 12+

# Hardware Wallet Compatibility

- **Trezor**: Model T, Safe 3, Safe 5
- **ColdCard**: MK1, MK2, MK3, MK4, Q
- **Ledger**: Nano S, Nano S Plus, Nano X
- **Blockstream**: Jade
- **BitBox**: BitBox02-BtcOnly<sup>1*</sup>

<sup><sup>1*</sup> The device by default asks for a "Pairing code". There is currently no such function in `abw`, so either disable the feature or unlock the device with BitBoxApp or `hwi-qt` before using it.</sup>

# Target Architectures

- x64 (Windows, Linux, macOS)
- arm64 (macOS, Linux (experimental))

# FAQ

## What is required to run `abw` on the target operating systems?

`abw` dependencies are:
- .NET 10.0 [reqs](https://github.com/dotnet/core/blob/main/release-notes/10.0/supported-os.md).
- Tor and Bitcoin Core or a compatible Bitcoin RPC endpoint.

## What are the bottlenecks of supporting hardware wallets?

`abw` depends on:
- [HWI](https://github.com/bitcoin-core/HWI), check the [device support](https://github.com/bitcoin-core/HWI#device-support) list there. Some hardware wallets supported by HWI are still not compatible because they implemented custom workflows.

## What about Tails and Whonix?

Tails and Whonix are privacy-oriented OSs, so it makes sense to use them with `abw`. At the moment, `abw` may work properly on these platforms, but our dependencies do not officially support them, so we cannot make promises regarding future stability.
To make `abw` work on these OSs, start it with: `--UseTor=EnabledOnlyRunning`.
