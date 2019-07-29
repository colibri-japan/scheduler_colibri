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

  $('tr.nurse-clickable-row').click ->
    $.getScript($(this).data('link'))
    return

  $('#payable-query-trigger').click ->
    url = window.location.href.split('?')[0] + '?m=' + $('#query_month').val() + '&y=' + $('#query_year').val();
    window.location = url
    return

  $('#nurse_monthly_wage').click ->
    $('#manage_nurse_monthly_wage').modal('show')    
    return
    
  
  return
