# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

  $('#activity-filter').change ->
    window.location = planningActivitiesUrl + '?n=' + $('#nurse-filter').val() + '&pat=' + $('#patient-filter').val() + '&us=' + $('#user-filter').val() + '&key=' + $('#key-filter').val()
    return

  return
