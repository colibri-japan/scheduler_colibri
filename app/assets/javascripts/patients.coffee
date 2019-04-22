# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

patientSelect2 = ->
  $('#patient_caveat_list').select2
    tags: true,
    theme: 'bootstrap',
    language: 'ja'
  return

$(document).on 'turbolinks:load', ->
  
  $('tr.patient-clickable-row').click ->
    $.getScript($(this).data('link'))
    return 

  $('#deactivated-patients').click ->
    $('.toggle-active-element').removeClass('toggle-active-selected')
    $(this).addClass('toggle-active-selected')
    $('#deactivated-patients-table').show()
    $('#active-patients-table').hide()
    return

  $('#active-patients').click ->
    $('.toggle-active-element').removeClass('toggle-active-selected')
    $(this).addClass('toggle-active-selected')
    $('#deactivated-patients-table').hide()
    $('#active-patients-table').show()
    return
    
  return