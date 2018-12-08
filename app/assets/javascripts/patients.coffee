# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

patientSelect2 = ->
  $('#patient_caveat_list').select2
    tags: true,
    theme: 'bootstrap',
    language: 'ja'
  
  $('tr.patient-clickable-row').click ->
    $.getScript($(this).data('link'))
    return 
    
  return