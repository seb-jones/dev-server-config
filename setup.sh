echo "Renaming existing files to backups"

mv /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.bak
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
mv /usr/local/bin/php /usr/local/bin/php.bak

echo "Creating symlinks to new files"

working_directory=$(pwd)

ln -s "$working_directory/dnsmasq.conf" /usr/local/etc/dnsmasq.conf
ln -s "$working_directory/nginx/nginx.conf" /usr/local/etc/nginx/nginx.conf
ln -s "$working_directory/nginx/snippets" /usr/local/etc/nginx/snippets
ln -s "$working_directory/php.sh" /usr/local/bin/php

echo "Adding home directory snippet to nginx configs"

echo "set \$home_directory $HOME;" > ./nginx/snippets/home-directory.conf

echo "Tweaking php.ini listen option to use sockets"

cp /usr/local/etc/php/7.3/php-fpm.d/www.conf /usr/local/etc/php/7.3/php-fpm.d/www.conf.bak
cp /usr/local/etc/php/8.0/php-fpm.d/www.conf /usr/local/etc/php/8.0/php-fpm.d/www.conf.bak

sed -i -E -e 's/^listen =.+$/listen = /usr/local/var/run/php/php7.3-fpm.sock/g' /usr/local/etc/php/7.3/php-fpm.d/www.conf 
sed -i -E -e 's/^listen =.+$/listen = /usr/local/var/run/php/php8.0-fpm.sock/g' /usr/local/etc/php/8.0/php-fpm.d/www.conf 

echo "Creating wildcard self-signed certificate for *.test domain"

mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.test-key.pem \
       "*.test"

echo "Adding custom resolver for *.test domain"

# Source: https://firxworx.com/blog/it-devops/sysadmin/using-dnsmasq-on-macos-to-setup-a-local-domain-for-development/
sudo mkdir -pv /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
