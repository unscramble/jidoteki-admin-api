[<< return to the Admin Dashboard](/)

# API documentation

The API enables programmable system administration. It is possible to remotely manage network,
system, and application settings using well-known tools such as _curl_, or _REST API libraries_.

## <a name="menu"></a>Menu

Individual API endpoints are documented in separate sections listed below.

**HTTP Prefix**

```
/api/v1/admin
```

> **Note:** All API endpoints must be prefixed with `/api/v1/admin`

### Default API Endpoints

These endpoints can not be disabled.

| Section | API Endpoints <br> /api/v1/admin | Description |
| :---- | :---- | :---- |
| 1. [Setup](#setup) | `POST /setup` | Initial setup for using the API |
| 2. [Authentication](#authentication) | `POST /setup` | How to authenticate to the API, and change the API token. |
| 3. [Updates](#updates) | `POST /update` <br/> `GET /update` <br/> `GET /update/log` | Updating the system using encrypted software update packages, and viewing the status of an update. |
| 4. [Support](#support) | `GET /logs` <br/> `GET /debug` | Retrieving log files and debug bundles to help troubleshoot various issues. |
| 5. [Administration](#administration) | `GET /reboot` | System administration, such as rebooting the system. |
| 6. [Services](#services) | `GET /services` | Retrieving the status of system services. |
| 7. [Information](#information) | `GET /version` <br/> `GET /changelog` <br/> `GET /build` <br/> `GET /health `<br/> `GET /endpoints` | Viewing system information, such as the version, changelog, build, health, and endpoints. |

### Optional API Endpoints

These endpoints are optional and can only be enabled through `/usr/local/etc/jidoteki-admin-api.json`.

**Example**

```
{
    "endpoints": ["settings", "certs", "license", "storage", "backup"],
    "parameters": ["public", "private", "ca", "license", "action", "archive"]
}
```

> **Note:** Disabled API endpoints will return `404 Not Found`

| Section | API Endpoints <br> /api/v1/admin | Description |
| :---- | :---- | :---- |
| 8. [Network](#network) | `POST /settings` <br/> `GET /settings` | Viewing and changing network/application settings. |
| 9. [TLS](#tls) | `POST /certs` <br/> `GET /certs` | Updating the system's TLS certificates to replace the default self-signed certificates. |
| 10. [License](#license) | `POST /license` <br/> `GET /license` | Viewing and changing the system license. |
| 11. [Storage](#storage) | `POST /storage` <br/> `GET /storage` | Viewing and changing persistent storage options. |
| 12. [Backup](#backup) | `POST /backup` <br/> `GET /backup` <br/> `GET /backup/download` <br/> `GET /backup/log` <br/> `POST /backup/restore` | Generating a backup, and viewing its status and log. Restore a backup |

# <a name="setup"></a>1. Setup

Before using the API, it is necessary to perform the **initial setup** of the `API token`. This procedure is only required once.

**Since**

`>= v1.0.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/setup
```

**Parameters**

* `newtoken` **(required)**: New API token, between 1 and 255 printable ASCII characters between codes 33 and 126 inclusively.

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/setup -F newtoken=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{"Status":"200 OK"}
```

**Error response**

If setting the new API token fails, `400 Bad Request` will be returned.

[^ return to menu](#menu)

----

# <a name="authentication"></a>2. Authentication

There are two methods to perform authentication: `token` and `hash`.

Every API endpoint requires a valid `API token` or `HMAC hash` to be sent as a query parameter, **except during initial setup**.

Once the `token` is set, it is recommended to only use `hash` authentication, to avoid sending the cleartext `token` on every request.

## API token authentication

**Since**

`>= v1.0.0`

Query parameter: `?token=[yourtoken]`

## HMAC hash authentication

**Since**

`>= v1.9.0`

Query parameter: `?hash=[sha256hmachash]`

To use `hash` authentication, an HMAC hash must be generated for each API endpoint, using the steps below.

#### i. Generate a secret key of your API token:

Hash your API token without a newline at the end.

```
echo -n "yourtoken" | openssl dgst -sha256
```

This should return the SHA256 _secret key_ hash: `13e2ff941bbc8692cad141c8d293dda2c4f1c1a3c51b93d54f1a1693e1206107`

#### ii. Generate an HMAC hash using your secret key:

Concatenate the **HTTP Method**, **Prefix**, and **Endpoint**, then HMAC hash it without a newline at the end.

```
echo -n "GET/api/v1/admin/version" | openssl dgst -sha256 -hmac 13e2ff941bbc8692cad141c8d293dda2c4f1c1a3c51b93d54f1a1693e1206107
```

This should return the SHA256 _HMAC_ hash: `b714a60732e096ccef06e360eefe0f1ba4fa5d16ef7da726612e2026e5523241`

#### iii. Append the HMAC hash as a query parameter:

```
GET /api/v1/admin/version?hash=b714a60732e096ccef06e360eefe0f1ba4fa5d16ef7da726612e2026e5523241
```

## Authentication errors

Authentication errors always return `403 Forbidden`, except in situations which may leak private information.

## Change the API token

Changing the API token is similar to the [initial setup](#setup) procedure, except the API call requires [authentication](#authentication).

**Since**

`>= v1.0.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/setup
```

**Parameters**

* `newtoken` **(required)**: New API token, between 1 and 255 printable ASCII characters between codes 33 and 126 inclusively.

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/setup?hash=[sha256hmachash] -F newtoken=[yourtoken]
or
curl -X POST https://[hostname]:8443/api/v1/admin/setup?token=[yourtoken] -F newtoken=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{"Status":"200 OK"}
```

**Error response**

If changing the API token fails, `400 Bad Request` will be returned.

[^ return to menu](#menu)

----

# <a name="updates"></a>3. Updates

### Updating the system

Updating the system is an asynchronous procedure. The API will return a response immediately while the system updates itself in the background. Only one update can run at any given time.

**Since**

`>= v1.0.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/update
```

**Parameters**

* `update` **(required)**: Encrypted software update package

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/update?hash=[sha256hmachash] -F update=@[software_package-name.enc]
or
curl -X POST https://[hostname]:8443/api/v1/admin/update?token=[yourtoken] -F update=@[software_package-name.enc]
```

**Success response**

```
HTTP/1.1 202 Accepted
Location: /api/v1/admin/update
Content-Type: application/json
{"Status":"202 Accepted","Location":"/api/v1/admin/update"}
```

**Error response**

If the system update API call fails, `400 Bad Request` will be returned.

### Viewing the system update status

This API endpoint will return the status of the system update, and the last 10 lines of the update log. It can be polled repeatedly until the update is complete.

**Since**

`>= v1.0.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/update
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/update?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/update?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "success",
    "log": "[1432140922][SYSTEM] Updating system successful"
}
```

**Error response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "failed",
    "log": "[1432140922][SYSTEM] Failed updating...",
    "error-message": "Missing update package",
    "error-code": "E1003"
}
```

**Status values**

* `running`: The system update is currently running.
* `success`: The system update completed successfully.
* `failed`: The system update failed.

**Error codes**

* `E1000`: There was a scripting error in the update script.
* `E1001`: There was a version error in the update package.
* `E1002`: There was an error during the update process.
* `E1003`: The update package was missing.
* `E1004`: The update process was already running.
* `E1005`: The update package couldn't be decrypted or extracted.

### Viewing the system update log

This API endpoint will return the full system update log in plain text format.

**Since**

`>= v1.0.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/update/log
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/update/log?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/update/log?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: text/plain
[1433080791][SYSTEM] Updating system. Please wait..
[1433080791][SYSTEM] Updating system successful
...
```

**Error response**

If the log file doesn't exist, `404 Not Found` will be returned.

[^ return to menu](#menu)

----

# <a name="support"></a>4. Support

### Retrieving log files

Retrieving compressed log files can help troubleshoot issues with the system. The log files generally don't contain sensitive information, therefore they are not encrypted. This will start a download of `logs.tar.gz`.

**Since**

`>= v1.1.1`

**HTTP Method**

```
GET
```

**Endpoint**

```
/logs
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/logs?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/logs?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/octet-stream
Filename: logs.tar.gz
```

**Error response**

If the logs.tar.gz file doesn't exist, `404 Not Found` will be returned.

If an error occurs when compressing the logs, `400 Bad Request` will be returned.

### Retrieve a debug bundle

Retrieving a debug bundle can help the system developpers troubleshoot issues with the system. The debug bundle can contain sensitive information, therefore it is encrypted. This will start a download of `debug-bundle.tar`.

**Since**

`>= v1.7.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/debug
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/debug?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/debug?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/octet-stream
Filename: debug-bundle.tar
```

**Error response**

If the debug-bundle.tar file doesn't exist, `404 Not Found` will be returned.

If an error occurs when creating the debug bundle, `400 Bad Request` will be returned.

[^ return to menu](#menu)

----

# <a name="administration"></a>5. Administration

### Rebooting the system

This API endpoint will reboot the system immediately after performing a system backup.

The API will return a response immediately while the system reboots in the background.

**Since**

`>= v1.5.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/reboot
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/reboot?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/reboot?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 202 Accepted
Content-Type: application/json
{"Status": "202 Accepted"}
```

[^ return to menu](#menu)

----

# <a name="services"></a>6. Services

### Retrieving service status

This API endpoint will retrieve the status of various system services.

The API will return a response immediately.

**Since**

`>= v1.12.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/services
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/services?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/services?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "services": [{
        "openssh": "running"
    }, {
        "jidoteki-admin-api": "running"
    }]
}
```

[^ return to menu](#menu)

----

# <a name="information"></a>7. Information

### Viewing the system's version

The system's version can be used to determine if an update can be applied. It can only be changed during the [updates](#updates) procedure.

**Since**

`>= v1.1.3`

**HTTP Method**

```
GET
```

**Endpoint**

```
/version
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/version?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/version?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "version": "1.0.0"
}
```

**Error response**

If the version file doesn't exist, `404 Not Found` will be returned.

### Viewing the system's changelog

This API endpoint will return the system's changelog since the last update, in plain text format. It can only be changed during the [updates](#updates) procedure.

**Since**

`>= v1.1.6`

**HTTP Method**

```
GET
```

**Endpoint**

```
/changelog
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/changelog?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/changelog?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: text/plain
# Changelog

## 1.0.9 (2015-08-21)

  * Update app to version 2.1.2
  * Update nodejs modules
  * Update system packages
  * Update API to version 1.1.6
```

**Error response**

If the changelog file doesn't exist, `404 Not Found` will be returned.

### Viewing the system's build information

This API endpoint will return the system's current build information, in JSON format. It can only be changed during the [updates](#updates) procedure.

**Since**

`>= v1.14.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/build
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/build?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/build?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "builddate":"123456789"
}
```

**Error response**

If the system's `build.json` file doesn't exist, `404 Not Found` will be returned.

### Viewing the system's health information

This API endpoint will return the system's current health information (disk/memory/cpu), in JSON format.

**Since**

`>= v1.15.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/health
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/health?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/health?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "disk": {
        "used": "3.4G",
        "total": "234G",
        "percentage": 2
    },
    "memory": {
        "used": "260M",
        "total": "1000M",
        "percentage": 26
    },
    "cpu": {
        "num": 1,
        "load": "0.66, 0.28, 0.14",
        "cpu5min": 0
    }
}
```

**Error response**

If the system's `health.json` file doesn't exist, `404 Not Found` will be returned.

### Viewing the system's API endpoints

This API endpoint will return the list of available API endpoints (first-level only).

> **Note:** Optional API endpoints are configured in `/usr/local/etc/jidoteki-admin-api.json`

**Since**

`>= v1.18.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/endpoints
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/endpoints?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/endpoints?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "endpoints": [
        "/api/v1/admin/backup",
        "/api/v1/admin/build",
        "/api/v1/admin/certs",
        "/api/v1/admin/changelog",
        "/api/v1/admin/debug",
        "/api/v1/admin/endpoints",
        "/api/v1/admin/health",
        "/api/v1/admin/logs",
        "/api/v1/admin/reboot",
        "/api/v1/admin/services",
        "/api/v1/admin/settings",
        "/api/v1/admin/setup",
        "/api/v1/admin/storage",
        "/api/v1/admin/update",
        "/api/v1/admin/version",
        "/docs"
    ]
}
```

[^ return to menu](#menu)

----

# <a name="network"></a>8. Network

### Updating the network/application settings

Updating the network/application settings is an asynchronous procedure. The API will return a response immediately while the settings are updated in the background. Only one update can run at any given time.

Network settings can be set to `DHCP` or `STATIC` by uploading a _settings.json_ file.

**Since**

`>= v1.0.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/settings
```

**Parameters**

* `settings` **(required)**: JSON settings file

**Settings validation (network)**

- **interface (required)**: `a-zA-Z0-9` (alphanumeric), between 3 and 14 characters
    (Not required prior to `v1.18.0`)
- **hostname (required)**: `a-zA-Z0-9` (alphanumeric) + `.-`, between 3 and 255 characters
    (Not required prior to `v1.18.0`)
- **ip_address**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **netmask**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **gateway**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **dns1**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **dns2**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **ntpserver**: `a-zA-Z0-9` (alphanumeric) + `.-:`, between 3 and 255 characters

**Content-type**

```
multipart/form-data
```

**Example `STATIC` _settings.json_ file**

```
{
    "network": {
        "interface": "eth0",
        "hostname": "test.host",
        "ip_address": "192.168.1.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.1.1",
        "dns1": "192.168.1.2",
        "dns2": "192.168.1.3",
        "ntpserver": "pool.ntp.org"
    },
    "app": {
        "name": "testapp"
    }
}
```

**Example `DHCP` _settings.json_ file**

Omit the `ip_address, netmask, gateway` fields, and the network settings will automatically switch to DHCP.

```
{
    "network": {
        "interface": "eth0",
        "hostname": "test.host"
    },
    "app": {
        "name": "testapp"
    }
}
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/settings?hash=[sha256hmachash] -F settings=@[settings.json]
or
curl -X POST https://[hostname]:8443/api/v1/admin/settings?token=[yourtoken] -F settings=@[settings.json]
```

**Success response**

```
HTTP/1.1 202 Accepted
Location: /api/v1/admin/settings
Content-Type: application/json
{"Status":"202 Accepted","Location":"/api/v1/admin/settings"}
```

**Error response**

If the network/application settings update API call fails, `400 Bad Request` will be returned.

### Viewing the network/application settings

This API endpoint will return the network/application settings. It can be polled repeatedly to monitor changes to the network settings.

**Since**

`>= v1.0.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/settings
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/settings?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/settings?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "network": {
        "interface": "eth0",
        "hostname": "test.host",
        "ip_address": "192.168.1.100",
        "netmask": "255.255.255.0",
        "gateway": "192.168.1.1",
        "dns1": "192.168.1.2",
        "dns2": "192.168.1.3",
        "ntpserver": "pool.ntp.org"
    },
    "app": {
        "name": "testapp"
    }
}
```

[^ return to menu](#menu)

----

# <a name="tls"></a>9. TLS

### Updating TLS certificates

Update TLS certificates to replace the default self-signed certificates.

Updating the TLS certificates is an asynchronous procedure. The API will return a response immediately while the system updates the certificates in the background. Only one update can run at any given time.

**Since**

`>= v1.8.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/certs
```

**Parameters**

* `public` **(required)**: Public TLS certificate (PEM format)
* `private` **(required)**: Private TLS certificate key (unencrypted RSA format)
* `ca` **(optional)**: Intermediate or Root TLS certificate (PEM format)

**Content-type**

```
multipart/form-data
```

**Example PEM format `public/ca` _cert_ file**

```
-----BEGIN CERTIFICATE-----
MIIDXTCCAkWgAwIBAgIJAJC1HiIAZAiIMA0GCSqGSIb3Df
BAYTAkFVMRMwEQYDVQQIDApTb21lLVN0YXRlMSEwHwYDVx
aWRnaXRzIFB0eSBMdGQwHhcNMTExMjMxMDg1OTQ0WhcNMT
A .... MANY LINES LIKE THAT ....
JjyzfN746vaInA1KxYEeI1Rx5KXY8zIdj6a7hhphpj2E04
C3Fayua4DRHyZOLmlvQ6tIChY0ClXXuefbmVSDeUHwc8Yu
B7xxt8BVc69rLeHV15A0qyx77CLSj3tCx2IUXVqRs5mlSb
vA==
-----END CERTIFICATE-----
```

**Example RSA format `private` _key_ file**

The RSA private key should be unencrypted to avoid being prompted for a passphrase

```
-----BEGIN RSA PRIVATE KEY-----
MIIFDjBABgkqhkiG9w0BBQ0wMzAbBgkqhkiG9w0BBQwwDg
MBQGCCqGSIb3DQMHBAgD1kGN4ZslJgSCBMi1xk9jhlPxPc
9g73NQbtqZwI+9X5OhpSg/2ALxlCCjbqvzgSu8gfFZ4yo+
A .... MANY LINES LIKE THAT ....
X0R+meOaudPTBxoSgCCM51poFgaqt4l6VlTN4FRpj+c/Wc
blK948UAda/bWVmZjXfY4Tztah0CuqlAldOQBzu8TwE7WD
H0ga/iLNvWYexG7FHLRiq5hTj0g9mUPEbeTXuPtOkTEb/0
GEs=
-----END RSA PRIVATE KEY-----
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/certs?hash=[sha256hmachash] -F public=@[hostname.pem] -F private=@[hostname.key] -F ca=@[ca-cert.pem]
or
curl -X POST https://[hostname]:8443/api/v1/admin/certs?token=[yourtoken] -F public=@[hostname.pem] -F private=@[hostname.key] -F ca=@[ca-cert.pem]
```

**Success response**

```
HTTP/1.1 202 Accepted
Location: /api/v1/admin/certs
{"Status":"202 Accepted","Location":"/api/v1/admin/certs"}
```

**Error response**

If the certificates update API call fails, `400 Bad Request` will be returned.

### Viewing the TLS certificates update status

This API endpoint will return the status of the certificates update, and the last 10 lines of the certificates update log. It can be polled repeatedly until the update is complete.

**Since**

`>= v1.8.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/certs
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/certs?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/certs?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "success",
    "log": "[1459884203][SYSTEM] Validating and adding TLS certificates"
}
```

**Status values**

* `running`: The certificates update is currently running.
* `success`: The certificates update completed successfully.
* `failed`: The certificates update failed.

[^ return to menu](#menu)

----

# <a name="license"></a>10. License

### Changing the system license

This API endpoint can be used to change the system license supplied by the system developpers.

**Since**

`>= v1.0.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/license
```

**Parameters**

* `license` **(required)**: Encrypted license file

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/license?hash=[sha256hmachash] -F license=@[license.asc]
or
curl -X POST https://[hostname]:8443/api/v1/admin/license?token=[yourtoken] -F license=@[license.asc]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "app": "enterprise",
    "users": 20,
    "expires": "19 January 2038",
    "name": "Enterprise Company",
    "contact": "cto@enterprise"
}
```

**Error response**

If the license file is invalid or doesn't exist, `404 Not Found` will be returned.

If an error occurs when updating the license, `400 Bad Request` will be returned.

### Viewing the license details

This API endpoint will return the details of the license.

**Since**

`>= v1.0.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/license
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/license?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/license?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "app": "enterprise",
    "users": 20,
    "expires": "19 January 2038",
    "name": "Enterprise Company",
    "contact": "cto@enterprise"
}
```

**Error response**

If the license file is invalid or doesn't exist, `404 Not Found` will be returned.

[^ return to menu](#menu)

----

# <a name="storage"></a>11. Storage

### Changing persistent storage options

Changing the storage options is an asynchronous procedure. The API will return a response immediately while the settings are updated in the background. Only one update can run at any given time.

> **Note:** Storage types are only available based on options found in `/usr/local/etc/storage-options.json`.

**Example**

```
{
    "options": ["local", "aoe", "nfs", "nbd", "iscsi"]
}
```

Settings are only applied after a reboot.

**Since**

`>= v1.13.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/storage
```

**Parameters**

* `settings` **(required)**: JSON settings file

**Settings validation (storage)**

- **type (required)**: Allowed: `local`, `nfs`, `aoe`, `iscsi`, `nbd`

[nfs]

- **mount_options (required)**: `a-zA-Z0-9` (alphanumeric) + `.-=,`, between 3 and 255 characters
- **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **share (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_/`, between 3 and 255 characters

[aoe]

- **device (required)**: `a-zA-Z0-9` (alphanumeric) + `.-`, between 3 and 255 characters

[iscsi]

- **target (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_:`, between 3 and 255 characters
- **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **username (required)**: printable ASCII characters (ASCII codes 33-126, no spaces), between 3 and 255 characters
- **password (required)**: printable ASCII characters (ASCII codes 33-126, no spaces), between 3 and 255 characters

[nbd]

- **export_name (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_/`, between 3 and 255 characters
- **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
- **port (required)**: `0-9` (numeric) + `.-_/`, between 1 and 5 characters

**Content-type**

```
multipart/form-data
```

**Example `local` _settings.json_ file (Local Disk)**

```
{
    "storage": {
        "type": "local"
    }
}
```

**Example `nfs` _settings.json_ file (Network File System)**

```
{
    "storage": {
        "type": "nfs",
        "mount_options": "noacl,sync",
        "ip": "192.168.1.100",
        "share": "/nfs/storage"
    }
}
```

**Example `aoe` _settings.json_ file (ATA-over-Ethernet)**

```
{
    "storage": {
        "type": "aoe",
        "device": "e0.1"
    }
}
```

**Example `iscsi` _settings.json_ file (iSCSI)**

```
{
    "storage": {
        "type": "iscsi",
        "target": "iqn.2016-01.com.example:storage.lun1",
        "ip": "192.168.1.100",
        "username": "user",
        "password": "pass"
    }
}
```

**Example `nbd` _settings.json_ file (Network Block Device)**

```
{
    "storage": {
        "type": "nbd",
        "export_name": "otherexport",
        "ip": "192.168.1.100",
        "port": "1043"
    }
}
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/storage?hash=[sha256hmachash] -F settings=@[settings.json]
or
curl -X POST https://[hostname]:8443/api/v1/admin/storage?token=[yourtoken] -F settings=@[settings.json]
```

**Success response**

```
HTTP/1.1 202 Accepted
Location: /api/v1/admin/storage
Content-Type: application/json
{"Status":"202 Accepted","Location":"/api/v1/admin/storage"}
```

**Error response**

If the storage settings update API call fails, `400 Bad Request` will be returned.

### Viewing the persistent storage settings

This API endpoint will return the storage options.

**Since**

`>= v1.13.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/storage
```

**Example**

```
curl -X GET https://[hostname]:8443/api/v1/admin/storage?hash=[sha256hmachash]
or
curl -X GET https://[hostname]:8443/api/v1/admin/storage?token=[yourtoken]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "storage": {
        "type": "nfs",
        "mount_options": "noacl,sync",
        "ip": "192.168.1.100",
        "share": "/nfs/storage"
    },
    "options": ["local", "nfs", "nbd", "iscsi", "aoe"]
}
```

[^ return to menu](#menu)

----

# <a name="backup"></a>12. Backup

### Generating a backup

Generating a backup is an asynchronous procedure. The API will return a response immediately while the backup is created in the background. Only one backup can run at any given time.

The backup file is stored in memory, and can be stopped or deleted at any time.

**Since**

`>= v1.18.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/backup
```

**Parameters**

* `action` **(required)**: `START` to start a backup, `STOP` to stop or delete a backup

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/backup?hash=[sha256hmachash] -F action=START
or
curl -X POST https://[hostname]:8443/api/v1/admin/backup?token=[yourtoken] -F action=START
```

**Success response**

```
HTTP/1.1 202 Accepted
Location: /api/v1/admin/backup
Content-Type: application/json
{"Status":"202 Accepted","Location":"/api/v1/admin/backup"}
```

**Error response**

`400 Bad Request` if the backup API call fails

### Viewing the backup status

This API endpoint will return the status of the backup.

**Since**

`>= v1.18.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/backup
```

**Example**

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "running"
}
```

or

```
HTTP/1.1 200 OK
Content-Type: application/json
{
    "status": "success",
    "filesize": "128.0K",
    "sha256": "6e31a817eb93270848e3c0b3c1d0c2bfa077fbb318f58a2bcbdec8f69f0dd420"
}
```

**Status values**

* `running`: The backup is currently running.
* `success`: The backup completed successfully.
* `failed`: The backup failed.

**Error response**

`404 Not Found` if the backup status file doesn't exist

### Retrieving a backup

This will start a download of `backup.tar`.

**Since**

`>= v1.18.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/backup/download
```

**Example**

```
HTTP/1.1 200 OK
Content-Type: application/octet-stream
Filename: backup.tar
```

**Error response**

`404 Not Found` if the `backup.tar` file doesn't exist

### Viewing the backup log

This API endpoint will return the log of the backup.

**Since**

`>= v1.18.0`

**HTTP Method**

```
GET
```

**Endpoint**

```
/backup/log
```

**Example**

```
HTTP/1.1 200 OK
Content-Type: text/plain
[1507206605][LIVE IMAGE] Validating backup file size
[1507206605][LIVE IMAGE] Starting backup
Created file: /opt/jidoteki/admin/home/sftp/uploads/backup.tar - size: 128.0K - hash: 6e31a817eb93270848e3c0b3c1d0c2bfa077fbb318f58a2bcbdec8f69f0dd420
[1507206606][LIVE IMAGE] Backup complete
[1507212882][LIVE IMAGE] Deleting backup archive
...
```

**Error response**

`404 Not Found` if the backup log file doesn't exist

### Restoring a backup

Restoring a backup is a synchronous procedure. The API will wait until the restore completes. Only one restore can run at any given time.

**Since**

`>= v1.18.0`

**HTTP Method**

```
POST
```

**Endpoint**

```
/backup/restore
```

**Parameters**

* `archive` **(required)**: tar backup archive, ex: `backup.tar`

**Content-type**

```
multipart/form-data
```

**Example**

```
curl -X POST https://[hostname]:8443/api/v1/admin/backup/restore?hash=[sha256hmachash] -F archive=@[backup.tar]
or
curl -X POST https://[hostname]:8443/api/v1/admin/backup/restore?token=[yourtoken] -F archive=@[backup.tar]
```

**Success response**

```
HTTP/1.1 200 OK
Content-Type: application/json
{"Status":"200 OK"}
```

**Error response**

`400 Bad Request` if the backup archive is missing or invalid

[^ return to menu](#menu)

----

Powered by Jidoteki.com - v1.18.0 - [Copyright notices](/docs/NOTICE.TXT)
