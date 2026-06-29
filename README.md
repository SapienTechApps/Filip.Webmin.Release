# Filip.Webmin public release

This public repository contains release downloads for **Filip.Webmin**, a controlled Webmin installer helper for Ubuntu/Debian-family servers.

The source repository is private. This repository is only for public release artifacts, checksum files, and a small download helper script.

## Current release

- Version: `v0.1.0`
- Binary: `filip-webmin-linux-x86_64`
- Supported target tested so far: Ubuntu Server 24.04 LTS on x86_64

## Quick install of the helper binary

On the target Ubuntu server:

```bash
mkdir -p ~/filip-webmin-release
cd ~/filip-webmin-release
curl -fL -O https://raw.githubusercontent.com/SapienTechApps/Filip.Webmin.Release/main/install-filip-webmin.sh
chmod +x install-filip-webmin.sh
./install-filip-webmin.sh
./filip-webmin --version
```

The script downloads the release binary and `.sha256` file from this repository's GitHub Release, verifies the checksum, and writes `./filip-webmin` in the current directory.

## Manual download

```bash
mkdir -p ~/filip-webmin-release
cd ~/filip-webmin-release

curl -fL -O https://github.com/SapienTechApps/Filip.Webmin.Release/releases/download/v0.1.0/filip-webmin-linux-x86_64
curl -fL -O https://github.com/SapienTechApps/Filip.Webmin.Release/releases/download/v0.1.0/filip-webmin-linux-x86_64.sha256

sha256sum -c filip-webmin-linux-x86_64.sha256
cp filip-webmin-linux-x86_64 filip-webmin
chmod +x filip-webmin
./filip-webmin --version
```

## Standard Webmin install flow

Run precheck first:

```bash
./filip-webmin
./filip-webmin --export filip-webmin-before-install.md
```

Configure the Webmin APT repository:

```bash
sudo ./filip-webmin --setup-webmin-repo --i-understand-this-mutates-system --confirm-webmin-repo-setup
```

Install Webmin:

```bash
sudo ./filip-webmin --install --i-understand-this-mutates-system --confirm-install-webmin
```

Verify after install:

```bash
./filip-webmin
./filip-webmin --export filip-webmin-after-install.md
```

Open Webmin:

```text
https://SERVER_IP:10000/
```

## Safety notes

- Do not pipe this script into a shell. Download it, inspect it, then run it.
- Filip.Webmin is not a generic shell runner.
- Mutating actions require explicit confirmation flags.
- Webmin should be reachable only from a management network or VPN.
- Do not expose port `10000/tcp` directly to the public internet without a separate security design.

## Documentation

See:

```text
docs/IT_dokumentacia_Filip_Webmin_Ubuntu24_manual.md
```
