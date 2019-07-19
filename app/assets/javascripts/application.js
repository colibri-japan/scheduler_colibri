// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require rails-ujs
//= require jquery
//= require turbolinks
//= require popper
//= require bootstrap
//= require bootstrap4-toggle.min
//= require moment.min
//= require popper
//= require fullcalendar
//= require locale-all
//= require scheduler
//= require daterangepicker
//= require selectize
//= require Chart.bundle
//= require chartkick
//= require_tree .

$.ajaxSetup({
  headers: {
    'X-CSRF-Token': $('meta[name="csrf-token"]').attr('content')
  }
});

var myDefaultWhiteList = $.fn.tooltip.Constructor.Default.whiteList;

myDefaultWhiteList.a = ['data-remote', 'href']

let setDefaultEnd = (start, end) => {
  if (end - start <= 900000) {
    end = moment(start).add(30, 'minutes') ;
  }
  return [start, end]
}

let setWishedSlotTime = (start, end, view) => {
  $('#wished_slot_anchor_1i').val(moment(start).format('YYYY'));
  $('#wished_slot_anchor_2i').val(moment(start).format('M'));
  $('#wished_slot_anchor_3i').val(moment(start).format('D'));
  $('#wished_slot_starts_at_4i').val(moment(start).format('YYYY'));
  $('#wished_slot_starts_at_2i').val(moment(start).format('M'));
  $('#wished_slot_starts_at_3i').val(moment(start).format('D'));
  $('#wished_slot_starts_at_4i').val(moment(start).format('HH'));
  $('#wished_slot_starts_at_5i').val(moment(start).format('mm'));
  $('#wished_slot_ends_at_1i').val(moment(end).format('YYYY'));
  $('#wished_slot_ends_at_2i').val(moment(end).format('M'));
  $('#wished_slot_ends_at_3i').val(moment(end).format('D'));
  $('#wished_slot_ends_at_4i').val(moment(end).format('HH'));
  $('#wished_slot_ends_at_5i').val(moment(end).format('mm'));
  $('#wished_slot_end_day_1i').val(moment(end).format('YYYY'));
  $('#wished_slot_end_day_2i').val(moment(end).format('M'));
  $('#wished_slot_end_day_3i').val(moment(end).format('D'));
  if (window.nurseId) {
    $("#wished_slot_nurse_id").val(window.nurseId);
  }
}

let setPrivateEventTime = (start, end, view) => {
  $('#private_event_starts_at_1i').val(moment(start).format('Y'));
  $('#private_event_starts_at_2i').val(moment(start).format('M'));
  $('#private_event_starts_at_3i').val(moment(start).format('D'));
  $('#private_event_starts_at_4i').val(moment(start).format('HH'));
  $('#private_event_starts_at_5i').val(moment(start).format('mm'));
  if (['month', 'timelineWeek'].includes(view.name) && moment(start).add(1, 'day').format('Y-M-D') == moment(end).format('Y-M-D')) {
    $('#private_event_ends_at_1i').val(moment(start).format('Y'));
    $('#private_event_ends_at_2i').val(moment(start).format('M'));
    $('#private_event_ends_at_3i').val(moment(start).format('D'));
    $('#private_event_ends_at_4i').val('23');
    $('#private_event_ends_at_5i').val('00');
  } else {
    $('#private_event_ends_at_1i').val(moment(end).format('Y'));
    $('#private_event_ends_at_2i').val(moment(end).format('M'));
    $('#private_event_ends_at_3i').val(moment(end).format('D'));
    $('#private_event_ends_at_4i').val(moment(end).format('HH'));
    $('#private_event_ends_at_5i').val(moment(end).format('mm'));
  }
  if (window.nurseId) {
    $("#private_event_nurse_id").val(window.nurseId);
  }
  if (window.patientId) {
    $("#private_event_patient_id").val(window.patientId);
  }

}

let setAppointmentTime = (start, end, view) => {
  $('#appointment_starts_at_1i').val(moment(start).format('YYYY'));
  $('#appointment_starts_at_2i').val(moment(start).format('M'));
  $('#appointment_starts_at_3i').val(moment(start).format('D'));
  $('#appointment_starts_at_4i').val(moment(start).format('HH'));
  $('#appointment_starts_at_5i').val(moment(start).format('mm'));
  if (['month', 'timelineWeek'].includes(view.name) && moment(start).add(1, 'day').format('Y-M-D') == moment(end).format('Y-M-D')) {
    $('#appointment_ends_at_1i').val(moment(start).format('YYYY'));
    $('#appointment_ends_at_2i').val(moment(start).format('M'));
    $('#appointment_ends_at_3i').val(moment(start).format('D'));
    $('#appointment_ends_at_4i').val('23');
    $('#appointment_ends_at_5i').val('00');
  } else {
    $('#appointment_ends_at_1i').val(moment(end).format('YYYY'));
    $('#appointment_ends_at_2i').val(moment(end).format('M'));
    $('#appointment_ends_at_3i').val(moment(end).format('D'));
    $('#appointment_ends_at_4i').val(moment(end).format('HH'));
    $('#appointment_ends_at_5i').val(moment(end).format('mm'));
  }
  if (window.nurseId) {
    $("#appointment_nurse_id").val(window.nurseId);
  }
  if (window.patientId) {
    $("#appointment_patient_id").val(window.patientId);
  }
}

let setRecurringAppointmentTime = (start, end, resource, view) => {
  $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
  $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
  $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
  $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
  $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
  if (['month', 'timelineWeek'].includes(view.name) && moment(start).add(1, 'day').format('Y-M-D') == moment(end).format('Y-M-D')) {
    $('#recurring_appointment_end_day_1i').val(moment(start).format('YYYY'));
    $('#recurring_appointment_end_day_2i').val(moment(start).format('M'));
    $('#recurring_appointment_end_day_3i').val(moment(start).format('D'));
    $('#recurring_appointment_ends_at_4i').val('23');
    $('#recurring_appointment_ends_at_5i').val('00');
  } else {
    $('#recurring_appointment_end_day_1i').val(moment(end).format('YYYY'));
    $('#recurring_appointment_end_day_2i').val(moment(end).format('M'));
    $('#recurring_appointment_end_day_3i').val(moment(end).format('D'));
    $('#recurring_appointment_ends_at_4i').val(moment(end).format('HH'));
    $('#recurring_appointment_ends_at_5i').val(moment(end).format('mm'));
  }
  if (window.nurseId) {
    $('#recurring_appointment_nurse_id').val(window.nurseId);
  }
  if (window.patientId) {
    $('#recurring_appointment_patient_id').val(window.patientId);
  }
  if (resource) {
    if (window.resourceType === 'nurse') {
      $("#recurring_appointment_nurse_id").val(resource.id);
    } else if (window.resourceType === 'patient') {
      $('#recurring_appointment_patient_id').val(resource.id)
    }
  }
}

var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  
  $('.nurse_calendar').each(function(){
    var nurse_calendar = $(this);
    nurse_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      locale: 'ja',
      views: {
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
        }
      },
      firstDay: window.firstDay,
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaDay,agendaWeek,month'
      },
      selectable: true,
      selectHelper: false,
      editable: true,
      eventColor: '#7AD5DE',
      eventSources: [{url: window.appointmentsURL, cache: true},{url: window.privateEventsUrl, cache: true}],

      select: function(start, end, jsEvent, view, resource) {
        let start_and_end = setDefaultEnd(start, end);
        let start_time = start_and_end[0];
        let end_time = start_and_end[1];
        $.getScript(window.selectActionUrl, function() {
          setAppointmentTime(start_time, end_time, view);
          setPrivateEventTime(start_time, end_time, view);
          appointmentSelectizeNursePatient();
          privateEventSelectizeNursePatient();
        });

        nurse_calendar.fullCalendar('unselect');
      },

      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },

      eventRender: function(event, element, view){
        if (window.eventDragging) {
          return
        }
        if (event.cancelled) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #FFBFBF, #FFBFBF 5px, #FF8484 5px, #FF8484 10px)' });  
          element.addClass('colibri-cancelled')
        } else if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #C8F6DF, #C8F6DF 5px, #99E6BF 5px, #99E6BF 10px)' });
          element.addClass('colibri-edit-requested')
        }

        let popoverContent;
        if (event.patient && event.patient.address) {
          popoverContent = event.patient.address + '<br/>' + event.description;
        } else {
          popoverContent = event.description;
        }

        let popoverTitle = event.service_type;
        window.popoverFocusAllowed = true;
        setPopover(element, popoverTitle, popoverContent)

        element.find('.fc-title').text(function(i, t){
          if (!event.private_event) {
            return event.patient.name;
          } else {
            let patient_name = event.patient.name ? ': ' + event.patient.name + '様' : ''
            return event.service_type + patient_name;
          }
        });
      },
         
      eventClick: function(event, jsEvent, view) {
        let dateClicked = moment(event.start).format('YYYY-MM-DD');
        $.getScript(event.edit_url + '?date=' + dateClicked, function() {
        });
      },

      eventAfterAllRender: function (view) {
        appointmentComments();
      },


      eventDrop: function (event, delta, revertFunc) {
        $(".popover").remove()
        let minutes = moment.duration(delta).asMinutes();
        let previous_start = moment(event.start).subtract(minutes, "minutes");
        let previous_end = moment(event.end).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]D[日][(]dd[)] ')  + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = event.start.format('M[月]D[日][(]dd[)]') + event.start.format('LT') + ' ~ ' + event.end.format('LT')
        let nurse_name = event.nurse.name;
        let patient_name = event.patient.name

        $('#drag-drop-content').html("<p>ヘルパー： " + nurse_name + '  / 利用者名： ' + patient_name + "</p> <p>" + previousAppointment + " >> </p><p>" + newAppointment + "</p>")
        
        $('#drag-drop-modal').modal({backdrop: 'static'})
        $('.close-drag-drop-modal').click(function(){
          revertFunc()
          $('.modal').modal('hide');
          $('.modal-backdrop').remove();
        })
        $('#drag-drop-save').one('click', function(){
          let ajaxData;
          if (event.private_event) {
            ajaxData = {
              private_event: {
                starts_at: event.start.format(),
                ends_at: event.end.format()
              }
            }
          } else {
            ajaxData = {
              appointment: {
                starts_at: event.start.format(),
                ends_at: event.end.format(),
              }
            }
          }
          handleAppointmentOverlapRevert(revertFunc)
          $.ajax({
              url: event.base_url + '.js?delta=' + delta,
              type: 'PATCH',
              data: ajaxData
          })
        })
      },

      dayRender: function(date, cell) {
        colorizeHolidays(date)
      },

      viewRender : function(view, element) {
        drawHourMarks();
        makeTimeAxisPrintFriendly()
      }



    })
  })
}


var initialize_patient_calendar;
initialize_patient_calendar = function(){
  
  $('.patient_calendar').each(function(){
    var patient_calendar = $(this);
    patient_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      minTime: window.minTime,
      maxTime: window.maxTime, 
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      nowIndicator: true,
      locale: 'ja',
      firstDay: window.firstDay,
      eventColor: '#7AD5DE',
      views: {
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        month: {
          displayEventEnd: true,
        }
      },
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaDay,agendaWeek,month'
      },
      selectable: true,
      selectHelper: false,
      editable: true,
      eventSources: [{url: window.appointmentsURL, cache: true}, {url: window.privateEventsUrl, cache: true}],


      select: function (start, end, jsEvent, view, resource) {
        let start_and_end = setDefaultEnd(start, end);
        let start_time = start_and_end[0];
        let end_time = start_and_end[1];
        $.getScript(window.selectActionUrl, function() {
          setAppointmentTime(start_time, end_time, view);     	         
          setPrivateEventTime(start_time, end_time, view);
          appointmentSelectizeNursePatient();
          privateEventSelectizeNursePatient();
        });
        patient_calendar.fullCalendar('unselect');
      },

      eventRender: function (event, element, view){
        if (window.eventDragging) {
          return
        }
        if (event.cancelled) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #FFBFBF, #FFBFBF 5px, #FF8484 5px, #FF8484 10px)' });
        } else if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #C8F6DF, #C8F6DF 5px, #99E6BF 5px, #99E6BF 10px)' });
        }

        window.popoverFocusAllowed = true;
        let popoverTitle = event.service_type;
        let popoverContent;
        if (event.patient && event.patient.address) {
          popoverContent = event.patient.address + '<br/>' + event.description;
        } else {
          popoverContent = event.description;
        }
        setPopover(element, popoverTitle, popoverContent)

        element.find('.fc-title').text(function(i, t){
          if (!event.private_event) {
            return event.nurse.name;
          } else {
            let nurse_name = event.nurse.name ? ': ' + event.nurse.name : ''
            return event.service_type + nurse_name;
          }
        });
      },

      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },
      
      eventDrop: function (event, delta, revertFunc) {
        $(".popover").remove()
        let minutes = moment.duration(delta).asMinutes();
        let previous_start = moment(event.start).subtract(minutes, "minutes");
        let previous_end = moment(event.end).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]D[日][(]dd[)]') + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = event.start.format('M[月]D[日][(]dd[)]') + event.start.format('LT') + ' ~ ' + event.end.format('LT')
        let nurse_name = event.nurse.name || '';
        let patient_name = event.patient.name || '';

        $('#drag-drop-content').html("<p>ヘルパー： " + nurse_name + '  / 利用者名： ' + patient_name +  "</p> <p>" + previousAppointment + " >> </p><p>"+ newAppointment +  "</p>")
    
        $('#drag-drop-modal').modal({ backdrop: 'static' })
        $('.close-drag-drop-modal').click(function () {
          revertFunc()
          $('.modal').modal('hide');
          $('.modal-backdrop').remove();
        })
        $('#drag-drop-save').one('click', function () {
          let ajaxData;
          if (event.private_event) {
            ajaxData = {
              private_event: {
                starts_at: event.start.format(),
                ends_at: event.end.format()
              }
            }
          } else {
            ajaxData = {
              appointment: {
                starts_at: event.start.format(),
                ends_at: event.end.format(),
              }
            }
          }
          handleAppointmentOverlapRevert(revertFunc)
          $.ajax({
            url: event.base_url + '.js?delta=' + delta,
            type: 'PATCH',
            data: ajaxData
          })
        })
      },
         
      eventClick: function(event, jsEvent, view) {
        let dateClicked = moment(event.start).format('YYYY-MM-DD');
        $.getScript(event.edit_url + '?date=' + dateClicked, function() {
        });
      },

      eventAfterAllRender: function (view) {
        appointmentComments();
      },

      dayRender: function (date, cell) {
        colorizeHolidays(date)
      },


      viewRender: function (view, element) {
        drawHourMarks();
        makeTimeAxisPrintFriendly()
      }

    });
  })
};

var initialize_master_calendar;
initialize_master_calendar = function() {
  $('.master_calendar').each(function(){
    var master_calendar = $(this);
    master_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      views: {
        timelineWeek: {
          slotDuration: { days: 1 },
          buttonText: '週',
          slotLabelFormat: 'D日[(]ddd[)]',
          resourceAreaWidth: '10%',
          displayEventEnd: true,
          resourceColumns: [{
            labelText: window.resourceLabel,
            field: 'title'
          }]
        },
        agendaDayWithoutResources: {
          type: 'agendaDay',
          resources: false,
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        day: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
        },
        agendaWeek: {
          resources: false
        },
        month: {
          displayEventEnd: true,
          resources: false
        }
      },
      lazyFetching: false,
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      timeFormat: 'H:mm',
      firstDay: window.firstDay,
      nowIndicator: true,
      locale: 'ja',
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: window.fullcalendarViewOptions
      },
      selectable: (window.userIsAdmin == 'true') ? true : false,
      selectHelper: false,
      editable: true,
      eventSources: [window.eventSource1, window.eventSource2],
      refetchResourcesOnNavigate: true,

      resources: function(callback, start, end, timezone){
        let concatChar = window.resourceUrl.includes('?') ? '&' : '?'
        let ajaxUrl = window.resourceUrl + concatChar + 'resource_type=recurring_appointments&planning_id=' + window.planningId + '&start=' + moment(start).format('YYYY-MM-DD') + '&end=' + moment(end).format('YYYY-MM-DD') + '&nurse_ids=' + $('#nurse_resource_filter').val()
        $.ajax({
          url: ajaxUrl,
          type: 'GET',
          error: function () {
            alert('従業員の検索中にエラーが発生しました')
          },
          success: function (response) {
            callback(response)
          }
        })
      },

      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },


      eventRender: function eventRender(event, element, view) {
        if (window.eventDragging) {
          return
        }

        window.popoverFocusAllowed = true;
        let popoverTitle = event.service_type;
        let popoverContent;
        if (event.patient && event.patient.address) {
          popoverContent = event.patient.address + '<br/>' + event.description;
        } else {
          popoverContent = event.description;
        }
        setPopover(element, popoverTitle, popoverContent)

        element.find('.fc-title').text(function(){
          if (window.resourceType == 'patient' && event.eventType !== 'wished_slot') {
            return event.nurse.name || '';
          } else if (window.resourceType == 'nurse' && event.eventType !== 'wished_slot') {
            return event.patient.name || '';
          }
        })
      },

      eventDrop: function (event, delta, revertFunc, jsEvent, ui, view) {
        $('.popover').remove();
        let frequency = humanizeFrequency(event.frequency);
        let newAppointmentDetails = event.start.format('[(]dd[)]') + frequency + ' ' + event.start.format('LT') + ' ~ ' + event.end.format('LT')
        let minutes = moment.duration(delta).asMinutes();
        let previous_start = moment(event.start).subtract(minutes, "minutes");
        let start_time = moment(view.start).format('YYYY-MM-DD')
        let end_time = moment(view.end).format('YYYY-MM-DD')
        let newNurseId;
        let newPatientId;
        let newPatientName;
        let newNurseName;
        let resourceName = $("[data-resource-id='" + event.resourceId + "']").html();
        let patientResource;
        if (window.resourceType == 'patient') {
          patientResource = "&patient_resource=true"
        } else {
          patientResource = ""
        }
        if (window.generalPlanning) {
          if (window.resourceType == 'nurse') {
            newNurseId = event.resourceId;
            newPatientId = event.patient_id;
            newNurseName = resourceName;
            newPatientName = event.patient.name
          } else if (window.resourceType == 'patient') {
            newPatientId = event.resourceId;
            newNurseId = event.nurse_id;
            newPatientName = resourceName;
            newNurseName = event.nurse.name
          }
        } else {
          newNurseId = event.nurse_id;
          newPatientId = event.patient_id;
          newNurseName = event.nurse.name;
          newPatientName = event.patient.name
        }
        $('#drag-drop-master-content').html("<p>従業員： " + newNurseName + '  / 利用者名： ' + newPatientName + "</p><p>"  + newAppointmentDetails + "</p>")


        $('#drag-drop-master').modal({ backdrop: 'static' })
        $('.close-drag-drop-modal').click(function(){
          revertFunc()
          $('.modal').modal('hide');
          $('.modal-backdrop').remove();
        })
        $('#master-drag-copy').one('click', function(){
          $.ajax({
            url: "/plannings/" + window.planningId + "/recurring_appointments.js?start=" + start_time + "&end=" + end_time + patientResource,
            type: 'POST',
            data: {
              recurring_appointment: {
                nurse_id: newNurseId,
                patient_id: newPatientId,
                frequency: event.frequency,
                title: event.service_type,
                color: event.color,
                anchor: event.start.format('YYYY-MM-DD'),
                end_day: event.end.format('YYYY-MM-DD'),
                starts_at: event.start.format(),
                ends_at: event.end.format()
              },
            },
            success: function (data) {
              $(".popover").remove();
            }
          });
          revertFunc();
        })
        $('#master-drag-move').one('click', function(){
          $.ajax({
            url: event.base_url + ".js?start=" + start_time + "&end=" + end_time + patientResource,
            type: 'PATCH',
            data: {
              recurring_appointment: {
                starts_at: event.start.format(),
                ends_at: event.end.format(),
                anchor: event.start.format('YYYY-MM-DD'),
                end_day: event.end.format('YYYY-MM-DD'),
                nurse_id: newNurseId,
                patient_id: newPatientId,
                editing_occurrences_after: previous_start.format('YYYY-MM-DD'),
                synchronize_appointments: 1
              }
            }
          })
          $(".popover").remove();
        })
      },


      select: function(start, end, jsEvent, view, resource) {
        let view_start = moment(view.start).format('YYYY-MM-DD');
        let view_end = moment(view.end).format('YYYY-MM-DD');
        let start_and_end = setDefaultEnd(start, end);
        let start_time = start_and_end[0];
        let end_time = start_and_end[1];
        $.getScript(window.selectActionUrl, function() {
          setWishedSlotTime(start_time, end_time, view);
          setRecurringAppointmentTime(start_time, end_time, resource, view);
          setHiddenStartAndEndFields(view_start, view_end);
          recurringAppointmentSelectizeNursePatient();
          wishedSlotsSelectize()
        });

        master_calendar.fullCalendar('unselect');
      },
         
      eventClick: function (event, jsEvent, view) {
        // Get the table
        let view_start = moment(view.start).format('YYYY-MM-DD');
        let view_end = moment(view.end).format('YYYY-MM-DD');
        let dateClicked = moment(event.start).format('YYYY-MM-DD');
        let patientResource;
        if (window.resourceType === 'patient') {
          patientResource = '&patient_resource=true'
        }
        if (window.userIsAdmin == 'true') {
          $.getScript(event.edit_url + '?date=' + dateClicked + patientResource, function(){
            terminateRecurringAppointment(dateClicked, view_start, view_end)
            setHiddenStartAndEndFields(view_start, view_end);
          })
        }
        return false;
      },
      
      eventAfterAllRender: function() {
        appointmentComments();
      },

      dayRender: function (date) {
        colorizeHolidays(date)
      },


      viewRender: function (view) {
        drawHourMarks();
        makeTimeAxisPrintFriendly();
        if (view.name == 'timelineWeek') {
          fixHeightForTimelineWeekView()
        }
      }
    })
    
  });
};

var initialize_calendar;
initialize_calendar = function() {
  let myResource;
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: window.defaultView,
      views: {
        timelineWeek: {
          slotDuration: {days: 1},
          buttonText: '週',
          slotLabelFormat: 'D日[(]ddd[)]',
          resourceAreaWidth: '10%',
          displayEventEnd: true,
          resourceColumns: [{
            labelText: window.resourceLabel,
            field: 'title'
          }]
        },
        agendaDay: {
          titleFormat: 'YYYY年M月D日 [(]ddd[)]',
          slotDuration: '00:15:00'
        }
      },
      slotLabelFormat: 'H:mm',
      timeFormat: 'H:mm',
      nowIndicator: true,
      firstDay: window.firstDay,
      locale: 'ja',
      minTime: window.minTime,
      maxTime: window.maxTime, 
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaDay,timelineWeek'
      },
      selectable: true,
      selectHelper: false,
      editable: true,
      eventLimit: true,
      eventColor: '#7AD5DE',
      refetchResourcesOnNavigate: true,

      resources: function(callback, start, end, timezone){
        let ajaxUrl = window.resourceUrl + '?include_undefined=true&resource_type=appointments&planning_id=' + window.planningId + '&start=' + moment(start).format('YYYY-MM-DD') + '&end=' + moment(end).format('YYYY-MM-DD') + '&nurse_ids=' + $('#nurse_resource_filter').val()
        $.ajax({
          url: ajaxUrl,
          type: 'GET',
          error: function(){
            alert('従業員の検索中にエラーが発生しました')
          },
          success: function(response) {
            callback(response)
          }
        })
      }, 

      eventSources: [ {url: window.appointmentsURL, cache: true}, {url: window.privateEventsUrl, cache: true}],

      eventDragStart: function (event, jsEvent, ui, view) {
        window.eventDragging = true;
        myResource = $('.calendar').fullCalendar('getResourceById', event.resourceId);
      },

      eventDragStop: function (event, jsEvent, ui, view) {
        window.eventDragging = false;
      },

      eventRender: function eventRender(event, element, view) {
        if (window.eventDragging) {
          return
        }
        if (event.cancelled) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #FFBFBF, #FFBFBF 5px, #FF8484 5px, #FF8484 10px)' });
        } else if (event.edit_requested) {
          element.css({ 'background-image': 'repeating-linear-gradient(45deg, #C8F6DF, #C8F6DF 5px, #99E6BF 5px, #99E6BF 10px)' });
        }
        
        let patient_name = event.patient.name ? event.patient.name + '様' : ''
        let nurse_name = event.nurse.name ? event.nurse.name : ''
        let patient_address = event.patient.address || ''

        window.popoverFocusAllowed = true;
        let popoverTitle = event.service_type;
        let popoverContent;
        if (event.patient && patient_address) {
          popoverContent = patient_address + '<br/>' + event.description;
        } else {
          popoverContent = event.description;
        }
        setPopover(element, popoverTitle, popoverContent)

        element.find('.fc-title').text(function (i, t) {
          if (window.resourceType == 'nurse') {
            if (!event.private_event) {
              return patient_name;
            } else {
              return event.service_type + ': ' + patient_name;
            }
          } else {
            if (!event.private_event) {
              return nurse_name;
            } else {
              return event.service_type + ': ' + nurse_name;
            }
          }
        })

        if ($('#nurse_resource_filter').val()) {
          let nurseId = event.nurse_id + ''
          return $('#nurse_resource_filter').val().includes(nurseId)
        }
      },




      select: function(start, end, jsEvent, view, resource) {
        let start_and_end = setDefaultEnd(start, end);
        let start_time = start_and_end[0];
        let end_time = start_and_end[1];
        $.getScript(window.selectActionUrl, function() {
          setAppointmentTime(start_time, end_time, view);
          setPrivateEventTime(start_time, end_time, view);
          setHiddenStartAndEndFields(start_time, end_time);
          autoFillResource(resource.id, window.resourceLabel);

          appointmentSelectizeNursePatient();
          privateEventSelectizeNursePatient()
        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function (event, delta, revertFunc) {
        $('.popover').remove()
        let minutes = moment.duration(delta).asMinutes();
        let previous_start = moment(event.start).subtract(minutes, "minutes");
        let previous_end = moment(event.end).subtract(minutes, "minutes");
        let previousAppointment = previous_start.format('M[月]D[日][(]dd[)]') + previous_start.format('LT') + ' ~ ' + previous_end.format('LT')
        let newAppointment = event.start.format('M[月]D[日][(]dd[)]') + event.start.format('LT') + ' ~ ' + event.end.format('LT')
        let newResource = $('.calendar').fullCalendar('getResourceById', event.resourceId)
        let resourceChange = '';
        let newPatientId;
        let newNurseId;
        let nurse_name = event.nurse.name || '';
        let patient_name = event.patient.name || '';
        let patientResource;

        if (window.resourceType == 'patient') {
          patientResource = "&patient_resource=true"
        } else {
          patientResource = ""
        }

        if (newResource !== myResource) {
          if (newResource.is_nurse_resource) {
            resourceChange = '新規従業員：' + newResource.title  + '</p><p>' ;
            newNurseId = newResource.id;
            newPatientId = event.patient_id;
          } else {
            resourceChange = '新規利用者：' + newResource.title  + '</p><p>' ;
            newPatientId = newResource.id;
            newNurseId = event.nurse_id;
          }
        } else {
          if (newResource.is_nurse_resource) {
            newNurseId = event.nurse_id;
            newPatientId = event.patient_id
          } else {
            newNurseId = event.nurse_id;
            newPatientId = event.patient_id
          }
        }

        $('#drag-drop-content').html("<p>従業員： " + nurse_name + '  / 利用者名： ' + patient_name + "</p> <p>" + resourceChange + previousAppointment + " >> </p><p>" + newAppointment + "</p>")
        
        $('#drag-drop-modal').modal({ backdrop: 'static' })
        $('.close-drag-drop-modal').click(function () {
          revertFunc()
          $('.modal').modal('hide');
          $('.modal-backdrop').remove();
        })
        $('#drag-drop-save').one('click', function () {
          let ajaxData;
          if (event.private_event) {
            ajaxData = {
              private_event: {
                starts_at: event.start.format(),
                ends_at: event.end.format(),
                patient_id: newPatientId,
                nurse_id: newNurseId,
              }
            }
          } else {
            ajaxData = {
              appointment: {
                starts_at: event.start.format(),
                ends_at: event.end.format(),
                patient_id: newPatientId,
                nurse_id: newNurseId,
              }
            }
          }
          handleAppointmentOverlapRevert(revertFunc)
          $.ajax({
            url: event.base_url + '.js?delta=' + delta + patientResource,
            type: 'PATCH',
            data: ajaxData
          });
        })
      },
         
      eventClick: function(event, jsEvent, view) {
        var caseNumber = Math.floor((Math.abs(jsEvent.offsetX + jsEvent.currentTarget.offsetLeft) / $(this).parent().parent().width() * 100) / (100 / 7));
        var table = $(this).parent().parent().parent().parent().children();
        let dateClicked;
        let patientResource;
        if (window.resourceType === 'patient') {
          patientResource = '&patient_resource=true'
        }
        $(table).each(function () {
          // Get the thead
          if ($(this).is('thead')) {
            var tds = $(this).children().children();
            dateClicked = $(tds[caseNumber]).attr("data-date");
          }
        });
        $.getScript(event.edit_url + '?date=' + dateClicked + patientResource, function() {
        }) 
      },

      viewRender: function(view){
        drawHourMarks();
        makeTimeAxisPrintFriendly();

        if (view.name == 'timelineWeek') {
          fixHeightForTimelineWeekView();
        }
      },

      dayRender: function (date, cell) {
        colorizeHolidays(date)
      }
    });

  });
};


let privateEventSelectizeNursePatient = () => {
  $('#private_event_nurse_id').selectize()
  $('#private_event_patient_id').selectize()
}

let editAfterDate = () => {
  $('#delete-recurring-appointment').hide();
  $('#recurring_appointment_editing_occurrences_after option').each(function () {
    var $this = $(this);
    if ($this.val()) {
      var date = moment($(this).text(), 'YYYY-MM-DD');
      $this.text(date.format('M月D日以降'));
    }
  });
}

let appointmentComments = () => {
  $('#appointment-comments').empty();
  if ($('.master_calendar').length) {
    var calendar = $('.master_calendar');
  } else if ($('.calendar').length) {
    var calendar = $('.calendar');
  } else if ($('.patient_calendar').length) {
    var calendar = $('.patient_calendar');
  } else if ($('.nurse_calendar').length) {
    var calendar = $('.nurse_calendar');
  }

  var clientEvents = calendar.fullCalendar('clientEvents');

  clientEvents.forEach(event => {
    if (event.description && !event.private_event && event.eventType !== 'wished_slot') {
      var stringToAppend =　event.start.format('M月D日　H:mm ~ ') + event.end.format('H:mm') + ' ヘルパー：' + event.nurse.name + ' 利用者：' + event.patient.name + ' ' + event.description;
      $('#appointment-comments').append("<p class='appointment-comment'>" + stringToAppend + "</p>")
    }
  })
}


let toggleFulltimeEmployee = () => {
  $('#full-timer-toggle').bootstrapToggle({
    on: '正社員',
    off: '非正社員',
    size: 'normal',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170
  });
}


let toggleReminderable = () => {
  $('#reminderable-toggle').bootstrapToggle({
    on: 'リマインダー送信',
    off: 'リマインダーなし',
    onstyle: 'success',
    offstyle: 'secondary',
    width: 170
  })
}


let phoneMailRequirement = () => {
  if ($('#reminderable-toggle').is(':checked')) {
    $('#nurse_phone_mail').prop('required', true);
  }
  $('#reminderable-toggle').change(function(){
    if ($(this).is(':checked')) {
      $('#nurse_phone_mail').prop('required', true);
    } else {
      $('#nurse_phone_mail').prop('required', false);
    }
  })
}

let toggleMarkAsReadForAll = () => {
  $('#toggle_share_to_all').bootstrapToggle({
    on: '共有する',
    off: '共有しない',
    size: 'small',
    onstyle: 'info',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let toggleEditRequested = () => {
  let $this  = $('.edit-requested-toggle')
  let requested = $this.data('requested')
  let onText = requested ? '残す' : '追加する';
  let offText = requested ? '出す' : '追加しない';
  $this.bootstrapToggle({
    on: onText,
    off: offText,
    size: 'small',
    onstyle: 'success',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let toggleCancelled = () => {
  let $this  = $('.cancelled-toggle')
  let cancelled = $this.data('cancelled')
  let onText = cancelled ? '残す' : 'キャンセルする';
  let offText = cancelled ? 'キャンセル解除' : 'キャンセルなし';
  $this.bootstrapToggle({
    on: onText,
    off: offText,
    size: 'small',
    onstyle: 'danger',
    offstyle: 'secondary',
    height: 30,
    width: 140
  })
}

let serviceLinkClick = () => {
  $('tr.clickable-row.service-clickable').click(function(){
    $.getScript($(this).data('service-link'), function(){
      $('#service_recalculate_previous_wages').bootstrapToggle({
        on: '反映する',
        off: '反映しない',
        onstyle: 'success',
        offstyle: 'secondary',
        width: 130
      })
    });
  })
}


let sendReminder = () => {
  $('#custom-email-days').selectize({
    plugins: ['remove_button'],
  })

  $('#send-email-reminder').click(function () {
    let customSubject = $('#nurse_custom_email_subject').val();
    let customMessage = $('#nurse_custom_email_message').val();
    let customDays = $('#custom-email-days').val();
    let ajaxUrl = $(this).data('send-reminder-url');

    $.ajax({
      url: ajaxUrl,
      type: 'PATCH',
      data: {
        nurse: {
          custom_email_subject: customSubject,
          custom_email_message: customMessage, 
          custom_email_days: customDays
        }
      },
    })
  })
}


let saveUserRole = () => {
  $('#save-user-role').click(function () {
    console.log('saveUserRole called')
    var user_data;
    user_data = {
      user: {
        role: $('#user_role').val()
      }
    };
    $.ajax({
      url: $(this).data('update-role-url'),
      data: user_data,
      type: 'PATCH'
    });
  });
};


let humanizeFrequency = (frequency) => {
  console.log(frequency)
  switch(frequency) {
    case 0:
      return '毎週';
      break;
    case 1:
      return '第一、三、五週目';
      break;
    case 2:
      return 'その日のみ'
      break;
    case 3:
      return '第二、四週目';
      break;
    case 4:
      return '第一週目';
      break;
    case 5:
      return '最後の週';
      break;
    default:
  }
}



let recurringAppointmenSelectizeTitle = () => {
  $('#recurring_appointment_title').selectize({
    persist: false,
    create: true,
    render: {
      option_create: function(data, escape) {
        return '<div class="create">新規タイプ <strong>' + escape(data.input) + '</strong>&hellip;</div>'
      }
    }
  });
};

let recurringAppointmentSelectizeNursePatient = () => {
  $('#recurring_appointment_nurse_id').selectize();
  $('#recurring_appointment_patient_id').selectize();
}

let appointmentSelectizeNursePatient = () => {
  $('#appointment_nurse_id').selectize();
  $('#appointment_patient_id').selectize();
}

let appointmentSelectize = () => {
  $('#appointment_title').selectize({
    persist: false,
    create: true,
    render: {
      option_create: function (data, escape) {
        return '<div class="create">新規タイプ <strong>' + escape(data.input) + '</strong>&hellip;</div>'
      }
    }
  });
}

let skillsSelectize = () => {
  $('#nurse_skill_list').selectize({
    delimiter: ',',
    persist: false,
    create: true,
    plugins: ['remove_button'],
    render: {
      option_create: function (data, escape) {
        return '<div class="create">新規スキル <strong>' + escape(data.input) + '</strong>&hellip;</div>'
      }
    }
  })
}

let wishedSlotsSelectize = () => {
  $('#wished_slot_nurse_id').selectize()
}

let caveatsSelectize = () => {
  $('#patient_caveat_list').selectize({
    delimiter: ',',
    persist: false,
    create: true,
    plugins: ['remove_button'],
    render: {
      option_create: function (data, escape) {
        return '<div class="create">新規特徴 <strong>' + escape(data.input) + '</strong>&hellip;</div>'
      }
    }
  });
};

let toggleServiceHourBasedWage = () => {
  $('#service_hour_based_wage').bootstrapToggle({
    on: '時給',
    off: '単価',
    onstyle: 'secondary',
    offstyle: 'secondary',
    width: 130
  })
};

let drawHourMarks = () => {
  $('tr*[data-time="09:00:00"]').addClass('thick-calendar-line');
  $('tr*[data-time="12:00:00"]').addClass('thick-calendar-line');
  $('tr*[data-time="15:00:00"]').addClass('thick-calendar-line');
  $('tr*[data-time="18:00:00"]').addClass('thick-calendar-line');
}

let makeTimeAxisPrintFriendly = () => {
  $('tr[data-time] > td > span').addClass('bolder-calendar-time-axis')
}

let teamMembersSelectize = () => {
  $('#team_member_ids').selectize({
    plugins: ['remove_button'],
    persist: false,
  })
}


let batchActionFormButton = () => {
  if (typeof actionButton === 'undefined') {
    let actionButton;
  }
  if (typeof actionUrl === 'undefined') {
    let actionUrl;
  }

  if ($('#new-batch-request-edit-submit').length > 0) {
    actionButton = $('#new-batch-request-edit-submit');
    actionUrl = '/batch_request_edit_confirm/appointments.js'
  } else if ($('#new-batch-cancel-submit').length > 0) {
    actionButton = $('#new-batch-cancel-submit');
    actionUrl = '/batch_cancel_confirm/appointments.js'
  } else if ($('#new-batch-archive-submit').length > 0) {
    actionButton = $('#new-batch-archive-submit');
    actionUrl = '/batch_archive_confirm/appointments.js'
  }

  actionButton.click(function(){
    let cancelledAndEditRequested = evaluateCancelledAndEditRequested();
    let edit_requested;
    let cancelled;

    if (cancelledAndEditRequested == -1) {
      alert('通常.調整中.キャンセルのどちらかを選択してください');
      return
    } else {
      if (!cancelledAndEditRequested) {
        edit_requested = 'undefined';
        cancelled = 'undefined'
      } else {
        edit_requested = cancelledAndEditRequested['edit_requested'];
        cancelled = cancelledAndEditRequested['cancelled']
      }
      appointment_filters = {
        nurse_ids: $('#nurse_id_filter').val(),
        patient_ids: $('#patient_id_filter').val(),
        range_start: $('#date_range').data('daterangepicker').startDate.format('YYYY-MM-DD H:mm'),
        range_end: $('#date_range').data('daterangepicker').endDate.format('YYYY-MM-DD H:mm'),
        edit_requested: edit_requested,
        cancelled: cancelled
      }
      $.ajax({
        url: actionUrl,
        data: appointment_filters,
        type: 'GET'
      })
    }
  });
}

let evaluateCancelledAndEditRequested = () => {

  if ($('#normal_filter').length < 1 && $('#edit_requested_filter').length < 1 && $('#cancelled_filter').length < 1) {
    return false;
  } else {
    let normal_filter = $('#normal_filter').is(':checked');
    let edit_requested_filter = $('#edit_requested_filter').is(':checked');
    let cancelled_filter = $('#cancelled_filter').is(':checked');
  
    if (normal_filter && !edit_requested_filter && !cancelled_filter) {
      return {edit_requested: false, cancelled: false}
    } else if (normal_filter && edit_requested_filter && cancelled_filter) {
      return {edit_requested: 'undefined', cancelled: 'undefined'}
    } else if (normal_filter && edit_requested_filter && !cancelled_filter) {
      return {edit_requested: 'undefined', cancelled: false}
    } else if (normal_filter && !edit_requested_filter && cancelled_filter) {
      return {edit_requested: false, cancelled: 'undefined'}
    } else if (!normal_filter && edit_requested_filter && !cancelled_filter) {
      return {edit_requested: true, cancelled: false}
    } else if (!normal_filter && !edit_requested_filter && cancelled_filter) {
      return {edit_requested: 'undefined', cancelled: true}
    } else if (!normal_filter && edit_requested_filter && cancelled_filter) {
      return {edit_requested: true, cancelled: true}
    } else {
      return -1
    }
  }
}

let initializeBatchActionForm = () => {
  $("#colibri-batch-action-button").popover('hide')
  $('#nurse_id_filter').selectize({
    delimiter: ',',
    plugins: ['remove_button']
  })
  $('#patient_id_filter').selectize({
    delimiter: ',',
    plugins: ['remove_button']
  })
  $('input[name="date_range"]').daterangepicker({
    timePicker: true,
    timePicker24Hour: true,
    timePickerIncrement: 15,
    startDate: moment().set({'hour': 6, 'minute': 0}),
    endDate: moment().set({ 'hour': 21, 'minute': 0}),
    locale: {
      format: 'M月DD日 H:mm',
      applyLabel: "選択する",
      cancelLabel: "取消",
      fromLabel: "",
      toLabel: "から",
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
      ],
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
      ],
      firstDay: 1
    }
  })
  batchActionFormButton()
}

let confirmBatchAction = () => {
  let array = [];
  $('.appointment_row').map(function(){
    array.push($(this).attr('id'))
  })
  appointment_ids = {
    appointment_ids: array
  }

  $('#batch-request-edit-confirm-submit').click(function(){
    $.ajax({
      url: $(this).data('submit-path'),
      data: appointment_ids,
      type: 'PATCH'
    })
  })
  $('#batch-cancel-confirm-submit').click(function () {
    $.ajax({
      url: $(this).data('submit-path'),
      data: appointment_ids,
      type: 'PATCH'
    })
  })
  $('#batch-archive-confirm-submit').click(function () {
    $.ajax({
      url: $(this).data('submit-path'),
      data: appointment_ids,
      type: 'PATCH'
    })
  })

}

let terminateRecurringAppointment = (date, start, end) => {

  $('#recurring-appointment-terminate').text(moment(date).format('M月DD日') + '以降削除');
  let data = {
    t_date: date,
    start: start,
    end: end
  };
  $('#recurring-appointment-terminate').click(function(){
    let message = confirm('サービスの繰り返しが' + moment(date).format('M月DD日') + '以降削除されます' )
    if (message) {
      $.ajax({
        url: $(this).data('terminate-url'),
        data: data,
        type: 'PATCH'
      })
    }
  })
} 

let setHiddenStartAndEndFields = (start, end) => {
  $('#start').val(start)
  $('#end').val(end)
}


let submitReflect = () => {
  $('#submit-reflect').one('click', function(event){
    event.preventDefault();
    let year = $('#master-reflect-year').val()
    let month = $('#master-reflect-month').val()
    let url = $(this).data('submit-url') + '?month=' + month + '&year=' + year;

    $.ajax({
      url: url,
      type: 'PATCH',
    })

    $(this).prop('disabled', true)
  })
}

let postSelectize = () => {
  $('#post_patient_id').selectize({
    plugins: ['remove_button']
  });
}


let clickableTableRowPost = () => {
  $('tr.post-clickable-row').click(function() {
    $.getScript($(this).data('url'));
  });
};

let clickablePost = () => {
  $('.post-clickable').click(function(){
    $.getScript($(this).data('url'))
  })
}

let patientDatePicker = () => {
  let datepickerlocale = {
    format: 'YYYY-MM-DD',
    daysOfWeek: [
      "日",
      "月",
      "火",
      "水",
      "木",
      "金",
      "土",
    ],
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
    ],
    firstDay: 1
  }
  $('#patient_date_of_contract').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      showDropDowns: true,
      locale: datepickerlocale
    })
  })
}

let nursePatientSelectize = () => {
  $('#patient_nurse_id').selectize()
}

let downloadTeamsReport = () => {
  $('#teams-report-download').click(function(){
    let range_start = $('#report_range').data('daterangepicker').startDate.format('YYYY-MM-DD');
    let range_end = $('#report_range').data('daterangepicker').endDate.format('YYYY-MM-DD');
    window.location.href = $(this).data('url') + '?range_start=' + range_start + '&range_end=' + range_end
  })
}

let scrollPosts = () => {
  if ($("#posts-container").length > 0) {
    $("#posts-container").scrollTop($("#posts-container")[0].scrollHeight)
  }
}

let wishedSlotRank = () => {
  if ($('#wished_slot_rank_2').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-yellow')
    $('#button_rank_2').addClass('btn-colibri-light-green')
  } else if ($('#wished_slot_rank_1').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-green btn-colibri-light-red')
    $('#button_rank_1').addClass('btn-colibri-light-yellow')
  } else if ($('#wished_slot_rank_0').is(':checked')) {
    $('.rank-button').removeClass('btn-colibri-light-yellow btn-colibri-light-green')
    $('#button_rank_0').addClass('btn-colibri-light-red')
  }
}

let wishedSlotChecked = () => {
  if ($('#wished_slot_rank_0').is(':checked')) {
    $('#button_rank_0').addClass('btn-colibri-light-red')
  } else if ($('#wished_slot_rank_1').is(':checked')) {
    $('#button_rank_1').addClass('btn-colibri-light-yellow')
  } else if ($('#wished_slot_rank_2').is(':checked')) {
    $('#button_rank_2').addClass('btn-colibri-light-green')
  }
}

let wishedSlotRadioLayout = () => {
  $('#button_rank_2').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-yellow btn-colibri-light-red");
    $(this).addClass("btn-colibri-light-green")
  })
  $('#button_rank_1').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-green btn-colibri-light-red");
    $(this).addClass("btn-colibri-light-yellow")
  })
  $('#button_rank_0').click(function(){
    $('.rank-button').removeClass("btn-colibri-light-green btn-colibri-light-yellow");
    $(this).addClass("btn-colibri-light-red")
  })
}

let toggleCalendarEventModel = () => {
  $('#calendar-event-appointment-button').click(function () {
    $(this).addClass('btn-colibri-light-blue');
    $('#calendar-event-private-event-button').removeClass('btn-colibri-light-red');
    $('#private-event-form-container').hide();
    $('#appointment-form-container').show();
  });
  $('#calendar-event-private-event-button').click(function () {
    $(this).addClass('btn-colibri-light-red');
    $('#calendar-event-appointment-button').removeClass('btn-colibri-light-blue');
    $('#private-event-form-container').show();
    $('#appointment-form-container').hide();
  });
}

let autoFillResource = (resourceId, resourceLabel) => {
  if (resourceLabel == "利用者") {
    $('#appointment_patient_id').val(resourceId);
    $('#private_event_patient_id').val(resourceId);
  } else if (resourceLabel == "従業員") {
    $('#appointment_nurse_id').val(resourceId);
    $('#private_event_nurse_id').val(resourceId);
  }
}

let selectSecondAppointmentCopyOption = () => {
  $('#second-option-selected-button').click(function(){
    $('#option2').show();
    $(this).hide();
    $('#third-option-selected-button').show()
  })
  $('#remove-second-option-button').click(function(){
    $('#option2').hide();
    if ($('#third-option-selected-button').is(':visible')) {
      $('#third-option-selected-button').hide()
    }
    $('#second-option-selected-button').show();
    $('#second_option_selected').prop('checked', false)
  })
  $('#third-option-selected-button').click(function(){
    $('#option3').show();
    $(this).hide();
  })
  $('#remove-third-option-button').click(function(){
    $('#option3').hide();
    $('#third-option-selected-button').show()
    if ($('#second-option-selected-button').is(':visible')) {
      $('#third-option-selected-button').hide();
    }
    $('#third_option_selected').prop('checked', false)
  })
}

let submitAppointmentCopyOption = () => {
  $('#create-appointments-trigger').one('click', function(event){
    event.preventDefault();
    $(this).prop('disabled', true);
    let ajaxData;
    ajaxData = {
      option1: {
        year: $('#reflect-year-1').val(),
        month: $('#reflect-month-1').val()
      },
      option2: {
        year: $('#reflect-year-2').val(),
        month: $('#reflect-month-2').val()
      },
      option3: {
        year: $('#reflect-year-3').val(),
        month: $('#reflect-month-3').val()
      },
      option2IsSelected: $('#second_option_selected').is(':checked'),
      option3IsSelected: $('#third_option_selected').is(':checked')
    }

    console.log(ajaxData)
    $.ajax({
      url: $(this).data('url'),
      type: 'PATCH',
      data: ajaxData
    })
  })
}

let colorizeHolidays = (date) => {
  let holidays = JSON.parse(window.holidays);
  if (holidays.length > 0) {
    let dates = [];
    holidays.forEach(function (holidayObject) {
      dates.push(moment(holidayObject["date"]).format("YYYY-MM-DD"));
    });
    if (dates.indexOf(moment(date).format('YYYY-MM-DD')) > -1) {
      let day_number = $("[data-date = " + moment(date).format('YYYY-MM-DD') + "] > span");
      day_number.css('color', '#ff304f')
    }
  }
}

let postsTimePicker = () => {
  $('#post_published_at').daterangepicker({
    singleDatePicker: true,
    timePicker: true,
    timePicker24Hour: true,
    locale: {
      format: 'YYYY-MM-DD H:mm',
      applyLabel: "選択する",
      cancelLabel: "取消",
      daysOfWeek: [
        "日",
        "月",
        "火",
        "水",
        "木",
        "金",
        "土",
      ],
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
      ],
    },
  })
}

let initializePostsWidget = () => {
  $.getScript('/posts_widget.js')
}

let initializeActivitiesWidget = () => {
  $.getScript('/activities_widget.js')
}

let fixHeightForTimelineWeekView = () => {
  let height = $('.fc-content').height();
  $('td.fc-resource-area.fc-widget-header > div.fc-scroller-clip').height(height);
  $('td.fc-time-area.fc-widget-header > div.fc-scroller-clip').height(height)
}


let initializeCalendar = () => {
  if ($('.calendar').length > 0) {
    initialize_calendar()
  } else if ($('.master_calendar').length > 0) {
    initialize_master_calendar()
  } else if ($('.nurse_calendar').length > 0) {
    initialize_nurse_calendar()
  } else if ($('.patient_calendar').length > 0) {
    initialize_patient_calendar()
  }
}

let filterSalaryLineItemCategory = () => {
  $('#service_type_filter').selectize({
    plugins: ['remove_button']
  })
  $('#refresh-service-types').click(function(){
    $.getScript('/salary_line_items_by_category_report/salary_line_items?y=' + $('#query_year').val() + '&m=' + $('#query_month').val() + '&categories=' + $('#service_type_filter').val())
  })
}

let newPostReminderLayout = () => {
  $('#show-reminder-form').click(function(){
    $(this).hide();
    $('#reminder-form').show();
  });
  $('#delete-reminder').click(function(){
    $('#reminder-form').hide();
    $('#form-reminder-anchor').val("");
    $('#show-reminder-form').show();
  });
  $('#delete-existing-reminder').click(function(){
    $('#reminder-form').hide()
  })

  $('#form-reminder-anchor').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      timePicker24Hour: true,
      timePickerIncrement: 15,
      startDate: moment().add(15, 'days'),
      locale: {
        format: 'YYYY-MM-DD',
        applyLabel: "選択する",
        cancelLabel: "取消",
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
          "12月"
        ],
        firstDay: 1
      }
    })
  })
}

$.fn.overflownY = function () { var e = this[0]; return e.scrollHeight > e.clientHeight; }

let setPopover = (element, popoverTitle, popoverContent) => {
  element.popover({
    html: true,
    title: popoverTitle,
    content: popoverContent,
    trigger: 'manual',
    animation: false,
    placement: 'top',
    container: 'body'
  }).on('mouseenter', function () {
    if (window.popoverFocusAllowed) {
      window.popoverFocusAllowed = false
      var _this = this;
      $(this).popover('show');
      $('.popover').on('mouseleave', function () {
        $(_this).popover('hide');
      });
    }
  }).on('mouseleave', function () {
    var _this = this;
    var condition = $('.popover-body').overflownY();
    if (condition) {
      setTimeout(function () {
        if (!$('.popover:hover').length) {
          $(_this).popover('hide');
        }
      }, 300);
    } else {
      $(_this).popover('hide')
    }
    window.popoverFocusAllowed = true
  });
}

let selectizeServiceToMerge = () => {
  $('#service_to_merge').selectize()
}

let submitMerge = () => {
  $('#merge-submit').click(function(){
    var destination_service_id = $('#service_to_merge').val();
    if (destination_service_id) {
      var condition = confirm('サービスタイプが削除され、既存のサービスと実績が選択されたサービスへ統合されます')
      if (condition) {
        $(this).attr('href', function(i,h){
          return h + (h.indexOf('?') != -1 ? "&destination_service_id=" + destination_service_id : "?destination_service_id=" + destination_service_id)
        })
        return true
      } else {
        return false
      }
    } else {
      alert('統合先のサービスを選択してください')
      return false
    }
  })
}

let salaryRulesFormLayout = () => {
  bootstrapToggleForAllNursesCheckbox();
  bootstrapToggleForAllServicesCheckbox();
  toggleNurseIdList();
  toggleServiceTitleList();
  console.log('is it working')
  $('#target-nurse-ids').selectize({
    plugins: ['remove_button']
  })
  $('#target-service-titles').selectize({
    plugins: ['remove_button']
  })
  serviceDaterangepicker();
}

let serviceDaterangepicker = () => {
  $('#salary_rule_service_date_range_start').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      timePicker: true,
      timePicker24Hour: true,
      timePickerIncrement: 15,
      startDate: moment().subtract(15, 'days'),
      locale: {
        format: 'YYYY-MM-DD H:mm',
        applyLabel: "選択する",
        cancelLabel: "取消",
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
          "12月"
        ],
        firstDay: 1
      }
    })
  })
  $('#salary_rule_service_date_range_end').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      timePicker: true,
      timePicker24Hour: true,
      timePickerIncrement: 15,
      startDate: moment(),
      locale: {
        format: 'YYYY-MM-DD H:mm',
        applyLabel: "選択する",
        cancelLabel: "取消",
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
          "12月"
        ],
        firstDay: 1
      }
    })
  })
}


let bootstrapToggleForAllNursesCheckbox = () => {
  $('#all_nurses_selected_checkbox').bootstrapToggle({
    onstyle: 'info',
    offstyle: 'secondary',
    on: '全従業員対象',
    off: '従業員選択',
    size: 'small',
    width: 170
  })
}

let bootstrapToggleForAllServicesCheckbox = () => {
  $('#all_services_selected_checkbox').bootstrapToggle({
    onstyle: 'info',
    offstyle: 'secondary',
    on: '全サービスタイプ',
    off: 'サービスタイプ選択',
    size: 'small',
    width: 170
  })
}

let toggleNurseIdList = () => {
  $('#all_nurses_selected_checkbox').on('change', function(){
    $selectize = $('#target-nurse-ids').selectize()
    selectize = $selectize[0].selectize 
    toggleNurseIdForm()
  })
}

let toggleNurseIdForm = () => {
  if ($('#all_nurses_selected_checkbox').is(':checked')) {
    $('#form_nurse_id_list_group').hide()
    $('#target_nurse_by_filter_group').hide()
    $('#target-nurse-ids').val('')
    $('#nurse_target_filter').val('')
    selectize.clear(true)
  } else {
    $('#target_nurse_by_filter_group').show()
    $('#form_nurse_id_list_group').show()
  }
}

let applyNurseFilterToSalaryService = () => {
  $('#nurse_target_filter').on('change', function(){
    $selectize = $('#target-nurse-ids').selectize()
    selectize = $selectize[0].selectize 
    if (["0", "1", "2"].includes($(this).val())) {
      $('#target-nurse-ids').val('')
      $('#form_nurse_id_list_group').hide()
      selectize.clear(true)
    } else {
      $('#form_nurse_id_list_group').show()
    }
  })
}

let toggleServiceTitleList = () => {
  $('#all_services_selected_checkbox').on('change', function(){
    if ($('#all_services_selected_checkbox').is(':checked')) {
      $('#form_service_title_list_group').hide()
      $('#target-service-titles').val('')
    } else {
      $('#form_service_title_list_group').show()
    }
  })
}

let editSalaryRuleOnClick = () => {
  $('tr.salary_rule').click(function(){
    $.getScript($(this).data('url'))
  })
}

let confirmNoPatientOnSubmit = () => {
  $('#post_form').submit(function(){
    if (!$('#post_patient_id').val()) {
      confirmNoPatient = confirm('利用者タグなしでセーブされます')
      if (confirmNoPatient) {
        return true
      } else {
        return false
      }
    }
  })
}

let validateKatakana = () => {
  $('#patient_form').submit(function(){
    kana_validation = /^[0-9１-９ 　^[ァ-ヶー]*$/.test($('#patient_kana').val())
    if (kana_validation) {
      return true
    } else {
      alert('フリガナはカタカナで入力してください')
      return false 
    }
  })
}

let selectizeInsurancePolicy = () => {
  $('#patient-insurance-policy').selectize({
    plugins: ['remove_button']
  })
}

let addSecondServiceCategory = () => {
  $('#add-second-service-type').click(function(){
    $('#second-service-type').show()
    $(this).hide()
  })
  $('#drop-second-service-category').click(function(){
    $('#service_category_ratio').val('')
    $('#service_category_2').val('')
    $('#second-service-type').hide()
    $('#add-second-service-type').show()
  })
}

let newBonusForm = () => {
  validateBonusForm()
  $('#bonus-provided-service-button').click(function () {
    $('.toggle-model-button').removeClass('btn-colibri-light-blue');
    $(this).addClass('btn-colibri-light-blue');
    $('#salary-rule-form-container').hide();
    $('#provided-service-form-container').show();
  });
  $('#bonus-salary-rule-button').click(function () {
    $('.toggle-model-button').removeClass('btn-colibri-light-blue');
    $(this).addClass('btn-colibri-light-blue');
    $('#salary-rule-form-container').show();
    $('#provided-service-form-container').hide();
  });
}

let validateBonusForm = () => {
  $('#new_salary_rule').submit(function () {
    let condition;
    let range_is_absent = $('#salary_rule_service_date_range_start').val() == "" && $('#salary_rule_service_date_range_end').val() == "";
    let both_range_present = $('#salary_rule_service_date_range_start').val() !== "" && $('#salary_rule_service_date_range_end').val() !== "";
    let range_in_correct_order = moment($('#salary_rule_service_date_range_start').val()).isBefore($('#salary_rule_service_date_range_end').val());

    if (range_is_absent) {
      alert('サービス期間を指定してください')
      return false
    } else if (!range_is_absent && !both_range_present) {
      alert('サービス期間の開始と終了を両方指定してください')
      return false
    } else if (!range_is_absent && both_range_present && !range_in_correct_order) {
      alert('サービス期間の終了を開始より過去の日に指定してください')
      return false
    } else if (!range_is_absent && both_range_present && range_in_correct_order) {
      return true
    }
  })
}

let completionFormLayout = () => {
  $('#completion_details_washing_details').selectize({
    plugins: ['remove_button'],
  })
  $('#completion_report_activities_done_with_the_patient').selectize({
    plugins: ['remove_button'],
  })
  $('#completion_report_cleanup').selectize({
    plugins: ['remove_button'],
  })
}

let toggleRecalculateCredits = () => {
  $('#service_recalculate_previous_credits_and_invoice').bootstrapToggle({
    on: '過去の実績に反映する',
    off: '反映なし',
    onstyle: 'info',
    offstyle: 'secondary',
    width: 220
  })
}

let reloadWhenDismissedInPayable = () => {
  $('.reload-page-when-dismissed-in-payable').click(function(){
    if (window.location.pathname.includes('payable')) {
      Turbolinks.reload()
    } else {
      $('.modal').modal('hide');
      $('.modal-backdrop').remove();
    }
  })
}

let endOfContractDate = () => {
  $('#patient_end_of_contract').focus(function(){
    $(this).daterangepicker({
      singleDatePicker: true,
      startDate: moment(),
      locale: {
        format: 'YYYY-MM-DD',
        applyLabel: "選択する",
        cancelLabel: "取消",
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
          "12月"
        ],
        firstDay: 1
      }
    })
  })
}

let handleAppointmentOverlapRevert = (revertFunc) => {
  $('#nurse-overlap-modal').on('shown.bs.modal', function () {
    $('#nurse-revert-overlap').one('click', function () {
      revertFunc()
    })
  })
}

let patientCaremanagerSelectize = () => {
  $('#patient_care_manager').selectize()
}

let patientWarekiFields = () => {
  $('#patient_kaigo_certification_validity_start_era').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#patient_kaigo_certification_validity_start_year').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#patient_kaigo_certification_validity_start_month').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#patient_kaigo_certification_validity_start_day').change(function(){
    set_kaigo_certification_validity_start()
  })
  $('#patient_kaigo_certification_date_era').change(function(){
    set_kaigo_certification_date()
  })
  $('#patient_kaigo_certification_date_year').change(function(){
    set_kaigo_certification_date()
  })
  $('#patient_kaigo_certification_date_month').change(function(){
    set_kaigo_certification_date()
  })
  $('#patient_kaigo_certification_date_day').change(function(){
    set_kaigo_certification_date()
  })
  $('#patient_kaigo_certification_validity_end_era').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#patient_kaigo_certification_validity_end_year').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#patient_kaigo_certification_validity_end_month').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#patient_kaigo_certification_validity_end_day').change(function(){
    set_kaigo_certification_validity_end()
  })
  $('#patient_birthday_era').change(function(){
    set_birthday()
  })
  $('#patient_birthday_year').change(function(){
    set_birthday()
  })
  $('#patient_birthday_month').change(function(){
    set_birthday()
  })
  $('#patient_birthday_day').change(function(){
    set_birthday()
  })
}

let set_kaigo_certification_validity_end = () => {
  let era = $('#patient_kaigo_certification_validity_end_era').val() || ''
  let year = $('#patient_kaigo_certification_validity_end_year').val() || ''
  let month = $('#patient_kaigo_certification_validity_end_month').val() || ''
  let day = $('#patient_kaigo_certification_validity_end_day').val() || ''
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#patient_kaigo_certification_validity_end').val(wareki_date)
}

let set_kaigo_certification_validity_start = () => {
  let era = $('#patient_kaigo_certification_validity_start_era').val() || ''
  let year = $('#patient_kaigo_certification_validity_start_year').val() || ''
  let month = $('#patient_kaigo_certification_validity_start_month').val() || ''
  let day = $('#patient_kaigo_certification_validity_start_day').val() || ''
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#patient_kaigo_certification_validity_start').val(wareki_date)
}

let set_kaigo_certification_date = () => {
  let era = $('#patient_kaigo_certification_date_era').val() || ''
  let year = $('#patient_kaigo_certification_date_year').val() || ''
  let month = $('#patient_kaigo_certification_date_month').val() || ''
  let day = $('#patient_kaigo_certification_date_day').val() || ''
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#patient_kaigo_certification_date').val(wareki_date)
}

let set_birthday = () => {
  let era = $('#patient_birthday_era').val() || ''
  let year = $('#patient_birthday_year').val() || ''
  let month = $('#patient_birthday_month').val() || ''
  let day = $('#patient_birthday_day').val() || ''
  let wareki_date = era + year + '年' + month + '月' + day + '日'
  $('#patient_birthday').val(wareki_date)
}

let scrollPosition

document.addEventListener('turbolinks:load', function () {
  if (scrollPosition) {
    window.scrollTo.apply(window, scrollPosition)
    scrollPosition = null
  }
}, false)

Turbolinks.reload = () => {
  scrollPosition = [window.scrollX, window.scrollY]
  Turbolinks.visit(window.location)
}

let resourceScroll

document.addEventListener('turbolinks:load', function() {
  menu_presence_condition = $('#resource-container').length > 0
  if (window.resourceScroll && menu_presence_condition) {
    $('#resource-container').scrollTop(window.resourceScroll);
    window.resourceSroll = null
  }
})

let adaptServiceInvoiceFields = () => {
  $('#service_insurance_category_1').change(function(){
    if ($(this).val() === "0") {
      $('#fields_for_kaigo_invoicing').show()
      $('#service_invoiced_amount').val('')
      $('#fields_for_invoicing_without_insurance').hide()
    } else if ($(this).val() === "1") {
      $('#service_official_title').val('')
      $('#service_service_code').val('')
      $('#service_unit_credits').val('')
      $('#fields_for_kaigo_invoicing').hide()
      $('#fields_for_invoicing_without_insurance').show()
    }
  })
}

let patientBirthdayHelper = () => {
  $('.wareki_era').change(function(){
    $(this).next('.wareki_year').focus()
  })
  let valid_years = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31", "32", "33", "34", "35", "36", "37", "38", "39", "40", "41", "42", "43", "44", "45", "46", "47", "48", "49", "50", "51", "52", "53", "54", "55", "56", "57", "58", "59", "60", "61", "62", "63", "64"]
  let valid_months = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12"]
  let valid_days = ["01", "02", "03", "04", "05", "06", "07", "08", "09", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25", "26", "27", "28", "29", "30", "31"]
  $('.wareki_year').on('input', function(){
    if ($(this).val().length > 1) {
      if (valid_years.includes($(this).val())) {
        $(this).next('.wareki_month').focus()
      } else {
        alert('年が間違ってます')
        $(this).val('')
      }
    }
  })
  $('.wareki_month').on('input', function(){
    if ($(this).val().length > 1) {
      if (valid_months.includes($(this).val())) {
        $(this).next('.wareki_day').focus()
      } else {
        alert('月が間違ってます')
        $(this).val('')
      }
    }
  })
  $('.wareki_day').on('input' ,function(){
    if ($(this).val().length > 1) {
      if (valid_days.includes($(this).val())) {
      } else {
        alert('日が間違ってます')
        $(this).val('')
      }
    }
  })
}

let availabilitiesDate = () => {
  $('#availabilities_date').daterangepicker({
    singleDatePicker: true,
    locale: {
      format: 'YYYY-MM-DD',
      daysOfWeek: [
          "日",
          "月",
          "火",
          "水",
          "木",
          "金",
          "土",
      ],
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
      ],
      firstDay: 1
    }
  })
}

$(document).on('turbolinks:load', function(){
  initializeCalendar()

  if ($('#posts-widget-container').length > 0) {
    initializePostsWidget()
  }

  if ($('#activities-widget-container').length > 0) {
    initializeActivitiesWidget()
  }

  $.fn.modal.Constructor.prototype._enforceFocus = function () { };

  $('#account-settings').click(function(){
    $('#account-settings-dropdown').toggle();
  });

  $('li.account-settings-li').click(function(){
    window.location = $(this).data('url');
  });

  window.setTimeout(function() {
      $(".alert").fadeTo(500, 0).slideUp(500, function(){
          $(this).remove(); 
      });
  }, 2500);

  $('.colibri-nav-username').hover(function(){
    $('#account-dropdown-icon').css({'color':'black', 'cursor':'pointer'})
  }, function(){
    $('#account-dropdown-icon').css({'color': 'white'})
  })
}); 

