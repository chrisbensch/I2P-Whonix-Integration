#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail
if [[ -n "${TRACE-}" ]]; then
  set -o xtrace
fi

cd "$(dirname "$0")"

main() {

# Credit for the original source commands were pieced together from these links:
# https://web.archive.org/web/20180802221447/https://github.com/mutedstorm/Whonix-I2P
# https://geti2p.net/en/download/debian#debian

# Add I2P Debian repo
echo "deb [signed-by=/usr/share/keyrings/i2p-archive-keyring.gpg] tor+https://deb.i2p2.de/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/i2p.list

curl -o ~/i2p-archive-keyring.gpg https://geti2p.net/_static/i2p-archive-keyring.gpg
cp ~/i2p-archive-keyring.gpg /usr/share/keyrings

apt-get update
# Firefox is only for making easy changes to the I2P router, delete once you're happy
apt-get -y install --no-install-recommends i2p i2p-keyring firefox-esr
# Ensure I2P is stopped before making any changes
systemctl stop i2p

# Allow Whonix WS to communicate with the I2P Router
echo "INTERNAL_OPEN_PORTS+=\" 4444 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 4445 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "NO_NAT_USERS+=\" $(id -u i2psvc)\"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

# Some smart settings for privacy and I2P reseed over Tor
cat << EOF >> /var/lib/i2p/i2p-config/router.config
stat.full=false
stat.logFile=stats.log
stat.logFilters=
stat.summaries=
i2np.upnp.enable=false
router.reseedProxy.authEnable=false
router.reseedProxyEnable=false
router.reseedSSLDisable=false
router.reseedSSLProxy.authEnable=false
router.reseedSSLProxyEnable=true
router.reseedSSLProxyHost=127.0.0.1
router.reseedSSLProxyPort=9050
router.reseedSSLProxyType=SOCKS5
router.reseedSSLRequired=false
time.disabled=true
EOF


# Fixes the gateway address before i2p splits the old config file to the tunnel configs in .d
GATEWAYIP=$(ip addr | grep 'eth1' | grep -v 'BROADCAST' | cut -d / -f 1 | awk '{print $2}')
echo "Gateway IP is: $GATEWAYIP"

sed -i "s/\(.*interface=\).*/\1$GATEWAYIP/g;s/\(.*targetHost=\).*/\1$GATEWAYIP/g" /var/lib/i2p/i2p-config/i2ptunnel.config.d/*

# Remove outproxies from both HTTP and HTTPS tunnels
sed -i '/^.*tunnel\.0\.\(proxyList\|option\.i2ptunnel\.httpclient\.SSLOutproxies\)/d' "/var/lib/i2p/i2p-config/i2ptunnel.config.d/*"
sed -i '/^.*tunnel\.5\.\(proxyList\|option\.i2ptunnel\.httpclient\.SSLOutproxies\)/d' "/var/lib/i2p/i2p-config/i2ptunnel.config.d/*"

# Add big subscription lists to Address Book
# As of this commit, there are about 6400 entries
echo "http://inr.i2p/export/alive-hosts.txt" >> /var/lib/i2p/i2p-config/addressbook/subscriptions.txt
echo "http://stats.i2p/cgi-bin/newhosts.txt" >> /var/lib/i2p/i2p-config/addressbook/subscriptions.txt
echo "http://rus.i2p/hosts.txt" >> /var/lib/i2p/i2p-config/addressbook/subscriptions.txt
echo "http://diva.i2p/hosts.txt" >> /var/lib/i2p/i2p-config/addressbook/subscriptions.txt
echo "http://reg.i2p/export/hosts-all.txt" >> /var/lib/i2p/i2p-config/addressbook/subscriptions.txt

# Restart the Whonix firewall and start I2P
/usr/bin/whonix_firewall
systemctl start i2p

}

main "$@"
