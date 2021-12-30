mv /usr/local/etc/dnsmasq.conf /usr/local/etc/dnsmasq.conf.bak
mv /usr/local/etc/nginx/nginx.conf /usr/local/etc/nginx/nginx.conf.bak

ln -s dnsmasq.conf /usr/local/etc/dnsmasq.conf
ln -s nginx/nginx.conf /usr/local/etc/nginx/nginx.conf
ln -s nginx/snippets /usr/local/etc/nginx/snippets

# Set up wildcard self-signed certificate for *.test domain
mkcert -install

mkcert -cert-file /usr/local/etc/ca-certificates/_wildcard.test.pem \
       -key-file  /usr/local/etc/ca-certificates/_wildcard.test-key.pem \
       "*.test"
