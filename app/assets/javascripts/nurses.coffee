# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#resource-details-panel').hide()
  $('#more-resource-history').hide()

  $('#resource-name-wrapper').hover ->
    $('#resource-details-panel').toggle()
    return

  $('#resource-details-button').click ->
    $('#resource-details-panel').toggle()
    return

  $('#see-more-resource-history-button').click ->
    $('#more-resource-history').toggle()
    return


  
    
  
  return
