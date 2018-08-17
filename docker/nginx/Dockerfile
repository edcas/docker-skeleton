FROM nginx:alpine

ARG PHP_UPSTREAM_CONTAINER
ARG PHP_UPSTREAM_PORT

ADD nginx.conf /etc/nginx/
ADD sites/ /etc/nginx/sites-available/

RUN apk update \
    && apk upgrade \
    && apk add --no-cache bash \
    && adduser -D -H -u 1000 -s /bin/bash www-data \
    && echo "upstream php-upstream { server ${PHP_UPSTREAM_CONTAINER}:${PHP_UPSTREAM_PORT}; }" > /etc/nginx/conf.d/upstream.conf \
    && rm /etc/nginx/conf.d/default.conf

EXPOSE 80 443
CMD ["nginx"]
