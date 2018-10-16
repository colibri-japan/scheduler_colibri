class DashboardController < ApplicationController
  before_action :set_corporation

  def index
    @plannings = @corporation.plannings.where(archived: false)
    @appointments = Appointment.where(planning_id: @plannings.ids, starts_at: Date.today.beginning_of_day..Date.today.end_of_day, master: false, displayable: true, deactivated: false).includes(:patient, :nurse).order(starts_at: :asc).group_by {|appointment| appointment.nurse_id}
  end

  private

  def set_corporation
    @corporation = current_user.corporation
  end
end
