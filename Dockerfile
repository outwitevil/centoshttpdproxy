# vim: set filetype=dockerfile :
FROM centos:centos6
MAINTAINER Adam Lund <adamlund@akamai.com>
LABEL name="CentOS HTTPD Reverse Proxy"

RUN yum update -y && yum clean all
RUN yum -y install wget rpm-build dos2unix
RUN rpm -Uvh http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
RUN mkdir -p ~/rpmbuild/{SOURCES,SPECS,BUILD,RPMS,SRPMS}

WORKDIR /root/rpmbuild/SOURCES


RUN wget http://www.webhostingreviewjam.com/mirror/apache/apr/apr-1.5.2.tar.bz2
RUN wget http://www.webhostingreviewjam.com/mirror/apache/apr/apr-util-1.5.4.tar.bz2

RUN yum -y install autoconf libtool doxygen ca-certificates
RUN rpmbuild -tb apr-1.5.2.tar.bz2
RUN rpm -ivh ~/rpmbuild/RPMS/x86_64/apr-1.5.2-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-devel-1.5.2-1.x86_64.rpm

# Install apr-util dependencies
RUN yum -y install expat-devel libuuid-devel db4-devel postgresql-devel mysql-devel freetds-devel unixODBC-devel openldap-devel nss-devel sqlite-devel freetds-devel
RUN rpmbuild -tb apr-util-1.5.4.tar.bz2
RUN rpm -ivh ~/rpmbuild/RPMS/x86_64/apr-util-1.5.4-1.x86_64.rpm ~/rpmbuild/RPMS/x86_64/apr-util-devel-1.5.4-1.x86_64.rpm
RUN yum -y install pcre-devel lua-devel libxml2-devel mailcap
WORKDIR /root/rpmbuild/RPMS
RUN pwd
RUN wget ftp://ftp.pbone.net/mirror/ftp.pramberger.at/systems/linux/contrib/rhel6/x86_64/distcache-lib-1.5.2-0.1.dev.el6.pp.x86_64.rpm


RUN rpm -ivh distcache-lib-1.5.2-0.1.dev.el6.pp.x86_64.rpm
RUN wget ftp://ftp.pbone.net/mirror/ftp.pramberger.at/systems/linux/contrib/rhel6/x86_64/distcache-devel-1.5.2-0.1.dev.el6.pp.x86_64.rpm
RUN rpm -ivh distcache-devel-1.5.2-0.1.dev.el6.pp.x86_64.rpm
WORKDIR /root/rpmbuild/SOURCES
RUN wget http://www.gtlib.gatech.edu/pub/apache/httpd/httpd-2.4.20.tar.bz2
RUN rpmbuild -tb httpd-2.4.20.tar.bz2
WORKDIR /root/rpmbuild/RPMS/x86_64/

RUN rpm -ivh httpd-2.4.20-1.x86_64.rpm
RUN rpm -ivh mod_proxy_html-2.4.20-1.x86_64.rpm




RUN yum clean all

RUN echo "Apache HTTPD"
WORKDIR /
EXPOSE 80 443

ADD etc/httpd/ /etc/httpd/

ADD run-httpd.sh /run-httpd.sh
RUN dos2unix /run-httpd.sh
RUN chmod -v +x /run-httpd.sh

RUN ln -sf /dev/stdout /var/log/httpd/access.log \
	&& ln -sf /dev/stderr /var/log/httpd/error.log

CMD ["./run-httpd.sh"]
