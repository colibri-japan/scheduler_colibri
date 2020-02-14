class CalendarEventsController < ApplicationController

  before_action :set_corporation

  def new
    @private_event = PrivateEvent.new 
    @appointment = Appointment.new 

    @planning = @corporation.planning
    @grouped_nurses_for_select = @corporation.cached_nurses_grouped_by_fulltimer_for_select
    @patients = @corporation.cached_active_patients_ordered_by_kana
    @services_with_recommendations = @corporation.cached_most_used_services_for_select

    respond_to do |format|
      format.js
      format.js.phone
    end
  end

end
