# Quit if CI environment variable is not set
if [[ -z ${CI} ]]; then
    echo "This command should only be run in a CI Runner"
    exit 1
fi

# Check NGINX configuration file syntax
nginx -t

# Start services
sudo brew services restart dnsmasq
brew services restart php@7.3
brew services restart php@8.0
brew services restart nginx

# Create directories for test sites
mkdir -pv ~/sites/p73/php73-test/public
mkdir -pv ~/sites/p80/php80-test/public

# Add test files to site directories
echo '<?php phpinfo(); ?>' > ~/sites/p73/php73-test/public/index.php
echo '<?php phpinfo(); ?>' > ~/sites/p80/php80-test/public/index.php

# Try running each PHP file in the terminal and check for correct version number
cd ~/sites/p73/php73-test/public && php index.php | grep --quiet -E '^PHP\s+Version\s+=>\s+7.3'
cd ~/sites/p80/php80-test/public && php index.php | grep --quiet -E '^PHP\s+Version\s+=>\s+8.0'

# Send a HTTPS request to each site and check version of result
curl --insecure 'https://php73-test.test' -o "php73-test-output.html" && grep --quiet -E 'PHP\s+Version\s+7.3' php73-test-output.html
curl --insecure 'https://php80-test.test' -o "php80-test-output.html" && grep --quiet -E 'PHP\s+Version\s+7.3' php80-test-output.html

# Send a HTTP request to each site and check for redirect to HTTPS in headers
curl --insecure -i 'http://php73-test.test' -o "php73-test-output.html" && \
    grep --quiet -E '301 Moved Permanently' php73-test-output.html && \
    grep --quiet -E 'Location: https://php73-test.test' php73-test-output.html
curl --insecure -i 'http://php80-test.test' -o "php80-test-output.html" && \
    grep --quiet -E '301 Moved Permanently' php80-test-output.html && \
    grep --quiet -E 'Location: https://php80-test.test' php80-test-output.html
