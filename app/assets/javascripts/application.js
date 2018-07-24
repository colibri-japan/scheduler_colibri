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
//= require turbolinks
//= require jquery
//= require moment.min
//= require popper
//= require bootstrap
//= require fullcalendar
//= require locale-all
//= require scheduler
//= require daterangepicker
//= require_tree .

var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  $('.nurse_calendar').each(function(){
    var nurse_calendar = $(this);
    nurse_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      locale: 'ja',
      views: {
        agendaThreeDay: {
          type: 'agenda',
          duration: {days: 3},
          buttonText: '３日'
        }
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      nowIndicator: true,
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: '07:00:00',   
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      eventStartEditable: false,
      eventColor: '#7AD5DE',
      editable: true,
      eventLimit: true,
      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL],


      select: function(start, end) {
        $.getScript(window.createRecurringAppointmentURL, function() {
        	$('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
        	$('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
        	$('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
        	$('#recurring_appointment_start_4i').val(moment(start).format('HH'));
        	$('#recurring_appointment_start_5i').val(moment(start).format('mm'));
        	$('#recurring_appointment_end_4i').val(moment(end).format('HH'));
        	$('#recurring_appointment_end_5i').val(moment(end).format('mm'));
        	$("#recurring_appointment_nurse_id").val(window.nurseId)
        });

        nurse_calendar.fullCalendar('unselect');
      },
         
      eventClick: function(unavailability, jsEvent, view) {
           $.getScript(unavailability.edit_url, function() {});
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
      defaultView: 'agendaWeek',
      minTime: '07:00:00',
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      nowIndicator: true,
      locale: 'ja',
      eventColor: '#7AD5DE',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      editable: true,
      eventLimit: true,
      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL],


      select: function(start, end) {
        $.getScript(window.createRecurringAppointmentURL, function() {
        	$('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          $("#recurring_appointment_patient_id").val(window.patientId)
        });

        nurse_calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format()
             }
           };
           $.ajax({
               url: appointment.base_url + '.js',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
           $.getScript(appointment.edit_url, function() {});
         }



    });
  })
};

var initialize_master_calendar;
initialize_master_calendar = function() {
  $('.master-calendar').each(function(){
    var master_calendar = $(this);
    master_calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      views: {
      	agendaThreeDay: {
      		type: 'agenda',
      		duration: {days: 3},
      		buttonText: '３日'
      	}
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      nowIndicator: true,
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: '07:00:00',
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: (window.userIsAdmin == 'true') ? true : false,
      selectHelper: (window.userIsAdmin == 'true') ? true : false,
      editable: (window.userIsAdmin == 'true') ? true : false,
      eventLimit: true,
      eventColor: '#74d680',


      resources: {
        url: window.corporationNursesURL,
      }, 

      eventSources: [ window.appointmentsURL + '?q=master', window.recurringAppointmentsURL + '?q=master'],


      select: function(start, end, jsEvent, view, resource) {
        $.getScript(window.createRecurringAppointmentURL + '?q=master', function() {
          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          $('#recurring_appointment_nurse_id').val(resource.id)
        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format()
             }
           };
           $.ajax({
               url: appointment.base_url + '.js?q=master',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
            if (window.userIsAdmin == 'true') {
              $.getScript(appointment.edit_url + '?q=master', function() {});
            }
            return false;
         }
    })
  });
};

var initialize_calendar;
initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaWeek',
      views: {
      	agendaThreeDay: {
      		type: 'agenda',
      		duration: {days: 3},
      		buttonText: '３日',
      	},
      },
      slotLabelFormat: 'H:mm',
      slotDuration: '00:15:00',
      nowIndicator: true,
      height: 'auto',
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: '07:00:00',
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'agendaWeek,agendaThreeDay,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      editable: true,
      eventLimit: true,
      eventColor: '#7AD5DE',


      resources: {
        url: window.corporationNursesURL,
      }, 

      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL],

      eventRender: function eventRender(event, element, view) {
        var patientFilterArray = $('#patient-filter-zentai_').val();
        var nurseFilterArray = $('#nurse-filter-zentai_').val();
        if (patientFilterArray === null) {
          patientFilterArray = ['']
        };

        if (nurseFilterArray === null) {
          nurseFilterArray = ['']
        };

        var filterPatient = function(){
          for (var i=0; i < patientFilterArray.length; i++) {
            if (['', event.patientId.toString()].indexOf(patientFilterArray[i]) >= 0) {
              return true
            }
          }
          return false
        }
        var filterNurse = function() {
          for (var i=0; i< nurseFilterArray.length; i++) {
            if (['', event.resourceId].indexOf(nurseFilterArray[i]) >= 0) {
              return true
            }
          }
          return false
        } 

        return filterPatient() && filterNurse() ;
      },



      select: function(start, end, jsEvent, view, resource) {
      	$.getScript(window.createRecurringAppointmentURL, function() {
          $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
          $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
          $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
          $('#recurring_appointment_start_4i').val(moment(start).format('HH'));
          $('#recurring_appointment_start_5i').val(moment(start).format('mm'));
          $('#recurring_appointment_end_4i').val(moment(end).format('HH'));
          $('#recurring_appointment_end_5i').val(moment(end).format('mm'));
          $('#recurring_appointment_nurse_id').val(resource.id)
        });

        calendar.fullCalendar('unselect');
      },

      eventDrop: function(appointment, delta, revertFunc) {
           appointment_data = { 
             appointment: {
               id: appointment.id,
               start: appointment.start.format(),
               end: appointment.end.format()
             }
           };
           $.ajax({
               url: appointment.base_url + '.js',
               type: 'PATCH',
               beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
               data: appointment_data,
           });
         },
         
      eventClick: function(appointment, jsEvent, view) {
           $.getScript(appointment.edit_url, function() {});
         }


    });
  })
};

$(document).on('turbolinks:load', initialize_calendar); 
$(document).on('turbolinks:load', initialize_nurse_calendar); 
$(document).on('turbolinks:load', initialize_patient_calendar); 
$(document).on('turbolinks:load', initialize_master_calendar);

$(document).on('turbolinks:load', function(){
  $("table > tbody > tr[data-link]").not('thead').click(function(){
    if (this.dataset.link != '') {
      window.location = this.dataset.link
    } 
  });

  $('#account-edit').click(function(){
    $('#account-delete-body').hide();
    $('#account-edit-body').show();
    $('.account-menu-item').removeClass('account-menu-selected');
    $(this).addClass('account-menu-selected');
  });

  $('#account-delete').click(function(){
    $('#account-edit-body').hide();
    $('#account-delete-body').show();
    $('.account-menu-item').removeClass('account-menu-selected');
    $(this).addClass('account-menu-selected');
  });

  $('#account-delete-body').hide();

  $('.switch').each(function(){
    $this = $(this);
    if ($this.data('admin') == true ) {
      $this.find('.switch-input').prop("checked", true);
    }

  });

  $('.slider').bind('sendAjax', function(){
    $.ajax({
      url: $(this).data('admin-toggle'),
      type: 'PATCH',
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    })
  })

  $('.slider').click(function(){
    $(this).trigger('sendAjax');

  });

  $('input.edit-hourly-wage').change(function(){
    $.ajax({
      url: $(this).data('service-url') + '.js',
      type: 'PATCH',
      data:  { 'provided_service': { 'hourly_wage': $(this).val() }  },
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))},
    })
  });

  $('input.edit-service-counts').change(function(){
    $.ajax({
      url: $(this).data('service-url') + '.js',
      type: 'PATCH',
      data: {'provided_service': {'service_counts': $(this).val()}},
      beforeSend: function(xhr) {xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))}
    })
  });

  $('#schedule-filter').change(function(){
    window.location = nursePayableUrl + '?p=' + $(this).val();
  });

  $('#activity-filter').change(function(){
    window.location = planningActivitiesUrl + '?n=' + $('#nurse-filter').val() + '&pat=' + $('#patient-filter').val() + '&us=' + $('#user-filter').val();
  })



  $('#schedule-filter option').append('月');

  $('#planning-activity-module').hide();
  $('#activity-hide-button').hide();

  $('#activity-show-button').click(function(){
    $('#planning-activity-module').show();
    $('.calendar').css({'max-width': '75%'});
    $(this).hide();
    $('#activity-hide-button').show();
  });

  $('#activity-hide-button').click(function(){
    $(this).hide();
    $('.calendar').css({'max-width': ''});
    $('#activity-show-button').show();
    $('#planning-activity-module').hide();
  });

  $('#unzoom-button').hide();

  $('#zoom-button').click(function(){
    $(this).hide();
    $('#unzoom-button').show();
    $('#planning-container .fc-view > table').css({'width': '300%'})
  });

  $('#unzoom-button').click(function(){
    $(this).hide();
    $('#zoom-button').show();
    $('#planning-container .fc-view > table').css({'width': ''})
  });

  $('#nurse-filter-zentai_').on('change', function(){
    $('.calendar').fullCalendar('rerenderEvents');
  });  

  $('#patient-filter-zentai_').on('change', function(){
    $('.calendar').fullCalendar('rerenderEvents');
  });




}); 
