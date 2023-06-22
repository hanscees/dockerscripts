#!/bin/bash

#gets tls pemfiles that are refreshed by waf server at 115. Waf uses certbot 
# then does some checks
# then runs script inside docker container formaly tomav / now  https://github.com/docker-mailserver/docker-mailserver
# is called by cron
# runs once a month typically

## if you copy this file for usage you should search and replace
# email address hanscees
# docker service name mailserver
## ip address 1.112
## certbot names cees.net

# old cd /var/lib/docker/volumes/tomavmail_ssl/_data/
cd /var/lib/docker/volumes/mailserver_ssl/_data/
today=`date +%d-%b-%Y`
mkdir old
mkdir new
cd new
FILE=cert.pem

#now get certs, that might be new

#for this to work ssh should work with keys
scp -i ~/.ssh/id_rsa root@192.168.1.112:/var/lib/docker/volumes/nginx_certbot_conf/_data/live/mail.hanscees.net/*.pem .

if [ -f $FILE ]; then
   echo "The file '$FILE' exists in new directory, so ssh worked fine."
else
   echo "The file '$FILE' is not found."
   #if no file is found something is broken with ssh so let warn
   logger warning: refreshcerts could not get file at 112 waf
   echo warning, mail could not find certfile, ssh might be broken | /root/dockerscripts/emailer.py -s warning -to hanscees@hanscees.com -body
   exit
fi

#ok, scp has copied new files in: lets work

cd /var/lib/docker/volumes/mailserver_ssl/_data/
echo " today is $today "
#if cert file does not exist, alsway take action
if [ -f $FILE ]; then
   echo "The file '$FILE' exists, take two"
else
  echo "The file '$FILE' does not exists in cert dir, take two"
  #so we need to do stuff
  #move away old smelly corroded files, move new int5o place
  mv cert.pem old
  mv chain.pem old
  mv fullchain.pem old
  mv privkey.pem old
  #move in the new fresh shiny files
  mv new/cert.pem ./
  mv new/chain.pem ./
  mv new/fullchain.pem ./
  mv new/privkey.pem ./
  # docker should pick up the certs, check them for sanity and use them if sane
  docker exec -it mailserver /tmp/docker-mailserver/tomav-renew-certs
  logger refreshpem refreshcerts ran fine probably
fi

# if the new cert is the same as thew last cert, no action, else yes action
DIFF=$(diff cert.pem new/cert.pem)
if [ "$DIFF" != "" ]
then
  echo "files are not the same"
  #so we need to do stuff
  #move away old files, move new int5o place
  #yes this is code usasge doubled, deal with it
  mv cert.pem old
  mv chain.pem old
  mv fullchain.pem old
  mv privkey.pem old

  mv new/cert.pem ./
  mv new/chain.pem ./
  mv new/fullchain.pem ./
  mv new/privkey.pem ./
  # docker should pick up the certs, check them for sanity and use them if sane
  docker exec -it mailserver /tmp/docker-mailserver/tomav-renew-certs
  logger refreshpem refreshcerts ran fine probably
else
   echo "files are the same do nothing. Have a nice day"
fi


