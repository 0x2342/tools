#!/bin/bash
#
# Retrieve certificate chain from a set of hosts
# Input file contains colon separated IP/FQDN and port
#
# MM, 2018-01-23

while read line
do
	openssl s_client -showcerts -connect $line </dev/null 2>/dev/null\
		|awk '/-----BEGIN/,/-----END/ > $line.pem'
done<$1
