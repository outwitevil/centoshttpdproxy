# vim: set filetype=dockerfile :
FROM: centos:latest
MAINTAINER Adam Lund <adamlund@akamai.com>
LABEL name="CentOS Apache2 Reverse Proxy"
RUN apt-get update
RUN apt-get install -y apache2-utils
RUN rm -rf /var/lib/apt/lists/*

RUN a2enmod proxy
RUN a2enmod proxy_http
RUN a2enmod proxy_ajp
RUN a2enmod deflate
RUN a2enmod proxy_balancer
RUN a2enmod proxy_connect
RUN a2enmod proxy_html
RUN a2enmod xml2enc

ENTRYPOINT /etc/init.d/apache2 restart && echo "Started apache2 deamon for reverse proxing in the background\n String bash now" && /bin/bash