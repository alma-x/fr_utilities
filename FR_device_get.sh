#!/bin/bash

# This script makes use of the offical FreedomRobotics API
# https://docs.freedomrobotics.ai/reference/get-device-credentials

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
#   MAIN PROGRAM
####################################################################

# Check if credentials has been provided or a file exist
if [ $# == 0 ]; then
    if [ -f "fr_device.env" ]; then
        export $(cat fr_device.env | sed 's/#.*//g' | xargs)
        if [ $quiet_mode = 0 ]; then echo "Device loaded from file..."; fi
		if [ $DEV_ID = "" ]; then
			echo "Device ID is empty"
			exit
		fi
    else
        # If no credentials provided, ask from terminal
        read -p "Insert Device ID: " DEV_ID
    fi

	# Load session token and secret
	if [ -f "fr_session.env" ]; then
        export $(cat fr_session.env | sed 's/#.*//g' | xargs)
        if [ $quiet_mode = 0 ]; then echo "Session loaded from file..."; fi
    else
        # If no credentials provided, ask from terminal
        read -p "Insert Session token: " FR_TOKEN
        read -p "Insert Session secret: " FR_SECRET
        echo " "
    fi
	
	# Load session token and secret
    if [ -f "fr_credentials.env" ]; then
        export $(cat fr_credentials.env | sed 's/#.*//g' | xargs)
        if [ $quiet_mode = 0 ]; then echo "Credentials loaded from file..."; fi
    else
        # If no credentials provided, ask from terminal
        read -p "Insert User Unique ID: " FR_UID
        echo " "
    fi
else
    source $1
fi

# Login with username and password to get account token and secret
fr_resp=$(curl -X GET --url "https://api.freedomrobotics.ai/accounts/$FR_UID/devices?attributes=%5B%22device%22%5D&zones=%5B%5D&include_subzones=true" -H "Content-Type: application/json" -H "mc_secret: ${FR_SECRET}" -H "mc_token: ${FR_TOKEN}" --silent)

# Process response and check if login has succedeed
if grep -q "$DEV_ID" <<< "$fr_resp"; then
    device_ok=1
    if [ $quiet_mode = 0 ]; then echo -e "\e[32mDevice found!\e[0m"; fi

	# Get device tokens
	dev_resp=$(curl -X GET --url "https://api.freedomrobotics.ai/accounts/$FR_UID/devices/$DEV_ID/credentials?webrtc_local_port=5540" -H "Accept: application/json" -H "mc_secret: ${FR_SECRET}" -H "mc_token: ${FR_TOKEN}" --silent)

    # Extract token and secret from JSON
    dev_token=$(echo "$dev_resp" | grep -o '"token": "[^"]*' | grep -o '[^"]*$')
    dev_secret=$(echo "$dev_resp" | grep -o '"secret": "[^"]*' | grep -o '[^"]*$')

    # Write session into file
    if [ -f "fr_session.env" ]; then rm fr_device.env; fi
	echo "DEV_ID=${DEV_ID}" >> fr_device.env
	echo "DEV_TOKEN=${dev_token}" >> fr_device.env
	echo "DEV_SECRET=${dev_secret}" >> fr_device.env

	if [ $quiet_mode = 0 ]; then echo "Device token and secret written correctly"; fi
else
	if [ $quiet_mode = 0 ]; then echo -e "\e[41mDevice not found\e[0m"; fi
fi
