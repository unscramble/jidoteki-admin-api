# Changelog

## 1.18.0 (TBD)

  * Update Fontello fonts
  * Minor update to the look and feel of main sections
  * Add Jidoteki footer to bottom of Dashboard UI
  * Add audit-logging to authentication and new API calls
  * Add '/backup' endpoints to create/delete/restore a backup
  * Add '/endpoints' endpoint to list all API endpoints
  * Ensure '/health' endpoint is not cached
  * Add the ability to disable "optional" API endpoints (ex: '/backup')
  * Refactor redundant functions

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

## 1.12.0 (2016-10-27)

  * Display RRD graphs in 'Monitor' (new) section
  * Fix '/certs' validation bypass. #22
  * Add '/services' endpoint. #11
  * Add 'error-message' and 'error-code' to update status responses. #23
  * Various minor fixes

## 1.11.0 (2016-08-29)

  * Add 'JIDO_API_CUSTOM' env variable for loading custom API code, docs, html

## 1.10.2 (2016-04-30)

  * Update API Documentation to be much more clear and better organized

## 1.10.1 (2016-04-23)

  * Replace original FontAwesome fonts with smaller Fontello/FA font files

## 1.10.0 (2016-04-17)

  * Add Admin UI for web-based API management

## 1.9.1 (2016-04-17)

  * Fix issue #17 - HMAC auth bypassed when no token is set

## 1.9.0 (2016-04-12)

  * Add HMAC signature-based authentication
  * Add new text/markdown mime type
  * Update documentation explaining HMAC authentication
  * Implement fix to hide source code when calling a /default file directly
  * Fix issue #15 - Admin API crashes when 'update.log' is missing
  * Fix issue #16 - Missing certs status

## 1.8.0 (2016-04-06)

  * Add endpoint to upload and update TLS certificates

## 1.7.0 (2016-04-04)

  * Add endpoint to retrieve an encrypted debug bundle

## 1.6.1 (2016-03-31)

  * Fix issue #12 - Server cannot start when JIDO_API_PORT env var (patrixl)
  * Apply identical fix in #12 to JIDO_API_VERSION env var

## 1.6.0 (2016-03-22)

  * Use software packages with '.enc' extension instead of '.asc'

## 1.5.0 (2015-09-26)

  * Add endpoint to reboot the system
  * Update documentation to reflect the API's ability to manage all types of systems

## 1.4.0 (2015-09-22)

  * Make network interface configurable by outputting 'interface' to network.conf in static/dhcp mode (defaults to eth0)

## 1.3.1 (2015-09-20)

  * Output 'hostname' in dhcp mode as well

## 1.3.0 (2015-09-20)

  * Replace 'sudo' commands with calls to 'wrapper.sh'

## 1.2.2 (2015-09-16)

  * Output 'hostname' to network.conf

## 1.2.1 (2015-09-16)

  * Output network settings to network.conf in 'key=value' format

## 1.2.0 (2015-09-07)

  * Add support for running on a 32-bit OS
  * Increase minimum PicoLisp requirement to 3.1.10.2+ (json.l)

## 1.1.7 (2015-08-26)

  * Remove hardcoded paths for the Admin_path
  * Add 'JIDO_ADMIN_PATH' env variable for Admin_path
  * Update documentation

## 1.1.6 (2015-08-21)

  * Add endpoint to retrive the changelog of the appliance
  * Update API documentation

## 1.1.5 (2015-07-08)

  * Use 'nohup' when processing vm update, to detach it from the parent

## 1.1.4 (2015-07-08)

  * Update dependency versions

## 1.1.3 (2015-07-08)

  * Add REPO_PREFIX to 'Makefile' to specify alternate path of git repos
  * Actually add the code to fetch the API version

## 1.1.2 (2015-07-06)

  * Add endpoint to retrieve the version of the appliance

## 1.1.1 (2015-07-06)

  * Add endpoint to retrieve compressed logs

## 1.1.0 (2015-07-03)

  * Return JSON body during POST settings/update
  * Update documentation

## 1.0.2 (2015-06-22)

  * Disable fips in stunnel config (bug in CentOS 6.6)

## 1.0.1 (2015-06-18)

  * Add initial CHANGELOG.md
  * Add 'JIDO_STUNNEL_BIN' env variable for stunnel binary fullpath
  * Rename API process to 'jido-api' at boot
  * Update dependency versions
