### bitcoin wallet for agents. open-source. non-custodial. privacy-focused.

  


# abw - "agentic bitcoin wallet"

  


# build from source code

### get the requirements

1. get git: [https://git-scm.com/downloads](https://git-scm.com/downloads)
2. get .NET 10.0 SDK: [https://dotnet.microsoft.com/download](https://dotnet.microsoft.com/download)
3. optionally disable .NET's telemetry by executing in the terminal `export DOTNET_CLI_TELEMETRY_OPTOUT=1` on Linux and macOS or `setx DOTNET_CLI_TELEMETRY_OPTOUT 1` on Windows.

### get abw

clone, restore, build

```sh
git clone --depth=1 --single-branch --branch=master https://github.com/nopara73/abw.git
cd abw/WalletWasabi.Daemon
dotnet build
```

### update abw

```sh
git pull
```

