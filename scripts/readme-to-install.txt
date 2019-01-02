readme-to-install

To use the scripts form docker install you must
- clone them
   git clone https://github.com/hanscees/dockerscripts/ ~/testds/
   cd testds/scripts

 or 
 curl https://raw.githubusercontent.com/hanscees/dockerscripts/master/scripts/check-docker-image-updates.sh \
 > check-docker-image-updates.sh
 curl https://raw.githubusercontent.com/hanscees/dockerscripts/master/scripts/get-docker-hub--image-tags.sh \ 
 > get-docker-hub--image-tags.sh
 curl https://raw.githubusercontent.com/hanscees/dockerscripts/master/scripts/get-docker-hub-image-tag-digest.sh \
 > get-docker-hub-image-tag-digest.sh
 curl https://raw.githubusercontent.com/hanscees/dockerscripts/master/scripts/emailer.py \
 > emailer.py


-chmod them 
   chmod +x *.sh
   chmod +x  *.py

- install qs 
  apt-get install jq

To check if your running containers need an update:
1- add info about your running conainers in a file

################### run on dockerhost
> ImageId-file
for i in `docker images -f dangling=false| egrep -v TAG | awk '{print $3}'` ; do
echo copying name, tag and image-ID digest to file
ImageId=`docker image inspect $i | jq -r '.[0] | {Id: .Id}' | egrep Id | awk -F":" '{print $3'} \
| awk -F"\"" '{print $1}'`
ImageData=`docker images | egrep $i | awk '{print $1," " , $2}'`
echo $ImageData $ImageId
echo $ImageData $ImageId >> ImageId-file
done
####################

cat ImageId-file
mv get-docker-hub-image-tag-digest.sh getdigest  #yes its silly
cat ImageId-file | ./check-docker-image-updates.sh








- install pythno3.6 plus smtplib
  apt-get install python3 python3-pip

send mail like
echo yo yo yo | ./emailer.py -s " keep the fish"   -to hanscees@hanscees.con -body 