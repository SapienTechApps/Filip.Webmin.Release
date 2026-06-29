#!/usr/bin/env bash
set -euo pipefail

VERSION="${FILIP_WEBMIN_VERSION:-v0.1.0}"
REPO="SapienTechApps/Filip.Webmin.Release"
BASE_URL="https://github.com/${REPO}/releases/download/${VERSION}"
BINARY_ASSET="filip-webmin-linux-x86_64"
CHECKSUM_ASSET="filip-webmin-linux-x86_64.sha256"
OUTPUT_NAME="${FILIP_WEBMIN_OUTPUT:-filip-webmin}"
INSTALL_DIR="${FILIP_WEBMIN_INSTALL_DIR:-.}"

usage() {
  cat <<USAGE
Filip.Webmin release downloader

Usage:
  ./install-filip-webmin.sh [--version v0.1.0] [--install-dir DIR] [--output NAME]

Environment overrides:
  FILIP_WEBMIN_VERSION      Release tag, default: v0.1.0
  FILIP_WEBMIN_INSTALL_DIR  Output directory, default: current directory
  FILIP_WEBMIN_OUTPUT       Output binary name, default: filip-webmin

This script downloads the Filip.Webmin helper binary and checksum from the
public release repository, verifies the checksum, and writes an executable
binary. It does not configure the Webmin repository and does not install Webmin.
USAGE
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --version)
      VERSION="${2:?missing value for --version}"
      shift 2
      ;;
    --install-dir)
      INSTALL_DIR="${2:?missing value for --install-dir}"
      shift 2
      ;;
    --output|--name)
      OUTPUT_NAME="${2:?missing value for --output}"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

require_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "Required command not found: $1" >&2
    exit 1
  fi
}

require_cmd curl
require_cmd sha256sum
require_cmd chmod
require_cmd mktemp
require_cmd cp
require_cmd mkdir

mkdir -p "$INSTALL_DIR"
TMP_DIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

printf 'Downloading Filip.Webmin %s from %s\n' "$VERSION" "$REPO"

curl -fL -o "$TMP_DIR/$BINARY_ASSET" "$BASE_URL/$BINARY_ASSET"
curl -fL -o "$TMP_DIR/$CHECKSUM_ASSET" "$BASE_URL/$CHECKSUM_ASSET"

(
  cd "$TMP_DIR"
  sha256sum -c "$CHECKSUM_ASSET"
)

cp "$TMP_DIR/$BINARY_ASSET" "$INSTALL_DIR/$OUTPUT_NAME"
chmod +x "$INSTALL_DIR/$OUTPUT_NAME"

printf '\nInstalled helper binary: %s/%s\n' "$INSTALL_DIR" "$OUTPUT_NAME"
"$INSTALL_DIR/$OUTPUT_NAME" --version

cat <<NEXT_STEPS

Next steps on the target server:
  cd "$INSTALL_DIR"
  ./$OUTPUT_NAME
  ./$OUTPUT_NAME --export filip-webmin-before-install.md

If the precheck is OK and you approve host mutation:
  sudo ./$OUTPUT_NAME --setup-webmin-repo --i-understand-this-mutates-system --confirm-webmin-repo-setup
  sudo ./$OUTPUT_NAME --install --i-understand-this-mutates-system --confirm-install-webmin
  ./$OUTPUT_NAME
NEXT_STEPS
