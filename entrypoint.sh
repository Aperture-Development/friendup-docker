#!/bin/bash

# Check if database is ready
RESULT="FirstStart"
until [ "$RESULT" == "mysqld is alive" ]
do
    echo "MariaDB didn't finish starting yet"
    sleep 5s
    RESULT=$(mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h friendup-db --protocol=tcp)
done

# Check if Database Exists, if not create it
RESULT=$(echo '$(mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -hfriendup-db --protocol=tcp -D"$MYSQL_DATABASE" -Bse 'SHOW TABLES' -D"$MYSQL_DATABASE")' | wc -l)
if [ "$RESULT" == "1" ]; then
    mysql -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -D"$MYSQL_DATABASE" -hfriendup-db --protocol=tcp < /friendup/db/FriendCoreDatabase.sql
fi
echo "$RESULT"

# Check if the config FIle already exists, if not create it
if [ -f '/friendup/build/cfg/cfg.ini' ]; then
    cd /friendup/build/
    /friendup/build/FriendCore
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
    cd /friendup/build/
    /friendup/build/FriendCore
fi