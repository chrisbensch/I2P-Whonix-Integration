#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ -n "${TRACE-}" ]]; then
  set -o xtrace
fi

cd "$(dirname "$0")"

main() {

# Get current i2pd release (Qubes Whonix 17)
I2PD_URL=$(wget -qO - https://api.github.com/repos/purplei2p/i2pd/releases/latest | grep 'bookworm' | grep 'amd64' | grep 'browser_download_url' | cut -d'"' -f 4)
wget $I2PD_URL

}

main "$@"
