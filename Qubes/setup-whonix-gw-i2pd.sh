#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ -n "${TRACE-}" ]]; then
  set -o xtrace
fi

cd "$(dirname "$0")"

main() {

# Install i2pd
sudo apt update && sudo apt -y install i2pd
systemctl stop i2pd

# Firefox is only for testing the i2pd router console
apt-get -y --no-install-recommends install firefox-esr

# Create .i2pd skeleton for new users
cp -r /etc/i2pd /etc/skel/.i2pd

# Allow Whonix WS to communicate with the i2pd Tunnels
# You can add new ports for tunnels in the tunnels.conf file
echo "INTERNAL_OPEN_PORTS+=\" 4444 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
#echo "INTERNAL_OPEN_PORTS+=\" 4445 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 4447 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 5000 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 6667 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 6668 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 6669 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 7655 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 7656 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

# Allow i2pd user to bypass NAT
echo "NO_NAT_USERS+=\" $(id -u i2pd)\"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

# Allow Whonix GW to receive connections from i2pd tunnels
#echo "EXTERNAL_OPEN_PORTS+=\" 38473 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

# Restart the Whonix firewall and start i2pd
/usr/bin/whonix_firewall
systemctl start i2pd

}

main "$@"
