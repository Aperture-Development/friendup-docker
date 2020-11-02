#!/bin/bash
export MYSQL_PWD="$MYSQL_PASSWORD"

# Check for old file structure
if [ -d '/friendup/build/storage' ]; then
    echo "[ERROR] Old filestructure found, please get the new version of the docker-compose.yml file here:"
    echo "https://github.com/Aperture-Development/friendup-docker"
    exit 1
fi

# Check if MYSQL_HOST enviroment variable is empty, if yes set it to default value
if [ -z "$MYSQL_HOST" ]; then
    MYSQL_HOST="friendup-db"
fi

# Check if database is ready
RESULT=$(mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h"$MYSQL_HOST" --protocol=tcp)
until [ "$RESULT" == "mysqld is alive" ]
do
    echo "[INFO] Could not connect to Database, retrying in 10 seconds"
    sleep 10s
    RESULT=$(mysqladmin ping -u"$MYSQL_USER" -p"$MYSQL_PASSWORD" -h"$MYSQL_HOST" --protocol=tcp)
done

# Check if Database Exists, if not create it
RESULT=$(echo $(mysql -u"$MYSQL_USER" -h"$MYSQL_HOST" --protocol=tcp -D"$MYSQL_DATABASE" -Bse 'SHOW TABLES' -D"$MYSQL_DATABASE" | wc -l))
if [ "$RESULT" == "0" ]; then
    echo '[INFO] Creating Database'
    mysql -u"$MYSQL_USER" -D"$MYSQL_DATABASE" -h"$MYSQL_HOST" --protocol=tcp < /opt/friendup/db/FriendCoreDatabase.sql

    for i in $(ls -v /opt/friendup/sqlupdatescripts/); do
        echo "[INFO] Running $i"
        mysql -u"$MYSQL_USER" -D"$MYSQL_DATABASE" -h"$MYSQL_HOST" --protocol=tcp < /opt/friendup/sqlupdatescripts/"$i"
    done;
fi

if [ ! -f '/opt/friendup/cfg/crt/key.pem' ]; then
    # generate new ssl certificate
    openssl req -nodes -sha512 -x509 -days 3650 -newkey rsa:2048 -keyout /opt/friendup/cfg/crt/key.pem -out /opt/friendup/cfg/crt/certificate.pem -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=$DOCKER_FRIEND_DOMAIN"
else
    # generate csr from existing key
    openssl req -new -sha512 -x509 -nodes -days 3650 -key /opt/friendup/cfg/crt/key.pem -out /opt/friendup/cfg/crt/certificate.pem -subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=$DOCKER_FRIEND_DOMAIN"
fi

# Check if the config File already exists, if not create it
if [ ! -f '/opt/friendup/cfg/cfg.ini' ]; then
    cp /opt/friendup/cfg/cfg.ini.sample /opt/friendup/cfg/cfg.ini
    sed -i "s/#DB_USER#/$MYSQL_USER/" /opt/friendup/cfg/cfg.ini
    sed -i "s/#DB_PASS#/$MYSQL_PASSWORD/" /opt/friendup/cfg/cfg.ini
    sed -i "s/#DB_HOST#/$MYSQL_HOST/" /opt/friendup/cfg/cfg.ini
    sed -i "s/#DB_NAME#/$MYSQL_DATABASE/" /opt/friendup/cfg/cfg.ini
    sed -i "s/#FRND_DOMAIN#/$DOCKER_FRIEND_DOMAIN/" /opt/friendup/cfg/cfg.ini
    echo '[INFO] Created new config file'
fi

# Finish up and start Friend
unset MYSQL_PWD
cd /opt/friendup/
/opt/friendup/FriendCore