#!/bin/bash

#cat << EOF >> /etc/anon-ws-disable-stacked-tor.d/50_user.conf
#
#I2P_PORTS="2827 3456 4444 4445 6668 7622 7650 7651 7654 7656 7658 7659 7660 7661 7662 8998 8118"
#
#for i2p_port in $I2P_PORTS ; do
#  $pre_command socat TCP-LISTEN:$i2p_port,fork,bind=127.0.0.1 TCP:$GATEWAY_IP:$i2p_port &
#done
#EOF
#
#/usr/bin/whonix_firewall

cp OmegaOptions.bak /home/user/ProxySwitchyOmegaProfile.bak