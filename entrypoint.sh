#!/bin/bash

# Check if Database Exists, if not create it
RESULT=`mysqlshow --host=friendup-mariadb --user=root --password=$MYSQL_ROOT_PASSWORD friendup| grep -v Wildcard | grep -o friendup`
if [ "$RESULT" == "friendup" ]; then
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -hfriendup-mariadb -e "CREATE DATABASE $MYSQL_DATABASE;CREATE USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; GRANT ALL PRIVILEGES ON '$MYSQL_DATABASE'.* TO '$MYSQL_USER'@'%' WITH GRANT OPTION;"
    mysql -uroot -p"$MYSQL_ROOT_PASSWORD" -hfriendup-mariadb < /friendup/db/FriendCoreDatabase.sql
fi

# Check if the config FIle already exists, if not create it
if [ -f '/friendup/build/cfg/cfg.ini' ]; then
    cd /friendup/build/
    /friendup/build/FriendCore
else
    touch /friendup/build/cfg/cfg.ini
    echo '[DatabaseUser]' >> /friendup/build/cfg/cfg.ini
    echo 'host=friendup-mariadb' >> /friendup/build/cfg/cfg.ini
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