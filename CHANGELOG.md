# Changelog

## 1.18.0 (TBD)

  ### Bug fixes

  * [api/dashboard] Jidoteki issue #416 - Authenticated API endpoint validation
    Certain authenticated API endpoints are not validating the length of strings,
    or the type of data which can be submitted. This could lead to unexpected
    behaviour or XSS script injection.
    All API endpoints and dashboard forms are correctly validated and escaped as of `v1.18.0`

  ### New features

  * [api] Add `/backup` endpoints to create/delete/restore a backup
  * [api] Add `/endpoints` endpoint to list all API endpoints
  * [api] Add the ability to disable "optional" API endpoints (ex: `/backup`)
  * [api] Add audit-logging to authentication and new API calls

  ### Minor fixes

  * [api] Ensure `/health` endpoint is not cached
  * [api] Refactor redundant functions
  * [api] Add regression tests for new features and validations
  * [api] Remove PicoLisp namespaces/symbols in unit tests
  * [dashboard] Update Fontello fonts
  * [dashboard] Standardize the look and feel of each section
  * [dashboard] Add Jidoteki footer to bottom of Dashboard UI
  * [dashboard] Split API documentation into two main sections: `default` and `optional` endpoints
  * [deps] Update `picolisp-json` and `picolisp-unit` dependencies

  ### Potentially breaking changes

  **HTTP security headers are included in every HTTPS request:**

  * `Strict-Transport-Security: max-age=31536000 ; includeSubDomains`
  * `X-Frame-Options: deny`
  * `X-XSS-Protection: 1`
  * `X-Content-Type-Options: nosniff`

  **All authenticated API endpoints are now validated, and will not accept missing or invalid data:**

  * `POST /setup`: `newtoken` parameter only accepts printable ASCII characters (ASCII codes 33-126, no spaces)
  This change does not affect existing tokens which may contain non-printable characters
  * `POST /settings`: `settings` parameter validates each `network` value:
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
  * `POST /storage`: `settings` parameter validates each `storage` value:
    - [nfs] **mount_options (required)**: `a-zA-Z0-9` (alphanumeric) + `.-=,`, between 3 and 255 characters
    - [nfs] **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
    - [nfs] **share (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_/`, between 3 and 255 characters
    - [aoe] **device (required)**: `a-zA-Z0-9` (alphanumeric) + `.-`, between 3 and 255 characters
    - [iscsi] **target (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_:`, between 3 and 255 characters
    - [iscsi] **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
    - [iscsi] **username (required)**: printable ASCII characters (ASCII codes 33-126, no spaces), between 3 and 255 characters
    - [iscsi] **password (required)**: printable ASCII characters (ASCII codes 33-126, no spaces), between 3 and 255 characters
    - [nbd] **export_name (required)**: `a-zA-Z0-9` (alphanumeric) + `.-_/`, between 3 and 255 characters
    - [nbd] **ip (required)**: `abcdef0123456789ABCDEF.:`, between 3 and 45 characters
    - [nbd] **port (required)**: `0-9` (numeric) + `.-_/`, between 1 and 5 characters

  **All "optional" endpoints are disabled by default:**

  * Configure the `/usr/local/etc/jidoteki-admin-api.json` file to enable the endpoints
   (network settings, certs, license, storage, backup)

  **"400 Bad Request" responses are descriptive:**

  * Many (not all) `400 Bad Request` responses now contain an `Error-Message` string and HTTP header

## 1.17.0 (2017-10-02)

  * Ensure NTP server is configurable and displayed correctly. #20

## 1.16.0 (2017-07-25)

  * Ensure '/changelog' returns a no-cache header
  * Ensure '/build' returns a no-cache header
  * Fix parsing of '/services' with capital T. #30
  * Disable all versions of TLS/SSL except TLSv1.2
  * Disable form autocomplete on login/token page

## 1.15.0 (2017-04-13)

  * Add '/health' endpoint to retrieve information about appliance health
  * Add 'picolisp-semver' module dependency
  * Display health status at top Admin Dashboard
  * Return jqXHR on API call errors for easier debugging
  * Fix disk usage graph display. #26

## 1.14.0 (2017-02-10)

  * Add '/build' endpoint to retrieve information about the specific build. #28
  * Make storage options "optional". #27
  * Add extra Storage options, such as NBD, AoE, iSCSI

## 1.13.0 (2017-01-09)

  * Add endpoint to upload and update persistent Storage options
  * Fix short auth token issue by limiting Token to 1-255 chars #25
