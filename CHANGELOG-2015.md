# Changelog 2015

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
