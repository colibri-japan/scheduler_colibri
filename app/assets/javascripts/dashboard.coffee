# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

  $('#query_date').on 'change', ->
    url = $(this).data('url') + '?q=' + $(this).val() + '&team_id=' + window.teamId
    $.getScript url
    return

  scrollPosts()

  return