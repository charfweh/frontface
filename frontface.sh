#!/bin/bash
# -z checks for null arg
Green='\033[0;32m'
Color_Off='\033[0m'
if [ -z "$1" ]
then
        echo "Usage: ./recon.sh <IP>"
        exit 1
fi

echo -e "${Green}[+] Running nmap ${Color_Off}\n" 


nmap  --min-rate 1000 $1 | tail -n +6 | head -n -2 > nmap

portnumbers=()
portandservice=()
while read line
do
	#$line | cut -d / -f 1	
	if [[ $line == *open* ]]
	then
		echo -e "[+] Found port: $line" | cut -d / -f 1
		#echo -e "$line" | cut -d / -f 1 >> openports
		portnumbers+=("$(echo "$line" | cut -d / -f 1)")
		echo -e "$line" | awk -F' ' '{print $3}'
		service=$(echo "$line" | awk -F' ' '{print $3}')
		port=$(echo "$line" | cut -d / -f 1)
		echo -e "PORT $port,$service"
		portandservice+=(["$port"]="$service")
		#nmap -sC -sV -oN servicescan $1 -p$portnumber 
	fi

done < nmap
echo -e "${portandservice[@]}"
#for val in "${portnumbers[@]}"
#do
#	echo -e "[+] running services and versions enumueration on $val"
#	nmap -sC -sV $1 -p$val >> servicescan
#done

for key in "${!portandservice[@]}"
do 
	echo "$key => ${portandservice[$key]}"
	if [[ ${portandservice[$key]} == *http* ]]
	then
		echo -e "[+]Running gobuster"
	fi
done


