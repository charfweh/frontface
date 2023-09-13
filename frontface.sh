#!/bin/bash
# -z checks for null arg
Green='\033[0;32m'
Color_Off='\033[0m'
Blue='\033[1;34m'
Green1='\033[0;92m'
Red='\033[0;31m'
bred='\033[1;31m'
bblue='\033[1;34m'
bgreen='\033[1;32m'
byellow='\033[1;33m'
red='\033[0;31m'
blue='\033[0;34m'
green='\033[0;32m'
yellow='\033[0;33m'
reset='\033[0m'
if [ -z "$1" ]
then
        echo -e "${byellow}[INF] Usage: ./recon.sh <IP>${Color_Off}"
        exit 1
fi

if ! [[ $1 =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
then
	echo -e "${Red}[x] IP address not identified${Color_Off}"
	exit 1
fi
echo -e "${Green}[+] Running nmap on ${1}${Color_Off}\n" 


nmap  --min-rate 1000 $1 | tail -n +6 | head -n -2 > "$1".nmap
echo -e "${bgreen}[+] Nmap top ports scan done > ${1}.nmap"

portnumbers=()
portandservice=()
while read line
do
	#$line | cut -d / -f 1	
	if [[ $line == *open* ]]
	then
		echo -e "${Blue}[+] Found port${Color_Off}: $line" | cut -d / -f 1
		#echo -e "$line" | cut -d / -f 1 >> openports
		portnumbers+=("$(echo "$line" | cut -d / -f 1)")
		#echo -e "$line" | awk -F' ' '{print $3}'
		service=$(echo "$line" | awk -F' ' '{print $3}')
		port=$(echo "$line" | cut -d / -f 1)
		portandservice+=(["$port"]="$service")
	fi
	
done < "$1".nmap
echo -e "${yellow}[INF] nmap command: nmap -sC -sV ${1} ${Color_Off}"
for val in "${portnumbers[@]}"
do
	echo -e "${Green1}[+] Running services and versions enumueration on ${Color_Off} $val"
	nmap -sC -sV $1 -p$val >> "$1".servicescan
done

echo -e "${bgreen}[INF] Service enumeration done > ${1}.service${Color_Off}"

#echo -e "${Green1}[+] Performing full port scan on (~3m)${1}${Color_Off}"
#nmap -T4 -p- --min-rate 1000 $1 > "${1}".fullportscan

echo -e "${bgreen}[INF] Full port scan done > ${1}.fullportscan${Color_Off}"

echo -e "${bblue}[+] Checking for webservers${Color_Off}"

for key in "${!portandservice[@]}"
do 
	if [[ ${portandservice[$key]} == *http* ]]
	then
		echo -e "[+] Running gobuster"
		echo -e "${yellow} Command ran: gobuster dir -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -u http://${1}/ -t 50${Color_Off}"
		gobuster dir -w /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt -u http://$1/ -t 50 > "$1".gobuster
		echo -e "\n${bgreen}[INF] Gobuster enumeration done > ${1}.gobuster ${Color_Off}"
	fi
	
done
echo -e "${bgreen}[END] Done with frontface, all the best!${Color_Off}"

