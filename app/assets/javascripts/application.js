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
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: '07:00:00',   
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      eventColor: '#7AD5DE',
      editable: true,
      eventLimit: true,
      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL, window.unavailabilitiesURL, window.recurringUnavailabilitiesURL],


      select: function(start, end) {
        $.getScript(window.createUnavailabilityURL, function() {
        	$('#unavailability_start_1i').val(moment(start).format('YYYY'));
        	$('#unavailability_start_2i').val(moment(start).format('M'));
        	$('#unavailability_start_3i').val(moment(start).format('DD'));
        	$('#unavailability_start_4i').val(moment(start).format('HH'));
        	$('#unavailability_start_5i').val(moment(start).format('mm'));
        	$('#unavailability_end_1i').val(moment(end).format('YYYY'));
        	$('#unavailability_end_2i').val(moment(end).format('M'));
        	$('#unavailability_end_3i').val(moment(end).format('DD'));
        	$('#unavailability_end_4i').val(moment(end).format('HH'));
        	$('#unavailability_end_5i').val(moment(end).format('mm'));
        	$("#unavailability_nurse_id").val(window.nurseId)
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
        $.getScript(window.createAppointmentURL, function() {
        	$('#appointment_start_1i').val(moment(start).format('YYYY'));
        	$('#appointment_start_2i').val(moment(start).format('M'));
        	$('#appointment_start_3i').val(moment(start).format('DD'));
        	$('#appointment_start_4i').val(moment(start).format('HH'));
        	$('#appointment_start_5i').val(moment(start).format('mm'));
        	$('#appointment_end_1i').val(moment(end).format('YYYY'));
        	$('#appointment_end_2i').val(moment(end).format('M'));
        	$('#appointment_end_3i').val(moment(end).format('DD'));
        	$('#appointment_end_4i').val(moment(end).format('HH'));
        	$('#appointment_end_5i').val(moment(end).format('mm'));
        	$("#appointment_patient_id").val(window.patientId)
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

var initialize_calendar;
initialize_calendar = function() {
  $('.calendar').each(function(){
    var calendar = $(this);
    calendar.fullCalendar({
      schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
      defaultView: 'agendaDay',
      locale: 'ja',
      validRange: {
        start: window.validRangeStart,
        end: window.validRangeEnd,
      },
      minTime: '07:00:00',
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
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



      select: function(start, end, resource) {
      	$.getScript(window.createAppointmentURL, function() {
      		$('#appointment_start_1i').val(moment(start).format('YYYY'));
      		$('#appointment_start_2i').val(moment(start).format('M'));
      		$('#appointment_start_3i').val(moment(start).format('DD'));
      		$('#appointment_start_4i').val(moment(start).format('HH'));
      		$('#appointment_start_5i').val(moment(start).format('mm'));
      		$('#appointment_end_1i').val(moment(end).format('YYYY'));
      		$('#appointment_end_2i').val(moment(end).format('M'));
      		$('#appointment_end_3i').val(moment(end).format('DD'));
      		$('#appointment_end_4i').val(moment(end).format('HH'));
      		$('#appointment_end_5i').val(moment(end).format('mm'));
      		$('#appointment_nurse_id').val(resource.id)
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
$(document).on('turbolinks:load', initialize_nurse_calendar); 
$(document).on('turbolinks:load', initialize_patient_calendar); 

$(document).on('turbolinks:load', initialize_calendar); 