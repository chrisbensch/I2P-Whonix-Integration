#!/bin/bash

apt-get update

apt-get -y install apt-transport-https lsb-release curl

echo "deb [signed-by=/usr/share/keyrings/i2p-archive-keyring.gpg] tor+https://deb.i2p2.de/ $(lsb_release -sc) main" | sudo tee /etc/apt/sources.list.d/i2p.list

curl -o ~/i2p-archive-keyring.gpg https://geti2p.net/_static/i2p-archive-keyring.gpg

cp ~/i2p-archive-keyring.gpg /usr/share/keyrings

apt-get update

apt-get -y install i2p i2p-keyring firefox-esr
    
    
cat << EOF >> /etc/whonix_firewall.d/50_user.conf

NO_NAT_USERS+=" $(id -u i2psvc)"
SOCKS_PORT_I2P_WWW=4444
SOCKS_PORT_I2P_WWW2=4445
SOCKS_PORT_I2P_IRC=6668
SOCKS_PORT_I2P_XMPP=7622
SOCKS_PORT_I2P_CONTROL=7650
SOCKS_PORT_I2P_SOCKSIRC=7651
SOCKS_PORT_I2P_SOCKS=7652
SOCKS_PORT_I2P_I2CP=7654
SOCKS_PORT_I2P_SAM=7656
SOCKS_PORT_I2P_EEP=7658
SOCKS_PORT_I2P_SMTP=7659
SOCKS_PORT_I2P_POP=7660
SOCKS_PORT_I2P_BOTESMTP=7661
SOCKS_PORT_I2P_BOTEIMAP=7662
SOCKS_PORT_I2P_MTN=8998
EOF

echo "INTERNAL_OPEN_PORTS+=" 4444 "" >> 30_whonix_gateway_default.conf
echo "INTERNAL_OPEN_PORTS+=" 4445 "" >> 30_whonix_gateway_default.conf

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

/usr/bin/whonix_firewall


