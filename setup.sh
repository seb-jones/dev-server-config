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

echo "Creating wildcard self-signed certificate for *.test domain"

mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.test-key.pem \
       "*.test"

echo "Adding custom resolver for *.test domain"

sudo mkdir -pv /etc/resolver
sudo bash -c 'echo "nameserver 127.0.0.1" > /etc/resolver/test'
