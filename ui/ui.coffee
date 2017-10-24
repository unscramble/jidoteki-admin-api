# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
# Copyright (c) 2015-2017 Alexander Williams, Unscramble <license@unscramble.jp>

apiType = 'admin'
apiEndpoints = [
  'settings',
  'certs',
  'license',
  'storage',
  'backup'
  ]

### content functions ###

loadHome = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-home').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-dashboard').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

  reloadHealth()
  reloadEndpoints()

  fetchData "/api/v1/admin/settings", (err, result) ->
    unless err
      networkSettings = for key, value of result.network
        key = "IP address" if key == 'ip_address'
        key = "DNS 1" if key == 'dns1'
        key = "DNS 2" if key == 'dns2'
        key = "NTP Server" if key == 'ntpserver'

        value = "" if typeof value is 'object'

        "<li class=\"list-group-item\">#{capitalize key} <span class=\"pull-right text-primary\">#{validator.escape(value)}</span></li>"

      $('.jido-data-network-info').html networkSettings

  fetchData "/api/v1/admin/changelog", (err, result) ->
    unless err
      $('.jido-data-changelog').html validator.escape(result)

  fetchData "/api/v1/admin/services", (err, result) ->
    unless err
      servicesStatus = ""
      for service in result.services
        for key, value of service
          if value == 'running'
            servicesStatus = servicesStatus + "<li class=\"list-group-item\"><i class=\"fa icon-ok-circled text-success\"></i> #{validator.escape(key)} <span class=\"pull-right text-success\">#{validator.escape(value)}</span></li>"
          else
            servicesStatus = servicesStatus + "<li class=\"list-group-item\"><i class=\"fa icon-cancel-circled text-danger\"></i> #{validator.escape(key)} <span class=\"pull-right text-danger\">#{validator.escape(value)}</span></li>"

      $('.jido-data-services-info').html servicesStatus

loadUpdateCerts = (msg) ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $("#jido-button-#{msg}").addClass('active')
  $('#jido-page-navbar').show()
  $(".jido-page-content-#{msg}").show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

  getStatus msg, (result) ->
    if result.status is "running"
      pollStatus msg

loadNetwork = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-settings').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-network').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

  fetchData "/api/v1/admin/settings", (err, result) ->
    unless err
      $('.network-form input.form-control').val '' # reset all network input fields

      unless result.network.interface?
        $('#interface-input').val 'eth0'

      networkSettings = for key, value of result.network
        value = "" if typeof value is 'object'
        $("##{key}-input").val validator.escape(value)

        "<li class=\"list-group-item\">#{capitalize key} <span class=\"pull-right label label-primary\">#{validator.escape(value)}</span></li>"

      $('.jido-data-network-info').html networkSettings

loadStorage = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-storage').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-storage').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

  fetchData "/api/v1/admin/storage", (err, result) ->
    unless err
      $('.storage-form input.form-control').val '' # reset all storage input fields

      storageOptions = for value in result.options
        $("#storage-help-#{value}").show()
        switch value
          when 'local'  then "<option value='local')>Local (disk)</option>"
          when 'nfs'    then "<option value='nfs'>NFS</option>"
          when 'aoe'    then "<option value='aoe'>AoE (ATA-over-Ethernet)</option>"
          when 'iscsi'  then "<option value='iscsi'>iSCSI</option>"
          when 'nbd'    then "<option value='nbd'>NBD</option>"

      $('#storage-name-select').html storageOptions

      if result.storage.type and result.storage.type in result.options
        $("#storage-name-select option[value=#{result.storage.type}]").attr 'selected', true
        $("#storage-#{result.storage.type}").show()

        switch result.storage.type
          when "nfs"
            $("#storage-#{result.storage.type} .mount-input").val validator.escape(result.storage.mount_options)
            $("#storage-#{result.storage.type} .ip-input").val validator.escape(result.storage.ip)
            $("#storage-#{result.storage.type} .share-input").val validator.escape(result.storage.share)
          when "aoe"
            $("#storage-#{result.storage.type} .device-input").val validator.escape(result.storage.device)
          when "iscsi"
            $("#storage-#{result.storage.type} .ip-input").val validator.escape(result.storage.ip)
            $("#storage-#{result.storage.type} .target-input").val validator.escape(result.storage.target)
            $("#storage-#{result.storage.type} .username-input").val validator.escape(result.storage.username)
            $("#storage-#{result.storage.type} .password-input").val validator.escape(result.storage.password)
          when "nbd"
            $("#storage-#{result.storage.type} .ip-input").val validator.escape(result.storage.ip)
            $("#storage-#{result.storage.type} .port-input").val validator.escape(result.storage.port)
            $("#storage-#{result.storage.type} .export-input").val validator.escape(result.storage.export)
      else
        $("#storage-name-select option[value=local]").attr 'selected', true

loadSupport = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-support').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-support').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

loadMonitor = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-monitor').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-monitor').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

      monitorClick '1h'

loadBackup = ->
  $('#jido-page-login').hide()
  $('.jido-page-content').hide()
  $('#jido-page-navbar .navbar-nav li').removeClass('active')
  $('#jido-button-backup').addClass('active')
  $('#jido-page-navbar').show()
  $('#jido-page-backup').show()

  fetchData "/api/v1/admin/version", (err, result) ->
    unless err
      $('.jido-data-platform-version').html validator.escape(result.version)

  getStatus "backup", (result) ->
    if result.status is "running"
      pollStatus "backup"
    else if result.status is "success"
      $('#backupInfo').show()
      $('#jido-button-backup-stop').show()
      $('#jido-page-backup pre.backup-status-filesize').html validator.escape(result.filesize)
      $('#jido-page-backup pre.backup-status-sha256').html validator.escape(result.sha256)
    else
      $('#backupInfo').hide()
      $('#jido-button-backup-stop').hide()

  # fetchData "/api/v1/admin/backup", (err, result) ->
  #   if err
  #     $('#backupInfo').hide()
  #     $('#jido-button-backup-stop').hide()
  #   else
  #     $('#backupInfo').show()
  #     $('#jido-button-backup-stop').show()
  #     $('#jido-page-backup pre.backup-status-filesize').html result.filesize
  #     $('#jido-page-backup pre.backup-status-sha256').html result.sha256

### generic functions ###
monitorClick = (result) ->
  makeGraph = (clicked) ->
    switch clicked
      when '1h'   then drawGraphs '-1h'
      when '1d'   then drawGraphs '-1d'
      when '1w'   then drawGraphs '-1w'
      when '1m'   then drawGraphs '-1m'
      when '1y'   then drawGraphs '-1y'
      else drawGraphs '-1d'

  $('#jido-monitor-duration li').removeClass 'active'
  $(".jido-duration-#{result}").addClass 'active'
  $('#jido-page-monitor p .jido-monitor-msg').fadeIn 500, ->
    makeGraph result

drawGraphs = (result) ->
  duration = "-s #{result}"

  draw('svgload', 'load', duration)
  draw('svgmemory', 'memory', duration)
  draw('svgnetwork', 'if_octets', duration)
  draw('svgdisk', 'disk', duration)
  $('#jido-page-monitor p .jido-monitor-msg').fadeOut 2000

### onclick listeners ###

updateButtonListener = ->
  $('#jido-button-update-upload').click ->
    formData = new FormData()
    formData.append 'update', $('#update-input[type=file]')[0].files[0]

    if formData
      putFile 'update', "/api/v1/admin/update", formData, (err, result) ->
        unless err
          pollStatus 'update'

networkButtonListener = ->
  $('#jido-button-network-upload').click ->

    json = new Object()
    json.app = {}
    json.network = {}
    json.network.hostname = $('#hostname-input').val()
    json.network.interface = $('#interface-input').val()
    json.network.ip_address = $('#ip_address-input').val()
    json.network.netmask = $('#netmask-input').val()
    json.network.gateway = $('#gateway-input').val()
    json.network.ntpserver = $('#ntpserver-input').val()
    if $('#dns1-input').val() then json.network.dns1 = $('#dns1-input').val()
    if $('#dns2-input').val() then json.network.dns2 = $('#dns2-input').val()

    # Validations
    unless json.network.hostname and validator.isFQDN(json.network.hostname, {require_tld: false})
      $('.network-form .network-hostname-label').parent().addClass 'has-error'
      $('.network-form .network-hostname-label').html 'Hostname (required)'
      $('.network-form .network-hostname-label').focus()
      return

    unless json.network.interface and validator.isAlphanumeric(json.network.interface)
      $('.network-form .network-interface-label').parent().addClass 'has-error'
      $('.network-form .network-interface-label').html 'Interface (required)'
      $('.network-form .network-interface-label').focus()
      return

    # ntpserver is not required, but if it's supplied, it must be valid
    if json.network.ntpserver
      if !validator.isFQDN(json.network.ntpserver) and !validator.isIP(json.network.ntpserver)
        $('.network-form .network-ntpserver-label').parent().addClass 'has-error'
        $('.network-form .network-ntpserver-label').html 'NTP Server (required)'
        $('.network-form .network-ntpserver-label').focus()
        return

    $('.jido-data-network-status').removeClass 'label-danger'
    $('.jido-data-network-status').removeClass 'label-success'
    $('.jido-data-network-status').removeClass 'label-default'

    if json.network.ip_address and json.network.netmask and json.network.gateway
      unless validator.isIP(json.network.ip_address)
        $('.network-form .network-ip_address-label').parent().addClass 'has-error'
        $('.network-form .network-ip_address-label').focus()
        return

      unless validator.isIP(json.network.netmask)
        unless validator.isInt(json.network.netmask.replace('/',''), { min: 1, max: 128 })
          $('.network-form .network-netmask-label').parent().addClass 'has-error'
          $('.network-form .network-netmask-label').focus()
          return

      unless validator.isIP(json.network.gateway)
        $('.network-form .network-gateway-label').parent().addClass 'has-error'
        $('.network-form .network-gateway-label').focus()
        return

      if json.network.dns1
        unless validator.isIP(json.network.dns1)
          $('.network-form .network-dns1-label').parent().addClass 'has-error'
          $('.network-form .network-dns1-label').focus()
          return

      if json.network.dns2
        unless validator.isIP(json.network.dns2)
          $('.network-form .network-dns2-label').parent().addClass 'has-error'
          $('.network-form .network-dns2-label').focus()
          return

      $('.jido-data-network-status').html 'STATIC'
      $('.jido-data-network-status').addClass 'label-success'
    else
      $('.jido-data-network-status').html 'DHCP'
      $('.jido-data-network-status').addClass 'label-success'
      delete json.network.ip_address
      delete json.network.netmask
      delete json.network.gateway
      delete json.network.ntpserver
      delete json.network.dns1
      delete json.network.dns2

    formData = new FormData()
    encoded = JSON.stringify json
    blob = new Blob [encoded], {type: 'application/json'}
    blob.lastModifiedDate = new Date()

    formData.append 'settings', blob, 'settings.json'

    if formData
      putFile 'network', '/api/v1/admin/settings', formData, (err, result) ->
        unless err
          successUpload 'network'

          if json.network.ip_address
            newIP = if validator.isIP(json.network.ip_address, 4) then json.network.ip_address else "[#{json.network.ip_address}]"
            newUrl = "#{window.location.protocol}//#{newIP}#{(if window.location.port? then ':' + window.location.port else '')}"
            $(".network-alert").html "Redirecting to <a href=\"#{newUrl}\">#{newUrl}</a> in 5 seconds"
            $(".network-alert").show()
            redirectUrl newUrl
          else
            loadNetwork()

certsButtonListener = ->
  $('#jido-button-certs-upload').click ->
    formData = new FormData()
    formData.append 'public', $('#public-key-input[type=file]')[0].files[0]
    formData.append 'private', $('#private-key-input[type=file]')[0].files[0]
    formData.append 'ca', $('#ca-key-input[type=file]')[0].files[0] if $('#ca-key-input[type=file]')[0].files[0]

    if formData
      putFile 'certs', "/api/v1/admin/certs", formData, (err, result) ->
        unless err
          pollStatus 'certs'

updateCertsButtonListener = (msg) ->
  $("#jido-button-#{msg}-fulllog").click ->
    fetchData "/api/v1/admin/#{msg}/log", (err, result) ->
      unless err
        $("#jido-button-#{msg}-fulllog").addClass 'active'
        $(".jido-data-#{msg}-full-log").parent().show()
        $(".jido-data-#{msg}-full-log").html(if result then validator.escape(result) else "No log file found")

logsButtonListener = ->
  $('#jido-data-logs-files').click ->
    fetchFile "/api/v1/admin/logs", (err) ->
      unless err
        return

debugButtonListener = ->
  $('#jido-data-debug-files').click ->
    fetchFile "/api/v1/admin/debug", (err) ->
      unless err
        return

restartButtonListener = ->
  $('#jido-button-restart-confirm').click ->
    fetchData "/api/v1/admin/reboot", (err) ->
      unless err
        $(".restart-alert").show()
        return

monitorButtonListener = ->
  $('#jido-monitor-duration li a').click ->
    clicked = $(this).attr 'duration'

    monitorClick clicked

storageButtonListener = ->
  $('#jido-button-storage-upload').click ->

    json = new Object()
    json.storage = {}
    json.storage.type = $('#storage-name-select').val()

    # Validations
    switch json.storage.type
      when "nfs"
        json.storage.ip = $("#storage-#{json.storage.type} .ip-input").val()
        json.storage.mount_options = $("#storage-#{json.storage.type} .mount-input").val()
        json.storage.share = $("#storage-#{json.storage.type} .share-input").val()

        unless json.storage.ip and validator.isIP(json.storage.ip)
          $("#storage-#{json.storage.type} .storage-ip-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-ip-label").html 'IP address (required)'
          $("#storage-#{json.storage.type} .ip-input").focus()
          return

        unless json.storage.share and validator.isWhitelisted(json.storage.share, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/")
          $("#storage-#{json.storage.type} .storage-share-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-share-label").html 'Share path (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/'
          $("#storage-#{json.storage.type} .share-input").focus()
          return

        unless json.storage.mount_options and validator.isWhitelisted(json.storage.mount_options, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=,.-")
          $("#storage-#{json.storage.type} .storage-mount-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-mount-label").html 'Mount options (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789=,.-'
          $("#storage-#{json.storage.type} .mount-input").focus()
          return

      when "aoe"
        json.storage.device = $("#storage-#{json.storage.type} .device-input").val()

        unless json.storage.device and validator.isWhitelisted(json.storage.device, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.")
          $("#storage-#{json.storage.type} .storage-device-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-device-label").html 'Device (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789.'
          $("#storage-#{json.storage.type} .device-input").focus()
          return

      when "iscsi"
        json.storage.ip = $("#storage-#{json.storage.type} .ip-input").val()
        json.storage.target = $("#storage-#{json.storage.type} .target-input").val()
        json.storage.username = $("#storage-#{json.storage.type} .username-input").val()
        json.storage.password = $("#storage-#{json.storage.type} .password-input").val()

        unless json.storage.ip and validator.isIP(json.storage.ip)
          $("#storage-#{json.storage.type} .storage-ip-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-ip-label").html 'IP address (required)'
          $("#storage-#{json.storage.type} .ip-input").focus()
          return

        unless json.storage.target and validator.isWhitelisted(json.storage.target, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-:")
          $("#storage-#{json.storage.type} .storage-target-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-target-label").html 'Target (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-:'
          $("#storage-#{json.storage.type} .target-input").focus()
          return

        unless json.storage.username and validator.isAscii(json.storage.username)
          $("#storage-#{json.storage.type} .storage-username-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-username-label").html 'Username (required)<br/>Allowed: ASCII characters'
          $("#storage-#{json.storage.type} .username-input").focus()
          return

        unless json.storage.password and validator.isAscii(json.storage.password)
          $("#storage-#{json.storage.type} .storage-password-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-password-label").html 'Password (required)<br/>Allowed: ASCII characters'
          $("#storage-#{json.storage.type} .password-input").focus()
          return

      when "nbd"
        json.storage.ip = $("#storage-#{json.storage.type} .ip-input").val()
        json.storage.port = $("#storage-#{json.storage.type} .port-input").val()
        json.storage.export_name = $("#storage-#{json.storage.type} .export-input").val()

        unless json.storage.ip and validator.isIP(json.storage.ip)
          $("#storage-#{json.storage.type} .storage-ip-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-ip-label").html 'IP address (required)'
          $("#storage-#{json.storage.type} .ip-input").focus()
          return

        unless json.storage.port and validator.isNumeric(json.storage.port)
          $("#storage-#{json.storage.type} .storage-port-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-port-label").html 'Port (required)'
          $("#storage-#{json.storage.type} .port-input").focus()
          return

        unless json.storage.export_name and validator.isWhitelisted(json.storage.export_name, "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/")
          $("#storage-#{json.storage.type} .storage-export-label").parent().addClass 'has-error'
          $("#storage-#{json.storage.type} .storage-export-label").html 'Export name (required)<br/>Allowed: abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789._-/'
          $("#storage-#{json.storage.type} .export-input").focus()
          return

    formData = new FormData()
    encoded = JSON.stringify json
    blob = new Blob [encoded], {type: 'application/json'}
    blob.lastModifiedDate = new Date()

    formData.append 'settings', blob, 'settings.json'

    if formData
      putFile 'storage', '/api/v1/admin/storage', formData, (err, result) ->
        $('.jido-panel').show()
        unless err
          successUpload 'storage'

          $(".storage-alert").html "Please Restart to apply storage settings."
          $(".storage-alert").show()

storageSelectListener = () ->
  $('#storage-name-select').change ->
    option = $(this).val()
    $('.storage-form-options').hide()
    $("#storage-#{option}").show()

backupButtonListener = () ->
  $('#jido-button-backup-start').click ->
    formData = new FormData()
    formData.append 'action', "START"

    if formData
      putFile 'backup', '/api/v1/admin/backup', formData, (err, result) ->
        if err
          $('.jido-data-backup-status').html 'failed'
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-danger'
        else
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-success'

          loadBackup()

  $('#jido-button-backup-stop').click ->
    formData = new FormData()
    formData.append 'action', "STOP"

    if formData
      putFile 'backup', '/api/v1/admin/backup', formData, (err, result) ->
        if err
          $('.jido-data-backup-status').html 'failed'
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-danger'

        else
          $('.jido-data-backup-status').html 'backup canceled'
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-success'

          successUpload "backup"
          loadBackup()

  $('#jido-data-backup-file').click ->
    fetchFile "/api/v1/admin/backup/download", (err) ->
      unless err
        return

  $('#jido-button-backup-upload').click ->
    formData = new FormData()
    formData.append 'archive', $('#backup-restore-input[type=file]')[0].files[0]

    if formData
      putFile 'backup', "/api/v1/admin/backup/restore", formData, (err, result) ->
        if err
          $('.jido-data-backup-status').html 'failed'
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-danger'
        else
          $('.jido-data-backup-status').html 'backup restored'
          $('.jido-data-backup-status').removeClass 'label-danger'
          $('.jido-data-backup-status').removeClass 'label-success'
          $('.jido-data-backup-status').removeClass 'label-default'
          $('.jido-data-backup-status').addClass 'label-success'

        $(".jido-page-content-backup .progress").hide()

navbarListener = ->
  $('#jido-page-navbar .navbar-nav li a').click ->
    clicked = $(this).parent().attr 'id'
    switch clicked
      when "jido-button-home"     then loadHome()
      when "jido-button-update"   then loadUpdateCerts 'update'
      when "jido-button-settings" then loadNetwork()
      when "jido-button-certs"    then loadUpdateCerts 'certs'
      when "jido-button-license"  then loadLicense()
      when "jido-button-storage"  then loadStorage()
      when "jido-button-token"    then loadToken()
      when "jido-button-support"  then loadSupport()
      when "jido-button-monitor"  then loadMonitor()
      when "jido-button-backup"   then loadBackup()

    reloadHealth()

### start here ###

updateButtonListener()
networkButtonListener()
certsButtonListener()
updateCertsButtonListener 'update'
# updateCertsButtonListener 'certs' # not used for now (endpoint doesn't exist)
logsButtonListener()
debugButtonListener()
restartButtonListener()
monitorButtonListener()
storageButtonListener()
storageSelectListener()
backupButtonListener()
navbarListener()

authenticate (err) ->
  if err then loadLogin() else loadHome()
