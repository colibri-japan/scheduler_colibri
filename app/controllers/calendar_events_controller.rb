class CalendarEventsController < ApplicationController

  before_action :set_corporation

  def new
    @private_event = PrivateEvent.new 
    @appointment = Appointment.new 

    @planning = @corporation.planning
    @nurses = @corporation.nurses.not_archived.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
    @services_with_recommendations = @corporation.cached_most_used_services_for_select
  end

  private 

  
end
