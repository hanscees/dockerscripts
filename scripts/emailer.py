#!/usr/bin/python3.6
# Python emailer for script using smtplib
# only for simple email to an ip-adress accepting port 25 simple email
#smtp client, you pust install python3, pip3 and smtplib
import argparse
import sys
import smtplib
import socket
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart

#we want to be able to do
# echo yo | mail -s subject -to hanscees@hanscees.con -body
# or
#  mail -s subject -to hanscees@hanscees.com -body  sometext and so on
# and the script should send this to smtp server at variable local-smtp-server-ip

hostname = socket.gethostname()
sender = "root@"

LocalSmtpServerIp = "192.168.4.1"
From = sender + hostname
print(From)

parser = argparse.ArgumentParser()
parser.add_argument("-s", "--subject", required=True, help="subject email message" )
parser.add_argument("-to", "--recipient", required=True, help="recipient of the  email message" )
parser.add_argument("-body", "--mailbody", required=True, nargs='*', help="body of the  email message" )

args = parser.parse_args()
Subject = args.subject
print("subject is",  Subject )
To = args.recipient
print("mail goes to",To )

#if body has text, ignore pipe input, if body has no text read pipe, if pipe empty body is there is no text
if args.mailbody:
  Body = str(args.mailbody)
  print("body is", Body )
elif not sys.stdin.isatty():
  Body = sys.stdin.read()
  print("body is stdin",Body)
else:
  Body = " his email was sent empty"
  print("body is empty")

html = ""
text = Body
msg = MIMEMultipart("alternative")
parttxt = MIMEText(text, 'plain')

msg['Subject'] = Subject
msg['From'] = From
msg['To'] = To
#part2 = MIMEText(html, 'html')
msg.attach(parttxt)

# Send the message
server = smtplib.SMTP(LocalSmtpServerIp)
#server.set.debuglevel(1)
server.sendmail(From, To, msg.as_string())
server.quit()
