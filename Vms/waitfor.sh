#!/bin/bash
USER=$1
HOST=$2
FILESPEC=$3

RESULT=1
while [ $RESULT = 1 ]
do
    sleep 1
    ssh -q -n -o BatchMode=yes -o StrictHostKeyChecking=no $USER@$HOST "test -e $FILESPEC"
    RESULT=$?
    if [ "$RESULT" = "255" ]; then
        (>&2 echo "waitfor failed in ssh")
        exit 255
    fi
done
exit 0

