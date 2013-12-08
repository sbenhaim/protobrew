#!/bin/bash
export MONGO_URL="mongodb://localhost"
# export MAIL_URL="smtp://user:password@mailhost:port/"
export ROOT_URL="http://humon.com"
export PORT=3000
cd /srv/node/humonwiki
npm install
node main.js
