import { Controller } from "stimulus"

import { Calendar } from '@fullcalendar/core'
import interactionPlugin from '@fullcalendar/interaction'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import resourcePlugin from '@fullcalendar/resource-common'
import resourceTimeGridPlugin from '@fullcalendar/resource-timegrid'
import resourceTimelinePlugin from '@fullcalendar/resource-timeline'
import jaLocale from '@fullcalendar/core/locales/ja'


import '@fullcalendar/core/main.css';
import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';
import '@fullcalendar/timeline/main.css';
import '@fullcalendar/resource-timeline/main.css';

let resourceHeader = {
    left: 'prev,next today',
    center: 'title',
    right: 'resourceTimeGridDay,resourceTimelineWeek'
}

let header = {
    left: 'prev,next today',
    center: 'title',
    right: 'timeGridDay,timeGridWeek,dayGridMonth'
}

let calendarEl = document.getElementById('calendar')

window.fullCalendar = new Calendar(calendarEl, {
    plugins: [interactionPlugin, timeGridPlugin, dayGridPlugin, resourcePlugin, resourceTimeGridPlugin, resourceTimelinePlugin],
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
    firstDay: window.firstDay,
    slotDuration: '00:15:00',
    timeFormat: 'H:mm',
    nowIndicator: true,
    defaultView: window.defaultView,
    locale: jaLocale,
    header: header,
    eventColor: '#7AD5DE',
    selectable: true,
    minTime: window.minTime,
    maxTime: window.maxTime,
    refetchResourcesOnNavigate: true,
    displayEventEnd: true,
    height: function() {
        return (screen.height - 240)
    },
    views: {
        'timeGrid': {
            slotLabelFormat: {hour: 'numeric', minute: '2-digit'},
        },
        'dayGrid': {
            slotLabelFormat: {day: 'numeric'},
        },
        'resourceTimeGridDay': {
            resourceLabelText: window.resourceLabel
        },
        'resourceTimelineWeek': {
            slotDuration: {days: 1},
            resourceAreaWidth: '10%',
            resourceLabelText: window.resourceLabel
        }
    },

    viewSkeletonRender: function(info) {
        drawHourMarks()
        makeTimeAxisPrintFriendly()
    },

    resources: function (fetchInfo, successCallback, failureCallback) {
        let connector = window.resourceUrl.indexOf('?') === -1 ? '?' : '&'
        let url = `${window.resourceUrl}${connector}start=${moment(fetchInfo.start).format('YYYY-MM-DD HH:mm')}&end=${moment(fetchInfo.end).format('YYYY-MM-DD HH:mm')}`
        $.getScript(url).then(data => successCallback($.parseJSON(data)))
    },

    eventSources: [
        {
            events: function (fetchInfo, successCallback, failureCallback) {
                let url1 = window.eventsUrl1
                let data = {};
                data['start'] = moment(fetchInfo.start).format('YYYY-MM-DD HH:mm')
                data['end'] = moment(fetchInfo.end).format('YYYY-MM-DD HH:mm')
                if (window.currentResourceId !== 'all') {
                    let resourceArgument = `${window.currentResourceType}_id`
                    data[resourceArgument] = window.currentResourceId
                }
                $.ajax({
                    url: url1,
                    type: 'GET',
                    data: data
                }).then(data => successCallback(data))
            },
            id: 'url1'
        }
    ], 

    eventRender: function(info) {
        if (info.event.extendedProps.cancelled) {
            info.el.style.backgroundImage = 'repeating-linear-gradient(45deg, #FFBFBF, #FFBFBF 5px, #FF8484 5px, #FF8484 10px)'
        } else if (info.event.extendedProps.edit_requested) {
            info.el.style.backgroundImage = 'repeating-linear-gradient(45deg, #C8F6DF, #C8F6DF 5px, #99E6BF 5px, #99E6BF 10px)'
        }
    },
    
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
            setAppointmentRange(selectStart, selectEnd, info.view);
            setPrivateEventRange(selectStart, selectEnd, info.view);
            appointmentSelectizeNursePatient();
            privateEventSelectizeNursePatient();
        });
        
        this.unselect()
    }
})



let dateFormatter = new Intl.DateTimeFormat('sv-SE')

let drawHourMarks = () => {
    $('tr*[data-time="09:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="12:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="15:00:00"]').addClass('thick-calendar-line');
    $('tr*[data-time="18:00:00"]').addClass('thick-calendar-line');
}

let makeTimeAxisPrintFriendly = () => {
    $('tr[data-time] > td > span').addClass('bolder-calendar-time-axis')
}

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

let updateCalendarHeader = () => {
    if (window.currentResourceType === 'team' ||(window.currentResourceType === 'nurse' && window.currentResourceId === 'all') || (window.currentResourceType === 'patient' && window.currentResourceId === 'all')) {
        window.fullCalendar.setOption('header', resourceHeader)
    } else {
        window.fullCalendar.setOption('header', header)
    }
}

let toggleResourceView = () => {
    let currentView = window.fullCalendar.view
    if (window.currentResourceType === 'team' || (window.currentResourceType === 'nurse' && window.currentResourceId === 'all') || (window.currentResourceType === 'patient' && window.currentResourceId === 'all')) {
        if (['timeGridDay', 'timeGridWeek', 'dayGridMonth'].includes(currentView.type)) {
            window.fullCalendar.changeView(window.defaultResourceView)
            drawHourMarks()
        }
    } else {
        if (['resourceTimeGridDay', 'resourceTimelineWeek'].includes(currentView.type)) {
            window.fullCalendar.changeView(window.defaultView)
            drawHourMarks()
        }
    }
}


let updateEventSources = () => {
    let eventSources = window.fullCalendar.getEventSources()
    
    for (let source of eventSources) {
        if (source.id !== 'url1') {
            source.remove()
        }
    }


    let remainingEvents = window.fullCalendar.getEvents()
    for (let event of remainingEvents) {
        event.remove()
    }

    return
}

export default class extends Controller {

    static targets = [ 'resourceName' ]
    
    connect() {
        window.fullCalendar.render()
        this.initializeResource()
    }

    disconnect() {
        window.fullCalendar.destroy()
    }

    navigate(event) {
        let selectedEl = document.getElementsByClassName('resource-selected')
        for (let el of selectedEl) {
            el.classList.remove('resource-selected')
        }
        event.target.classList.add('resource-selected')

        window.currentResourceType = event.target.dataset.resourceType
        window.currentResourceId = event.target.dataset.resourceId
        window.resourceLabel = window.currentResourceType === 'patient' ? '利用者' : '従業員'

        updateCalendarHeader()
        toggleResourceView()

        let fcResources = window.fullCalendar.getResources()
        for (let resource of fcResources) {
            resource.remove()
        }

        if (event.target.dataset.fcResourceUrl) {
            window.resourceUrl = event.target.dataset.fcResourceUrl
        }

        updateEventSources(event)
              
        window.fullCalendar.refetchResources()
        window.fullCalendar.refetchEvents()

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