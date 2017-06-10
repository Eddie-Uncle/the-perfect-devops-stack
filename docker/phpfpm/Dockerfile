FROM centos:7
LABEL maintainer "iarlyy@gmail.com"
RUN rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm \  
    && rpm -Uvh http://rpms.remirepo.net/enterprise/remi-release-7.rpm \
    && yum install php56-php-fpm php56-php-gd php56-php-mysqlnd php56-php-mbstring php56-php-xml php56-php-pdo php56-php-soap --enablerepo=remi -y

RUN /bin/mkdir /var/www/html/{sessions,web} -p
RUN /bin/chown nobody. /var/www -R

COPY files/default-fpm-www.conf /opt/remi/php56/root/etc/php-fpm.d/www.conf

EXPOSE 9000

CMD [ "/opt/remi/php56/root/usr/sbin/php-fpm", "--nodaemonize" ]
