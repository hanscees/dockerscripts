readme-to-install

To use the scripts form docker install you must
- clone them
   git clone https://github.com/hanscees/dockerscripts/ ~/testds/
   cd testds/scripts

-chmod them 
   chmod +x *.sh
   chmod +x  *.py

- install qs 
  apt-get install qs

- install pythno3.6 plus smtplib
  apt-get install python3 python3-pip

send mail like
echo yo yo yo | ./emailer.py -s " keep the fish"   -to hanscees@hanscees.con -body 