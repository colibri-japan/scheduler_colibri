class CalendarEventsController < ApplicationController

  before_action :set_corporation

  def new
    @private_event = PrivateEvent.new 
    @appointment = Appointment.new 

    @planning = @corporation.planning
    @nurses = @corporation.nurses.displayable.order_by_kana
    @patients = @corporation.patients.active.order_by_kana
    @services = @corporation.cached_most_used_services_for_select
  end

  private 

  def set_corporation 
    @corporation = Corporation.cached_find(current_user.corporation_id)
  end
  
end
