#!/bin/bash
# 
# Runs a different version of `pecl` depending on the current working directory.
# Works in the same way as `./php.sh` - see the comment there for full details.

wd=$(pwd)

if [[ $wd =~ '/p80' ]]; then
    /usr/local/opt/php@8.0/bin/pecl "$@"
elif [[ $wd =~ '/p74' ]]; then
    /usr/local/opt/php@7.4/bin/pecl "$@"
elif [[ $wd =~ '/p73' ]]; then
    /usr/local/opt/php@7.3/bin/pecl "$@"
elif [[ $wd =~ '/p56' ]]; then
    /usr/local/opt/php@5.6/bin/pecl "$@"
else
    /usr/local/opt/php@8.0/bin/pecl "$@"
fi
