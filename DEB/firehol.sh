#!/bin/bash eu

# DISABLE POTENTIAL FIREWALL
systemctl disable pve-firewall ufw
systemctl stop pve-firewall ufw

# INSTALL
apt install -y --no-install-recommends firehol firehol-tools

echo -e "
version 6

ENABLE_IPV6=0
FIREHOL_LOG_MODE="NFLOG"

### INTERFACES
WAN=""
LAN=""
ZT=""

lan_ips="172.16.1.0/24"
zt_ips="172.24.0.0/16"

### IPSET
# dshield
ipv4 ipset create dshield hash:ip
ipv4 ipset addfile dshield /etc/firehol/ipsets/dshield.netset
ipv4 blacklist full ipset:dshield

# spamhaus_drop
#ipv4 ipset create spamhaus_drop hash:ip
#ipv4 ipset addfile spamhaus_drop /etc/firehol/ipsets/spamhaus_drop.netset
#ipv4 blacklist full ipset:spamhaus_drop
# spamhaus_edrop
#ipv4 ipset create spamhaus_edrop hash:ip
#ipv4 ipset addfile spamhaus_edrop /etc/firehol/ipsets/spamhaus_edrop.netset
#ipv4 blacklist full ipset:spamhaus_edrop

# feodo
ipv4 ipset create feodo hash:ip
ipv4 ipset addfile feodo /etc/firehol/ipsets/feodo.ipset
ipv4 blacklist full ipset:feodo

# palevo
ipv4 ipset create palevo hash:ip
ipv4 ipset addfile palevo /etc/firehol/ipsets/palevo.ipset
ipv4 blacklist full ipset:palevo

# sslbl
ipv4 ipset create sslbl hash:ip
ipv4 ipset addfile sslbl /etc/firehol/ipsets/sslbl.ipset
ipv4 blacklist full ipset:sslbl

### FAIL2BAN
#ipv4 ipset create f2b hash:ip
#blacklist4 full ipset:f2b
#postprocess -warn /usr/bin/fail2ban-client reload || return 1

### INTERFACES
interface4 "${LAN}" lan src "${lan_ips}"
        policy reject
        server "http https ssh icmp" accept
        client "icmp" accept

interface4 "${ZT}" zt src "${zt_ips}"
        policy reject
        server "ssh icmp" accept
        server custom pveweb tcp/8006 default accept
        client "icmp" accept

interface4 "${WAN}" net src not "${lxc_ips} ${zt_ips} ${RESERVED_IPS} ${MULTICAST_IPS}"
        protection strong 10/sec 10
        server "http https" accept
        server ident reject with tcp-reset
        client all accept

### ROUTE
router4 net2lxc inface "${WAN}" outface "${LAN}"
        masquerade reverse
        client all accept
        server ident reject with tcp-reset
" > /etc/firehol/firehol.conf

sed -i s"|^START_FIREHOL=NO|START_FIREHOL=YES|g" /etc/default/firehol

update-ipsets enable dshield spamhaus_drop spamhaus_edrop feodo palevo sslbl
update-ipsets

firehol start
