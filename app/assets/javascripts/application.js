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
//= require scheduler
//= require_tree .

var initialize_nurse_calendar;
initialize_nurse_calendar = function(){
  $('.weekly_calendar').each(function(){
    var nurse_calendar = $(this);
    nurse_calendar.fullCalendar({
      defaultView: 'agendaWeek',
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
        $.getScript(window.createAppointmentURL, function() {});

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
      header: {
        left: 'prev,next today',
        center: 'title',
        right: 'month,agendaWeek,agendaDay'
      },
      selectable: true,
      selectHelper: true,
      editable: true,
      eventLimit: true,

      resources: {
        url: window.corporationNursesURL,
      }, 

      eventSources: [ window.appointmentsURL, window.recurringAppointmentsURL],



      select: function(start, end) {
        $.getScript(window.createAppointmentURL, function() {});

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

$(document).on('turbolinks:load', initialize_calendar); 