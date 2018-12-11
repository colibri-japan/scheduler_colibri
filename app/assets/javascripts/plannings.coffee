# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->
  
  $('.resource-title-selectable').click ->
    window.location = $(this).data('url')
    return

  $('tr.clickable-row').click ->
    window.location = $(this).data('link')
    return

  $('.print-option-checkbox').bootstrapToggle
    on: '有',
    off: '無',
    size: 'small',
    onstyle: 'primary',
    offstyle: 'secondary',
    width: 55
  
  $('#nurse-filter-zentai_').chosen
    no_results_text: "ヘルパーが見つかりません"

  $('#patient-filter-zentai_').chosen
    no_results_text: "利用者が見つかりません"

  $('#master-nurse-filter-zentai_').chosen
    no_results_text: "ヘルパーが見つかりません"

  $('#master-patient-filter-zentai_').chosen
    no_results_text: "利用者が見つかりません"

  $('#nurse-filter-zentai_').on 'change', ->
    $('.calendar').fullCalendar('rerenderEvents')
    return

  $('#patient-filter-zentai_').on 'change', ->
    $('.calendar').fullCalendar('rerenderEvents')
    return

  $('#master-nurse-filter-zentai_').on 'change', -> 
    $('.master_calendar').fullCalendar('rerenderEvents')

  $('#master-patient-filter-zentai_').on 'change', ->
    $('.master_calendar').fullCalendar('rerenderEvents')
  
  $('#edit-request-filter').bootstrapToggle
    on: "全サービス",
    off: "調整中リスト",
    offstyle: "success"



  $('#edit-request-filter').parent().on 'change', -> 
    $('.calendar').fullCalendar('rerenderEvents')
    return 

  $('#activity-show-button').click -> 
    $('#planning-activity-module').show()
    $('.calendar').css({'max-width': '75%'})
    $('.nurse_calendar').css({'max-width': '75%'})
    $('.patient_calendar').css({'max-width': '75%'})
    $(this).hide()
    $('#activity-hide-button').show()
    return

  $('#activity-hide-button').click ->
    $(this).hide()
    $('.calendar').css({'max-width': ''})
    $('.nurse_calendar').css({'max-width': ''})
    $('.patient_calendar').css({'max-width': ''})
    $('#activity-show-button').show()
    $('#planning-activity-module').hide()
    return

  $('li.planning-menu-items').click ->
    window.location = $(this).data('url')
    return
  
  $('.master-list-element').click ->
    window.location = $(this).data('url')
    return

  $('.resource-list-element').click ->
    window.location = $(this).data('url')
    return 
  
  $('#toggle-patients-nurses').bootstrapToggle
    on: '利用者',
    off: '従業員',
    onstyle: 'info',
    offstyle: 'info',
    width: 100

  $('#toggle-patients-nurses').on 'change', ->
    $('#patients-resource').toggleClass('hide-resource')
    $('#nurses-resource').toggleClass('hide-resource')
    return
  

  $('#print-button').click ->
    if window.printDates == "false"
      $('.fc-center').addClass('no-print')
      $('.fc-day-header.fc-mon').html('月')
      $('.fc-day-header.fc-tue').html('火')
      $('.fc-day-header.fc-wed').html('水')
      $('.fc-day-header.fc-thu').html('木')
      $('.fc-day-header.fc-fri').html('金')
      $('.fc-day-header.fc-sat').html('土')
      $('.fc-day-header.fc-sun').html('日')
    window.print()
    return

  $('#master-print-button').click ->
    if window.printDates == "false"
      $('.fc-center').addClass('no-print')
      $('.fc-day-header.fc-mon').html('月')
      $('.fc-day-header.fc-tue').html('火')
      $('.fc-day-header.fc-wed').html('水')
      $('.fc-day-header.fc-thu').html('木')
      $('.fc-day-header.fc-fri').html('金')
      $('.fc-day-header.fc-sat').html('土')
      $('.fc-day-header.fc-sun').html('日')
    window.print()
    return

  
  return