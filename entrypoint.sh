#!/bin/bash

CONFIG_WEB="/var/www/html/config.php"
CONFIG_WEB_ADMIN="/var/www/html/admin/config.php"
CONFIG_REAL="/var/www/config.php"
CONFIG_REAL_ADMIN="/var/www/config_admin.php"

#This will run only once and only after the OpenCart installation is completed by moving the storage folder.
if grep -q "define('DIR_STORAGE', '/var/www/storage/');" "$CONFIG_WEB" && [ ! -f "$CONFIG_REAL" ]; then

    chown -R root:root /var/www

    mv "$CONFIG_WEB" "$CONFIG_REAL"
    printf "<?php\nrequire_once('/var/www/config.php');\n" > "$CONFIG_WEB"

    if  [ ! -f "$CONFIG_REAL_ADMIN" ]; then
        mv "$CONFIG_WEB_ADMIN" "$CONFIG_REAL_ADMIN"
        printf "<?php\nrequire_once('/var/www/config_admin.php');\n" > "$CONFIG_WEB_ADMIN"
    fi

    chown -R www-data:www-data /var/www/storage/
    chown -R www-data:www-data /var/www/html/image/

    rm -rf /var/www/html/install
fi

exec php-fpm
