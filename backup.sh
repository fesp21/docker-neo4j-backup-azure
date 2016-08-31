#!/bin/bash

if [ "$BACKUP_WINDOW" == "" ]; then

    BACKUP_WINDOW="0 6 * * * ";

fi

sed 's,{{NEO4J_HOST}},'"${NEO4J_HOST}"',g' -i /backup/functions.sh
sed 's,{{NEO4J_PORT}},'"${NEO4J_PORT}"',g' -i /backup/functions.sh
sed 's,{{DB_USER}},'"${DB_USER}"',g' -i /backup/functions.sh
sed 's,{{DB_PASSWORD}},'"${DB_PASSWORD}"',g' -i /backup/functions.sh
sed 's,{{DB_NAME}},'"${DB_NAME}"',g' -i /backup/functions.sh
sed 's,{{DEBUG}},'"${DEBUG}"',g' -i /backup/functions.sh
sed 's,{{AZURE_STORAGE_ACCOUNT}},'"${AZURE_STORAGE_ACCOUNT}"',g' -i /backup/functions.sh
sed 's,{{AZURE_STORAGE_ACCESS_KEY}},'"${AZURE_STORAGE_ACCESS_KEY}"',g' -i /backup/functions.sh
sed 's,{{FILENAME}},'"${FILENAME}"',g' -i /backup/functions.sh
sed 's,{{CONTAINER}},'"${CONTAINER}"',g' -i /backup/functions.sh

if  [ "$ONE_SHOOT" == "true" ]; then

    . /backup/functions.sh;
    exit 0

else

    touch /var/log/cron.log;
    echo "$BACKUP_WINDOW /backup/variable.sh & /backup/functions.sh >> /var/log/cron.log 2>&1" >> job;
    echo "" >> job
    crontab job; cron;
    tail -f /var/log/cron.log;
    exit $?

fi
