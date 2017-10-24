/*
  This Source Code Form is subject to the terms of the Mozilla Public
  License, v. 2.0. If a copy of the MPL was not distributed with this
  file, You can obtain one at http://mozilla.org/MPL/2.0/.

  Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>
 */

(function() {
  'use strict';
  var apiEndpoints, apiServer, apiType, authenticate, backupButtonListener, capitalize, certsButtonListener, clearToken, debugButtonListener, drawGraphs, failedUpload, fetchData, fetchFile, getHmac, getSha256, getStatus, getToken, loadBackup, loadHome, loadLogin, loadMonitor, loadNetwork, loadSetup, loadStorage, loadSupport, loadToken, loadUpdateCerts, loginButtonListener, logoutButtonListener, logsButtonListener, monitorButtonListener, monitorClick, navbarListener, networkButtonListener, newTokenButtonListener, pollStatus, putFile, putToken, redirectUrl, reloadEndpoints, reloadHealth, restartButtonListener, runningUpload, storageButtonListener, storageSelectListener, successUpload, tokenButtonListener, updateButtonListener, updateCertsButtonListener,
    indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  apiServer = window.location.origin != null ? window.location.origin : window.location.protocol + "//" + window.location.hostname + (window.location.port != null ? ':' + window.location.port : '');


  /* generic functions */

  putToken = function(sha256) {
    var date, days, oneDay;
    if ($('#login-remember').is(':checked')) {
      date = new Date();
      oneDay = 24 * 60 * 60 * 1000;
      days = 30;
      date.setTime(+date + (days * oneDay));
      return document.cookie = "jidoteki-admin-api-token=" + sha256 + "; expires=" + (date.toGMTString()) + "; path=/";
    } else {
      return document.cookie = "jidoteki-admin-api-token=" + sha256 + "; path=/";
    }
  };

  getToken = function() {
    return (document.cookie.match('(^|; )jidoteki-admin-api-token=([^;]*)') || 0)[2];
  };

  clearToken = function() {
    return document.cookie = 'jidoteki-admin-api-token=; path=/';
  };

  capitalize = function(string) {
    return string.charAt(0).toUpperCase() + string.slice(1);
  };

  getSha256 = function(string) {
    var md;
    md = forge.md.sha256.create();
    md.update(string);
    return md.digest().toHex();
  };

  getHmac = function(string, key) {
    var hmac;
    hmac = forge.hmac.create();
    hmac.start('sha256', key);
    hmac.update(string);
    return hmac.digest().toHex();
  };

  fetchData = function(endpoint, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("GET" + endpoint, sha256);
      return $.get("" + apiServer + endpoint + "?hash=" + hmac).done(function(response) {
        return callback(null, response);
      }).fail(function(err) {
        return callback(new Error(err));
      });
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  fetchFile = function(endpoint, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("GET" + endpoint, sha256);
      return $(location).attr('href', "" + apiServer + endpoint + "?hash=" + hmac);
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  putFile = function(msg, endpoint, file, callback) {
    var hmac, sha256;
    sha256 = getToken();
    if (sha256 != null) {
      hmac = getHmac("POST" + endpoint, sha256);
      $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-danger');
      $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-primary');
      $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-striped');
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('progress-bar-striped', 33);
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 33);
      $(".jido-page-content-" + msg + " .progress .progress-bar").html('....uploading, please wait');
      $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 33%');
      $(".jido-page-content-" + msg + " .progress").show();
      return $.ajax({
        url: "" + apiServer + endpoint + "?hash=" + hmac,
        type: "POST",
        data: file,
        processData: false,
        contentType: false,
        success: function(response, status, jqXHR) {
          runningUpload(msg);
          return callback(null, response);
        },
        error: function(jqXHR, status, err) {
          failedUpload(msg, 'upload failed');
          return callback(new Error(err), jqXHR);
        }
      });
    } else {
      return callback(new Error("Missing or invalid API token"));
    }
  };

  runningUpload = function(msg) {
    $(".jido-page-content-" + msg + " .progress").show();
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-primary');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('progress-bar-striped', 66);
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 66);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html('...updating');
    return $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 66%');
  };

  successUpload = function(msg) {
    $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-striped');
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-success');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 100);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html('done');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 100%');
    $("." + msg + "-form").show();
    return $("." + msg + "-alert").hide();
  };

  failedUpload = function(msg, message) {
    $(".jido-page-content-" + msg + " .progress .progress-bar").removeClass('progress-bar-striped');
    $(".jido-page-content-" + msg + " .progress .progress-bar").addClass('progress-bar-danger');
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('aria-valuenow', 100);
    $(".jido-page-content-" + msg + " .progress .progress-bar").html(validator.escape(message));
    $(".jido-page-content-" + msg + " .progress .progress-bar").attr('style', 'width: 100%');
    $("." + msg + "-form").show();
    return $("." + msg + "-alert").hide();
  };

  getStatus = function(msg, callback) {
    return fetchData("/api/v1/" + apiType + "/" + msg, function(err, result) {
      var label, status;
      if (err) {
        return callback(new Error(err));
      } else {
        if (typeof result.status === 'object') {
          status = "";
        } else {
          status = validator.escape(result.status);
        }
        $(".jido-data-" + msg + "-status").html(status);
        if (result.log) {
          $(".jido-data-" + msg + "-log").html(typeof result.log === 'object' ? "No log file found" : validator.escape(result.log).replace(/\\n/g, '<br/>'));
        }
        label = (function() {
          switch (status) {
            case "failed":
              return "label-danger";
            case "success":
              return "label-success";
            case "running":
              return "label-primary";
            default:
              $(".jido-data-" + msg + "-status").html("waiting for " + msg);
              return "label-default";
          }
        })();
        if (status === 'failed') {
          $(".jido-page-content-" + msg + " .alert.jido-panel").addClass("alert-danger");
          $(".jido-page-content-" + msg + " .jido-page-content-" + msg + "-panel").attr('style', 'background-color: none');
        } else {
          $(".jido-page-content-" + msg + " .alert.jido-panel").removeClass("alert-danger");
          $(".jido-page-content-" + msg + " .jido-page-content-" + msg + "-panel").attr('style', 'background-color: #EEEEEE');
        }
        if (result['error-code'] && result['error-message'] && status === 'failed') {
          $(".jido-data-" + msg + "-status-error").show();
          $(".jido-data-" + msg + "-status-error-message").html((validator.escape(result['error-code'])) + ": " + (validator.escape(result['error-message'])));
        } else {
          $(".jido-data-" + msg + "-status-error").hide();
          $(".jido-data-" + msg + "-status-error-message").html('');
        }
        $(".jido-data-" + msg + "-status").removeClass("label-danger");
        $(".jido-data-" + msg + "-status").removeClass("label-success");
        $(".jido-data-" + msg + "-status").removeClass("label-default");
        $(".jido-data-" + msg + "-status").addClass(label);
        return callback(result);
      }
    });
  };

  pollStatus = function(msg) {
    var interval;
    $("." + msg + "-form").hide();
    $("." + msg + "-alert").show();
    return interval = setInterval(function() {
      return getStatus(msg, function(result) {
        if (result.status === "failed") {
          clearInterval(interval);
          return failedUpload(msg, 'failed');
        } else if (result.status === "success") {
          clearInterval(interval);
          successUpload(msg);
          if (msg === "backup") {
            return loadBackup();
          }
        } else if (result.status === "running") {
          return runningUpload(msg);
        }
      });
    }, 1000);
  };

  redirectUrl = function(newUrl) {
    var interval;
    return interval = setInterval(function() {
      clearInterval(interval);
      return $(location).attr('href', newUrl);
    }, 5000);
  };

  authenticate = function(callback) {
    return fetchData("/api/v1/admin/version", function(err, result) {
      if (err) {
        clearToken();
        return callback(err);
      } else {
        return callback(null);
      }
    });
  };

  reloadHealth = function() {
    return fetchData("/api/v1/admin/health", function(err, result) {
      var cpudanger, diskdanger, memdanger;
      if (!err) {
        cpudanger = result['cpu']['cpu5min'] >= result['cpu']['num'] ? 'jido-health-danger' : '';
        diskdanger = result['disk']['percentage'] >= 98 ? 'jido-health-danger' : '';
        memdanger = result['memory']['percentage'] >= 90 ? 'jido-health-danger' : '';
        $('#jido-health-bar').empty();
        $('#jido-health-bar').append("<li class=\"" + cpudanger + "\">cpu " + result['cpu']['load'] + " (" + result['cpu']['num'] + " cores)</li>");
        $('#jido-health-bar').append("<li class=\"" + diskdanger + "\">disk " + result['disk']['used'] + " of " + result['disk']['total'] + " (" + result['disk']['percentage'] + "%)</li>");
        return $('#jido-health-bar').append("<li class=\"" + memdanger + "\">memory " + result['memory']['used'] + " of " + result['memory']['total'] + " (" + result['memory']['percentage'] + "%)</li>");
      }
    });
  };

  reloadEndpoints = function() {
    return fetchData("/api/v1/admin/endpoints", function(err, result) {
      var i, len, ref, results, value;
      if (!err) {
        results = [];
        for (i = 0, len = apiEndpoints.length; i < len; i++) {
          value = apiEndpoints[i];
          if (ref = "/api/v1/admin/" + value, indexOf.call(result.endpoints, ref) >= 0) {
            results.push($("#jido-button-" + value).show());
          } else {
            results.push(void 0);
          }
        }
        return results;
      }
    });
  };


  /* generic content functions */

  loadToken = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-token').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-token').show();
    $('.jido-page-content-token .jido-panel-network').show();
    $('.token-form .token-token1-label').focus();
    return $('.token-form input.form-control').val('');
  };

  loadSetup = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar').hide();
    $('#jido-page-token').show();
    $('.jido-page-content-token .jido-panel-network').show();
    $('.token-form .token-token1-label').focus();
    return $('.token-form input.form-control').val('');
  };

  loadLogin = function() {
    $('.jido-page-content').hide();
    $('#jido-page-navbar').hide();
    $('#jido-page-login').show();
    return $('#login-password').focus();
  };


  /* generic onclick listeners */

  logoutButtonListener = function() {
    return $('#jido-button-logout').click(function() {
      clearToken();
      return loadLogin();
    });
  };

  loginButtonListener = function() {
    return $('#jido-button-login').click(function() {
      var pass, sha256;
      pass = $('#login-password').val();
      if (pass.length >= 0 && pass.length <= 255) {
        sha256 = getSha256(pass);
      }
      if (sha256 != null) {
        putToken(sha256);
        return authenticate(function(err) {
          if (err) {
            $('#invalid-token').show();
            return $('#login-password').focus();
          } else {
            $('#login-password').val('');
            $('#invalid-token').hide();
            return loadHome();
          }
        });
      } else {
        $('#invalid-token').show();
        return $('#login-password').focus();
      }
    });
  };

  newTokenButtonListener = function() {
    return $('#new-token').click(function() {
      return loadSetup();
    });
  };

  tokenButtonListener = function() {
    return $('#jido-button-token-upload').click(function() {
      var formData, pass1, pass2, sha256;
      pass1 = $('#token1-input').val();
      pass2 = $('#token2-input').val();
      if (!pass1) {
        $('.token-form .token-token1-label').parent().addClass('has-error');
        $('.token-form .token-token1-label').html('API Token (required)');
        $('.token-form .token-token1-label').focus();
        return;
      }
      if (!pass2) {
        $('.token-form .token-token2-label').parent().addClass('has-error');
        $('.token-form .token-token2-label').html('Confirm API Token (required)');
        $('.token-form .token-token2-label').focus();
        return;
      }
      if (pass1 !== pass2) {
        $('.token-alert').html('API Token mismatch. Please verify the API Token.');
        $(".token-alert").show();
        return;
      }
      if (pass1.length > 0 && pass1.length <= 255) {
        sha256 = getSha256(pass1);
      }
      if (sha256 == null) {
        $(".token-alert").html('Invalid API Token. Must be between 1 and 255 characters');
        $(".token-alert").show();
        $('.token-form .token-token1-label').parent().addClass('has-error');
        $('.token-form .token-token1-label').html('API Token (required)');
        $('.token-form .token-token2-label').parent().addClass('has-error');
        $('.token-form .token-token2-label').html('Confirm API Token (required)');
        $('.token-form .token-token1-label').focus();
        return;
      }
      formData = new FormData();
      formData.append('newtoken', pass1);
      if (formData) {
        return putFile('token', '/api/v1/admin/setup', formData, function(err, result) {
          if (err) {
            $('.jido-data-token-status').html('failed');
            $('.jido-data-token-status').removeClass('label-danger');
            $('.jido-data-token-status').removeClass('label-success');
            $('.jido-data-token-status').removeClass('label-default');
            $('.jido-data-token-status').addClass('label-danger');
            return failedUpload('token');
          } else {
            $('.jido-data-token-status').html('changed');
            $('.jido-data-token-status').removeClass('label-danger');
            $('.jido-data-token-status').removeClass('label-success');
            $('.jido-data-token-status').removeClass('label-default');
            $('.jido-data-token-status').addClass('label-success');
            $(".token-alert").hide();
            putToken(sha256);
            successUpload('token');
            $('#token1-input').val('');
            $('#token2-input').val('');
            $('.jido-page-content-token .jido-panel-network').hide();
            return loadToken();
          }
        });
      }
    });
  };


  /* generic start here */

  logoutButtonListener();

  loginButtonListener();

  newTokenButtonListener();

  tokenButtonListener();

  apiType = 'admin';

  apiEndpoints = ['settings', 'certs', 'license', 'storage', 'backup'];


  /* content functions */

  loadHome = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-home').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-dashboard').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
    reloadHealth();
    reloadEndpoints();
    fetchData("/api/v1/admin/settings", function(err, result) {
      var key, networkSettings, value;
      if (!err) {
        networkSettings = (function() {
          var ref, results;
          ref = result.network;
          results = [];
          for (key in ref) {
            value = ref[key];
            if (key === 'ip_address') {
              key = "IP address";
            }
            if (key === 'dns1') {
              key = "DNS 1";
            }
            if (key === 'dns2') {
              key = "DNS 2";
            }
            if (key === 'ntpserver') {
              key = "NTP Server";
            }
            if (typeof value === 'object') {
              value = "";
            }
            results.push("<li class=\"list-group-item\">" + (capitalize(key)) + " <span class=\"pull-right text-primary\">" + (validator.escape(value)) + "</span></li>");
          }
          return results;
        })();
        return $('.jido-data-network-info').html(networkSettings);
      }
    });
    fetchData("/api/v1/admin/changelog", function(err, result) {
      if (!err) {
        return $('.jido-data-changelog').html(validator.escape(result));
      }
    });
    return fetchData("/api/v1/admin/services", function(err, result) {
      var i, key, len, ref, service, servicesStatus, value;
      if (!err) {
        servicesStatus = "";
        ref = result.services;
        for (i = 0, len = ref.length; i < len; i++) {
          service = ref[i];
          for (key in service) {
            value = service[key];
            if (value === 'running') {
              servicesStatus = servicesStatus + ("<li class=\"list-group-item\"><i class=\"fa icon-ok-circled text-success\"></i> " + (validator.escape(key)) + " <span class=\"pull-right text-success\">" + (validator.escape(value)) + "</span></li>");
            } else {
              servicesStatus = servicesStatus + ("<li class=\"list-group-item\"><i class=\"fa icon-cancel-circled text-danger\"></i> " + (validator.escape(key)) + " <span class=\"pull-right text-danger\">" + (validator.escape(value)) + "</span></li>");
            }
          }
        }
        return $('.jido-data-services-info').html(servicesStatus);
      }
    });
  };

  loadUpdateCerts = function(msg) {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $("#jido-button-" + msg).addClass('active');
    $('#jido-page-navbar').show();
    $(".jido-page-content-" + msg).show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
    return getStatus(msg, function(result) {
      if (result.status === "running") {
        return pollStatus(msg);
      }
    });
  };

  loadNetwork = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-settings').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-network').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
    return fetchData("/api/v1/admin/settings", function(err, result) {
      var key, networkSettings, value;
      if (!err) {
        $('.network-form input.form-control').val('');
        if (result.network["interface"] == null) {
          $('#interface-input').val('eth0');
        }
        networkSettings = (function() {
          var ref, results;
          ref = result.network;
          results = [];
          for (key in ref) {
            value = ref[key];
            if (typeof value === 'object') {
              value = "";
            }
            $("#" + key + "-input").val(validator.escape(value));
            results.push("<li class=\"list-group-item\">" + (capitalize(key)) + " <span class=\"pull-right label label-primary\">" + (validator.escape(value)) + "</span></li>");
          }
          return results;
        })();
        return $('.jido-data-network-info').html(networkSettings);
      }
    });
  };

  loadStorage = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-storage').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-storage').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
    return fetchData("/api/v1/admin/storage", function(err, result) {
      var ref, storageOptions, value;
      if (!err) {
        $('.storage-form input.form-control').val('');
        storageOptions = (function() {
          var i, len, ref, results;
          ref = result.options;
          results = [];
          for (i = 0, len = ref.length; i < len; i++) {
            value = ref[i];
            $("#storage-help-" + value).show();
            switch (value) {
              case 'local':
                results.push("<option value='local')>Local (disk)</option>");
                break;
              case 'nfs':
                results.push("<option value='nfs'>NFS</option>");
                break;
              case 'aoe':
                results.push("<option value='aoe'>AoE (ATA-over-Ethernet)</option>");
                break;
              case 'iscsi':
                results.push("<option value='iscsi'>iSCSI</option>");
                break;
              case 'nbd':
                results.push("<option value='nbd'>NBD</option>");
                break;
              default:
                results.push(void 0);
            }
          }
          return results;
        })();
        $('#storage-name-select').html(storageOptions);
        if (result.storage.type && (ref = result.storage.type, indexOf.call(result.options, ref) >= 0)) {
          $("#storage-name-select option[value=" + result.storage.type + "]").attr('selected', true);
          $("#storage-" + result.storage.type).show();
          switch (result.storage.type) {
            case "nfs":
              $("#storage-" + result.storage.type + " .mount-input").val(validator.escape(result.storage.mount_options));
              $("#storage-" + result.storage.type + " .ip-input").val(validator.escape(result.storage.ip));
              return $("#storage-" + result.storage.type + " .share-input").val(validator.escape(result.storage.share));
            case "aoe":
              return $("#storage-" + result.storage.type + " .device-input").val(validator.escape(result.storage.device));
            case "iscsi":
              $("#storage-" + result.storage.type + " .ip-input").val(validator.escape(result.storage.ip));
              $("#storage-" + result.storage.type + " .target-input").val(validator.escape(result.storage.target));
              $("#storage-" + result.storage.type + " .username-input").val(validator.escape(result.storage.username));
              return $("#storage-" + result.storage.type + " .password-input").val(validator.escape(result.storage.password));
            case "nbd":
              $("#storage-" + result.storage.type + " .ip-input").val(validator.escape(result.storage.ip));
              $("#storage-" + result.storage.type + " .port-input").val(validator.escape(result.storage.port));
              return $("#storage-" + result.storage.type + " .export-input").val(validator.escape(result.storage["export"]));
          }
        } else {
          return $("#storage-name-select option[value=local]").attr('selected', true);
        }
      }
    });
  };

  loadSupport = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-support').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-support').show();
    return fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
  };

  loadMonitor = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-monitor').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-monitor').show();
    return fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        $('.jido-data-platform-version').html(validator.escape(result.version));
        return monitorClick('1h');
      }
    });
  };

  loadBackup = function() {
    $('#jido-page-login').hide();
    $('.jido-page-content').hide();
    $('#jido-page-navbar .navbar-nav li').removeClass('active');
    $('#jido-button-backup').addClass('active');
    $('#jido-page-navbar').show();
    $('#jido-page-backup').show();
    fetchData("/api/v1/admin/version", function(err, result) {
      if (!err) {
        return $('.jido-data-platform-version').html(validator.escape(result.version));
      }
    });
    return getStatus("backup", function(result) {
      if (result.status === "running") {
        return pollStatus("backup");
      } else if (result.status === "success") {
        $('#backupInfo').show();
        $('#jido-button-backup-stop').show();
        $('#jido-page-backup pre.backup-status-filesize').html(validator.escape(result.filesize));
        return $('#jido-page-backup pre.backup-status-sha256').html(validator.escape(result.sha256));
      } else {
        $('#backupInfo').hide();
        return $('#jido-button-backup-stop').hide();
      }
    });
  };


  /* generic functions */

  monitorClick = function(result) {
    var makeGraph;
    makeGraph = function(clicked) {
      switch (clicked) {
        case '1h':
          return drawGraphs('-1h');
        case '1d':
          return drawGraphs('-1d');
        case '1w':
          return drawGraphs('-1w');
        case '1m':
          return drawGraphs('-1m');
        case '1y':
          return drawGraphs('-1y');
        default:
          return drawGraphs('-1d');
      }
    };
    $('#jido-monitor-duration li').removeClass('active');
    $(".jido-duration-" + result).addClass('active');
    return $('#jido-page-monitor p .jido-monitor-msg').fadeIn(500, function() {
      return makeGraph(result);
    });
  };

  drawGraphs = function(result) {
    var duration;
    duration = "-s " + result;
    draw('svgload', 'load', duration);
    draw('svgmemory', 'memory', duration);
    draw('svgnetwork', 'if_octets', duration);
    draw('svgdisk', 'disk', duration);
    return $('#jido-page-monitor p .jido-monitor-msg').fadeOut(2000);
  };


  /* onclick listeners */

  updateButtonListener = function() {
    return $('#jido-button-update-upload').click(function() {
      var formData;
      formData = new FormData();
      formData.append('update', $('#update-input[type=file]')[0].files[0]);
      if (formData) {
        return putFile('update', "/api/v1/admin/update", formData, function(err, result) {
          if (!err) {
            return pollStatus('update');
          }
        });
      }
    });
  };

  networkButtonListener = function() {
    return $('#jido-button-network-upload').click(function() {
      var blob, encoded, formData, json;
      json = new Object();
      json.app = {};
      json.network = {};
      json.network.hostname = $('#hostname-input').val();
      json.network["interface"] = $('#interface-input').val();
      json.network.ip_address = $('#ip_address-input').val();
      json.network.netmask = $('#netmask-input').val();
      json.network.gateway = $('#gateway-input').val();
      json.network.ntpserver = $('#ntpserver-input').val();
      if ($('#dns1-input').val()) {
        json.network.dns1 = $('#dns1-input').val();
      }
      if ($('#dns2-input').val()) {
        json.network.dns2 = $('#dns2-input').val();
      }
      if (!(json.network.hostname && validator.isFQDN(json.network.hostname, {
        require_tld: false
      }))) {
        $('.network-form .network-hostname-label').parent().addClass('has-error');
        $('.network-form .network-hostname-label').html('Hostname (required)');
        $('.network-form .network-hostname-label').focus();
        return;
      }
      if (!(json.network["interface"] && validator.isAlphanumeric(json.network["interface"]))) {
        $('.network-form .network-interface-label').parent().addClass('has-error');
        $('.network-form .network-interface-label').html('Interface (required)');
        $('.network-form .network-interface-label').focus();
        return;
      }
      if (json.network.ntpserver) {
        if (!validator.isFQDN(json.network.ntpserver) && !validator.isIP(json.network.ntpserver)) {
          $('.network-form .network-ntpserver-label').parent().addClass('has-error');
          $('.network-form .network-ntpserver-label').html('NTP Server (required)');
          $('.network-form .network-ntpserver-label').focus();
          return;
        }
      }
      $('.jido-data-network-status').removeClass('label-danger');
      $('.jido-data-network-status').removeClass('label-success');
      $('.jido-data-network-status').removeClass('label-default');
      if (json.network.ip_address && json.network.netmask && json.network.gateway) {
        if (!validator.isIP(json.network.ip_address)) {
          $('.network-form .network-ip_address-label').parent().addClass('has-error');
          $('.network-form .network-ip_address-label').focus();
          return;
        }
        if (!validator.isIP(json.network.netmask)) {
          if (!validator.isInt(json.network.netmask.replace('/', ''), {
            min: 1,
            max: 128
          })) {
            $('.network-form .network-netmask-label').parent().addClass('has-error');
            $('.network-form .network-netmask-label').focus();
            return;
          }
        }
        if (!validator.isIP(json.network.gateway)) {
          $('.network-form .network-gateway-label').parent().addClass('has-error');
          $('.network-form .network-gateway-label').focus();
          return;
        }
        if (json.network.dns1) {
          if (!validator.isIP(json.network.dns1)) {
            $('.network-form .network-dns1-label').parent().addClass('has-error');
            $('.network-form .network-dns1-label').focus();
            return;
          }
        }
        if (json.network.dns2) {
          if (!validator.isIP(json.network.dns2)) {
            $('.network-form .network-dns2-label').parent().addClass('has-error');
            $('.network-form .network-dns2-label').focus();
            return;
          }
        }
        $('.jido-data-network-status').html('STATIC');
        $('.jido-data-network-status').addClass('label-success');
      } else {
        $('.jido-data-network-status').html('DHCP');
        $('.jido-data-network-status').addClass('label-success');
        delete json.network.ip_address;
        delete json.network.netmask;
        delete json.network.gateway;
        delete json.network.ntpserver;
        delete json.network.dns1;
        delete json.network.dns2;
      }
      formData = new FormData();
      encoded = JSON.stringify(json);
      blob = new Blob([encoded], {
        type: 'application/json'
      });
      blob.lastModifiedDate = new Date();
      formData.append('settings', blob, 'settings.json');
      if (formData) {
        return putFile('network', '/api/v1/admin/settings', formData, function(err, result) {
          var newIP, newUrl;
          if (!err) {
            successUpload('network');
            if (json.network.ip_address) {
              newIP = validator.isIP(json.network.ip_address, 4) ? json.network.ip_address : "[" + json.network.ip_address + "]";
              newUrl = window.location.protocol + "//" + newIP + (window.location.port != null ? ':' + window.location.port : '');
              $(".network-alert").html("Redirecting to <a href=\"" + newUrl + "\">" + newUrl + "</a> in 5 seconds");
              $(".network-alert").show();
              return redirectUrl(newUrl);
            } else {
              return loadNetwork();
            }
          }
        });
      }
    });
  };

  certsButtonListener = function() {
    return $('#jido-button-certs-upload').click(function() {
      var formData;
      formData = new FormData();
      formData.append('public', $('#public-key-input[type=file]')[0].files[0]);
      formData.append('private', $('#private-key-input[type=file]')[0].files[0]);
      if ($('#ca-key-input[type=file]')[0].files[0]) {
        formData.append('ca', $('#ca-key-input[type=file]')[0].files[0]);
      }
      if (formData) {
        return putFile('certs', "/api/v1/admin/certs", formData, function(err, result) {
          if (!err) {
            return pollStatus('certs');
          }
        });
      }
    });
  };

  updateCertsButtonListener = function(msg) {
    return $("#jido-button-" + msg + "-fulllog").click(function() {
      return fetchData("/api/v1/admin/" + msg + "/log", function(err, result) {
        if (!err) {
          $("#jido-button-" + msg + "-fulllog").addClass('active');
          $(".jido-data-" + msg + "-full-log").parent().show();
          return $(".jido-data-" + msg + "-full-log").html(result ? validator.escape(result) : "No log file found");
        }
      });
    });
  };

  logsButtonListener = function() {
    return $('#jido-data-logs-files').click(function() {
      return fetchFile("/api/v1/admin/logs", function(err) {
        if (!err) {

        }
      });
    });
  };

  debugButtonListener = function() {
    return $('#jido-data-debug-files').click(function() {
      return fetchFile("/api/v1/admin/debug", function(err) {
        if (!err) {

        }
      });
    });
  };

  restartButtonListener = function() {
    return $('#jido-button-restart-confirm').click(function() {
      return fetchData("/api/v1/admin/reboot", function(err) {
        if (!err) {
          $(".restart-alert").show();
        }
      });
    });
  };

  monitorButtonListener = function() {
    return $('#jido-monitor-duration li a').click(function() {
      var clicked;
      clicked = $(this).attr('duration');
      return monitorClick(clicked);
    });
  };

  storageButtonListener = function() {
    return $('#jido-button-storage-upload').click(function() {
      var blob, encoded, formData, json;
      json = new Object();
      json.storage = {};
      json.storage.type = $('#storage-name-select').val();
      switch (json.storage.type) {
        case "nfs":
          json.storage.ip = $("#storage-" + json.storage.type + " .ip-input").val();
          json.storage.mount_options = $("#storage-" + json.storage.type + " .mount-input").val();
          json.storage.share = $("#storage-" + json.storage.type + " .share-input").val();
          if (!(json.storage.ip && validator.isIP(json.storage.ip))) {
            $("#storage-" + json.storage.type + " .storage-ip-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-ip-label").html('IP address (required)');
            $("#storage-" + json.storage.type + " .ip-input").focus();
            return;
          }
          if (!(json.storage.share && validator.isWhitelisted(json.storage.share, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/"))) {
            $("#storage-" + json.storage.type + " .storage-share-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-share-label").html('Share path (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/');
            $("#storage-" + json.storage.type + " .share-input").focus();
            return;
          }
          if (!(json.storage.mount_options && validator.isWhitelisted(json.storage.mount_options, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=,.-"))) {
            $("#storage-" + json.storage.type + " .storage-mount-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-mount-label").html('Mount options (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=,.-');
            $("#storage-" + json.storage.type + " .mount-input").focus();
            return;
          }
          break;
        case "aoe":
          json.storage.device = $("#storage-" + json.storage.type + " .device-input").val();
          if (!(json.storage.device && validator.isWhitelisted(json.storage.device, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789."))) {
            $("#storage-" + json.storage.type + " .storage-device-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-device-label").html('Device (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.');
            $("#storage-" + json.storage.type + " .device-input").focus();
            return;
          }
          break;
        case "iscsi":
          json.storage.ip = $("#storage-" + json.storage.type + " .ip-input").val();
          json.storage.target = $("#storage-" + json.storage.type + " .target-input").val();
          json.storage.username = $("#storage-" + json.storage.type + " .username-input").val();
          json.storage.password = $("#storage-" + json.storage.type + " .password-input").val();
          if (!(json.storage.ip && validator.isIP(json.storage.ip))) {
            $("#storage-" + json.storage.type + " .storage-ip-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-ip-label").html('IP address (required)');
            $("#storage-" + json.storage.type + " .ip-input").focus();
            return;
          }
          if (!(json.storage.target && validator.isWhitelisted(json.storage.target, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-:"))) {
            $("#storage-" + json.storage.type + " .storage-target-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-target-label").html('Target (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-:');
            $("#storage-" + json.storage.type + " .target-input").focus();
            return;
          }
          if (!(json.storage.username && validator.isAscii(json.storage.username))) {
            $("#storage-" + json.storage.type + " .storage-username-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-username-label").html('Username (required)<br/>Allowed: ASCII characters');
            $("#storage-" + json.storage.type + " .username-input").focus();
            return;
          }
          if (!(json.storage.password && validator.isAscii(json.storage.password))) {
            $("#storage-" + json.storage.type + " .storage-password-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-password-label").html('Password (required)<br/>Allowed: ASCII characters');
            $("#storage-" + json.storage.type + " .password-input").focus();
            return;
          }
          break;
        case "nbd":
          json.storage.ip = $("#storage-" + json.storage.type + " .ip-input").val();
          json.storage.port = $("#storage-" + json.storage.type + " .port-input").val();
          json.storage.export_name = $("#storage-" + json.storage.type + " .export-input").val();
          if (!(json.storage.ip && validator.isIP(json.storage.ip))) {
            $("#storage-" + json.storage.type + " .storage-ip-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-ip-label").html('IP address (required)');
            $("#storage-" + json.storage.type + " .ip-input").focus();
            return;
          }
          if (!(json.storage.port && validator.isNumeric(json.storage.port))) {
            $("#storage-" + json.storage.type + " .storage-port-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-port-label").html('Port (required)');
            $("#storage-" + json.storage.type + " .port-input").focus();
            return;
          }
          if (!(json.storage.export_name && validator.isWhitelisted(json.storage.export_name, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/"))) {
            $("#storage-" + json.storage.type + " .storage-export-label").parent().addClass('has-error');
            $("#storage-" + json.storage.type + " .storage-export-label").html('Export name (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/');
            $("#storage-" + json.storage.type + " .export-input").focus();
            return;
          }
      }
      formData = new FormData();
      encoded = JSON.stringify(json);
      blob = new Blob([encoded], {
        type: 'application/json'
      });
      blob.lastModifiedDate = new Date();
      formData.append('settings', blob, 'settings.json');
      if (formData) {
        return putFile('storage', '/api/v1/admin/storage', formData, function(err, result) {
          $('.jido-panel').show();
          if (!err) {
            successUpload('storage');
            $(".storage-alert").html("Please Restart to apply storage settings.");
            return $(".storage-alert").show();
          }
        });
      }
    });
  };

  storageSelectListener = function() {
    return $('#storage-name-select').change(function() {
      var option;
      option = $(this).val();
      $('.storage-form-options').hide();
      return $("#storage-" + option).show();
    });
  };

  backupButtonListener = function() {
    $('#jido-button-backup-start').click(function() {
      var formData;
      formData = new FormData();
      formData.append('action', "START");
      if (formData) {
        return putFile('backup', '/api/v1/admin/backup', formData, function(err, result) {
          if (err) {
            $('.jido-data-backup-status').html('failed');
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            return $('.jido-data-backup-status').addClass('label-danger');
          } else {
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            $('.jido-data-backup-status').addClass('label-success');
            return loadBackup();
          }
        });
      }
    });
    $('#jido-button-backup-stop').click(function() {
      var formData;
      formData = new FormData();
      formData.append('action', "STOP");
      if (formData) {
        return putFile('backup', '/api/v1/admin/backup', formData, function(err, result) {
          if (err) {
            $('.jido-data-backup-status').html('failed');
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            return $('.jido-data-backup-status').addClass('label-danger');
          } else {
            $('.jido-data-backup-status').html('backup canceled');
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            $('.jido-data-backup-status').addClass('label-success');
            successUpload("backup");
            return loadBackup();
          }
        });
      }
    });
    $('#jido-data-backup-file').click(function() {
      return fetchFile("/api/v1/admin/backup/download", function(err) {
        if (!err) {

        }
      });
    });
    return $('#jido-button-backup-upload').click(function() {
      var formData;
      formData = new FormData();
      formData.append('archive', $('#backup-restore-input[type=file]')[0].files[0]);
      if (formData) {
        return putFile('backup', "/api/v1/admin/backup/restore", formData, function(err, result) {
          if (err) {
            $('.jido-data-backup-status').html('failed');
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            $('.jido-data-backup-status').addClass('label-danger');
          } else {
            $('.jido-data-backup-status').html('backup restored');
            $('.jido-data-backup-status').removeClass('label-danger');
            $('.jido-data-backup-status').removeClass('label-success');
            $('.jido-data-backup-status').removeClass('label-default');
            $('.jido-data-backup-status').addClass('label-success');
          }
          return $(".jido-page-content-backup .progress").hide();
        });
      }
    });
  };

  navbarListener = function() {
    return $('#jido-page-navbar .navbar-nav li a').click(function() {
      var clicked;
      clicked = $(this).parent().attr('id');
      switch (clicked) {
        case "jido-button-home":
          loadHome();
          break;
        case "jido-button-update":
          loadUpdateCerts('update');
          break;
        case "jido-button-settings":
          loadNetwork();
          break;
        case "jido-button-certs":
          loadUpdateCerts('certs');
          break;
        case "jido-button-license":
          loadLicense();
          break;
        case "jido-button-storage":
          loadStorage();
          break;
        case "jido-button-token":
          loadToken();
          break;
        case "jido-button-support":
          loadSupport();
          break;
        case "jido-button-monitor":
          loadMonitor();
          break;
        case "jido-button-backup":
          loadBackup();
      }
      return reloadHealth();
    });
  };


  /* start here */

  updateButtonListener();

  networkButtonListener();

  certsButtonListener();

  updateCertsButtonListener('update');

  logsButtonListener();

  debugButtonListener();

  restartButtonListener();

  monitorButtonListener();

  storageButtonListener();

  storageSelectListener();

  backupButtonListener();

  navbarListener();

  authenticate(function(err) {
    if (err) {
      return loadLogin();
    } else {
      return loadHome();
    }
  });

}).call(this);
