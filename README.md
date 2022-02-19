# dev-server-config

Serves multiple PHP versions with NGINX at the same time on a single dev domain with a self-signed certificate. No manual switching of PHP version required. MacOS only (for now).

## Installation

Homebrew is required for installation.

Clone this repo to a directory of your choice (I use `~/config/dev-server-config`), change into that directory with the terminal and run the setup script:

```sh
./setup.sh
```

This installs the required packages with `brew`, symlinks the relevant config files to the files in this repo, and creates a self-signed certificate for `*.dev.test` using `mkcert`.

**NOTE:** the setup script requires password input for `sudo` at a certain point, to start the `dnsmasq` service, create the resolver file and flush the DNS cache.
