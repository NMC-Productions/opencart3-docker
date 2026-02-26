# ---------------------------------------------------------
# 1. Builder stage — download & extract OpenCart
# ---------------------------------------------------------
FROM debian:stable-slim AS builder

ARG OC_VERSION=3.0.5.0

RUN apt-get update && apt-get install -y --no-install-recommends \
        unzip \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

RUN curl -L -o opencart.zip \
      https://github.com/opencart/opencart/archive/refs/tags/${OC_VERSION}.zip \
    && unzip opencart.zip \
    && mv opencart-${OC_VERSION}/upload ./upload \
    && rm -rf opencart.zip opencart-${OC_VERSION}

# ---------------------------------------------------------
# 2. Runtime stage — minimal PHP + Apache
# ---------------------------------------------------------
FROM php:8.4-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
        vim \
        zlib1g-dev \
        libgd-dev \
        libfreetype6-dev \
        libjpeg-dev \
        libpng-dev \
        libwebp-dev \
        libzip-dev \
 && docker-php-ext-configure gd \
      --with-external-gd \
      --with-freetype \
      --with-jpeg \
      --with-webp \
 && docker-php-ext-install gd mysqli zip \
 && rm -rf /var/lib/apt/lists/*

RUN echo "Listen 8080" > /etc/apache2/ports.conf \
    && sed -i "s/<VirtualHost \*:80>/<VirtualHost \*:8080>/" /etc/apache2/sites-available/000-default.conf

WORKDIR /var/www
RUN mkdir -p html

# Copy OpenCart from builder
COPY --from=builder /build/upload/ html/

RUN mv /var/www/html/config-dist.php /var/www/html/config.php && mv /var/www/html/admin/config-dist.php /var/www/html/admin/config.php

RUN cp /var/www/html/php.ini /usr/local/etc/php/

# This is temporary, only for OpenCart to install/move its stuff; entrypoint.sh secures the folders at the 2nd server startup
RUN chown -R www-data:www-data /var/www

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8080
