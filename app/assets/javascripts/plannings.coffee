# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#service-index').hide()
  
  $('#settings-options').click ->
    $('#planning-options').show()
    $('#settings-options').addClass('settings-list-element-selected')
    $('#service-index').hide()
    $('#settings-services').removeClass('settings-list-element-selected')
    return
  
  $('#settings-services').click ->    
    $('#planning-options').hide()
    $('#settings-options').removeClass('settings-list-element-selected')
    $('#service-index').show()
    $('#settings-services').addClass('settings-list-element-selected')
    return
  
  return