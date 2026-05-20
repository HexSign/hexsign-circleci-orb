#!/usr/bin/env bash
# Install the HexSign CLI: resolve the release, download, verify SHA-256,
# and place the binary on $PATH for subsequent steps.
#
# Reads (set as `environment` by the calling orb command):
#   HEXSIGN_PARAM_VERSION      release tag or "latest"
#   HEXSIGN_PARAM_INSTALL_DIR  install destination
#   HEXSIGN_PARAM_USE_SUDO     "true" to prefix install with sudo
set -euo pipefail

if [ "${HEXSIGN_PARAM_USE_SUDO}" = "true" ] && command -v sudo >/dev/null 2>&1; then
  SUDO="sudo"
else
  SUDO=""
fi

tag="${HEXSIGN_PARAM_VERSION}"
if [ "${tag}" = "latest" ] || [ -z "${tag}" ]; then
  tag="$(curl -fsSL -H 'Accept: application/vnd.github+json' \
    https://api.github.com/repos/hexsign/hexsign-cli/releases/latest | jq -r .tag_name)"
fi
version_no_v="${tag#v}"
echo "Installing hexsign CLI ${tag}"

case "$(uname -s)" in
  Linux)  os=linux ;;
  Darwin) os=darwin ;;
  *) echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
esac
case "$(uname -m)" in
  x86_64|amd64)   arch=amd64 ;;
  aarch64|arm64)  arch=arm64 ;;
  *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
esac

asset="hexsign_${version_no_v}_${os}_${arch}.tar.gz"
base_url="https://github.com/hexsign/hexsign-cli/releases/download/${tag}"
workdir="$(mktemp -d)"
cd "${workdir}"

curl -fsSL -o "${asset}"    "${base_url}/${asset}"
curl -fsSL -o checksums.txt "${base_url}/checksums.txt"
if command -v sha256sum >/dev/null 2>&1; then
  grep " ${asset}$" checksums.txt | sha256sum -c -
else
  grep " ${asset}$" checksums.txt | shasum -a 256 -c -
fi

tar -xzf "${asset}"
chmod +x hexsign
$SUDO install -d "${HEXSIGN_PARAM_INSTALL_DIR}"
$SUDO install -m 0755 hexsign "${HEXSIGN_PARAM_INSTALL_DIR}/hexsign"

# Make the binary discoverable in subsequent steps.
echo "export PATH=\"${HEXSIGN_PARAM_INSTALL_DIR}:\$PATH\"" >> "$BASH_ENV"
"${HEXSIGN_PARAM_INSTALL_DIR}/hexsign" --version
