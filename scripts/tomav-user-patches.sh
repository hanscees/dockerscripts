#!/bin/bash

# these are script snippits to use in config/user-patches.sh of https://github.com/tomav/docker-mailserver/
# first snippit changes spam settings
# second snippit adds internal networks to whitelisting for several daemons
# for the code to work you must add the code in user-patches.sh and add env variables to your docker config


# for instance add to your environment in docker-compose.yml
#    environment:
#    - SPAM_BANNED_DESTINY=D_REJECT
#    - SPAM_FINAL_DESTINY=D_PASS
#    - WHITELIST_INT_NETWORKS="192.168.0.0/24 10.0.0.2/32"


##########################################################
#script snippit1 to change the anti-spam configuration in tomav mailserver
#so nothing is bounced. All spam that reaches spamassasin (so email is accepted in)
# is tagged only in subject
# no spam is bounced ever
# two lines in /etc/amavis/conf.d/20-debian_defaults are changed
#############################################################
##add this in
#    environment:
#    - SPAM_BANNED_DESTINY=D_REJECT
#    - SPAM_FINAL_DESTINY=D_PASS


##set env variable SPAM_BANNED_DESTINY = D_REJECT
if [ "$SPAM_BANNED_DESTINY" = "D_REJECT" ]; then
  ##tested below, works
  bannedbouncecheck=`egrep "final_banned_destiny.*D_BOUNCE" /etc/amavis/conf.d/20-debian_defaults`
  if [ -n "$bannedbouncecheck" ] ;
    then
       ##BOUNCE needs to be changed
       echo "yo need to act, my variable is wrongly D_BOUNCE"
       sed -i "/final_banned_destiny/ s|D_BOUNCE|D_REJECT|" /etc/amavis/conf.d/20-debian_defaults
       #supervisorctl restart amavis
       logger "SPAM_BANNED_DESTINY set to D_REJECT"
    fi
fi
##set env variable SPAM_FINAL_DESTINY = D_PASS
if [ "$SPAM_FINAL_DESTINY" = "D_PASS" ]; then
  ##tested below, works
  finalbouncecheck=`egrep "final_spam_destiny.*D_BOUNCE" /etc/amavis/conf.d/20-debian_defaults`
  if [ -n "$finalbouncecheck" ] ;
    then
       ##BOUNCE needs to be changed
       echo "yo need to act, my variable is wrongly D_BOUNCE"
       sed -i "/final_spam_destiny/ s|D_BOUNCE|D_PASS|" /etc/amavis/conf.d/20-debian_defaults
       #supervisorctl restart amavis
       logger "SPAM_BANNED_DESTINY set to D_REJECT"
    fi
fi


## script snippit 2 lines below adds internal networks to whitelist lines in
# postfix main.cf
# opendkim TrustedHosts
# fail2ban jail.conf
# spamassassin local.cf

## add to your docker tomav mailserver environment
# WHITELIST_INT_NETWORKS="192.168.0.0/24 10.0.0.2/32"
# and of course change the networks to your internal ip ranges

## set env variable WHITELIST_INT_NETWORKS
if [ ! -z "$WHITELIST_INT_NETWORKS" ]; then
   WHITELIST_INT_NETWORKS=`echo $WHITELIST_INT_NETWORKS | sed 's/\"//g'` #ditch possible "" in variables
   #adjust main.cf
   postfixcheck=`egrep "mynetworks.*$WHITELIST_INT_NETWORKS" /etc/postfix/main.cf`
   #echo  $postfixcheck
   #adjust main.cf
   if [ ! -n "$postfixcheck" ] ;
   then
    ##mynetwork needs to be added
    echo "yo need to act for postfix main.cf, my network is $WHITELIST_INT_NETWORKS"
    sed -i "/^mynetworks / s|$| $WHITELIST_INT_NETWORKS|" /etc/postfix/main.cf ## dont use / cause its in var too
   fi

    ##adjust opendkim
    ## here we need one network per line in config file
    opendkimcheck=`egrep "$WHITELIST_INT_NETWORKS" /etc/opendkim/TrustedHosts`
    if [ ! -n "$opendkimcheck" ] ;
    then
       ##mynetwork needs to be added
       echo "yo need to act for opendkim, my network is $WHITELIST_INT_NETWORKS"
       ranges=$(echo $WHITELIST_INT_NETWORKS | tr " " "\n") # split
       for netws in $ranges
       do
          echo "$netws" >> /etc/opendkim/TrustedHosts
       done
       #echo "$WHITELIST_INT_NETWORKS" >> /etc/opendkim/TrustedHosts
       #supervisorctl restart opendkim
    fi

    ##adjust fail2ban
    fail2bancheck=`egrep "ignoreip.*$WHITELIST_INT_NETWORKS" /etc/fail2ban/jail.conf`
    if [ ! -n "$fail2bancheck" ] ;
    then
       ##mynetwork needs to be added
       echo "yo need to act for fail2ban, my network is $WHITELIST_INT_NETWORKS"
       sed -i "s/^#ignoreip/ignoreip/;/^ignoreip / s|$| $WHITELIST_INT_NETWORKS|" /etc/fail2ban/jail.conf
       #supervisorctl restart fail2ban
    fi

    ##adjust spamassassin
    spamascheck=`egrep "$WHITELIST_INT_NETWORKS" /etc/spamassassin/local.cf`
    if [ ! -n "$spamascheck" ] ;
    then
       ##mynetwork needs to be added
       echo "yo need to act for spamassassin, my network is $WHITELIST_INT_NETWORKS"
       echo "clear_trusted_networks" >> /etc/spamassassin/local.cf
       echo "trusted_networks $WHITELIST_INT_NETWORKS" >> /etc/spamassassin/local.cf
       #supervisorctl restart amavis
    fi
  logger "Internal networks whitelisted"
fi

