#!/bin/bash
export MYSQL_PWD="$MYSQL_PASSWORD"

# Check for old file structure
if [ -d '/friendup/build/storage' ]; then
    echo "[ERROR] Old filestructure found, please get the new version of the docker-compose.yml file here:"
    echo "https://github.com/Aperture-Development/friendup-docker"
    exit 1
fi

# Check if database is ready
RESULT="FirstStart"
until [ "$RESULT" == "mysqld is alive" ]
do
    echo "[ENTRY] MariaDB didn't finish starting yet"
    sleep 10s
    RESULT=$(mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h friendup-db --protocol=tcp)
done

# Check if Database Exists, if not create it
RESULT=$(echo $(mysql -u"$MYSQL_USER" -hfriendup-db --protocol=tcp -D"$MYSQL_DATABASE" -Bse 'SHOW TABLES' -D"$MYSQL_DATABASE" | wc -l))
if [ "$RESULT" == "0" ]; then
    echo '[ENTRY] Creating Database'
    mysql -u"$MYSQL_USER" -D"$MYSQL_DATABASE" -hfriendup-db --protocol=tcp < /opt/friendup/db/FriendCoreDatabase.sql

    for i in $(ls -v /opt/friendup/sqlupdatescripts/); do
        echo "[ENTRY] Running $i"
        mysql -u"$MYSQL_USER" -D"$MYSQL_DATABASE" -hfriendup-db --protocol=tcp < /opt/friendup/sqlupdatescripts/"$i"
    done;
fi

# Check if the config FIle already exists, if not create it
if [ ! -f '/opt/friendup/cfg/cfg.ini' ]; then
    touch /opt/friendup/cfg/cfg.ini
    echo '[DatabaseUser]'                   >> /opt/friendup/cfg/cfg.ini
    echo 'host=friendup-db'                 >> /opt/friendup/cfg/cfg.ini
    echo "login=$MYSQL_USER"                >> /opt/friendup/cfg/cfg.ini
    echo "password=$MYSQL_PASSWORD"         >> /opt/friendup/cfg/cfg.ini
    echo "dbname=$MYSQL_DATABASE"           >> /opt/friendup/cfg/cfg.ini
    echo ''                                 >> /opt/friendup/cfg/cfg.ini
    echo '[FriendCore]'                     >> /opt/friendup/cfg/cfg.ini
    echo "fchost = $DOCKER_FRIEND_DOMAIN"   >> /opt/friendup/cfg/cfg.ini
    echo 'port = 6502'                      >> /opt/friendup/cfg/cfg.ini
    echo 'fcupload = storage/'              >> /opt/friendup/cfg/cfg.ini
    echo ''                                 >> /opt/friendup/cfg/cfg.ini
    echo '[Core]'                           >> /opt/friendup/cfg/cfg.ini
    echo 'SSLEnable=0'                      >> /opt/friendup/cfg/cfg.ini
    echo 'port=6502'                        >> /opt/friendup/cfg/cfg.ini
    echo ''                                 >> /opt/friendup/cfg/cfg.ini
    echo '[FriendNetwork]'                  >> /opt/friendup/cfg/cfg.ini
    echo 'enabled = 0'                      >> /opt/friendup/cfg/cfg.ini
    echo ''                                 >> /opt/friendup/cfg/cfg.ini
    echo '[FriendChat]'                     >> /opt/friendup/cfg/cfg.ini
    echo 'enabled = 0'                      >> /opt/friendup/cfg/cfg.ini
    echo '[ENTRY] Created new config file'
fi

# Finish up and start Friend
unset MYSQL_PWD
cd /opt/friendup/
/opt/friendup/FriendCore