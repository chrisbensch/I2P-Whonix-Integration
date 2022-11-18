#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ -n "${TRACE-}" ]]; then
  set -o xtrace
fi

cd "$(dirname "$0")"

main() {

# Install i2pd Debian
wget -qO /tmp/i2pd.deb https://github.com/PurpleI2P/i2pd/releases/download/2.43.0/i2pd_2.43.0-1bullseye1_amd64.deb
apt -y install /tmp/i2pd.deb
systemctl stop i2pd

apt-get update
# Firefox is only for testing the i2pd router, delete once you're happy
apt-get -y --no-install-recommends install firefox-esr

# These are preconfigured for some basic things, you should customize your own
cp i2pd.conf /etc/i2pd/
cp tunnels.conf /etc/i2pd/

# Allow Whonix WS to communicate with the i2pd Tunnels
# You can add new ports for tunnels in the tunnels.conf file
echo "INTERNAL_OPEN_PORTS+=\" 4444 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 4445 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 6668 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 6669 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "NO_NAT_USERS+=\" $(id -u i2pd)\"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

# Restart the Whonix firewall and start i2pd
/usr/bin/whonix_firewall
systemctl start i2pd

}

main "$@"
