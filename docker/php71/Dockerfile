FROM php:7.1-fpm-alpine

COPY --from=composer:1.5 /usr/bin/composer /usr/bin/composer

ARG BITBUCKET_CONSUMER_KEY
ARG BITBUCKET_CONSUMER_SECRET
ARG PHP_UPSTREAM_PORT

ENV COMPOSER_AUTH "{\"bitbucket-oauth\":{\"bitbucket.org\":{\"consumer-key\":\"$BITBUCKET_CONSUMER_KEY\",\"consumer-secret\":\"$BITBUCKET_CONSUMER_SECRET\"}}}"
ENV FOLDER_PATH "/var/www/html/"

RUN mkdir -p $FOLDER_PATH \
    && chown -Rf www-data:www-data /var/www

ADD ./docker/php71/php-fpm.conf /etc/php/7.1/fpm/php-fpm.conf
ADD ./docker/php71/www.conf /etc/php/7.1/fpm/pool.d/www.conf

COPY composer.json $FOLDER_PATH
WORKDIR $FOLDER_PATH

RUN apk update \
    && apk upgrade \
    && apk add --no-cache curl \
       libmemcached-dev \
       icu-dev \
       openssl-dev \
       libmcrypt-dev \
       git \
    && docker-php-ext-install mcrypt pdo_mysql intl

COPY . $FOLDER_PATH

RUN mkdir ${FOLDER_PATH}vendor \
    && chgrp -Rf www-data $FOLDER_PATH \
    && chmod -R 0770 ${FOLDER_PATH}storage \
    && chmod -R 0770 ${FOLDER_PATH}vendor

EXPOSE $PHP_UPSTREAM_PORT
CMD ["php-fpm"]