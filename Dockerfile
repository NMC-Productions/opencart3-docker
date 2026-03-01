# ---------------------------------------------------------
# 1. Builder stage — download & extract OpenCart
# ---------------------------------------------------------
FROM debian:stable-slim AS builder

ARG OC_VERSION=3.0.5.0

RUN apt-get update && apt-get install -y \
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
# 2. Runtime stage — PHP FPM
# ---------------------------------------------------------
FROM php:8.4-fpm

RUN apt-get update && apt-get install -y \
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

WORKDIR /var/www
RUN mkdir -p html

# Copy OpenCart from builder
COPY --from=builder /build/upload/ html/

RUN mv /var/www/html/config-dist.php /var/www/html/config.php && mv /var/www/html/admin/config-dist.php /var/www/html/admin/config.php

# Replace MyISAM engine with InnoDB, as MyISAM is unsupported by most cloud providers
RUN sed -i 's/ENGINE=MyISAM/ENGINE=InnoDB/g' /var/www/html/install/opencart.sql

RUN cp /var/www/html/php.ini /usr/local/etc/php/

# This is temporary, only for OpenCart to install/move its stuff; entrypoint.sh secures the folders at the 2nd server startup
RUN chown -R www-data:www-data /var/www

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 9000
