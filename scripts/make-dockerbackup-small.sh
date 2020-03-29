#!/bin/bash

#this script is meant to backup some dirs on a docker host: the dirs with
# dockerfiles or docker-compose files, and the script dir (if you have one)
# it does not backup volumes or docker images or containers at all.
# first we make a tgz file, and then we scp this to a backup host
# scp expects login with ssh keys, so not passwds of course.
# use at your own risk hanscees [ad] hanscees.com

##vars docker
VOLDIR="/var/lib/docker/volumes/"
SCRIPTDIR=~/dockerscripts/
CONTDIR=~/containers/

# scp /ssh vars
BackupToDir="/srv/dWD-WCC7K3FJ3ERS-part1/backup/dockerbackups/"
ScpTarget="hc-backup@backup.hanscees.net"

#rest of vars
HISTORYfile=~/hist
BackupDir=~/backuptmp
TIMESTAMP=`date --rfc-3339 seconds | sed 's/ /-/' | sed 's/\:/_/g'  `
echo "Time is $TIMESTAMP"
#Time is 2020-03-29-16:40:07+02:00
HOSTNAME=`hostname`

echo $HOSTNAME

##get some facts for later
touch  $HISTORYfile
echo "Time is $TIMESTAMP" > $HISTORYfile
uname -a >> $HISTORYfile
echo "network data" >> $HISTORYfile
ip a >> $HISTORYfile
echo "######" >> $HISTORYfile
echo "docker image ls" >> $HISTORYfile
docker image ls >> $HISTORYfile
echo "docker ps" >> $HISTORYfile
docker ps  >> $HISTORYfile
echo "docker volume ls " >> $HISTORYfile
docker volume ls  >> $HISTORYfile

echo " will make backup now from docker dirs $CONTDIR and $SCRIPTDIR"
logger " making docker backup at $TIMESTAMP"
##
mkdir $BackupDir
cd $BackupDir

#small tgz file
Backupfile_S="${HOSTNAME}_small-dockerbackup_${TIMESTAMP}.tgz"
echo $Backupfile_S
tar -cvzf $Backupfile_S $SCRIPTDIR $CONTDIR $HISTORYfile

echo "backup was written to $BackupDir"
sleep 2
echo " starting copy to backup server"
sleep 2

## check the files
#tar -ztvf  $Backupfile_S

#script below gets files from a server
# to make that work that seerver needs to have your ssh keys in the ssh trusted keys
## if I am hanscees and I connect root@xxxxx  the keys of hanscees must be in the .ssh/authorized_keys files of root@xxxx on server xxxx
#####
#root@debian2020:~# cat .ssh/authorized_keys
#ssh-rsa AAAABp.... hanscees@hanscees-late2018
###############
# they key is the .ssh/id_rsa/pub key
# run ssh-keygen
#cd /var/lib/docker/volumes/tomavmail_ssl/_data/
#scp -i ~/.ssh/id_rsa root@192.168.0.15:/etc/letsencrypt/live/mail2.hanscees.net-0003/*.pem .

#To copy a file called rebels.txt from your home directory on empire.gov to a directory called revenge in your account #on the computer #deathstar.com, enter:
#scp ~/rebels.txt dvader@deathstar.com:~/revenge


### backup the files now with ssh scp
## make sure you tested ssh to vault4 and added keys to authorized_keys
#BackupDir="/root/backuptmp"
cd $BackupDir

### works from mail.hanscees.com
scp -i ~/.ssh/backup_rsa $Backupfile_S \
$ScpTarget:$BackupToDir


# check if all went well: if so $? will be 1
if [ $? -eq 0 ]; then
   echo scp copy went OK
   logger small backup was succesfully copied to backup server
else
   echo FAIL
   logger small backup was NOT copied to backup server
fi
