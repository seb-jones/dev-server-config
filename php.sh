#!/bin/bash
# 
# Runs a different version of `php` depending on the current working directory.
# If it contains `/p80`, `/p73` or `/p56` then PHP 8.0, 7.3 or 5.6 are run,
# respectively. Otherwise it falls back to PHP 8.0. Any arguments to the script
# are passed straight to the `php` executable.
# 
# Symlink `/usr/local/bin/php` to this script (you might need to do `brew unlink`
# with your currently active version of PHP first) and it should work anywhere,
# including Tinkerwell!

wd=$(pwd)

if [[ $wd =~ '/p80' ]]; then
    /usr/local/opt/php@8.0/bin/php "$@"
elif [[ $wd =~ '/p73' ]]; then
    /usr/local/opt/php@7.3/bin/php "$@"
elif [[ $wd =~ '/p56' ]]; then
    /usr/local/opt/php@5.6/bin/php "$@"
else
    /usr/local/opt/php@8.0/bin/php "$@"
fi
