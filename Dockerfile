from php:apache

LABEL version="1.0"
LABEL description="Base PHP install for docker. Mount /var/www/html to volume or bind location."
LABEL maintainer="Chris Howatt <chowatt@galencollege.edu>"

RUN apt-get update && apt-get install -y git libc-client-dev libkrb5-dev libxml2-dev libbz2-dev zlib1g-dev libpng-dev libicu-dev libldap2-dev vim && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-install pdo_mysql mysqli gd intl ldap xmlrpc

RUN apt-get update && apt-get install -y libzip* && rm -r /var/lib/apt/lists/*
RUN docker-php-ext-install zip opcache exif
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl && docker-php-ext-install imap

RUN curl https://getcomposer.org/installer | php && mv composer.phar /bin
RUN a2enmod rewrite

ENV ACCEPT_EULA=Y

RUN apt-get update \
    && apt install -y gnupg \
    && curl https://packages.microsoft.com/keys/microsoft.asc | apt-key add - \
    && curl https://packages.microsoft.com/config/debian/9/prod.list \
        > /etc/apt/sources.list.d/mssql-release.list \
    && apt-get install -y --no-install-recommends \
        locales \
        apt-transport-https \
    && echo "en_US.UTF-8 UTF-8" > /etc/locale.gen \
    && locale-gen \
    && apt-get update \
    && apt-get -y --no-install-recommends install \
        unixodbc-dev \
        msodbcsql17 \
        libonig-dev \
    && rm -r /var/lib/apt/lists/*

RUN pecl install sqlsrv pdo_sqlsrv xdebug \
    && docker-php-ext-enable sqlsrv pdo_sqlsrv xdebug
