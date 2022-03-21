# Dev Server Config

Serves multiple PHP versions with NGINX at the same time on a single dev domain with a self-signed certificate. No manual switching of PHP version required. MacOS only (for now).

## Usage

All sites are accessed through the `.dev.test` domain. The subdomain is used to determine the directory name.

The NGINX config uses the the first working directory to match the requested subdomain to determine what PHP version to use:

 * PHP 5.6 is used for any directories containing `/p56/` in their full path
 * PHP 7.3 is used for any directories containing `/p73/` in their full path
 * PHP 7.4 is used for any directories containing `/p74/` in their full path
 * PHP 8.0 is used for any other directory

For example, if you request `https://website.dev.test`, and you have a directory `~/sites/p56/website`, then `~/sites/p56/website/public/index.php` will be executed using the PHP 5.6 FPM.

## Installation

[Homebrew](https://brew.sh/) is required for installation.

Clone this repo to a directory of your choice (I use `~/config/dev-server-config`), change into that directory with the terminal and run the setup script:

```sh
./setup.sh
```

This installs the required packages with `brew`, symlinks the relevant config files to the files in this repo, and creates a self-signed certificate for `*.dev.test` using [mkcert](https://github.com/FiloSottile/mkcert).

**NOTE:** the setup script requires password input for `sudo` at a certain point, to start the `dnsmasq` service, create the resolver file and flush the DNS cache.
