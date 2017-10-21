# Changelog 2016

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
