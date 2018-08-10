#/bin/sh
#
# 1) Read IP-Adresses from file
# 2) nmap & extract ports
# 3) create file w/ IPs + open ports
# 4) use file from 3) for testssl.sh and nessus etc.
#
# MM, 2018-04-18
#

targets=$1
targets=./targets

zimName="audit" #The name of the project
zimPath="./"

nmap_out=./nmap-results.gnmap

#Use template and create main section for each host in $target
function initZim()
{
	echo "[*] Initializing Zim Notebook at $zimPath/$zimName"
	cp -Ra $zimPath/Audit-Template/ $zimPath/$zimName
	creationTime=$(date --iso-8601=seconds)
	creationDate=$(date "+%A %d %B %Y")
	while read line
	do
		cp $zimPath/$zimName/Home.txt $zimPath/$zimName/$line.txt
		cp -ra $zimPath/$zimName/Home $zimPath/$zimName/$line
		find $zimPath/$zimName/ -type f -name "${line}.txt" -exec sed -Ei "s/^====== Home/====== ${line}/g" {} \;
	done<$targets
	rm -rf $zimPath/$zimName/Home*

	find $zimPath/$zimName -type f -name "*.txt" -exec sed -Ei "s/[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}-[0-9]{2}:[0-9]{2}/${creationTime}/g" {} \;
	find $zimPath/$zimName -type f -name "*.txt" -exec sed -Ei "s/^Created.*[0-9]{4}/Created ${creationDate}/g" {} \;
}

#Choose whichever you like...
#sudo nmap -sT -sU -sV -iL $targets -oG ./$nmap_out
sudo nmap -sS -sV -iL $targets -oG ./$nmap_out

#Create file of all ports to be fed into Nessus
function createNessusPortlist()
{
	file=./portstotal.txt
	echo "[*] Writing portlist to $file"
	while read line
	do
		grep -Eo '[0-9]{1,5}/(open|filtered)/.*/' $nmap_out \
			| awk -F"/, " '{for(i=1; i<=NF; i++) print $i}' \
			| cut -f1 -d"/" >> /tmp/portstotal.txt 
		cat /tmp/portstotal.txt | sort | uniq > $file
	done<$targets
}

#Create individual files per host from $nmap_out
function createHostFile()
{
while read line
do
	grep -E $line $nmap_out > $line-ports.txt
done<$targets
}

function parseHostFile()
{
for host in *-ports.txt
do
	numports=$(grep -Eo 'Ports.*/' $host|awk -F"/," '{print NF}' )
	name=$(echo $host|cut -f1 -d"-")
	tcpenumfile=$zimPath/$zimName/$name/Enumeration/1-TCP.txt
	echo -e "\n|Port|State|Proto|Owner|Service|RPC|Version|" >> $tcpenumfile
	for port in `seq 1 $numports`
	do
		portstring=$(grep -Eo '[0-9]{1,5}/(open|filtered)/.*/' $host \
			| awk -v p=$port -F"/," '{print $p}' )
		sanitized=$(echo $portstring \
			| sed -E 's/\|/_/g')
		echo $sanitized \
			| awk -F"/" '{print "|"$1"|"$2"|"$3"|"$4"|"$5"|"$6"|"$7"|"}' 	>> $tcpenumfile
		#If there is an SSL-Port, write to file
		[[ $portstring =~ .*ssl\|.* ]] && echo $portstring |grep -Eo '^[0-9]{1,5}' > $name-ssl.txt
	done
	echo -e "\n" >> $tcpenumfile
done
}

function cipherScan()
{
	echo -n "[*] Running TLS checks ..."
	[[ ! -d ./ssl ]] && mkdir ./ssl 
	for host in *-ssl.txt
	do
		hostname=$(echo $host |cut -f1 -d"-")
		while read port
		do
			#testssl -e -p --logfile ./ssl $(echo $host|cut -f1 -d"-"):$port >/dev/null 2>&1
			#openssl s_client -showcerts -connect $(echo $host|cut -f1 -d"-"):$port </dev/null 2>/dev/null|awk '/-----BEGIN/,/-----END/' > ./ssl/$(echo $host|cut -f1 -d"-"):$port.pem
			testssl -e -p --logfile ./ssl $hostname:$port >/dev/null 2>&1
			openssl s_client -showcerts -connect $hostname:$port </dev/null 2>/dev/null|awk '/-----BEGIN/,/-----END/' > ./ssl/$hostname:$port.pem
		done<$host
	done
	echo "Done"
}

initZim
createNessusPortlist
createHostFile
parseHostFile
cipherScan
