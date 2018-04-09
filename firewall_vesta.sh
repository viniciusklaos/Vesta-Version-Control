v-add-sys-firewall

v-list-firewall | grep , | awk '{print $4}' | sed "s/,/\n/g" | sed "s/-/\n/g" > ports.info
v-list-firewall | grep , | awk '{print $1}' > records.info
v-list-firewall | grep 25251 | awk '{print $1}' >> records.info

for RECORD in `cat records.info`; do
	v-delete-firewall-rule $RECORD;
done;

for PORT in `cat ports.info`; do
	v-add-firewall-rule ACCEPT 0.0.0.0/0 $PORT TCP;
done;

v-add-firewall-rule ACCEPT 127.0.0.1 25251 TCP PMTA
v-add-firewall-rule DROP 0.0.0.0/0 25251 TCP NO-INVADE
v-add-firewall-rule ACCEPT 0.0.0.0/0 2294 TCP PMTAWEB

sed -i '/multiport/d' /etc/sysconfig/iptables

/etc/init.d/iptables restart
/etc/init.d/iptables save

rm -f ports.info dports.info records.info