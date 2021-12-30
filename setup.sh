echo "Renaming existing files to backups"

mv /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.bak
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak
mv /usr/local/bin/php /usr/local/bin/php.bak

echo "Creating symlinks to new files"

ln -s dnsmasq.conf /usr/local/etc/dnsmasq.conf
ln -s nginx/nginx.conf /usr/local/etc/nginx/nginx.conf
ln -s nginx/snippets /usr/local/etc/nginx/snippets
ln -s php.sh /usr/local/bin/php

echo "Creating wildcard self-signed certificate for *.test domain"

ssh-add --apple-use-keychain

mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.test-key.pem \
       "*.test"
