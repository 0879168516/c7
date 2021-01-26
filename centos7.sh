#!/bin/bash
# Created By M Fauzan Romandhoni (+6281311310405) (m.fauzan58@yahoo.com)

clear

#Requirement
if [ ! -e /usr/bin/curl ]; then
   yum -y update && yum -y upgrade
   yum -y install curl
fi

# install wget curl nano
yum -y install wget curl
yum -y install nano

# initializing var
OS=`uname -m`;
MYIP=$(curl -4 icanhazip.com)
if [ $MYIP = "" ]; then
   MYIP=`ifconfig | grep 'inet addr:' | grep -v inet6 | grep -vE '127\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' | cut -d: -f2 | awk '{ print $1}' | head -1`;
fi
MYIP2="s/xxxxxxxxx/$MYIP/g";

# go to root
cd

#vps="zvur";
vps="aneka";

#if [[ $vps = "zvur" ]]; then
	#source="http://"
#else
	source="https://cloudip.org/sshinjector.net/cent6"
#fi

wget http://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
rpm -ivh epel-release-latest-7.noarch.rpm

wget https://rpms.remirepo.net/enterprise/remi-release-7.rpm
rpm -ivh remi-release-7.rpm

# setting repo
rpm -Uvh http://dl.fedoraproject.org/pub/epel/7/x86_64/Packages/e/epel-release-7-11.noarch.rpm
rpm -Uvh http://rpms.famillecollet.com/enterprise/remi-release-7.rpm
rpm -Uvh https://raw.githubusercontent.com/daybreakersx/premscript/master/rpmforge-release-0.5.3-1.el7.rf.x86_64.rpm


sed -i -e "/^\[remi\]/,/^\[.*\]/ s|^\(enabled[ \t]*=[ \t]*0\\)|enabled=1|" /etc/yum.repos.d/remi.repo
rm -f *.rpm

# remove unused

yum -y remove sendmail;
yum -y remove httpd;
yum -y remove cyrus-sasl

# install webserver
yum -y install nginx php-fpm php-cli
systemctl restart nginx
systemctl restart php-fpm
systemctl enable nginx
systemctl enable php-fpm

# install essential package
yum -y install rrdtool screen iftop htop nmap bc nethogs vnstat ngrep mtr git zsh mrtg unrar rsyslog rkhunter mrtg net-snmp net-snmp-utils expect nano bind-utils
yum -y groupinstall 'Development Tools'
yum -y install cmake

yum -y --enablerepo=rpmforge install axel sslh ptunnel unrar

# disable exim
systemctl stop exim
systemctl disable exim

# setting vnstat
vnstat -u -i venet0
echo "MAILTO=root" > /etc/cron.d/vnstat
echo "*/5 * * * * root /usr/sbin/vnstat.cron" >> /etc/cron.d/vnstat
sed -i 's/eth0/venet0/g' /etc/sysconfig/vnstat
systemctl restart vnstat
systemctl enable vnstat

# Instal (D)DoS Deflate
if [ -d '/usr/local/ddos' ]; then
	echo; echo; echo "Please un-install the previous version first"
	exit 0
else
	mkdir /usr/local/ddos
fi
clear
echo; echo 'Installing DOS-Deflate 0.6'; echo
echo; echo -n 'Downloading source files...'
wget -q -O /usr/local/ddos/ddos.conf $source/ddos.conf
echo -n '.'
wget -q -O /usr/local/ddos/LICENSE $source/LICENSE
echo -n '.'
wget -q -O /usr/local/ddos/ignore.ip.list $source/ignore.ip.list
echo -n '.'
wget -q -O /usr/local/ddos/ddos.sh $source/ddos.sh
chmod 0755 /usr/local/ddos/ddos.sh
cp -s /usr/local/ddos/ddos.sh /usr/local/sbin/ddos
echo '...done'
echo; echo -n 'Creating cron to run script every minute.....(Default setting)'
/usr/local/ddos/ddos.sh --cron > /dev/null 2>&1
echo '.....done'
echo; echo 'Installation has completed.'
echo 'Config file is at /usr/local/ddos/ddos.conf'
echo 'Please send in your comments and/or suggestions to zaf@vsnl.com'
rm -rf /root/master.zip

# install fail2ban
yum -y install fail2ban
service fail2ban restart
chkconfig fail2ban on

# install screenfetch
cd
wget $source/screenfetch-dev
mv screenfetch-dev /usr/bin/screenfetch
chmod +x /usr/bin/screenfetch

# install text warna
cd
rm -rf .bashrc
cd
rm -rf /root/.bashrc
wget -O /root/.bashrc "$source/bash.sh"

# install webserver
cd
wget -O /etc/nginx/nginx.conf "https://raw.githubusercontent.com/Urabephc/Autoscript/master/Centos7/nginx.conf"
sed -i 's/www-data/nginx/g' /etc/nginx/nginx.conf
mkdir -p /home/vps/public_html
echo "<pre>Setup by urabe</pre>" > /home/vps/public_html/index.html
echo "<?php phpinfo(); ?>" > /home/vps/public_html/info.php
rm /etc/nginx/conf.d/*
wget -O /etc/nginx/conf.d/vps.conf "https://raw.githubusercontent.com/Urabephc/Autoscript/master/Centos7/vps.conf"
sed -i 's/apache/nginx/g' /etc/php-fpm.d/www.conf
chmod -R +rx /home/vps
systemctl restart php-fpm
systemctl restart nginx

#install OpenVPN
yum install -y openvpn
cp -r /usr/share/easy-rsa/ /etc/openvpn
mkdir /etc/openvpn/easy-rsa/keys

# replace bits
sed -i 's|export KEY_COUNTRY="US"|export KEY_COUNTRY="ID"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_PROVINCE="CA"|export KEY_PROVINCE="Jawa Tengah"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_CITY="SanFrancisco"|export KEY_CITY="Blora"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_ORG="Fort-Funston"|export KEY_ORG="Sshinjector.net"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_EMAIL="me@myhost.mydomain"|export KEY_EMAIL="cs@sshinjector.net"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU="MyOrganizationalUnit"|export KEY_OU="Free Premium SSH dan VPN SSL/TLS Service"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_NAME="EasyRSA"|export KEY_NAME="Sshinjector.net"|' /etc/openvpn/easy-rsa/vars
sed -i 's|export KEY_OU=changeme|export KEY_OU=server|' /etc/openvpn/easy-rsa/vars
#Create Diffie-Helman Pem
openssl dhparam -out /etc/openvpn/dh2048.pem 2048
# Create PKI
cd /etc/openvpn/easy-rsa
cp openssl-1.0.0.cnf openssl.cnf
. ./vars
./clean-all
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --initca $*
# create key server
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" --server server
# setting KEY CN
export EASY_RSA="${EASY_RSA:-.}"
"$EASY_RSA/pkitool" client
cd
#cp /etc/openvpn/easy-rsa/keys/{server.crt,server.key} /etc/openvpn
cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/server.crt
cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/server.key
cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/ca.crt
chmod +x /etc/openvpn/ca.crt

# Setting Server
tar -xzvf /root/plugin.tgz -C /usr/lib/openvpn/
chmod +x /usr/lib/openvpn/*
cat > /etc/openvpn/server.conf <<-END
port 1194
proto tcp
dev tun
ca ca.crt
cert server.crt
key server.key
dh dh2048.pem
verify-client-cert none
username-as-common-name
plugin /usr/lib/openvpn/plugins/openvpn-plugin-auth-pam.so login
server 192.168.10.0 255.255.255.0
ifconfig-pool-persist ipp.txt
push "redirect-gateway def1 bypass-dhcp"
push "dhcp-option DNS 8.8.8.8"
push "dhcp-option DNS 8.8.4.4"
push "route-method exe"
push "route-delay 2"
socket-flags TCP_NODELAY
push "socket-flags TCP_NODELAY"
keepalive 10 120
comp-lzo
user nobody
group nogroup
persist-key
persist-tun
status openvpn-status.log
log openvpn.log
verb 3
ncp-disable
cipher none
auth none
END
systemctl start openvpn@server
#Create OpenVPN Config
mkdir -p /home/vps/public_html
cat > /home/vps/public_html/client.ovpn <<-END
# Created by urabe
auth-user-pass
client
dev tun
proto tcp
remote $MYIP 1194
persist-key
persist-tun
pull
resolv-retry infinite
nobind
user nobody
comp-lzo
remote-cert-tls server
verb 3
mute 2
connect-retry 5 5
connect-retry-max 8080
mute-replay-warnings
redirect-gateway def1
script-security 2
cipher none
auth none
END
echo '<ca>' >> /home/vps/public_html/client.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/client.ovpn
echo '</ca>' >> /home/vps/public_html/client.ovpn

cat > /home/vps/public_html/OpenVPN-Stunnel.ovpn <<-END
# Created by urabe
auth-user-pass
client
dev tun
proto tcp
remote 127.0.0.1 1194
route $MYIP 255.255.255.255 net_gateway
persist-key
persist-tun
pull
resolv-retry infinite
nobind
user nobody
comp-lzo
remote-cert-tls server
verb 3
mute 2
connect-retry 5 5
connect-retry-max 8080
mute-replay-warnings
redirect-gateway def1
script-security 2
cipher none
auth none
END
echo '<ca>' >> /home/vps/public_html/OpenVPN-Stunnel.ovpn
cat /etc/openvpn/ca.crt >> /home/vps/public_html/OpenVPN-Stunnel.ovpn
echo '</ca>' >> /home/vps/public_html/OpenVPN-Stunnel.ovpn

cat > /home/vps/public_html/stunnel.conf <<-END
client = yes
debug = 6
[openvpn]
accept = 127.0.0.1:1194
connect = $MYIP:587
TIMEOUTclose = 0
verify = 0
sni = m.facebook.com
END

# Configure Stunnel
sed -i 's/ENABLED=0/ENABLED=1/g' /etc/default/stunnel4
openssl req -new -newkey rsa:2048 -days 3650 -nodes -x509 -sha256 -subj '/CN=127.0.0.1/O=localhost/C=ID' -keyout /etc/stunnel/stunnel.pem -out /etc/stunnel/stunnel.pem
cat > /etc/stunnel/stunnel.conf <<-END
sslVersion = all
pid = /stunnel.pid
socket = l:TCP_NODELAY=1
socket = r:TCP_NODELAY=1
client = no
[openvpn]
accept = 587
connect = 127.0.0.1:1194
cert = /etc/stunnel/stunnel.pem
[dropbear]
accept = 443
connect = 127.0.0.1:442
cert = /etc/stunnel/stunnel.pem
END

#Setting UFW
ufw allow ssh
ufw allow 1194/tcp
sed -i 's|DEFAULT_INPUT_POLICY="DROP"|DEFAULT_INPUT_POLICY="ACCEPT"|' /etc/default/ufw
sed -i 's|DEFAULT_FORWARD_POLICY="DROP"|DEFAULT_FORWARD_POLICY="ACCEPT"|' /etc/default/ufw

# set ipv4 forward
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's|#net.ipv4.ip_forward=1|net.ipv4.ip_forward=1|' /etc/sysctl.conf

#Setting IPtables
cat > /etc/iptables.up.rules <<-END
*nat
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
-A POSTROUTING -j SNAT --to-source xxxxxxxxx
-A POSTROUTING -o eth0 -j MASQUERADE
-A POSTROUTING -s 192.168.10.0/24 -o eth0 -j MASQUERADE
COMMIT
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:fail2ban-ssh - [0:0]
-A INPUT -p tcp -m multiport --dports 22 -j fail2ban-ssh
-A INPUT -p ICMP --icmp-type 8 -j ACCEPT
-A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
-A INPUT -p tcp --dport 22  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 80  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 143  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 442  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 443  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 587  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 1194  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 1194  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 3128  -m state --state NEW -j ACCEPT
-A INPUT -p tcp --dport 8080  -m state --state NEW -j ACCEPT
-A INPUT -p udp --dport 8080  -m state --state NEW -j ACCEPT 
-A INPUT -p tcp --dport 10000  -m state --state NEW -j ACCEPT
-A fail2ban-ssh -j RETURN
COMMIT
*raw
:PREROUTING ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
COMMIT
*mangle
:PREROUTING ACCEPT [0:0]
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:POSTROUTING ACCEPT [0:0]
COMMIT
END
sed -i $MYIP2 /etc/iptables.up.rules;
iptables-restore < /etc/iptables.up.rules

# Create and Configure rc.local
cat > /etc/rc.local <<-END
#!/bin/sh -e
exit 0
END
chmod +x /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.8.8" > /etc/resolv.conf' /etc/rc.local
sed -i '$ i\echo "nameserver 8.8.4.4" >> /etc/resolv.conf' /etc/rc.local
sed -i '$ i\iptables-restore < /etc/iptables.up.rules' /etc/rc.local

# compress configs
cd /home/vps/public_html
zip configs.zip client.ovpn OpenVPN-Stunnel.ovpn stunnel.conf

# install badvpn
cd
wget -O /usr/bin/badvpn-udpgw "$source/badvpn-udpgw"
if [ "$OS" == "x86_64" ]; then
  wget -O /usr/bin/badvpn-udpgw "$source/badvpn-udpgw64"
fi
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7000' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500' /etc/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7000' /etc/rc.d/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100' /etc/rc.d/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200' /etc/rc.d/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300' /etc/rc.d/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400' /etc/rc.d/rc.local
sed -i '$ i\screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500' /etc/rc.d/rc.local
chmod +x /usr/bin/badvpn-udpgw
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7000
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7100
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7200
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7300
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7400
screen -AmdS badvpn badvpn-udpgw --listen-addr 127.0.0.1:7500


# install mrtg
cd /etc/snmp/
wget -O /etc/snmp/snmpd.conf "$source/snmpd.conf"
wget -O /root/mrtg-mem.sh "$source/mrtg-mem.sh"
chmod +x /root/mrtg-mem.sh
systemctl restart snmpd
systemctl enable snmpd
snmpwalk -v 1 -c public localhost | tail
mkdir -p /home/vps/public_html/mrtg
cfgmaker --zero-speed 100000000 --global 'WorkDir: /home/vps/public_html/mrtg' --output /etc/mrtg/mrtg.cfg public@localhost
curl "https://raw.githubusercontent.com/Urabephc/Autoscript/master/Centos7/mrtg.conf" >> /etc/mrtg/mrtg.cfg
sed -i 's/WorkDir: \/var\/www\/mrtg/# WorkDir: \/var\/www\/mrtg/g' /etc/mrtg/mrtg.cfg
sed -i 's/# Options\[_\]: growright, bits/Options\[_\]: growright/g' /etc/mrtg/mrtg.cfg
indexmaker --output=/home/vps/public_html/mrtg/index.html /etc/mrtg/mrtg.cfg
echo "0-59/5 * * * * root env LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg" > /etc/cron.d/mrtg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
LANG=C /usr/bin/mrtg /etc/mrtg/mrtg.cfg
cd

# setting port ssh
sed -i '/Port 22/a Port 444' /etc/ssh/sshd_config
sed -i '/Port 22/a Port  90' /etc/ssh/sshd_config
sed -i '/Port 444/a Banner bannerssh' /etc/ssh/sshd_config
sed -i 's/#Port 22/Port  22/g' /etc/ssh/sshd_config
systemctl restart sshd
systemctl enable sshd

# install dropbear
yum -y install dropbear
echo "OPTIONS=\"-b bannerssh -p 109 -p 110 -p 143\"" > /etc/sysconfig/dropbear
echo "/bin/false" >> /etc/shells
service start dropbear
chkconfig enable dropbear

# bannerssh
wget $source/bannerssh
mv ./bannerssh /bannerssh
chmod 0644 /bannerssh
service dropbear restart
service sshd restart

yum -y install boxes
yum -y install ruby

# install squid
yum -y install squid
wget -O /etc/squid/squid.conf "https://raw.githubusercontent.com/Urabephc/Autoscript/master/Centos7/squid-centos7.conf"
sed -i $MYIP2 /etc/squid/squid.conf;
systemctl restart squid
systemctl enable squid

# install vnstat gui
cd /home/vps/public_html/
wget $source/vnstat_php_frontend-1.5.1.tar.gz
tar xf vnstat_php_frontend-1.5.1.tar.gz
rm vnstat_php_frontend-1.5.1.tar.gz
mv vnstat_php_frontend-1.5.1 vnstat
cd vnstat
sed -i 's/eth0/venet0/g' config.php
sed -i "s/\$iface_list = array('venet0', 'sixxs');/\$iface_list = array('venet0');/g" config.php
sed -i "s/\$language = 'nl';/\$language = 'en';/g" config.php
sed -i 's/Internal/Internet/g' config.php
sed -i '/SixXS IPv6/d' config.php
cd

# install Webmin
wget http://prdownloads.sourceforge.net/webadmin/webmin-1.900-1.noarch.rpm
yum -y install perl perl-Net-SSLeay openssl perl-IO-Tty perl-Encode-Detect
rpm -U webmin-1.900-1.noarch.rpm
systemctl restart webmin
systemctl enable webmin

# install bmon
yum -y install bmon

# cron
systemctl restart crond
systemctl enable crond

# set time GMT +7
ln -fs /usr/share/zoneinfo/Asia/Jakarta /etc/localtime

# download script
cd
wget -O /usr/bin/benchmark $source/benchmark.sh
wget -O /usr/bin/speedtest $source/speedtest_cli.py
wget -O /usr/bin/ps-mem $source/ps_mem.py
wget -O /usr/bin/dropmon $source/dropmon.sh
wget -O /usr/bin/menu $source/menu
wget -O /usr/bin/user-active-list $source/user-active-list.sh
wget -O /usr/bin/user-add $source/user-add.sh
wget -O /usr/bin/user-del $source/user-del.sh
wget -O /usr/bin/disable-user-expire $source/disable-user-expire.sh
wget -O /usr/bin/delete-user-expire $source/delete-user-expire.sh
wget -O /usr/bin/banned-user $source/banned-user.sh
wget -O /usr/bin/unbanned-user $source/unbanned-user.sh
wget -O /usr/bin/user-expire-list $source/user-expire-list.sh
wget -O /usr/bin/user-gen $source/user-gen.sh
wget -O /usr/bin/userlimit.sh $source/userlimit.sh
wget -O /usr/bin/userlimitssh.sh $source/userlimitssh.sh
wget -O /usr/bin/user-list $source/user-list.sh
wget -O /usr/bin/user-login $source/user-login.sh
wget -O /usr/bin/user-pass $source/user-pass.sh
wget -O /usr/bin/user-renew $source/user-renew.sh
wget -O /usr/bin/edit-openssh $source/edit-openssh.sh
wget -O /usr/bin/edit-dropbear $source/edit-dropbear.sh
wget -O /usr/bin/edit-squid $source/edit-squid.sh
wget -O /usr/bin/edit-stunnel $source/edit-stunnel.sh
wget -O /usr/bin/edit-banner $source/edit-banner.sh
wget -O /usr/bin/health $source/server-health.sh
wget -O /usr/bin/clearcache.sh $source/clearcache.sh
cd

#rm -rf /etc/cron.weekly/
#rm -rf /etc/cron.hourly/
#rm -rf /etc/cron.monthly/
rm -rf /etc/cron.daily/

# autoreboot
echo "*/10 * * * * root service dropbear restart" > /etc/cron.d/dropbear
echo "*/10 * * * * root service stunnel restart" > /etc/cron.d/stunnel
echo "*/10 * * * * root service squid restart" > /etc/cron.d/squid
echo "*/10 * * * * root service sshd restart" > /etc/cron.d/sshd
echo "*/10 * * * * root service webmin restart" > /etc/cron.d/webmin
#echo "0 */48 * * * root /sbin/reboot" > /etc/cron.d/reboot
echo "00 23 * * * root /usr/bin/disable-user-expire" > /etc/cron.d/disable-user-expire
echo "00 23 * * * root /usr/bin/delete-user-expire" > /etc/cron.d/delete-user-expire
echo "0 */1 * * * root echo 3 > /proc/sys/vm/drop_caches" > /etc/cron.d/clearcaches
#echo "0 */1 * * * root /usr/bin/clearcache.sh" > /etc/cron.d/clearcache1
wget -O /root/passwd "$source/passwd.sh"
chmod +x /root/passwd
echo "01 23 * * * root /root/passwd" > /etc/cron.d/passwd
cd

chmod +x /usr/bin/benchmark
chmod +x /usr/bin/speedtest
chmod +x /usr/bin/ps-mem
#chmod +x /usr/bin/autokill
chmod +x /usr/bin/dropmon
chmod +x /usr/bin/menu
chmod +x /usr/bin/user-active-list
chmod +x /usr/bin/user-add
chmod +x /usr/bin/user-del
chmod +x /usr/bin/disable-user-expire
chmod +x /usr/bin/delete-user-expire
chmod +x /usr/bin/banned-user
chmod +x /usr/bin/unbanned-user
chmod +x /usr/bin/user-expire-list
chmod +x /usr/bin/user-gen
chmod +x /usr/bin/userlimit.sh
chmod +x /usr/bin/userlimitssh.sh
chmod +x /usr/bin/user-list
chmod +x /usr/bin/user-login
chmod +x /usr/bin/user-pass
chmod +x /usr/bin/user-renew
chmod +x /usr/bin/edit-openssh
chmod +x /usr/bin/edit-dropbear
chmod +x /usr/bin/edit-squid
chmod +x /usr/bin/edit-stunnel
chmod +x /usr/bin/edit-banner
chmod +x /usr/bin/health
chmod +x /usr/bin/clearcache.sh

# swap ram
dd if=/dev/zero of=/swapfile bs=2048 count=2048k
# buat swap
mkswap /swapfile
# jalan swapfile
swapon /swapfile
#auto star saat reboot
wget $source/fstab
mv ./fstab /etc/fstab
chmod 644 /etc/fstab
sysctl vm.swappiness=10
#permission swapfile
chown root:root /swapfile 
chmod 0600 /swapfile
cd

# finalisasi
chown -R nginx:nginx /home/vps/public_html
systemctl restart nginx
systemctl start openvpn@server
systemctl restart php-fpm
systemctl restart vnstat
systemctl restart snmpd
systemctl restart sshd
systemctl restart dropbear
systemctl restart fail2ban
systemctl restart squid
systemctl restart webmin
systemctl restart crond

rm -f centos7.sh

rm -f /root/centos7.sh

rm -f /root/.bash_history && history -c

clear

# info
clear
echo " "
echo "################################################################################"
echo "#     SELAMAT DATANG DI SCRIPT AUTO INSTALL VPS BY M FAUZAN ROMANDHONI         #"
echo "#                         SCRIPT VERSION V1.0 FOR CENTOS 7                     #"
echo "#                               SEMOGA BERMANFAAT                              #"
echo "#------------------------------------------------------------------------------#"
echo "################################################################################"
echo "============================================================" | tee -a log-install.txt
echo " FINISH AND THANK YOU / Please Restart You VPS     "| tee -a log-install.txt
echo "============================================================" | tee -a log-install.txt
echo "Service :" | tee -a log-install.txt
echo "---------" | tee -a log-install.txt
echo "OpenSSH  : 22, 143" | tee -a log-install.txt
echo "Dropbear : 442, 456, 777" | tee -a log-install.txt
echo "SSL/TLS  : 443, 444" | tee -a log-install.txt
echo "Squid3   : 80, 8080, 8000, 3128 limit to IP $MYIP" | tee -a log-install.txt
echo "badvpn   : badvpn-udpgw port 7000 - 7500" | tee -a log-install.txt
echo "nginx    : 81" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Tools :" | tee -a log-install.txt
echo "axel, bmon, htop, iftop, mtr, rkhunter, nethogs: nethogs $ether" | tee -a log-install.txt
echo "Script :" | tee -a log-install.txt
echo "--------" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo "Fitur lain :" | tee -a log-install.txt
echo "------------" | tee -a log-install.txt
echo "Webmin         : http://$MYIP:10000/" | tee -a log-install.txt
echo "vnstat         : http://$MYIP:81/vnstat/ [Cek Bandwith]" | tee -a log-install.txt
echo "MRTG           : http://$MYIP:81/mrtg/" | tee -a log-install.txt
echo "Timezone       : Asia/Jakarta " | tee -a log-install.txt
echo "Fail2Ban       : [on]" | tee -a log-install.txt
echo "DDoS Deflate.  : [on]" | tee -a log-install.txt
echo "Block Torrent  : [on]" | tee -a log-install.txt
echo "IPv6           : [on]" | tee -a log-install.txt 
echo "Auto Lock User Expire tiap jam 00:00" | tee -a log-install.txt
echo "Auto Reboot tiap jam 00:00 dan jam 12:00" | tee -a log-install.txt
echo "Credit to all developers script, M Fauzan Romandhoni" | tee -a log-install.txt
echo "THANK YOU FOR CHOICE US!!" | tee -a log-install.txt
echo "" | tee -a log-install.txt
echo " !!! SILAHKAN REBOOT VPS ANDA !!!" | tee -a log-install.txt
echo "=======================================================" | tee -a log-install.txt