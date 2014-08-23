FROM debian:wheezy
MAINTAINER Richard Fullmer <richardfullmer@gmail.com>

ENV DEBIAN_FRONTEND noninteractive

ENV APACHE_RUN_USER     www-data
ENV APACHE_RUN_GROUP    www-data
ENV APACHE_PID_FILE     /var/run/apache2.pid
ENV APACHE_RUN_DIR      /var/run/apache2
ENV APACHE_LOCK_DIR     /var/lock/apache2
ENV APACHE_LOG_DIR      /var/log/apache2

RUN apt-get update -y && apt-get install -y curl 

# Add php55 dotdeb
RUN echo "deb http://packages.dotdeb.org wheezy all" | tee /etc/apt/sources.list.d/dotdeb.list
RUN echo "deb-src http://packages.dotdeb.org wheezy all" | tee -a /etc/apt/sources.list.d/dotdeb.list
RUN echo "deb http://packages.dotdeb.org wheezy-php55 all" | tee -a /etc/apt/sources.list.d/dotdeb.list
RUN echo "deb-src http://packages.dotdeb.org wheezy-php55 all" | tee -a /etc/apt/sources.list.d/dotdeb.list
RUN curl -s http://www.dotdeb.org/dotdeb.gpg | apt-key add -

# install PHP
RUN apt-get update && apt-get install -y --force-yes php5 apache2 libapache2-mod-php5 php5-pgsql php5-json php5-xsl php5-intl php5-mcrypt \
	php5-gd php5-curl php5-memcached

# apt clean
RUN apt-get clean & rm -rf /var/lib/apt/lists/*

RUN a2enmod rewrite ssl headers php5

# install composer
RUN curl -sS https://getcomposer.org/installer | php && mv composer.phar /usr/local/bin/composer

# Set timezone
#RUN echo $TIMEZONE > /etc/timezone && dpkg-reconfigure --frontend noninteractive tzdata
#RUN sed -i "s@^;date.timezone =.*@date.timezone = $TIMEZONE@" /etc/php5/*/php.ini

ADD 000-default.conf /etc/apache2/sites-available/000-default.conf
#https://github.com/yankcrime/dockerfiles/issues/3
RUN mkdir /var/run/apache2

ADD app.php /var/www/app.php

CMD ["/usr/sbin/apache2", "-D", "FOREGROUND"]

EXPOSE 80 443