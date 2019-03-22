# Download Ubuntu Image
FROM ubuntu:18.04

LABEL maintainer="Aperture Development <webmaster@Aperture-Development.de>"

ENV DEBIAN_FRONTEND noninteractive

RUN apt update
RUN 

CMD [ "echo", "Hello World!" ]
