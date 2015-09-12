#!/bin/sh

SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd $SCRIPTDIR

# cidr to netmask
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
sort -u chnroute.txt -o chnroute.txt
perl ./merge-cidr.pl chnroute.txt > chnroute-1st.txt
sort -u chnroute-1st.txt -o chnroute-1st.txt

# change suffix to /11
cp -f chnroute-1st.txt chnroute-tmp.txt
for i in $( seq 12 32 )
do
  perl -i -pe "s|/$i$|/11|g" chnroute-tmp.txt
done

# merge 2nd time
sort -u chnroute-tmp.txt -o chnroute-tmp.txt
perl ./merge-cidr.pl chnroute-tmp.txt > chnroute-2nd.txt
sort -u chnroute-2nd.txt -o chnroute-2nd.txt

rm -f chnroute-tmp.txt

#change to netmask
cp -f chnroute-2nd.txt chnroute-ocserv.txt
for k in $( seq 1 32 )
do
  tmpnetmask=$(_cidr2netmask k)
  perl -i -pe "s|/$k$|/$tmpnetmask|g" chnroute-ocserv.txt
done

# generate ocserv no-route conf file
cp -f chnroute-ocserv.txt chnroute-ocserv-no-route.conf
perl -i -pe "s|^|no-route = |g" chnroute-ocserv-no-route.conf
