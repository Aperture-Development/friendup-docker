# FriendUP Docker
![Build Status](https://tcci.aperture-development.de/app/rest/builds/buildType:(id:FriendUP_Docker)/statusIcon.svg) ![Licence](https://img.shields.io/badge/licence-MIT-brightgreen)

This is the repository for the FriendUP docker container. The purpose of this is to allow people to easily deploy FriendUP without complicated setups or anything. We achive that using the Docker Platform, Docker containers are pre-setup and ready-to-deploy application containers.

# How to Deploy

Currently FriendUP Docker requires you to use Docker-Compose, a easy way to deploy multible dependant applications at once, without the need to configure them all one by one.

1. Download or Clone this repository to your server/node/computer where you want FriendUP to be installed
2. Change the .env file to fit your configuration
3. Navigate into the folder using a cli and type ``docker-compose up``
4. After a few minutes FriendCore should be starting up and you should be able to reach Friend on port 6502

You might want to use a reverse proxy redirecting the friend domain to the docker container. Here is a usefull guide how to do that with Apache: https://www.digitalocean.com/community/tutorials/how-to-use-apache-http-server-as-reverse-proxy-using-mod_proxy-extension


# Enviroment Variables

**MYSQL_USER** - The Database username

**MYSQL_PASSWORD** - The Password for the database user

**MYSQL_DATABASE** - The to be used database name

**MYSQL_ROOT_PASSWORD** - The password of the databases root user

**DOCKER_FRIEND_DOMAIN** - the domain friend will run under

# Updating FriendUP

To update friend go back to the place of the docker-compose.yml file using a cli and type ``docker-compose down`` this will stop and remove the containers ( Don't worry, your data is safe ). After you done that just type ``docker-compose up`` again and the container should be updated

# Additional Info

FriendUP: https://github.com/FriendUPCloud/friendup
Docker: https://www.docker.com/
Docker-Compose: https://docs.docker.com/compose/

This repository and the code is licenced under MIT.

The FriendUP-Docker container has been made by [Aperture Development](https://www.aperture-development.de/). We are in no way owning or claiming ownership over FriendUP and it's code. 