# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$(document).on 'turbolinks:load', ->

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


  $('.colibri-clickable-link').click ->
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

  popoverContent = $('#batch-action-menu').html()

  $('#colibri-batch-action-button').popover
    html: true
    title: ''
    content: popoverContent
    trigger: 'click'
    placement: 'top'

  $('#colibri-batch-master-action-button').popover 
    html: true
    title: 'マスター反映'
    content: popoverContent
    trigger: 'click'
    placement: 'top'
  
  $('#teams-report').click ->
    $('.modal').modal('hide')
    $('.modal-backdrop').remove()
    $('#remote-container').html($('#team-report-range'))
    $('#team-report-range').modal('show')
    downloadTeamsReport()
    return

  $('#report_range').daterangepicker
    locale: 
      format: 'M月DD日'
      applyLabel: "選択する"
      cancelLabel: "取消"
      fromLabel: ""
      toLabel: "から"
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
      ]
      monthNames: [
        "1月",
        "2月",
        "3月",
        "4月",
        "5月",
        "6月",
        "7月",
        "8月",
        "9月",
        "10月",
        "11月",
        "12月",
      ]
      firstDay: 1

  $('#toggle-switch-patients').click ->
    $(this).hide()
    $('#toggle-switch-nurses').show()
    $('#patients-resource').hide()
    $('#nurses-resource').show()
    return
  
  $('#toggle-switch-nurses').click ->
    $(this).hide()
    $('#toggle-switch-patients').show()
    $('#patients-resource').show()
    $('#nurses-resource').hide()
    return

  $('#toggle-switch-appointments').click ->
    $(this).hide()
    $('#toggle-switch-unavailabilities').show()
    window.bootstrapToggleUrl = window.createUnavailabilityURL
    return 

  $('#toggle-switch-unavailabilities').click ->
    $(this).hide()
    $('#toggle-switch-appointments').show()
    window.bootstrapToggleUrl = window.createRecurringAppointmentURL
    return 

  return
