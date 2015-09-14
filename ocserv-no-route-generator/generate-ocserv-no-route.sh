#!/bin/sh

#若將所有/13及以上改成/12,則不含保留IP的路由表是263條，超過了客戶端限制的最高200條。
#若將所有/12及以上改成/11，則不含保留IP的路由表是144條
#若將所有/11及以上改成/10，則不含保留IP的路由表是69條，IP範圍進一步擴大，誤差進一步擴大。
#所以cidrstart使用12

cidrstart=12
cidrtarget=`expr $cidrstart - 1`

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

# cidr to netmask
# $1: number of cidr, from 1 to 32
_cidr2netmask() {
        local cidr="$1" netmask="" done=0 i=0 sum=0 cur=128 
        local octets= frac= 

        local octets=$((${cidr} / 8)) 
        local frac=$((${cidr} % 8)) 
        while [ ${octets} -gt 0 ]; do 
                netmask="${netmask}.255" 
                octets=$((${octets} - 1)) 
                done=$((${done} + 1)) 
        done 

        if [ ${done} -lt 4 ]; then 
                while [ ${i} -lt ${frac} ]; do 
                        sum=$((${sum} + ${cur})) 
                        cur=$((${cur} / 2)) 
                        i=$((${i} + 1)) 
                done 
                netmask="${netmask}.${sum}" 
                done=$((${done} + 1)) 

                while [ ${done} -lt 4 ]; do 
                        netmask="${netmask}.0" 
                        done=$((${done} + 1)) 
                done 
        fi 

        echo "${netmask#.*}" 
}

cidr2netmask() {
for z in $( seq 1 32 )
do
  tmpnetmask=$(_cidr2netmask z)
  perl -i -pe "s|/$z$|/$tmpnetmask|g" "$1"
done
}

# use '.' as sort seperator
# $1: input file
# $2: output file
sortandmerge() {
  sort -u -t"." -k1,1n -k2,2n -k3,3n -k4,4n "$1" -o "$1"
  perl ./merge-cidr.pl "$1" > "$2"
  sort -u -t"." -k1,1n -k2,2n -k3,3n -k4,4n "$2" -o "$2"
}

# is script exists
[ -f merge-cidr.pl ] || {
  echo "no merge-cidr.pl"
  exit 1
}

# are we running the 1st time?
[ -f chnroute-origin.txt ] && {
  cp -f chnroute-origin.txt chnroute.txt
}

# get latest China IP range
[ -f chnroute.txt ] || {
  echo "no chnroute.txt, downloading..."
  curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnroute.txt
  # backup
  cp -f chnroute.txt chnroute-origin.txt
}

# remove previous generated files
rm -f chnroute-1st.txt chnroute-2nd.txt chnroute-2nd-private-ip.txt chnroute-oc*.{conf,txt}

# merge 1st time
sortandmerge chnroute.txt chnroute-1st.txt

# change suffix to /11 (cidrtarget)
cp -f chnroute-1st.txt chnroute-tmp.txt
for i in $( seq $cidrstart 32 )
do
  perl -i -pe "s|/$i$|/$cidrtarget|g" chnroute-tmp.txt
done

# merge 2nd time
sortandmerge chnroute-tmp.txt chnroute-2nd.txt

rm -f chnroute-tmp.txt

#get known ip block more accurate
cp -f chnroute-2nd.txt chnroute-tmp2.txt
sed -i "/192.160.0.0\/11/d" chnroute-tmp2.txt
cat >> chnroute-tmp2.txt <<'EOF'
192.160.0.0/13
192.169.0.0/16
192.170.0.0/15
192.172.0.0/14
192.176.0.0/12
EOF
sed -i "/203.0.0.0\/9/d" chnroute-tmp2.txt
cat >> chnroute-tmp2.txt <<'EOF'
203.0.0.0/18
203.0.64.0/19
203.0.96.0/20
203.0.112.0/24
203.0.114.0/23
203.0.116.0/22
203.0.120.0/21
203.0.128.0/17
203.1.0.0/16
203.2.0.0/15
203.4.0.0/14
203.8.0.0/13
203.16.0.0/12
203.32.0.0/11
203.64.0.0/10
EOF
sortandmerge chnroute-tmp2.txt chnroute-2nd.txt
rm -f chnroute-tmp2.txt

cp -f chnroute-2nd.txt chnroute-mod.txt
echo "you can modify chnroute-mod.txt now, then press any key to continue.."
echo "i.e. remove private IP range from chnroute-mod.txt"
echo "192.168.0.0/16 and 203.0.113.0/24 already removed from chnroute-mod.txt"
read
cp -f chnroute-mod.txt chnroute-tmp3.txt
# merge 3rd time if any change has been made
sortandmerge chnroute-tmp3.txt chnroute-2nd.txt

rm -f chnroute-tmp3.txt chnroute-mod.txt

echo -n "Do you want to add Reserved IP block? Default is no [y/n]:"
read answer
case "$answer" in
  y|Y|yes|Yes|YeS|yEs|YES)
  cp -f chnroute-2nd.txt chnroute-tmp4.txt
  cat >> chnroute-tmp4.txt <<'EOF'
0.0.0.0/8
10.0.0.0/8
100.64.0.0/10
127.0.0.0/8
169.254.0.0/16
172.16.0.0/12
192.0.0.0/24
192.0.2.0/24
192.88.99.0/24
192.168.0.0/16
198.18.0.0/15
198.51.100.0/24
203.0.113.0/24
224.0.0.0/4
240.0.0.0/4
255.255.255.255/32
EOF
  sortandmerge chnroute-tmp4.txt chnroute-2nd-private-ip.txt
  rm -f chnroute-tmp4.txt
  echo "Reserved IP block appending success!"
  ;;
  *)
  echo "Reserved IP block appending skipped!"
  ;;
esac

# add ocserv leading no-route entry to conf file
cp -f chnroute-2nd.txt chnroute-ocserv-no-route-no-private-ip.conf
cidr2netmask chnroute-ocserv-no-route-no-private-ip.conf
perl -i -pe "s|^|no-route = |g" chnroute-ocserv-no-route-no-private-ip.conf

[ -f chnroute-2nd-private-ip.txt ] && {
  cp -f chnroute-2nd-private-ip.txt chnroute-ocserv-no-route-private-ip.conf
  cidr2netmask chnroute-ocserv-no-route-private-ip.conf
  perl -i -pe "s|^|no-route = |g" chnroute-ocserv-no-route-private-ip.conf
}
