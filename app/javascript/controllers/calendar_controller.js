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
    
    connect() {
        console.log('connected')
        this.getCalendar().destroy()
        this.getCalendar().render()
    }

    disconnect() {
        console.log('disconnected')
        this.getCalendar().destroy()
    }

    getCalendar() {
        let calendarEl = document.getElementById('nurse-calendar')

        let calendar = new Calendar(calendarEl, {
            plugins: [interactionPlugin, timeGridPlugin],
            defaultView: 'timeGridWeek'
        })

        return calendar
    }
}