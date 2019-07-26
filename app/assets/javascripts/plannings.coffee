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
    if $('#resource-container').length > 0
      window.resourceScroll = $('#resource-container')[0].scrollTop
    else
      window.resourceScroll = null
    Turbolinks.visit($(this).data('url'))
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

  $('#colibri-batch-master-action-button').click ->
    $.getScript($(this).data('url'))
    return
  
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

  $('#toggle-switch-recurring-appointments').click ->
    $(this).hide()
    $('#toggle-switch-wished-slots').show()
    window.selectActionUrl = window.createWishedSlotUrl
    window.eventSource2 = window.wishedSlotsUrl
    calendar = $('.master_calendar')
    calendar.fullCalendar('removeEventSources')
    calendar.fullCalendar('addEventSource', window.eventSource2)
    calendar.fullCalendar('refetchEvents')
    return

  $('#toggle-switch-wished-slots').click -> 
    $(this).hide()
    $('#toggle-switch-recurring-appointments').show()
    window.eventSource1 = window.recurringAppointmentsUrl
    window.eventSource2 = window.wishedSlotsUrl + '&background=true'
    window.selectActionUrl = window.createRecurringAppointmentURL
    calendar = $('.master_calendar')
    calendar.fullCalendar('removeEventSources')
    calendar.fullCalendar('addEventSource', window.eventSource1)
    calendar.fullCalendar('addEventSource', window.eventSource2)
    calendar.fullCalendar('refetchEvents')
    return

  if $('#colibri-salary-rules-index').length > 0
    $.getScript('/salary_rules.js')

  if $('#nurse_resource_filter').length > 0
    $('#nurse_resource_filter').selectize
      plugins: ['remove_button']
    $('#nurse_resource_filter').on 'change', ->
      window.selected_resource_ids = $(this).val()
      $('.calendar').fullCalendar('refetchResources')
      $('.master_calendar').fullCalendar('refetchResources')
      
  $('#availabilities-print').click ->
    $('#availabilities-form').modal()
    availabilitiesDate()
    return 

  $('#service-type-filter').click ->
    $('#service_type_filter_content').toggle()
    return

  if $('#category-subcontainer').length > 0
    $.getScript('/appointments_by_category_report/appointments?y=' + $('#query_year').val() + '&m=' + $('#query_month').val())
    
  $('#confirm-availabilities-print').click -> 
    date = $('#availabilities_date').val()
    text = $('#availabilities_text').val().replace(/\n/g, '<br />')
    if date
      window.open($(this).data('link') + '?date=' + date + '&text=' + text, '_blank')
    else
      alert('期間を選択してください')
    return

  if $('#cm_filter').length > 0
    $('#cm_filter').selectize 
      plugins: ['remove_button']
      placeholder: '検索する...'
    filterCmCorporations()

  if $('#cm_teikyohyo_filter').length > 0
    $('#cm_teikyohyo_filter').selectize 
      plugins: ['remove_button']
      placeholder: '検索する...'
    filterCmTeikyohyo()

  return
