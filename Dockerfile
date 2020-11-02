# Download Ubuntu Image
FROM ubuntu:18.04
# Set the Image Maintainer
LABEL maintainer="Aperture Development <webmaster@Aperture-Development.de>"
# Disable interactive questions
ENV DEBIAN_FRONTEND noninteractive
# Prepare Container enviroment
RUN apt-get update &&\
    apt-get install -y git mysql-client libsmbclient-dev libssh2-1-dev libssh-dev libssl-dev libaio-dev php7.2-cli php7.2-gd php7.2-imap php7.2-mysql php7.2-curl libmysqlclient-dev build-essential libmatheval-dev libmagic-dev libgd-dev libwebsockets-dev rsync valgrind-dbg libxml2-dev php7.2-readline cmake ssh make libssh-dev php7.2-zip libsqlite3-dev &&\
    useradd -ms /bin/bash friendup &&\
    apt-get clean autoclean &&\
    apt-get autoremove -y &&\
    rm -rf /var/lib/apt/lists/*
#    apt-get install -y git mysql-client libsqlite3-dev libsmbclient-dev libssh2-1-dev libssh-dev libaio-dev build-essential libmatheval-dev libmagic-dev libgd-dev rsync valgrind-dbg libxml2-dev php-readline cmake ssh curl build-essential python php php-cli php-gd php-imap php-mysql php-curl php-readline default-libmysqlclient-dev libsqlite3-dev libsmbclient-dev libuv1-dev libwebsockets-dev
# Check for Repository changes and invalidate the docker cache when there was one
ADD https://api.github.com/repos/FriendUPCloud/friendup/git/refs/heads/master friendup_version.json
ADD https://api.github.com/repos/Aperture-Development/friendup-docker/git/refs/heads/master friendup_docker_version.json
# Create friendup directory and Temporary directory. Then clone friend into the temp directory
RUN mkdir /opt/friendup &&\
    mkdir /buildTemp &&\
    git clone https://github.com/FriendUPCloud/friendup /buildTemp
# Copy our Entrypoint into the container and make it executable
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
# Build friend
RUN cd /buildTemp &&\
    make clean setup &&\
    make compile install
# Move friendup to the right location and delete the temporary folder
RUN cp -r /buildTemp/build/* /opt/friendup &&\
    mkdir /opt/friendup/db &&\
    cp -r /buildTemp/db/* /opt/friendup/db &&\
    rm -rf /buildTemp
# Copy sample ini into friendup and change user for advanced security
COPY cfg.ini.sample /opt/friendup/cfg/cfg.ini.sample
RUN chown -R friendup:friendup /opt/friendup &&\
    chown friendup:friendup /opt/friendup/cfg
USER friendup
WORKDIR /opt/friendup
# Set the entrypoint for the container
ENTRYPOINT ["/entrypoint.sh"]
