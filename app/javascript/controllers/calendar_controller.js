import { Controller } from "stimulus"

import { Calendar } from '@fullcalendar/core'
import interactionPlugin from '@fullcalendar/interaction'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import bootstrapPlugin from '@fullcalendar/bootstrap'


import '@fullcalendar/core/main.css';
import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';

let calendarEl = document.getElementById('nurse-calendar')

let calendar = new Calendar(calendarEl, {
    plugins: [interactionPlugin, timeGridPlugin, dayGridPlugin, bootstrapPlugin],
    schedulerLicenseKey: 'GPL-My-Project-Is-Open-Source',
    firstDay: window.firstDay,
    themeSystem: 'unthemed',
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
    minTime: window.minTime,
    maxTime: window.maxTime,

    events: '/plannings/62/appointments?nurse_id=39'
})

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
        let resourceId = window.currentResourceType || window.defaultResourceId

        let selectedItem = document.getElementById(`${resourceType}_${resourceId}`)
        selectedItem.classList.add('resource-selected')

        this.resourceNameTarget.textContent = selectedItem.textContent

        return
    }
}