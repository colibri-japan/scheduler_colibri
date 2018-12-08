# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

  $('#resource-name-wrapper').hover ->
    $('#resource-details-panel').toggle()
    return

  $('#resource-details-button').click ->
    $('#resource-details-panel').toggle()
    return

  $('#see-more-resource-history-button').click ->
    $('#more-resource-history').toggle()
    return

  $('#new-email-reminder').click ->
    targetPath =  $(this).data('reminder-url')
    $.getScript targetPath, ->
      $('#chosen-custom-email-days').chosen
        disable_search_threshold: 8
      return
    return

  $('#payable-download-button').click ->
    window.location = window.excelUrl + '?p=' + $('#schedule-filter').val()
    return

  $('tr.nurse-clickable-row').click ->
    $.getScript($(this).data('link'))
    return
    
  
  return
