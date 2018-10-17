class DashboardController < ApplicationController
  before_action :set_corporation

  def index
    @plannings = @corporation.plannings.where(archived: false).order(created_at: :desc)
    @activities = PublicActivity::Activity.where(planning_id: @plannings.ids, created_at: current_user.last_sign_in_at..current_user.current_sign_in_at)
    @unseen_activity_count = @activities.count
    if @unseen_activity_count == 0
      @activities = PublicActivity::Activity.where(planning_id: @plannings.ids).last(5)
    end
    @appointments = Appointment.where(planning_id: @plannings.ids, starts_at: Date.today.beginning_of_day..Date.today.end_of_day, master: false, displayable: true, deactivated: false).includes(:patient, :nurse).order(starts_at: :asc).group_by {|appointment| appointment.nurse_id}
  end

  private

  def set_corporation
    @corporation = current_user.corporation
  end
end
