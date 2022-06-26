#!/bin/bash

quiet_mode=0

# Parse -x flags
while getopts ":hqe" option; do
	case $option in
    	h) # display Help
			echo "Use this command to logout and disable user token and secret"
			exit;;
		q) # Quiet mode
			quiet_mode=1;;
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
		echo " "
	fi
    if [ -f "fr_session.env" ]; then
        export $(cat fr_session.env | sed 's/#.*//g' | xargs)
        if [ $quiet_mode = 0 ]; then echo "Session loaded from file..."; fi
    else
        # If no session provided, ask from terminal
        read -p "Insert Session Token: " FR_TOKEN
		read -p "Insert Session Secret: " FR_SECRET
    fi
else
	for i in "$@"; do
 	  case $i in
    	-e=*|--email=*)
      	  FR_EMAIL="${i#*=}"
    	  shift # past argument=value
    	  ;;
    	-*|--*)
      	  echo "Unknown option $i"
      	  exit 1
      	  ;;
    	*)
      	  ;;
  	  esac
	done
fi

# Login with username and password to get account token and secret 
fr_resp=$(curl -X PUT --url https://api.freedomrobotics.ai/users/$FR_EMAIL/logout -H "Content-Type: application/json" -H "mc_secret: ${FR_SECRET}" -H "mc_token: ${FR_TOKEN}" --silent)

# Process response and check if login has succedeed
if grep -q "\"status\":\"success\"" <<< "$fr_resp"; then
	logout_ok=1
	if [ $quiet_mode = 0 ]; then echo "OK"; fi
	if [ -f "fr_session.env" ]; then rm fr_session.env; fi
else
	logout_ok=1
	if [ $quiet_mode = 0 ]; then echo "FAILED"; fi
fi
