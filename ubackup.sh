#!/usr/bin/bash
# By arshatech.com
# Automating user backup script!

requirements () {
	permin=`date '+%Y-%m-%d-AT-%H:%M'`
	perday=`date '+%Y-%m-%d'`
    arg=$1
    bpath=`echo $arg | sed 's:/[/]*$::g'`
	passwd=/etc/passwd
	logpath=/var/log/users
	logfile=${perday}.log
}

colors () {
	green='\033[1;32m'
	red='\033[1;31m'
	blue='\033[1;34m'
	cyan='\033[1;36m'
	yellow='\033[1;33m'
	nc='\033[0m'
}

backup () {
	printf "\n%17s${blue}Running Date: ${permin}${nc}\n"
	printf "%7s${blue}#####################################################${nc}"
	echo >> ${logpath}/${logfile}
	printf "\n%17sRunning Date: ${permin}\n" >> ${logpath}/${logfile}
	printf "%7s#####################################################" >> ${logpath}/${logfile}
	echo
	for each in `ls -d /home/*`; do
		if grep -q $each $passwd; then
			persec=`date '+%Y-%m-%d-AT-%H_%M_%S'`
			user=`echo $each | awk -F/ '{print $3}'`
			cd /home && tar -czf "${bpath}/${perday}/${user}-${persec}.tar.gz" ${user}
			ts=`echo $?`
			if [ $ts == "0" ]; then
				printf "%7s${green}[+] ${bpath}/${perday}/${user}-${persec}.tar.gz${nc}\n"
				echo >> ${logpath}/${logfile}
				printf "%7s[+] ${bpath}/${perday}/${user}-${persec}.tar.gz" >> ${logpath}/${logfile}
			else
				printf "%7s${red}[-] Failed to create ${bpath}/${perday}/${user}-${persec}.tar.gz${nc}\n"
				echo >> ${logpath}/${logfile}
				printf "%7s[-] Failed to create ${bpath}/${perday}/${user}-${persec}.tar.gz\n" >> ${logpath}/${logfile}
			fi
		fi
	done
    echo >> ${logpath}/${logfile}
}

requirements $1
colors
printf "%7s${cyan}[~] By: arshatech.com${nc}\n"
if [ "$EUID" -ne 0 ]; then
	printf "%7s${red}[-] Error: Run this script as root user!${nc}\n"
	exit 0
else
	if [ "$#" == "1" ]; then
		if [ ! -d ${logpath} ]; then
			mkdir -p ${logpath}
		fi

		printf "%7s${green}[+] Path: ${bpath}${nc}\n"
		mount | grep ${bpath} 1>/dev/null 2>&1
		ms=`echo $?`
		if [ $ms != "0" ]; then
			printf "%7s${green}[+] Type: Internal Hard.${nc}\n"
			printf "%7s${cyan}[*] If '${bpath}' not existed we will create it!${nc}\n"
			printf "%7s${cyan}[?] Do you want to continue? [y/n] ${nc}"
			read
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				mkdir -p ${bpath}/${perday}
				printf "%7s${cyan}[*] Starting...${nc}\n"
				if [ ! -d ${bpath} ]; then
					mkdir ${bpath}
				fi
				backup $bpath
			else
				printf "%7s${yellow}[*] Exiting...${nc}\n"
				exit 0
			fi

		elif [ $ms == "0" ]; then
			mounted=`mount | grep ${bpath} | awk '{print $1}'`
			printf "%7s${green}[+] Type: External Hard.${nc}\n"
			printf "%7s${green}[+] Mounted on: ${mounted}${nc}\n"
			printf "%7s${cyan}[?] Do you want to continue? [y/n] ${nc}"
			read
			if [[ $REPLY =~ ^[Yy]$ ]]; then
				mkdir -p ${1}/${perday}
				printf "%7s${cyan}[*] Starting...${nc}\n"
				backup $bpath
			else
				printf "%7s${yellow}[*] Exiting...${nc}\n"
				exit 0
			fi
		fi
	else
		printf "%7s${yellow}[*] Usage:   bash `basename $0` <backup-path>${nc}\n"
		printf "%7s${yellow}    Example: bash `basename $0` /backup${nc}\n"
		exit 0
	fi
fi
