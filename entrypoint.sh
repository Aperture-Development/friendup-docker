#!/bin/bash

# Check if friend already exists
if [ -e /friend/core/FriendCore ]; then
    unset MYSQL_USER
    unset MYSQL_PASSWORD
    unset MYSQL_DATABASE
    unset MYSQL_ROOT_PASSWORD
    nohup ./friend/core/FriendCore >> /dev/null &
else
    git clone
    ./friend/friendup/install.sh
    unset MYSQL_USER
    unset MYSQL_PASSWORD
    unset MYSQL_DATABASE
    unset MYSQL_ROOT_PASSWORD
fi

if [ "$DOCKER_FRIEND_FEATURE_CHAT" -eq "1" ]; then
    ./friend/friendup/installFriendChat.sh
else
    echo "FriendChat feature has not been selected."
fi

if [ "$DOCKER_FRIEND_FEATURE_NETWORK" -eq "1" ]; then
    ./friend/friendup/installFriendNetwork.sh   
else
    echo "FriendNetwork feature has not been selected."
fi