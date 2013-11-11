#!/bin/sh

GATEWAY='10.0.62.1'
INTERNET='google.de'
LOGIN='login.rz.ruhr-uni-bochum.de'
WAN_INTERFACE='eth1'
RUBID='shornam3'
RUBPW='secret'

singlePing()
{
	ping -c 1 $1 >/dev/null 2>/dev/null #for some reason the parameter -t causes problems in OpenWRT - unfortunatedly the default value is about ~~10sec. 

	if [ $? == 0 ] 
	then
		echo 1
	else
		echo 0
	fi;
}
echoAvailability()
{
	if [ $1 == 1 ]
	then
		echo "Checking "$2".. available"
	else
		echo "Checking "$2".. unavailable"
	fi;
}

# First ping gateway to check if network connection is working
avail_gateway=`singlePing $GATEWAY`
echoAvailability $avail_gateway "gateway"
if [ $avail_gateway == 0 ]
then
	echo "No network connection."
	exit 1
fi;
# Ping some server on the internet to check if connection is available
avail_internet=`singlePing $INTERNET`
echoAvailability $avail_internet "internet"
if [ $avail_internet == 1 ]
then
	echo "Everthing fine."
	exit 0
fi;

# For some reason ping isn't working without beeing logged in, so we'll check availability with curl
curl http://${LOGIN} >/dev/null 2>/dev/null
if [ $? == 0 ] 
then
	avail_login=1
else
	avail_login=0
	exit 1;
fi;
echoAvailability $avail_login "login service"
if [ $avail_login == 0 ]
then
	echo "Login service not reachable."
	exit 2
fi;

# If we haven't exited until this point we know:
# - internet connection is down
# - all neccessary hosts are available

# Continue with login process:

wan_ip=`ifconfig $WAN_INTERFACE | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}'`

# Send HTTP POST to https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin
# Form data is
#	- loginid
#	- password
#	- ipaddr
#	- action=Login
# As response you'll get a HTML page, but the interessting part comes in a single line between
#	<font face="Helvetica, Arial, sans-serif"><big><big> STUFF <br>

echo "Logging in.." `curl --insecure -s -L -d "loginid=${RUBID}" -d "password=${RUBPW}" -d "ipaddr=${wan_ip}" -d "action=Login" https://login.rz.ruhr-uni-bochum.de/cgi-bin/laklogin | grep '<font face="Helvetica, Arial, sans-serif"><big><big>' | sed -e "s/<font face=\"Helvetica, Arial, sans-serif\"><big><big>//g" | sed -e "s/<br>//g"`

