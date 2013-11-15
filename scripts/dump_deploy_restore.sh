#!/bin/bash
#                    __                           
#   _____    ____  _/  |_   ____    ____  _______ 
#  /     \ _/ __ \ \   __\_/ __ \  /  _ \ \_  __ \
# |  Y Y  \\  ___/  |  |  \  ___/ (  <_> ) |  | \/
# |__|_|  / \___  > |__|   \___  > \____/  |__|   
#      \/      \/             \/                 
#
#     .___                        
#   __| _/ __ __   _____  ______  
#  / __ | |  |  \ /     \ \____ \ 
# / /_/ | |  |  /|  Y Y  \|  |_> >
# \____ | |____/ |__|_|  /|   __/ 
#      \/              \/ |__|    
#
# The meteor.com Hot Dump 2-step 
# Dump a mongo db from a live meteor app to a local dump dir. 
#
# Splits up the output of:
#    meteor mongo $METEOR_DOMAIN --url 
# and pushes it into 
#    mongodump -u $MONGO_USER -h $MONGO_DOMAIN -d $MONGO_DB -p "${MONGO_PASSWORD}"
# 
# Doing so by hand is tedious as the password in the url is only valid for 60 seconds.
#
# Requires 
# - meteor  (tested on 0.5.9)
# - mongodb (tested in 2.4.0)
#
# Usage
#    ./meteor-dump.sh goto
#
# If all goes well it'll create a dump folder in the current working directory.
#
# By @olizilla
# On 2013-03-20. Using this script after it's sell by date may void your warranty.
#
 
METEOR_DOMAIN="$1"
 
if [[ "$METEOR_DOMAIN" == "" ]]
then
	echo "You need to supply your meteor app name"
	echo "e.g. ./meteor-dump.sh app"
	exit 1
fi
 
echo ''
echo 'ATTENTION'
echo 'goto https://code.google.com/apis/console/'
echo 'to create new clientId and secret for 'dev$METEOR_DOMAIN
echo 'enter both below:'
read -p 'clientId:' clientId
echo ''
read -p 'secret:' secret
echo ''
 
# REGEX ALL THE THINGS.
# Chomps the goodness flakes out of urls like "mongodb://client:pass-word@skybreak.member0.mongolayer.com:27017/goto_meteor_com"
MONGO_URL_REGEX="mongodb:\/\/(.*):(.*)@(.*)\/(.*)"
 
# stupid tmp file as meteor may want to prompt for a password
TMP_FILE="/tmp/meteor-dump.tmp"
 
# Get the mongo url for your meteor app
meteor mongo $METEOR_DOMAIN --url | tee "${TMP_FILE}"
 
MONGO_URL=$(sed '/Password:/d' "${TMP_FILE}")
 
# clean up the temp file
if [[ -f "${TMP_FILE}" ]]
then
	rm "${TMP_FILE}"
fi
 
if [[ $MONGO_URL =~ $MONGO_URL_REGEX ]] 
then
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
 
	#e.g mongodump -u client -h skybreak.member0.mongolayer.com:27017 -d goto_meteor_com -p "guid-style-password"
	mongodump -u $MONGO_USER -h $MONGO_DOMAIN -db $MONGO_DB -p "${MONGO_PASSWORD}"
else
	echo "Sorry, no dump for you. Couldn't extract your details from the url: ${MONGO_URL}"
	exit 1
fi
 
####
# deploy
###
 
# get deploy URL in form something.meteor.com from input
http_removed=$(echo $METEOR_DOMAIN | sed 's/https\?:\/\///' )
meteor_url=$(echo $http_removed | sed 's/\///' ) #trailing slash
echo meteor_url: $meteor_url
 
# echo 'enter password for deploy'
# read -s -p 'Password:' password
# echo ' '
# read -s -p 'Password(again):' password2
# echo ' '
 
# if [[ $password == $password2 ]] 
# then
# 	echo "passwords match" 
# else
# 	echo "Sorry, passwords didn't match"
# 	exit 1
# fi
 
 
dev_url='dev'$meteor_url
echo deploying to: $dev_url
	(cd ../protobrew/ && meteor deploy --password $dev_url)
 
# stupid tmp file as meteor may want to prompt for a password
DEV_TMP_FILE="/tmp/dev-meteor-dump.tmp"
 
# Get the mongo url for your meteor app
meteor mongo $dev_url --url | tee "${DEV_TMP_FILE}"
 
DEV_MONGO_URL=$(sed '/Password:/d' "${DEV_TMP_FILE}")
 
# clean up the temp file
if [[ -f "${DEV_TMP_FILE}" ]]
then
	rm "${DEV_TMP_FILE}"
fi
 
if [[ $DEV_MONGO_URL =~ $MONGO_URL_REGEX ]] 
then
	DEV_MONGO_USER="${BASH_REMATCH[1]}"
	DEV_MONGO_PASSWORD="${BASH_REMATCH[2]}"
	DEV_MONGO_DOMAIN="${BASH_REMATCH[3]}"
	DEV_MONGO_DB="${BASH_REMATCH[4]}"
 
	echo ''
	echo dev_url: $DEV_MONGO_URL
	echo dev_user: $DEV_MONGO_USER
	echo dev_psswd: $DEV_MONGO_PASSWORD
	echo dev_domain: $DEV_MONGO_DOMAIN
	echo dev_db: $DEV_MONGO_DB
	echo ''
 
	DUMP_DB_PATH='./dump/'$MONGO_DB
 
	#e.g mongodump -u client -h skybreak.member0.mongolayer.com:27017 -d goto_meteor_com -p "guid-style-password"
	echo mongorestore -u $DEV_MONGO_USER -h $DEV_MONGO_DOMAIN -db $DEV_MONGO_DB $DUMP_DB_PATH -p "${DEV_MONGO_PASSWORD}"
	mongorestore -u $DEV_MONGO_USER -h $DEV_MONGO_DOMAIN -db $DEV_MONGO_DB ./dump/$MONGO_DB -p "${DEV_MONGO_PASSWORD}"
else
	echo "Sorry, no restore for you. Couldn't extract your details from the url: ${MONGO_URL}"
	exit 1
fi
 
 
echo 'goto https://code.google.com/apis/console/ to create new client id for the dev instance'
 
#mongodump -u $MONGO_USER -h $MONGO_DOMAIN -d $MONGO_DB -p "${MONGO_PASSWORD}"
#mongorestore -u client -p 387shff-fe52-07d4-69a4-ba321f3665fe7 -h c0.meteor.m0.mongolayer.com:27017 -db yoapp_meteor_com ./home/user/dump/yoapp
 
 
# read -p 'clientId:' clientId
# echo ''
# read -p 'secret:' secret
# echo ''
 
# clientId='576725913237-r16f179us722576422docefpbrv1125m.apps.googleusercontent.com'
# secret='Ytc6lYZmBgBOPkDmb1HkekAd'
 
 
#need to quote actual mongo commands with \ 
#  http://stackoverflow.com/questions/2500436/how-does-cat-eof-work-in-bash
#heredocs:
#  http://stackoverflow.com/questions/1167746/how-to-assign-a-heredoc-value-to-a-variable-in-bash
read -d '' jscript <<- EOF
	var clientId = '$clientId';
	var secret = '$secret';
 
	db.meteor_accounts_loginServiceConfiguration.update(
		{clientId : {\$exists: true}},
		{\$set: { 'clientId' : clientId }});
 
	db.meteor_accounts_loginServiceConfiguration.update(
		{secret : {\$exists: true}},
		{\$set: { 'secret' : secret }});
EOF
 
 
#(cd ../protobrew && meteor mongo $dev_url mongocommands.js -p)
 
# db.meteor_accounts_loginServiceConfiguration.findOne({clientId : {$exists: true}})
 
#mongo -u client production-db-a2.meteor.io.meteor.com:27017/humontest_meteor_com -p 0c418262-5441-e9d5-639a-e5ca6177a7ca
 
#http://stackoverflow.com/questions/10114355/how-to-pass-argument-to-mongo-script
 
mongo -u client $DEV_MONGO_DOMAIN/$DEV_MONGO_DB -p $DEV_MONGO_PASSWORD --eval "$jscript"