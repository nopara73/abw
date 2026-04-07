# Guide for deterministic builds

This guide describes how to reproduce daemon release artifacts for `abw`.

## 1. Prepare the environment

You need:

- `git`
- the exact `.NET 10` SDK version pinned by `global.json`
- a clean checkout of the repo
- `zip`, `tar`, and `dpkg-deb` if you want to reproduce every artifact produced by `Contrib/release.sh`

## 2. Build the daemon release artifacts

Use a tagged checkout so the generated package version matches the release:

```sh
git clone --depth 1 --branch <git-tag> https://github.com/nopara73/abw.git
cd abw
dotnet nuget locals all --clear
./Contrib/release.sh debian
```

This produces daemon-only artifacts under `packages/`, including:

- `abw-daemon-<version>-win-x64.zip`
- `abw-daemon-<version>-macOS-x64.zip`
- `abw-daemon-<version>-macOS-arm64.zip`
- `abw-daemon-<version>-linux-x64.zip`
- `abw-daemon-<version>-linux-x64.tar.gz`
- `abw-daemon-<version>-linux-arm64.zip`
- `abw-daemon-<version>-linux-arm64.tar.gz`
- `abw-daemon-<version>.deb`
- `abw-daemon-<version>-arm64.deb`

## 3. Verify the artifacts

The simplest verification is to rebuild from the same tag in a second clean environment and compare the generated files:

```sh
sha256sum packages/*
```

For archive-level inspection, unpack the generated artifact and compare its contents to another clean rebuild:

```sh
tar -pxzf packages/abw-daemon-<version>-linux-x64.tar.gz
git diff --no-index abw-daemon build/linux-x64
```

On Debian-based systems you can also inspect the package payload directly:

```sh
dpkg-deb -x packages/abw-daemon-<version>.deb extracted
git diff --no-index extracted/usr/local/lib/abw-daemon build/linux-x64
```
