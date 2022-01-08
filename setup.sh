#!/bin/bash

echo "(Re)installing Brew Packages"

brew tap shivammathur/php
brew install php@8.0 php@7.3 php@5.6 nginx dnsmasq mkcert

echo "Renaming existing files to backups"

mv -v /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.bak
mv -v /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
mv -v /usr/local/bin/php /usr/local/bin/php.bak

echo "Creating symlinks to new files"

working_directory=$(pwd)

ln -vs "$working_directory/dnsmasq.conf" /usr/local/etc/dnsmasq.conf
ln -vs "$working_directory/nginx/nginx.conf" /usr/local/etc/nginx/nginx.conf
ln -vs "$working_directory/nginx/snippets" /usr/local/etc/nginx/snippets
ln -vs "$working_directory/php.sh" /usr/local/bin/php

echo "Adding home directory snippet to nginx configs"

echo "set \$home_directory $HOME;" > ./nginx/snippets/home-directory.conf

echo "Tweaking php.ini listen option to use sockets"

mv -v /usr/local/etc/php/7.3/php-fpm.d/www.conf /usr/local/etc/php/7.3/php-fpm.d/www.conf.bak
mv -v /usr/local/etc/php/8.0/php-fpm.d/www.conf /usr/local/etc/php/8.0/php-fpm.d/www.conf.bak

sed -E 's!^listen =.+$!listen = /usr/local/var/run/php/php7.3-fpm.sock!g' /usr/local/etc/php/7.3/php-fpm.d/www.conf.bak > /usr/local/etc/php/7.3/php-fpm.d/www.conf
sed -E 's!^listen =.+$!listen = /usr/local/var/run/php/php8.0-fpm.sock!g' /usr/local/etc/php/8.0/php-fpm.d/www.conf.bak > /usr/local/etc/php/8.0/php-fpm.d/www.conf

echo "Creating PHP FPM socket directory"

mkdir -pv /usr/local/var/run/php

echo "Creating wildcard self-signed certificate for *.test domain"

mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.test-key.pem \
       "*.test"

echo "Adding custom resolver for *.test domain"

# Source: https://firxworx.com/blog/it-devops/sysadmin/using-dnsmasq-on-macos-to-setup-a-local-domain-for-development/
sudo mkdir -pv /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'

echo "Checking NGINX configuration file syntax"

nginx -t

echo "Starting Brew Services"

sudo brew services restart dnsmasq
brew services restart php@7.3
brew services restart php@8.0
brew services restart nginx
