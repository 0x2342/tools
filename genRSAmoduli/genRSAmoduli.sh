#!/bin/bash
#
# generates a batch of RSA moduli
# MM, 21.03.2015

usage(){
cat << EOF
usage: $0 [options]

Options:
 -b Number of bytes per modulus (defaults to whatever openssl's default is)
 -n Number of moduli to be computed (defaults to 1)
EOF
exit 1
}

while getopts ":b:n:" opt; do
	case $opt in
		b) BYTES=$OPTARG
		;;
		n) NUM_MODULI=$OPTARG
		;;
		\?) usage
		;;
	esac
done

for i in `seq 1 $NUM_MODULI`; do
	openssl rsa -in <(openssl genrsa $BYTES 2>/dev/null) -modulus 2>/dev/null|grep Modulus|cut -d"=" -f2|tr '[:upper:]' '[:lower:']
done
