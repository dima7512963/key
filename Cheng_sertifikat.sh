#!/bin/bash
# =====================================================

termin=$(ipsec listcerts | awk '/expires in/ {print $10}')
echo $termin

if [[ $termin -ge 5 ]]
then  
  echo "You Termin ", $termin
else
  echo "is work"
  IFACE=$(find /sys/class/net ! -type d | xargs --max-args=1 realpath  | awk -F\/ '/pci/{print $NF}')
  IP=$(ip -4 address show $IFACE | grep 'inet' | sed 's/.*inet \([0-9\.]\+\).*/\1/')
  DOMEN=$(ls /etc/letsencrypt/live/ | sed '/README/d')
  sudo ufw disable
  sleep 1
  certbot certonly --standalone --agree-tos -d $DOMEN
  sleep 10
  sudo ufw --force enable
  cp /etc/letsencrypt/live/$DOMEN/cert.pem /etc/ipsec.d/certs/
  cp /etc/letsencrypt/live/$DOMEN/privkey.pem /etc/ipsec.d/private/
  cp /etc/letsencrypt/live/$DOMEN/chain.pem /etc/ipsec.d/cacerts/
  /usr/sbin/ipsec reload
  /usr/sbin/ipsec purgecerts
  /usr/sbin/ipsec rereadall
  echo "REBOOT"

  reboot
fi
