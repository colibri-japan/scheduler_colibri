# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  
  $('.resource-title-selectable').click ->
    window.location = $(this).data('url')
    return

  $('.print-option-checkbox').bootstrapToggle
    on: '有',
    off: '無',
    size: 'small',
    onstyle: 'primary',
    offstyle: 'secondary',
    width: 55
  
  return