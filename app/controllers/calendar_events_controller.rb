class CalendarEventsController < ApplicationController

  before_action :set_corporation
  before_action :set_planning
  before_action :fetch_patients

  def new
    @private_event = PrivateEvent.new 
    @appointment = Appointment.new 

    @grouped_nurses_for_select = @corporation.cached_nurses_grouped_by_fulltimer_for_select
    @services_with_recommendations = @corporation.cached_most_used_services_for_select

    respond_to do |format|
      format.js
      format.js.phone
    end
  end

end
