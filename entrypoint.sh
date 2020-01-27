#!/bin/bash

# Check if database is ready
RESULT="FirstStart"
until [ "$RESULT" == "mysqld is alive" ]
do
    echo "[ENTRY] MariaDB didn't finish starting yet"
    sleep 10s
    RESULT=$(mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h friendup-db --protocol=tcp)
done

# Check if Database Exists, if not create it
RESULT=$(echo $(mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -hfriendup-db --protocol=tcp -D"$MYSQL_DATABASE" -Bse 'SHOW TABLES' -D"$MYSQL_DATABASE" | wc -l))
if [ "$RESULT" == "0" ]; then
    echo '[ENTRY] Creating Database'
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -D"$MYSQL_DATABASE" -hfriendup-db --protocol=tcp < /friendup/db/FriendCoreDatabase.sql
fi

# Check if the config FIle already exists, if not create it
if [ -f '/friendup/build/cfg/cfg.ini' ]; then
    echo '[ENTRY] Configuration found, starting FriendCore'
    cd /friendup/build/
    /friendup/build/FriendCore
else
    if [ -f '/dockervolume/cfg.ini' ]; then
        cp /dockervolume/cfg.ini /friendup/build/cfg/cfg.ini
        echo '[ENTRY] Found config file, copying it back over'
    else
        touch /friendup/build/cfg/cfg.ini
        echo '[DatabaseUser]' >> /friendup/build/cfg/cfg.ini
        echo 'host=friendup-db' >> /friendup/build/cfg/cfg.ini
        echo "login=$MYSQL_USER" >> /friendup/build/cfg/cfg.ini
        echo "password=$MYSQL_PASSWORD" >> /friendup/build/cfg/cfg.ini
        echo "dbname=$MYSQL_DATABASE" >> /friendup/build/cfg/cfg.ini
        echo '' >> /friendup/build/cfg/cfg.ini
        echo '[FriendCore]' >> /friendup/build/cfg/cfg.ini
        echo "fchost = $DOCKER_FRIEND_DOMAIN" >> /friendup/build/cfg/cfg.ini
        echo 'port = 6502' >> /friendup/build/cfg/cfg.ini
        echo 'fcupload = storage/' >> /friendup/build/cfg/cfg.ini
        echo '' >> /friendup/build/cfg/cfg.ini
        echo '[Core]' >> /friendup/build/cfg/cfg.ini
        echo 'SSLEnable=0' >> /friendup/build/cfg/cfg.ini
        echo 'port=6502' >> /friendup/build/cfg/cfg.ini
        echo '' >> /friendup/build/cfg/cfg.ini
        echo '[FriendNetwork]' >> /friendup/build/cfg/cfg.ini
        echo 'enabled = 0' >> /friendup/build/cfg/cfg.ini
        echo '' >> /friendup/build/cfg/cfg.ini
        echo '[FriendChat]' >> /friendup/build/cfg/cfg.ini
        echo 'enabled = 0' >> /friendup/build/cfg/cfg.ini
        cp /friendup/build/cfg/cfg.ini /dockervolume/cfg.ini
        echo '[ENTRY] Created new config file'
    fi
    cd /friendup/build/
    /friendup/build/FriendCore > /firstrun.log&
    echo '[ENTRY] Please wait while we prepare everything...'
    until [ "$RESULT" == "Starting FriendCore" ]
    do
        sleep 10s
        RESULT=$(grep -o 'Starting FriendCore' /firstrun.log)
    done
    sleep 10s
    PID=$(pidof FriendCore)
    kill -9 "$PID"
    
fi