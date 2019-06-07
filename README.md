# On-Prem Admin Dashboard and REST API

[![GitHub release](https://img.shields.io/github/release/on-prem/jidoteki-admin-api.svg)](https://github.com/on-prem/jidoteki-admin-api) [![Build Status](https://travis-ci.org/on-prem/jidoteki-admin-api.svg?branch=master)](https://travis-ci.org/on-prem/jidoteki-admin-api) [![Dependency](https://img.shields.io/badge/[deps]&#32;jidoteki--admin-v1.23.0-ff69b4.svg)](https://github.com/on-prem/jidoteki-admin)

This API enables simple management of a [On-Prem](https://on-premises.com) system.

An Admin Dashboard is included, and enables simpler management through a web-based interface:

![Admin Dashboard](https://user-images.githubusercontent.com/153401/31997699-69b65a34-b97c-11e7-9eef-fb09b296fbb3.png)

In combination with the [jidoteki-admin](https://github.com/on-prem/jidoteki-admin), it is possible to use the REST API to:

  * Upload and validate a license file
  * Upload a software update package
  * Upload TLS certificates
  * View the status of a software update
  * View and update network settings
  * View and update application settings
  * View the status of system services
  * Retrieve compressed log files
  * Retrieve an encrypted debug bundle
  * Retrieve version and changelog of the system
  * Reboot the system
  * View and update persistent storage options
  * Retrieve build details

# Requirements

  * PicoLisp 32-bit or 64-bit v3.1.11+
  * Git
  * UNIX/Linux development/build tools (gcc, make/gmake, etc..)
  * OpenSSL command line tool (openssl)
  * Stunnel4 (for HTTPS only)
  * _(required)_ `jidoteki-admin v1.23.0+` deployment in `/opt/jidoteki/tinyadmin/`

# Getting started

  1. Type `./run.l` to launch the HTTP listener
  2. View the API documentation at: `http://enterprise.vm:8080` or `https://enterprise.vm:8443`

# File and directory permissions

The API does not need to run as root.

If using the [jidoteki-admin](https://github.com/on-prem/jidoteki-admin), it requires `sudo` access to commands in `/opt/jidoteki/admin/bin`, write access to `/opt/jidoteki/admin/home/sftp/uploads`, and read access to files in `/opt/jidoteki/admin/etc/`.

# Environment variables

It is possible to specify a few environment variables at runtime.

  * **JIDO_API_VERSION**: There is only one API version (`1`), but this makes it possible to load a completely different set of API endpoints, ex: `JIDO_API_VERSION=2 ./run.l`.
  * **JIDO_API_PORT**: The default port for the HTTP listener is `8080`.
  * **JIDO_WITH_SSL**: By default, only the HTTP listener will be launched. If you want to start an HTTPS server as well, you can set `JIDO_WITH_SSL=true`. It will launch an `stunnel4` process on port `8443`, so ensure an `enterprise.pem` SSL certificate exists in the same directory as `stunnel.conf`.
  * **JIDO_STUNNEL_BIN**: The name of the stunnel binary. On CentOS it's `stunnel`, but on Debian it's `stunnel4`. Defaults to `stunnel4`.
  * **JIDO_ADMIN_PATH**: The full path to the Admin application. In most cases it refers to `/opt/jidoteki/admin/`, but it may be different depending on the application.
  * **JIDO_API_CUSTOM**: When this is set (ex: `JIDO_API_CUSTOM=yourapp`), the API will load `custom.l` from the `yourapp/api/v1/core/` directory.

# API Endpoints

See the [API Documentation](docs/API.md).

# Contributing

If you find any bugs or issues, please [create an issue](https://github.com/on-prem/jidoteki-admin-api/issues/new).

If you want to improve this application, please make a pull-request.

## HTML and JavaScript

The HTML and JavaScript files are written in Jade and CoffeeScript, respectively.

`npm install -g jade coffeescript minify`

To compile the HTML, type: `make html`

To compile the JavaScript, type: `make javascript`

To minify the JavaScript, type: `make minify`

To do everything at once, type: `make ui`

# Changelogs

* [Changelog](CHANGELOG.md)
* [Changelog 2017](CHANGELOG-2017.md)
* [Changelog 2016](CHANGELOG-2016.md)
* [Changelog 2015](CHANGELOG-2015.md)

# Screenshots

### Update

![screen-update](https://user-images.githubusercontent.com/153401/31997710-6ae25e08-b97c-11e7-9ab4-7245c38090cb.png)

### Backup/Restore

![screen-backup](https://user-images.githubusercontent.com/153401/31997698-6984f598-b97c-11e7-8567-08d1cde65d27.png)

### Network

![screen-network](https://user-images.githubusercontent.com/153401/31997702-6a12ad3e-b97c-11e7-8086-b70479b280d6.png)

### Certs

![screeen-certs](https://user-images.githubusercontent.com/153401/31997697-695606f2-b97c-11e7-83e7-3f5acfee2723.png)

### Storage

![screen-storage](https://user-images.githubusercontent.com/153401/31997703-6a4b18f4-b97c-11e7-9494-441d2e90eb80.png)

### API Token

![screen-token](https://user-images.githubusercontent.com/153401/31997705-6aaae3ce-b97c-11e7-9075-55d54fe16edc.png)

### Monitor

![screen-monitor](https://user-images.githubusercontent.com/153401/31997701-69e69528-b97c-11e7-9bdf-d46710bcc646.png)

### Support

![screen-support](https://user-images.githubusercontent.com/153401/31997704-6a81a3e2-b97c-11e7-84bc-fc3c8d733121.png)

# License

[MPL-2.0 License](LICENSE)

Copyright (c) 2015-2018 Alexander Williams, Unscramble <license@unscramble.jp>
