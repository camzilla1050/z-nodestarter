#!/bin/bash

#--> CONFIGURE YOUR VALUES HERE !
# Service
SERVICE=zend.service
# Domain name of your zen server
dns= #myserverdomainname
# Path of your config file. By default: $HOME"/.zen/zen.conf"
conf=$HOME"/.zen/zen.conf"

# 
#-----------------------------------------------------------------------------
# Check if file exists; if true then initialize public address of config file
if test -e $conf
	then 
		echo "Path of your config file is correct";
		c_addr=$(cat $conf | tail -1 | cut -d'=' -f2); echo " |_Your address in \""$conf"\" is: "$c_addr;
	else 
		echo "No config file at this path: "$conf" . Or check if the file exists"; 
fi

# How use nslookup command
# Source: https://geekflare.com/linux-networking-commands/

p_addr=$(nslookup $dns | tail -2 | cut -d' ' -f2)
echo "Your actual public address is: "$p_addr

# Init While loop
while :
do
if [ ! -e "$conf" ] 
	then 
		echo "Sorry config file not found";
	elif [ $c_addr != $p_addr ] 
		#then echo "Both address matches. Nice, nothing to do";
		then echo "Your actual address don't match with your config file values!. 
			This bash script will :
			|- change your public address in your zen node config file
			|- restart your zend node service"; 
		echo "Writing now in your \""$conf"\" the new public address...";			

# replace in config file externalip=xx.xx.xx.xx with 'sed' command
# Source: https://www.cyberciti.biz/faq/how-to-use-sed-to-find-and-replace-text-in-files-in-linux-unix-shell/
		sed -i 's/'$c_addr'/'$p_addr'/g' $conf

# Write modification date in a log file
		echo "#Changed:"$(date)" - IP="$p_addr >> $HOME"/zendfile.log"

		cat $conf | grep externalip	
fi

# if $zen-cli return public addres means that service zend is running
# Ternary operator
# Source: https://stackoverflow.com/questions/3953645/ternary-operator-in-bash
geti=$([[ $(zen-cli getnetworkinfo | grep \"address\" | cut -d'"' -f4) = $p_addr ]] && echo "TRUE" || echo "FALSE" ); #echo $geti
# PID of zend
pidZend=$([ ! -z "$(pidof zend)" ] && echo "TRUE" || echo "FALSE" ); #echo $pidZend;
# PID of zentracker
pidZenTracker=$([ ! -z "$(pidof zentracker)" ] && echo "TRUE" || echo "FALSE" ); #echo $pidTracker;

#

if [ $geti = FALSE ] || [ $pidZend = FALSE ]
	then
	if [ $(sudo systemctl status $SERVICE | grep Active: | cut -d' ' -f6) = "(running)" ];
		then
			echo "this service is active. Must be restarted to take effect"; 
			options="restart";
		else 
			echo "This service is down. Activate now"; 
			option="start";
	fi 

#	Restart zend && zentracker 
	sudo systemctl $option zend zentracker
	sudo systemctl status zenupdate.timer

fi
sleep 10
done







