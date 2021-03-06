#!/bin/bash

php_versions=(
    php@8.0
    php@7.4
    shivammathur/php/php@7.3
)

function php_version_numbers() {
    echo "${php_versions[@]}" | grep -o '[0-9]\.[0-9]';
}

echo "(Re)installing Brew Packages"
    
brew tap shivammathur/php
brew install nginx dnsmasq mkcert nss ${php_versions[@]}

echo "Renaming existing files to backups"

mv -v /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.bak
mv -v /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
mv -v /usr/local/bin/php /usr/local/bin/php.bak
mv -v /usr/local/bin/pecl /usr/local/bin/pecl.bak

echo "Creating symlinks to new files"

working_directory=$(pwd)

ln -vs "$working_directory/dnsmasq.conf" /usr/local/etc/dnsmasq.conf
ln -vs "$working_directory/nginx/nginx.conf" /usr/local/etc/nginx/nginx.conf
ln -vs "$working_directory/nginx/snippets" /usr/local/etc/nginx/snippets
ln -vs "$working_directory/php.sh" /usr/local/bin/php
ln -vs "$working_directory/pecl.sh" /usr/local/bin/pecl

if [[ -f ./nginx/snippets/home-directory.conf ]]; then
    echo "home-directory.conf exists, not creating"
else
    echo "Adding home directory snippet to nginx configs"
    echo "set \$home_directory $HOME;" > ./nginx/snippets/home-directory.conf
fi

echo "Tweaking php.ini listen option to use sockets"

for version_number in $(php_version_numbers); do
    mv -v "/usr/local/etc/php/$version_number/php-fpm.d/www.conf" "/usr/local/etc/php/$version_number/php-fpm.d/www.conf.bak"

    sed -E "s!^listen =.+\$!listen = /usr/local/var/run/php/php$version_number-fpm.sock!g" "/usr/local/etc/php/$version_number/php-fpm.d/www.conf.bak" > "/usr/local/etc/php/$version_number/php-fpm.d/www.conf"
done

echo "Creating PHP FPM socket directory"

mkdir -pv /usr/local/var/run/php

echo "Creating wildcard self-signed certificate for *.dev.test domain"

mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.dev.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.dev.test-key.pem \
       "*.dev.test"

echo "Adding custom resolver for *.dev.test domain"

# Source: https://firxworx.com/blog/it-devops/sysadmin/using-dnsmasq-on-macos-to-setup-a-local-domain-for-development/
sudo mkdir -pv /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'

echo "Checking NGINX configuration file syntax"

nginx -t

echo "Starting Brew Services"

# Apparently `brew services restart` sometimes doesn't work right with dnsmasq if
# it was previously running non-sudo, so we do `start` and `stop` here instead
sudo brew services stop dnsmasq && sudo brew services start dnsmasq

brew services restart nginx

for version_number in $(php_version_numbers); do
    brew services restart "php@$version_number"
done

# Flush the DNS cache
sudo killall -HUP mDNSResponder
