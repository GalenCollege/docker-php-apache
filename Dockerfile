FROM php:7.4-apache
WORKDIR /var/www/html

ENV ACCEPT_EULA=Y

LABEL version="1.2"
LABEL description="Base PHP install for docker. Mount /var/www/html to volume or bind location."
LABEL maintainer="Chris Howatt <chowatt@galencollege.edu>"

# Fix debconf warnings upon build
ARG DEBIAN_FRONTEND=noninteractive

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install apt-utils libxml2-dev gnupg apt-transport-https ldb-dev libldap openldap-dev gnupg \
    && libc-client-dev libkrb5-dev libxml2-dev libbz2-dev zlib1g-dev libpng-dev libicu-dev libldap2-dev vim \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git wget \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* \
    && wget http://archive.ubuntu.com/ubuntu/pool/main/g/glibc/multiarch-support_2.27-3ubuntu1.5_amd64.deb \
    && apt-get install ./multiarch-support_2.27-3ubuntu1.5_amd64.deb

# Install MS ODBC Driver for SQL Server / PHP Extensions
RUN apt-get update \
    && apt-get -y install gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add \
    && curl https://packages.microsoft.com/config/debian/10/prod.list > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && ACCEPT_EULA=Y apt-get install -y msodbcsql17 \
    && apt-get install -y unixodbc-dev \
    && pecl install sqlsrv \
    && pecl install pdo_sqlsrv \
    && printf "priority=20\nextension=sqlsrv.so\n" > /usr/local/etc/php/conf.d/sqlsrv.ini \
    && printf "priority=30\nextension=pdo_sqlsrv.so\n" > /usr/local/etc/php/conf.d/pdo_sqlsrv.ini \
    && apt-get -y install libldb-dev libldap2-dev libicu-dev libzip-dev zip zlib1g-dev libpng-dev libzip-dev libodbc1\
    && docker-php-ext-install pdo_mysql ldap intl zip gd \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*
  

RUN a2enmod rewrite
RUN php -m
