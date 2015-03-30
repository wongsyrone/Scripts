#! /bin/sh

X="/usr/bin/X"
Xorg="/usr/bin/Xorg"

if [ ! -f "$X" -o ! -f "$Xorg" ] ; then
    echo "You must have Xorg-server installed!"
    exit 1
fi

if ! which synclient > /dev/null ; then
    echo "synclient not found. Plz reinstall touchpad driver."
    exit 1
fi

status=`synclient -l | grep -i "touchpadoff" | sed -e "s/\s*//g" | awk -F"=" '{print $2}'`

open() {
    if [ "$status" = "0" ] ; then
        echo "touchpad already open!"
        exit 1
    fi
    synclient touchpadoff=0
    RETVAL=$?
    [ $RETVAL -eq 0 ] && echo "open success"
    return $RETVAL
}

close() {
    if [ "$status" = "1" ] ; then
        echo "touchpad already closed!"
        exit 1
    fi
    synclient touchpadoff=1
    RETVAL=$?
    [ $RETVAL -eq 0 ] && echo "close success"
    return $RETVAL
}

switch() {
if [ "$status" = "1" ] ; then
    open
else
    close
fi
}

case "$1" in
open)
open
;;
close)
close
;;
switch)
switch
;;
status)
echo "Info: 0 stand for open"
echo "      1 stand for closed"
echo "Status is:    $status"
;;
*)
echo $"Usage: $0 {open|close|switch|status}"
RETVAL=1
esac

exit $RETVAL
#synclient touchpadoff=0
