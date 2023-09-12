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


nmap --min-rate 1000 $1 | tail -n +6 | head -n -2 > nmap

while read line
do
	if [[ $line == *open* ]]
	then
		portnumber = $line | $(cut -d / -f 1)
		echo -e "[+] $portnumber"
	fi

done < nmap
