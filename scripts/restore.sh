#!/bin/bash
#                    __                           
#   _____    ____  _/  |_   ____    ____  _______ 
#  /     \ _/ __ \ \   __\_/ __ \  /  _ \ \_  __ \
# |  Y Y  \\  ___/  |  |  \  ___/ (  <_> ) |  | \/
# |__|_|  / \___  > |__|   \___  > \____/  |__|   
#      \/      \/             \/                 
#
#     restore!!!!
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
 
# stupid tmp file as meteor may want to prompt for a password
TMP_FILE="/tmp/meteor-restore.tmp"
 
# Get the mongo url for your meteor app
meteor mongo $METEOR_DOMAIN --url | tee "${TMP_FILE}"

# delete Password: out of TMP_FILE if the tee captured it
MONGO_URL=$(sed '/Password:/d' "${TMP_FILE}") 
 
# clean up the temp file
if [[ -f "${TMP_FILE}" ]]
then
	rm "${TMP_FILE}"
fi
 


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