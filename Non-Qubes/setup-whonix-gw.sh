#!/bin/bash




apt-get update
apt-get -y install apt-transport-https lsb-release curl

echo "deb [signed-by=/usr/share/keyrings/i2p-archive-keyring.gpg] tor+https://deb.i2p2.de/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/i2p.list

curl -o ~/i2p-archive-keyring.gpg https://geti2p.net/_static/i2p-archive-keyring.gpg
cp ~/i2p-archive-keyring.gpg /usr/share/keyrings

apt-get update
apt-get -y install i2p i2p-keyring firefox-esr
systemctl stop i2p
sleep 10

echo "INTERNAL_OPEN_PORTS+=\" 4444 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=\" 4445 \"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf
echo "NO_NAT_USERS+=\" $(id -u i2psvc)\"" >> /etc/whonix_firewall.d/30_whonix_gateway_default.conf

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

systemctl start i2p
sleep 60
systemctl stop i2p
sleep 10

# Update listening to $GATEWAYIP
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
GATEWAYIP=$(ip addr | grep 'eth1' | grep -v 'BROADCAST' | cut -d / -f 1 | awk '{print $2}')
echo "Gateway IP is: $GATEWAYIP"
for file in $(ls /var/lib/i2p/i2p-config/i2ptunnel.config.d/)
do
	sudo sed -i "s/\(.*interface=\).*/\1$GATEWAYIP/g;s/\(.*targetHost=\).*/\1$GATEWAYIP/g" "${file}"
done
IFS=$SAVEIFS
/usr/bin/whonix_firewall
systemctl start i2p

echo "Don't forget to run 'dpkg-reconfigure i2p' to adjust I2P memory and restart I2P!"

