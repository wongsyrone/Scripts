#! /bin/bash

# Upper Hex IP address
# args: $1-- the lower case file
# output: <filename>-upper
var1="$1"
var2="-upper"
file=${var1}${var2}
while read line
do
	UPPER=$(echo $line | tr '[a-z]' '[A-Z]')
	echo "$UPPER" >> ${file}
done <$1
