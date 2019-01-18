class DashboardController < ApplicationController
  before_action :set_corporation
  before_action :set_main_nurse, only: :index


  def index
    @plannings = @corporation.plannings.where(archived: false).order(created_at: :desc)

    #activity module
    @activities = PublicActivity::Activity.where(planning_id: @plannings.ids, created_at: current_user.last_sign_in_at..current_user.current_sign_in_at)
    @unseen_activity_count = @activities.count
    if @unseen_activity_count == 0
      @activities = PublicActivity::Activity.where(planning_id: @plannings.ids).last(5)
    end

    #posts
    @posts = @corporation.posts.order(created_at: :desc).limit(40)

    #appointments : today, upcoming two weeks, since monday
    today = Date.today 
    appointments = Appointment.valid.where(planning_id: @plannings.ids, master: false, starts_at: (today - (today.strftime('%u').to_i - 1).days).beginning_of_day..(today + 15.days).beginning_of_day).includes(:patient, :nurse)

    #edit requested appointments for next two weeks
    @edit_requested_appointments = appointments.where(starts_at: today.beginning_of_day..(today + 15.days).beginning_of_day, edit_requested: true).order(starts_at: :asc)

    #appointments with comments for the next two weeks
    @commented_appointments = appointments.where(starts_at: today.beginning_of_day..(today + 15.days).beginning_of_day).where.not(description: [nil, '']).order(starts_at: :asc)
  end

  def extended_daily_summary
    @plannings = @corporation.plannings.where(archived: false).order(created_at: :desc)

    query_day = params[:q].to_date
    team = Team.find(params[:team_id]) if params[:team_id] != 'undefined'

    appointments = Appointment.valid.edit_not_requested.where(planning_id: @plannings.ids, master: false, starts_at: query_day.beginning_of_month.beginning_of_day..query_day.end_of_day).includes(:patient, :nurse)

    if team.present?
      puts 'presence of team, further filter appointments'
      appointments = appointments.where(nurse_id: team.nurses.displayable.ids)
    end

    #daily summary
    @appointments_grouped_by_title = appointments.where(starts_at: query_day.beginning_of_day..query_day.end_of_day).group_by(&:title)
    @female_patients_ids = @corporation.patients.where(gender: true).ids 
    @male_patients_ids = @corporation.patients.where(gender: false).ids

    #weekly  summary, from monday to query date
    @weekly_appointments_grouped_by_title = appointments.where(starts_at: (query_day - (query_day.strftime('%u').to_i - 1).days).beginning_of_day..query_day.end_of_day).group_by(&:title)
    
    #monthly summary, until end of today
		@monthly_appointments_grouped_by_title = appointments.group_by(&:title)

    #daily provided_services to be verified
    daily_provided_services = ProvidedService.where(planning_id: @plannings.ids, temporary: false, cancelled: false, archived_at: nil, service_date: query_day.beginning_of_day..query_day.end_of_day).includes(:patient, :nurse).order(service_date: :asc)
    daily_provided_services = daily_provided_services.where(nurse_id: team.nurses.displayable.ids) if team.present?
    @daily_provided_services = daily_provided_services.group_by {|provided_service| provided_service.nurse_id}

  end

  private

  def set_corporation
    @corporation = current_user.corporation
  end

  def set_main_nurse
    @main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
  end
end
