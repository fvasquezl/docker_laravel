FROM php:7.2-fpm-buster as php

# Set environment variables
ENV PHP_OPCACHE_ENABLE=1
ENV PHP_OPCACHE_ENABLE_CLI=0
ENV PHP_OPCACHE_VALIDATE_TIMESTAMPS=0
ENV PHP_OPCACHE_REVALIDATE_FREQ=0
ENV ACCEPT_EULA=Y

ARG DEBIAN_FRONTEND=noninteractive

RUN usermod -u 1000 www-data

RUN apt-get update && apt-get -y install --no-install-recommends unzip \
    libpq-dev libcurl4-gnutls-dev nginx libonig-dev 

# Install selected extensions and other stuff
RUN apt-get update \
    && apt-get -y --no-install-recommends install apt-utils libxml2-dev gnupg apt-transport-https \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*

# Install git
RUN apt-get update \
    && apt-get -y install git \
    && apt-get clean; rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/*


# Install PHP extensions.
RUN docker-php-ext-install  bcmath curl opcache mbstring

WORKDIR /var/www

COPY --chown=www-data:www-data . .

# Copy configuration files.
COPY ./docker/php/php.ini /usr/local/etc/php/php.ini
COPY ./docker/php/php-fpm.conf /usr/local/etc/php-fpm.d/www.conf
COPY ./docker/nginx/nginx.conf /etc/nginx/nginx.conf

# Install php-sqlsrv
RUN curl https://packages.microsoft.com/keys/microsoft.asc | tee /etc/apt/trusted.gpg.d/microsoft.asc \
    && curl https://packages.microsoft.com/config/debian/10/prod.list | tee /etc/apt/sources.list.d/mssql-release.list \
    && apt-get update \
    && apt-get install -y msodbcsql17 unixodbc-dev \
    && pecl install sqlsrv-5.2.0 \
    && pecl install pdo_sqlsrv-5.2.0 

# Run the entrypoint file.
ENTRYPOINT [ "docker/entrypoint.sh" ]