# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  $('#query_date').daterangepicker
    singleDatePicker: true
    showDropdowns: true
    minYear: 2016
    maxYear: 2030
    locale: {
        format: 'YYYY年MM月DD日'
        daysOfWeek: [
            "日",
            "月",
            "火",
            "水",
            "木",
            "金",
            "土"
        ],
        monthNames: [
            "1",
            "2",
            "3",
            "4",
            "5",
            "6",
            "7",
            "8",
            "9",
            "10",
            "11",
            "12",
        ],
        firstDay: 1
    }

  $('.post-clickable').click ->
    $.getScript $(this).data('url')
    return

  $('#query_date').on 'change', ->
    url = $(this).data('url') + '?q=' + $(this).val() + '&team_id=' + window.teamId
    $.getScript url
    return

  scrollPosts()

  return