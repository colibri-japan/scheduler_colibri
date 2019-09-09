import { Controller } from "stimulus"

import { Calendar } from '@fullcalendar/core'
import interactionPlugin from '@fullcalendar/interaction'
import dayGridPlugin from '@fullcalendar/daygrid'
import timeGridPlugin from '@fullcalendar/timegrid'
import listPlugin from '@fullcalendar/list'

import '@fullcalendar/core/main.css';
import '@fullcalendar/daygrid/main.css';
import '@fullcalendar/timegrid/main.css';
import '@fullcalendar/list/main.css';



export default class extends Controller {

    static targets = [ 'resourceName' ]
    
    connect() {
        console.log('connected')
        this.getCalendar().render()
        this.initializeResource()
    }

    disconnect() {
        console.log('disconnected')
        this.getCalendar().destroy()
    }

    navigate(event) {
        let selectedEl = document.getElementsByClassName('resource-selected')
        for (let el of selectedEl) {
            el.classList.remove('resource-selected')
        }
        event.target.classList.add('resource-selected')
        this.resourceNameTarget.textContent = event.target.textContent
    }

    getCalendar() {
        let calendarEl = document.getElementById('nurse-calendar')

        let calendar = new Calendar(calendarEl, {
            plugins: [interactionPlugin, timeGridPlugin],
            defaultView: 'timeGridWeek'
        })

        return calendar
    }

    initializeResource() {
        let resourceType = window.currentResourceType || window.defaultResourceType
        let resourceId = window.currentResourceType || window.defaultResourceId

        let selectedItem = document.getElementById(`${resourceType}_${resourceId}`)
        selectedItem.classList.add('resource-selected')

        return
    }
}