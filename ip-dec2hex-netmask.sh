#! /bin/bash

# use netmask tool to change IP address from Decimal to Hex
# TODO: write a version without netmask

# go to script dir
SCRIPTDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd ${SCRIPTDIR}

echo -e "\033[32m>> Checking Root Permission..\033[0m"
[ $(id -u) = 0 ] || {
	echo -e "\e[00;31mThis script must be run as root/sudo to check and install netmask.\e[00m"
	exit 1
}

echo -e "\033[32m>> Checking ip-hex.list file..\033[0m"
[ -f ip-hex.list ] && {
	echo -e "\e[00;31mYou already have a file named ip-hex.list.\e[00m"
	echo -e "\e[00;31mI will delete ip-hex.list file if you continue this procedure.\e[00m"
	echo -n "Do you want to go anyway? [yes/no]: "
	read answer
	case "$answer" in
	y|Y|yes|Yes|YeS|yEs|YES)
		echo "Let us go!"
		rm -f ip-hex.list
	;;
	*)
		echo "Good choice! Please check ip-hex.list file at first."
		exit 1
	;;
	esac
}

echo -e "\033[32m>> Checking ip-origin.list file..\033[0m"
[ -f ip-origin.list ] && {
	echo -e "\e[00;31mYou have already executed this script.\e[00m"
	echo -n "Do you want to use the old file? [yes/no]: "
	read answer
	case "$answer" in
	y|Y|yes|Yes|YeS|yEs|YES)
		echo -e "\e[00;31mUsing old ip-origin.list!\e[00m"
		mv ip-origin.list ip.list
	;;
	*)
		echo "Good choice! Please make sure you have ip.list file."
		rm ip-origin.list
	;;
	esac
}
echo -e "\033[32m>> Checking ip.list file..\033[0m"
if [ ! -f ip.list ]; then
	echo -e "\e[00;31mPlease create iplist file named ip.list \e[00m"
	echo -e "\e[00;31m--DO NOT put multi IP addresses in one line.\e[00m"
	echo -e "\e[00;31m--Please try again.\e[00m"
	exit 1
fi

echo -e "\033[32m>> Checking netmask..\033[0m"
if ! which netmask > /dev/null
then
	apt-get update && apt-get install -y --no-install-recommends netmask 1>/dev/null
fi

echo -e "\033[32m>> Sort and unique your ip.list..\033[0m"
sort -u ip.list -o ip-sort-uniq.list
mv ip.list ip-origin.list

echo -e "\033[32m>> Read and convert to Hex..\033[0m"
touch ip-hex.list
while read line
do
	LOWER="`netmask -x $line`"
	UPPER=$(echo $LOWER | tr '[a-z]' '[A-Z]')
	echo "$UPPER" >> ip-hex.list
done <ip-sort-uniq.list
sort -u ip-hex.list -o ip-hex.list

echo -n "Do you want to DELETE 10.0.0.1 format sorted ip addr file:ip-sort-uniq.list ? [yes/no]: "
read answer
case "$answer" in
y|Y|yes|Yes|YeS|yEs|YES)
	echo -e "\e[00;31mip-sort-uniq.list file DELETEd!\e[00m"
	rm -f ip-sort-uniq.list
;;
*)
	echo "ip-sort-uniq.list is safe now. You can check it at any time."
;;
esac

echo -n "Do you want to generate iptables rules using 'string' module? [yes/no]: "
read answer
case "$answer" in
y|Y|yes|Yes|YeS|yEs|YES)
	cp ip-hex.list ip-hex-iptables.list
	sed -i "s/\/.*$/\|\" --from 60 --to 180  -j DROP/g" ip-hex-iptables.list
	sed -i "s/^0X/iptables -t mangle -I PREROUTING -p udp --sport 53 -m string --algo bm --hex-string \"\|/g" ip-hex-iptables.list
;;
*)
	echo "Don't generate iptables rules using 'string' module"
;;
esac

echo -e "\033[32m>> Changing file owner..\033[0m"
echo -n "Please enter your login user name: "
read answer
whoami="${answer}"
chown ${whoami} ip-hex.list
chown ${whoami} ip-sort-uniq.list 2> /dev/null
chown ${whoami} ip-hex-iptables.list 2> /dev/null

exit 0

