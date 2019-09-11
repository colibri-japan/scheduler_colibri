import { Controller } from "stimulus"

import { Calendar } from '@fullcalendar/core'
import interactionPlugin from '@fullcalendar/interaction'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'


import '@fullcalendar/core/main.css';
import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';



let calendarEl = document.getElementById('calendar')

let calendar = new Calendar(calendarEl, {
    plugins: [interactionPlugin, timeGridPlugin, dayGridPlugin],
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
    firstDay: window.firstDay,
    slotDuration: '00:15:00',
    timeFormat: 'H:mm',
    nowIndicator: true,
    defaultView: 'timeGridWeek',
    locale: 'ja',
    header: {
        left: 'prev,next today',
        center: 'title',
        right: 'timeGridDay,timeGridWeek,dayGridMonth'
    },
    eventColor: '#7AD5DE',
    selectable: true,
    minTime: window.minTime,
    maxTime: window.maxTime,

    events: '/plannings/62/appointments?nurse_id=39',

    eventClick: function(info) {
        if (window.userAllowedToEdit) {
            let dateClicked = dateFormatter.format(info.event.start)
            $.getScript(info.event.extendedProps.edit_url + '?date=' + dateClicked);
        }
    },

    select: function(info) {
        let selectEnd = info.end 
        let selectStart = info.start
        if (selectEnd - selectStart <= 900000) {
            selectEnd.setMinutes(selectStart.getMinutes() + 30)
        }
        $.getScript(window.selectActionUrl, function () {
            console.log(info.view)
            console.log(info.view.type)
            console.log(info.view.name)
            setAppointmentRange(selectStart, selectEnd, info.view);
            setPrivateEventRange(selectStart, selectEnd, info.view);
            appointmentSelectizeNursePatient();
            privateEventSelectizeNursePatient();
        });

        calendar.unselect()
    }
})

let dateFormatter = new Intl.DateTimeFormat('sv-SE')

let setWishedSlotRange = (start, end, view) => {
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
    if (window.currentResourceType === 'nurse' && window.currentResourceId !== 'all') {
        $("#wished_slot_nurse_id").val(window.nurseId);
    }
}

let setPrivateEventRange = (start, end, view) => {
    $('#private_event_starts_at_1i').val(moment(start).format('Y'));
    $('#private_event_starts_at_2i').val(moment(start).format('M'));
    $('#private_event_starts_at_3i').val(moment(start).format('D'));
    $('#private_event_starts_at_4i').val(moment(start).format('HH'));
    $('#private_event_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'timelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
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
    if (window.currentResourceType === 'nurse' && window.currentResourceId && window.currentResourceId !== 'all') {
        $("#private_event_nurse_id").val(window.currentResourceId);
    }
    if (window.currentResourceType === 'patient' && window.currentResourceId && window.currentResourceId !== 'all') {
        $("#private_event_patient_id").val(window.currentResourceId);
    }

}

let setAppointmentRange = (start, end, view) => {
    $('#appointment_starts_at_1i').val(moment(start).format('YYYY'));
    $('#appointment_starts_at_2i').val(moment(start).format('M'));
    $('#appointment_starts_at_3i').val(moment(start).format('D'));
    $('#appointment_starts_at_4i').val(moment(start).format('HH'));
    $('#appointment_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'timelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
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
    if (window.currentResourceType === 'nurse' && window.currentResourceId && window.currentResourceId !== 'all') {
        $("#appointment_nurse_id").val(window.currentResourceId);
    }
    if (window.currentResourceType === 'patient' && window.currentResourceId && window.currentResourceId !== 'all') {
        $("#appointment_patient_id").val(window.currentResourceId);
    }
}

let setRecurringAppointmentRange = (start, end, resource, view) => {
    $('#recurring_appointment_anchor_1i').val(moment(start).format('YYYY'));
    $('#recurring_appointment_anchor_2i').val(moment(start).format('M'));
    $('#recurring_appointment_anchor_3i').val(moment(start).format('D'));
    $('#recurring_appointment_starts_at_4i').val(moment(start).format('HH'));
    $('#recurring_appointment_starts_at_5i').val(moment(start).format('mm'));
    if (['dayGridMonth', 'timelineWeek'].includes(view.type) && moment(start).add(1, 'day').format('YYYY-MM-DD') === moment(end).format('YYYY-MM-DD')) {
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
    if (window.currentResourceType === 'nurse' && window.currentResourceId && window.currentResourceId !== 'all') {
        $('#recurring_appointment_nurse_id').val(window.currentResourceId);
    }
    if (window.currentResourceType === 'patient' && window.currentResourceId && window.currentResourceId !== 'all') {
        $('#recurring_appointment_patient_id').val(window.currentResourceId);
    }
}

export default class extends Controller {

    static targets = [ 'resourceName' ]
    
    connect() {
        calendar.render()
        this.initializeResource()
    }

    disconnect() {
        calendar.destroy()
    }

    navigate(event) {
        let selectedEl = document.getElementsByClassName('resource-selected')
        for (let el of selectedEl) {
            el.classList.remove('resource-selected')
        }
        event.target.classList.add('resource-selected')

        window.currentResourceType = event.target.dataset.resourceType
        window.currentResourceId = event.target.dataset.resourceId

        let eventSources = calendar.getEventSources()

        for (let source of eventSources) {
            source.remove()
        }
        
        calendar.addEventSource(`${window.appointmentsUrl}?${window.currentResourceType}_id=${window.currentResourceId}`)
        calendar.refetchEvents()

        this.resourceNameTarget.textContent = event.target.textContent
    }

    initializeResource() {
        let resourceType = window.currentResourceType || window.defaultResourceType
        let resourceId = window.currentResourceId || window.defaultResourceId

        let selectedItem = document.getElementById(`${resourceType}_${resourceId}`)

        selectedItem.classList.add('resource-selected')

        this.resourceNameTarget.textContent = selectedItem.textContent

        return
    }
}