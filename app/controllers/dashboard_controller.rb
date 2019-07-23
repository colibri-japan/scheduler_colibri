class DashboardController < ApplicationController
  before_action :set_corporation
  before_action :set_main_nurse, only: :index


  def index
    @planning = @corporation.planning

    #appointments : today, upcoming two weeks, since monday
    today = Date.today 
    appointments = Appointment.not_archived.not_cancelled.where(planning_id: @planning.id, starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..(today + 15.days).beginning_of_day)

    #edit requested appointments for next two weeks
    @current_user_team = Team.find(current_user.nurse.team_id) if current_user.nurse.present? && current_user.nurse.team.present?

    @edit_requested_appointments = appointments.includes(:patient, :nurse).where(starts_at: today.beginning_of_day..(today + 15.days).beginning_of_day, edit_requested: true).order(starts_at: :asc)
    @edit_requested_appointments = @edit_requested_appointments.where(nurse_id: @current_user_team.nurses.ids) if @current_user_team.present?
    #appointments with comments for the next two weeks
    @commented_appointments = appointments.includes(:patient, :nurse).where(starts_at: today.beginning_of_day..(today + 15.days).beginning_of_day).where.not(description: [nil, '']).order(starts_at: :asc)

    respond_to do |format|
      format.html
      format.js
    end
  end

  def extended_daily_summary
    @planning = @corporation.planning

    query_day = params[:q].to_date
    team = Team.find(params[:team_id]) if params[:team_id] != 'undefined'

    appointments = Appointment.operational.where(planning_id: @planning.id, starts_at: query_day.beginning_of_month.beginning_of_day..query_day.end_of_day).includes(:patient, :nurse)

    if team.present?
      appointments = appointments.where(nurse_id: team.nurses.displayable.ids)
    end

    #daily summary
    @daily_appointments = appointments.in_range(query_day.beginning_of_day..query_day.end_of_day).includes(:verifier, :second_verifier).order('nurse_id, starts_at desc')
    @female_patients_ids = @corporation.patients.female.ids 
    @male_patients_ids = @corporation.patients.male.ids

    #weekly  summary, from monday to query date
    @weekly_appointments = appointments.where(starts_at: (query_day - (query_day.strftime('%u').to_i - 1).days).beginning_of_day..query_day.end_of_day)
    
    #monthly summary, until end of today
		@monthly_appointments = appointments
  end

  private

  def set_main_nurse
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end
end
