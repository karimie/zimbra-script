#!/bin/bash

sndr=$1
subject=$2

#Searching for affected users
echo "Searching and saving for affected users.."
/opt/zimbra/libexec/zmmsgtrace -s $sndr | grep Recipient | awk '{print $2}' > /tmp/affectedusers.txt
AFUSR=`wc -l /tmp/affectedusers.txt|awk '{print $1}'`
echo "Total of $AFUSR are affected.."

SRCF=/tmp/affectedusers.txt
while IFS= read line
do
echo "Checking $line mailbox for SPAM email from $sndr.."

for msg in `/opt/zimbra/bin/zmmailbox -z -m $line s -l 999 -t message "from:$sndr subject:$subject"|awk '{ print $2 }' |awk '{ if (NR!=1) {print}}' | grep -o '[0-9]\+'`
do
echo "Moving $msg from $line to Junk Folder"
/opt/zimbra/bin/zmmailbox -z -m $line mm $msg /Junk
if [ $? == 0 ]
then
echo "..Successfully move message id $msg.."
else
echo "..No message to process.."
fi
done

done < "$SRCF"

echo "Process complete..."

echo "Clearing current session data.."
echo "" > /tmp/affectedusers.txt
