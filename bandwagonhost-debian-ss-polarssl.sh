#! /bin/bash
#===============================================================================================
#   System Required:  Debian or Ubuntu (32bit/64bit)
#   Description:  Install Shadowsocks(libev) for Debian or Ubuntu
#   Author: tennfy <admin@tennfy.com>
#   Modifier: wongsyrone
#===============================================================================================

clear
echo "#############################################################"
echo "# Install Shadowsocks(libev) for Debian or Ubuntu (32bit/64bit)"
echo "#"
echo "#  This version with polarssl support"
echo "#"
echo "#############################################################"
echo ""

# prepare packages
apt-get update
apt-get install -y --force-yes build-essential autoconf libtool libssl-dev git

# go to /root dir
cd /root

# build polarssl library using make
# please refer to polarssl's Makefile 
git clone https://github.com/polarssl/polarssl.git
cd polarssl
make lib
cd ..

#download source code
# madeye had already transfered to shadowsocks
git clone https://github.com/shadowsocks/shadowsocks-libev.git

#compile install
cd shadowsocks-libev
./configure --prefix=/usr --with-crypto-library=polarssl --with-polarssl-include=/root/polarssl/include --with-polarssl-lib=/root/polarssl/library
make && make install
mkdir -p /etc/shadowsocks-libev
cp ./debian/shadowsocks-libev.init /etc/init.d/shadowsocks-libev
cp ./debian/shadowsocks-libev.default /etc/default/shadowsocks-libev
chmod +x /etc/init.d/shadowsocks-libev

# Get IP address(Default No.1)
IP=`ifconfig | grep 'inet addr:'| grep -v '127.0.0.*' | cut -d: -f2 | awk '{ print $1}' | head -1`;

#config setting
echo "#############################################################"
echo "#"
echo "# Please input your shadowsocks server_port and password"
echo "#  Default is aes-256-cfb, which is highly recommended"
echo "#############################################################"
echo ""
echo -n "input server_port(443 is suggested) :"
read serverport
echo -n "input password :"
read shadowsockspwd

# Config shadowsocks
cat > /etc/shadowsocks-libev/config.json<<-EOF
{
    "server":"${IP}",
    "server_port":${serverport},
    "local_port":1080,
    "password":"${shadowsockspwd}",
    "timeout":60,
    "method":"aes-256-cfb"
}
EOF

#restart
/etc/init.d/shadowsocks-libev restart

#start with boot
update-rc.d shadowsocks-libev defaults
#echo "nohup /usr/bin/ss-server -c /etc/shadowsocks-libev/config.json > /dev/null 2>&1 &">> /etc/rc.local
#install successfully
    echo ""
    echo "Congratulations, shadowsocks-libev install completed!"
    echo -e "Your Server IP: ${IP}"
    echo -e "Your Server Port: ${serverport}"
    echo -e "Your Password: ${shadowsockspwd}"
    echo -e "Your Local Port: 1080"
    echo -e "Your Encryption Method:aes-256-cfb"

