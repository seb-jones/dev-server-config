#!/bin/bash

# Quit if CI environment variable is not set
if [[ -z ${CI} ]]; then
    echo "This command should only be run in a CI Runner"
    exit 1
fi

# Create directories for test sites and output
mkdir -pv ~/sites/p73/php73-test/public
mkdir -pv ~/sites/p74/php74-test/public
mkdir -pv ~/sites/p80/php80-test/public
mkdir -pv ~/test-output

# Add test files to site directories
echo '<?php phpinfo(); ?>' > ~/sites/p73/php73-test/public/index.php
echo '<?php phpinfo(); ?>' > ~/sites/p74/php74-test/public/index.php
echo '<?php phpinfo(); ?>' > ~/sites/p80/php80-test/public/index.php

# Try running each PHP file in the terminal and check for correct version number
cd ~/sites/p73/php73-test/public && php index.php > ~/test-output/php73-test-output.txt \
    && grep -E '^PHP\s+Version\s+=>\s+7.3' ~/test-output/php73-test-output.txt
cd ~/sites/p74/php74-test/public && php index.php > ~/test-output/php74-test-output.txt \
    && grep -E '^PHP\s+Version\s+=>\s+7.4' ~/test-output/php74-test-output.txt
cd ~/sites/p80/php80-test/public && php index.php > ~/test-output/php80-test-output.txt \
    && grep -E '^PHP\s+Version\s+=>\s+8.0' ~/test-output/php80-test-output.txt

# Send a HTTPS request to each site and check version of result
curl -vk 'https://php73-test.test' -o ~/test-output/php73-test-output.html \
    && grep -oE 'PHP\s+Version\s+7.3' ~/test-output/php73-test-output.html
curl -vk 'https://php74-test.test' -o ~/test-output/php74-test-output.html \
    && grep -oE 'PHP\s+Version\s+7.4' ~/test-output/php74-test-output.html
curl -vk 'https://php80-test.test' -o ~/test-output/php80-test-output.html \
    && grep -oE 'PHP\s+Version\s+8.0' ~/test-output/php80-test-output.html

# Send a HTTP request to each site and check for redirect to HTTPS in headers
curl -vki 'http://php73-test.test' -o "php73-test-output.html" && \
    grep --quiet -E '301 Moved Permanently' php73-test-output.html && \
    grep --quiet -E 'Location: https://php73-test.test' php73-test-output.html
curl -vki 'http://php74-test.test' -o "php74-test-output.html" && \
    grep --quiet -E '301 Moved Permanently' php74-test-output.html && \
    grep --quiet -E 'Location: https://php74-test.test' php74-test-output.html
curl -vki 'http://php80-test.test' -o "php80-test-output.html" && \
    grep --quiet -E '301 Moved Permanently' php80-test-output.html && \
    grep --quiet -E 'Location: https://php80-test.test' php80-test-output.html
