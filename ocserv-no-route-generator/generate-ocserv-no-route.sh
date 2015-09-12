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
_cidr2netmask()
{ 
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

# $1: input file
# $2: output file
sortandmerge() {
  sort -u "$1" -o "$1"
  perl ./merge-cidr.pl "$1" > "$2"
  sort -u "$2" -o "$2"
}

# is script exists
[ -f merge-cidr.pl ] || {
  echo "no merge-cidr.pl"
  exit 1
}

# get latest China IP range
[ -f chnroute.txt ] || {
  echo "no chnroute.txt, downloading..."
  curl 'http://ftp.apnic.net/apnic/stats/apnic/delegated-apnic-latest' | grep ipv4 | grep CN | awk -F\| '{ printf("%s/%d\n", $4, 32-log($5)/log(2)) }' > chnroute.txt
}

# backup
cp -f chnroute.txt chnroute-origin.txt

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

#change to netmask
cp -f chnroute-2nd.txt chnroute-ocserv.txt
echo "you can modify chnroute-ocserv.txt now, then press any key to continue.."
echo "i.e. remove private IP range from chnroute-ocserv.txt"
read
cp -f chnroute-ocserv.txt chnroute-tmp2.txt
# merge 3rd time if any change has been made
sortandmerge chnroute-tmp2.txt chnroute-ocserv.txt

rm -f chnroute-tmp2.txt

for k in $( seq 1 32 )
do
  tmpnetmask=$(_cidr2netmask k)
  perl -i -pe "s|/$k$|/$tmpnetmask|g" chnroute-ocserv.txt
done

# add ocserv leading no-route entry to conf file
cp -f chnroute-ocserv.txt chnroute-ocserv-no-route.conf
perl -i -pe "s|^|no-route = |g" chnroute-ocserv-no-route.conf
