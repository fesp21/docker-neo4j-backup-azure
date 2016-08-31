#!/bin/bash

DATETIME=`date +"%Y-%m-%d_%H-%M-$S"`

if [ "$NO_PASSWORD" == "" ]; then
    export NO_PASSWORD="false";
fi

make_backup () {

    export FILENAME={{FILENAME}}
    export CONTAINER={{CONTAINER}}
    export NEO4J_HOST={{NEO4J_HOST}}
   # export NEO4J_PORT={{NEO4J_PORT}}
    export DB_USER={{DB_USER}}
    export DB_PASSWORD={{DB_PASSWORD}}
    export DB_NAME={{DB_NAME}}
    export DEBUG={{DEBUG}}
    export AZURE_STORAGE_ACCOUNT={{AZURE_STORAGE_ACCOUNT}}
    export AZURE_STORAGE_ACCESS_KEY={{AZURE_STORAGE_ACCESS_KEY}}

   # if [ "$NEO4J_PORT" == "" ]; then
    #    export NEO4J_PORT="6362";
   # fi

    if [ "$FILENAME" == "" ]; then
        export FILENAME="default";
    fi

    if [ "$DEBUG" == "true" ]; then
        echo "######################################"
        echo "FILENAME = $FILENAME"
        echo "CONTAINER = $CONTAINER"
        echo "NEO4J_HOST = $NEO4J_HOST"
       # echo "NEO4J_PORT = $NEO4J_PORT"
        echo "DB_USER = $DB_USER"
        echo "DB_PASSWORD = $DB_PASSWORD"
        echo "AZURE_STORAGE_ACCOUNT = $AZURE_STORAGE_ACCOUNT"
        echo "AZURE_STORAGE_ACCESS_KEY = $AZURE_STORAGE_ACCESS_KEY "
        echo "DB_NAME = $DB_NAME"
        echo "######################################"
    else
        echo "No debug"
    fi

    if [ "$NO_PASSWORD" == "true" ]; then

       # NEO4Jdump --host=$NEO4J_HOST -P $NEO4J_PORT -u $DB_USER $DB_NAME > $FILENAME-$DATETIME.sql;
        cd /var/lib/neo4j/
        ./bin/neo4j-backup -host $NEO4J_HOST -to /mnt/backup/neo4j-backup/$FILENAME-$DATETIME

    else
	cd /var/lib/neo4j/
       # NEO4Jdump --host=$NEO4J_HOST -P $NEO4J_PORT -u $DB_USER --password=$DB_PASSWORD $DB_NAME > $FILENAME-$DATETIME.sql;
       ./bin/neo4j-backup -host $NEO4J_HOST -to /mnt/backup/neo4j-backup/$FILENAME-$DATETIME
    fi

    # exit if last command have problems
    if  [ "$?" != "0" ]; then
        echo "Error occurred in database dump process. Exiting now"
        exit 1
    fi
    # compress the file
    #gzip -9 $FILENAME-$DATETIME.sql
    cd /mnt/backup/neo4j-backup/
    #gzip -9 /mnt/backup/neo4j-backup/$FILENAME-$DATETIME
    tar -zcvf $FILENAME-$DATETIME.tar.gz $FILENAME-$DATETIME    
    # Send to cloud storage
    /usr/local/bin/azure telemetry --disable
    /usr/local/bin/azure storage container create $CONTAINER -c "DefaultEndpointsProtocol=https;BlobEndpoint=https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/;AccountName=$AZURE_STORAGE_ACCOUNT;AccountKey=$AZURE_STORAGE_ACCESS_KEY"
    /usr/local/bin/azure storage blob upload -q /mnt/backup/neo4j-backup/$FILENAME-$DATETIME.tar.gz $CONTAINER -c "DefaultEndpointsProtocol=https;BlobEndpoint=https://$AZURE_STORAGE_ACCOUNT.blob.core.windows.net/;AccountName=$AZURE_STORAGE_ACCOUNT;AccountKey=$AZURE_STORAGE_ACCESS_KEY"

    # Remove file to save space
    rm -fR *.tar.gz

    if  [ "$?" != "0" ]; then
        exit 1
    fi
}

make_backup;
