class DashboardController < ApplicationController
  before_action :set_corporation
  before_action :set_main_nurse, only: :index


  def index
    @planning = @corporation.planning

    #activity module
    @activities = PublicActivity::Activity.where(planning_id: @planning.id, created_at: current_user.last_sign_in_at..current_user.current_sign_in_at).includes(:owner).limit(15)
    @unseen_activity_count = @activities.count
    if @unseen_activity_count == 0
      @activities = PublicActivity::Activity.where(planning_id: @planning.id).last(5)
    end

    #appointments : today, upcoming two weeks, since monday
    today = Date.today 
    appointments = Appointment.valid.where(planning_id: @planning.id, master: false, starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..(today + 15.days).beginning_of_day)

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

    appointments = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, master: false, starts_at: query_day.beginning_of_month.beginning_of_day..query_day.end_of_day).includes(:patient, :nurse)

    if team.present?
      appointments = appointments.where(nurse_id: team.nurses.displayable.ids)
    end

    #daily summary
    @daily_appointments = appointments.where(starts_at: query_day.beginning_of_day..query_day.end_of_day)
    @female_patients_ids = @corporation.patients.where(gender: true).ids 
    @male_patients_ids = @corporation.patients.where(gender: false).ids

    #weekly  summary, from monday to query date
    @weekly_appointments = appointments.where(starts_at: (query_day - (query_day.strftime('%u').to_i - 1).days).beginning_of_day..query_day.end_of_day)
    
    #monthly summary, until end of today
		@monthly_appointments = appointments

    #daily provided_services to be verified
    daily_provided_services = ProvidedService.where(planning_id: @planning.id, temporary: false, cancelled: false, archived_at: nil, service_date: query_day.beginning_of_day..query_day.end_of_day).from_appointments.includes(:patient, :nurse, :appointment).where(appointments: {edit_requested: false}).order(service_date: :asc)
    daily_provided_services = daily_provided_services.where(nurse_id: team.nurses.displayable.ids) if team.present?
    @daily_provided_services = daily_provided_services.group_by {|provided_service| provided_service.nurse_id}

  end

  private

  def set_main_nurse
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end
end
