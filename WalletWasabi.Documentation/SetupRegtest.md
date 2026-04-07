# Bitcoin Setup (RegTest)

## What is RegTest?

RegTest is a local network in which you can generate blocks and coins for testing. In this daemon-only repo, the practical local setup is `bitcoind` plus `WalletWasabi.Daemon` connected over RPC. You don't need to download the blockchain.

## Bitcoin Core Setup

1. Install Bitcoin Core from the [Official Website](https://bitcoincore.org/en/download/) or [GitHub](https://github.com/bitcoin/bitcoin/releases/) on your computer. Verify the PGP signatures. Check the security advisories [here](https://bitcoincore.org/en/security-advisories/).
2. Start Bitcoin Core with: `bitcoin-qt.exe -regtest` then select Bitcoin data directory or leave it as the default. If you use the `-datadir` parameter, make sure the directory exists.

    `-datadir` using example:

    Windows:
    ```
    "C:\Program Files\Bitcoin\bitcoin-qt.exe" -regtest -blockfilterindex -txindex -datadir=C:\Bitcoin
    ```
    macOS:
    ```
    "/Applications/Bitcoin-Qt.app/Contents/MacOS/Bitcoin-Qt" -regtest -blockfilterindex -txindex -datadir=$HOME/Library/Application Support/Bitcoin"
    ```
    Linux:
    ```
     ~/bitcoin-[version number]/bin/bitcoin-qt -regtest -blockfilterindex -txindex -datadir=$HOME/.bitcoin/
    ```

4. Go to Bitcoin data directory.

    There may be differences if you used the `-datadir` parameter before.

    Defaults:

    Windows:
    ```
    %APPDATA%\Bitcoin\
    ```
    macOS:
    ```
    $HOME/Library/Application Support/Bitcoin/
    ```
    Linux:
    ```
    $HOME/.bitcoin/
    ```
4. Edit / Create a **bitcoin.conf** file and add these lines:
    ```C#
    regtest.server = 1
    regtest.listen = 1
    regtest.txindex = 1
    regtest.whitebind = 127.0.0.1:18444
    regtest.rpchost = 127.0.0.1
    regtest.rpcport = 18443
    regtest.rpcuser = rpcuser
    regtest.rpcpassword = rpcpassword
    regtest.disablewallet = 0
    regtest.softwareexpiry = 0
    regtest.listenonion = 0
    regtest.blockfilterindex = 1
    ```
5. Save it.
6. Close Bitcoin Core to confirm changes and open it again with: `bitcoin-qt.exe -regtest`.
7. Do not worry about "Syncing Headers" just press the Hide button. Because you run on Regtest, no Mainnet blocks will be downloaded.
8. Go to menu *File / Create* and create a wallet with the name you prefer. Use the default options.
9. Go to menu *Window / Console*.
10. Generate a new address with:
`getnewaddress`
11. Generate the first 101 blocks with:
`generatetoaddress 101 <replace_new_address_here>`
12. Now you have your own Bitcoin blockchain. You can create transactions with the Send button and confirm with creating a new block:
`generatetoaddress 1 <replace_new_address_here>`

You can force rebuilding the txindex with the `-reindex` command line argument. Bitcoin Core needs to be running during the next steps.

# abw daemon setup

Build from source using the repo `README.md`, then run the daemon against your local regtest node:

```bash
dotnet run --project WalletWasabi.Daemon -- \
  --network=regtest \
  --usetor=disabled \
  --jsonrpcserverenabled=true \
  --bitcoinrpcuri=http://127.0.0.1:18443/ \
  --bitcoinrpccredentialstring=rpcuser:rpcpassword
```

Notes:

- this repo no longer ships separate backend, coordinator, or desktop GUI projects
- local regtest wallet and RPC testing still work with the daemon
- full local coinjoin/coordinator integration now requires extra external setup beyond this repo
