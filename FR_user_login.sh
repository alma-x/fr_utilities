#!/bin/bash

quiet_mode=0

# Parse -x flags
while getopts ":hq" option; do
	case $option in
    	h) # display Help
			echo "Use this commed to retrieve user token and secret from Freeedom Robotics"
			exit;;
		q) # Quiet mode
			quiet_mode=1;;
		\?) # incorrect option
			echo "Error: Invalid option"
			#exit;;
	esac
done

####################################################################
#	MAIN PROGRAM
####################################################################

# Check if credentials has been provided or a file exist
if [ $# == 0 ]; then
	if [ -f "fr_credentials.env" ]; then
		export $(cat fr_credentials.env | sed 's/#.*//g' | xargs)	
		if [ $quiet_mode = 0 ]; then echo "Credentials loaded from file..."; fi
	else
		# If no credentials provided, ask from terminal
		read -p "Insert FR email: " FR_EMAIL
	    read -sp "Insert FR password: " FR_PASS
		read -p "Insert User Unique ID: " FR_UID
	fi
else
	# To Implement...
	source $1
fi

# Login with username and password to get account token and secret 
fr_resp=$(curl -X PUT --url https://api.freedomrobotics.ai/users/$FR_EMAIL/login -H "Content-Type: application/json" -d "{\"password\": \"${FR_PASS}\"}" --silent)

# Process response and check if login has succedeed
if grep -q "Login failed" <<< "$fr_resp"; then
	login_ok=0
	if [ $quiet_mode = 0 ]; then echo -e "\e[41mLogin failed!\e[0m"; fi
else
	login_ok=1
	if [ $quiet_mode = 0 ]; then echo -e "\e[32mLogin succedeed!\e[0m"; fi
	
	# Extract token and secret from JSON
	fr_token=$(echo "$fr_resp" | grep -o '"token":"[^"]*' | grep -o '[^"]*$')
	fr_secret=$(echo "$fr_resp" | grep -o '"secret":"[^"]*' | grep -o '[^"]*$')
	
	# Write session into file
	if [ -f "fr_session.env" ]; then rm fr_session.env; fi
	echo "FR_TOKEN=${fr_token}" >> fr_session.env
	echo "FR_SECRET=${fr_secret}" >> fr_session.env
	echo "FR_UID=${FR_UID}" >> fr_session.env
fi

if [ $quiet_mode = 0 ]; then echo "Session token and secret written correctly"; fi
