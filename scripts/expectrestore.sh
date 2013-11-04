#!/bin/bash
#                    __                           
#   _____    ____  _/  |_   ____    ____  _______ 
#  /     \ _/ __ \ \   __\_/ __ \  /  _ \ \_  __ \
# |  Y Y  \\  ___/  |  |  \  ___/ (  <_> ) |  | \/
# |__|_|  / \___  > |__|   \___  > \____/  |__|   
#      \/      \/             \/                



#
#     requires expect
#


 
METEOR_DOMAIN="$1"
 
if [[ "$METEOR_DOMAIN" == "" ]]
then
	echo "You need to supply your meteor app name"
	echo "e.g. ./meteor-restore.sh app.meteor.com"
	exit 1
fi
 

 
# REGEX ALL THE THINGS.
# Chomps the goodness flakes out of urls like "mongodb://client:pass-word@skybreak.member0.mongolayer.com:27017/goto_meteor_com"
MONGO_URL_REGEX="mongodb:\/\/(.*):(.*)@(.*)\/(.*)"

# Get the mongo url for your meteor app
# meteor mongo $METEOR_DOMAIN --url

# expect <assword:
# <12ezferu
# MONGO_URL= $expect_out
# EOF


password="12ezferu"

echo "Entering expect..."
expect <<- DONE
  set timeout -1

  spawn meteor mongo $METEOR_DOMAIN --url

  # Look for passwod prompt * any / ? does
  expect "*?assword:*"
  # Send password aka $password
  send -- "$password\r"
  # send blank line (\r) to make sure we get back to gui
  # MONGO_URL=$expect_out
  expect eof
DONE

echo "expect mongo =" $MONGO_URL


 
if [[ $MONGO_URL =~ $MONGO_URL_REGEX ]] # does the regexp on the right match MONGO_URL
then
	
	#BASH_REMATCH = An array variable whose members are assigned by the ‘=~’ binary operator
	MONGO_USER="${BASH_REMATCH[1]}"
	MONGO_PASSWORD="${BASH_REMATCH[2]}"
	MONGO_DOMAIN="${BASH_REMATCH[3]}"
	MONGO_DB="${BASH_REMATCH[4]}"
 
	echo ''
	echo url: $MONGO_URL
	echo user: $MONGO_USER
	echo psswd: $MONGO_PASSWORD
	echo domain: $MONGO_DOMAIN
	echo db: $MONGO_DB
	echo ''
 	
 	# for protobrew the mongo DB name is still "meteor" so this VV ----------VV needs to be  ./dump/meteor
	mongorestore -u $MONGO_USER -h $MONGO_DOMAIN -db $MONGO_DB ./dump/$MONGO_DB -p "${MONGO_PASSWORD}"
else
	echo "Sorry, no restore for you. Couldn't extract your details from the url: ${MONGO_URL}"
	exit 1
fi