class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master, :archive, :new_master_to_schedule, :master_to_schedule, :duplicate_from, :duplicate, :settings, :payable]
	before_action :set_nurses, only: :show
	before_action :set_patients, only: [:show, :master]
	before_action :set_main_nurse, only: [:show, :settings]

	def index
		@plannings = @corporation.plannings.where(archived: false)
	end

	def show
		authorize @planning, :is_employee?
		authorize @planning, :is_not_archived?
	end

	def new
		if @corporation.nurses.count < 2
			redirect_to nurses_path, notice: 'スケジュールを作成する前にヘルパーを追加してください'
		elsif @corporation.patients.empty?
			redirect_to patients_path, notice: 'スケジュールを作成する前に利用者を追加してください'
		else
			@planning = Planning.new
		end
	end

	def create
		@planning = Planning.new(planning_params)
		@planning.corporation_id = current_user.corporation_id

		respond_to do |format|
			if @planning.save
				format.html { redirect_to planning_duplicate_from_path(@planning), notice: 'スケジュールがセーブされました'}
				format.js
			else
				format.html { render :new }
				format.js
			end
		end
	end

	def new_master_to_schedule
		authorize current_user, :has_admin_access?
	end

	def master_to_schedule
		authorize @planning, :is_employee?
		authorize current_user, :has_admin_access?

		
        puts 'params'
        puts params[:month]
        puts params[:year]

		CopyPlanningFromMasterWorker.perform_async(@planning.id, params[:month], params[:year])

	    redirect_to @planning, notice: 'マスタースケジュールが全体へ反映されてます。数秒後にリフレッシュしてください'
	end

	def duplicate_from
		@plannings = @corporation.plannings.where(archived: false) - [@planning]
	end

	def duplicate
		template_planning = Planning.find(params[:template_id])
		authorize template_planning, :is_employee?

		DuplicatePlanningWorker.perform_async(template_planning.id, @planning.id)

		redirect_to planning_nurse_master_path(@planning, @corporation.nurses.where(displayable: true).first), notice: 'サービスが新しいスケジュールへコピーされてます。数十秒後にリフレッシュしてください。'
	end

	def destroy
	  authorize @planning, :is_employee?

	  @planning.destroy
	  respond_to do |format|
	    format.html { redirect_to plannings_url, notice: 'サービスなどを含めて、スケジュールが削除されました。' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	def payable
		@nurse = @corporation.nurses.displayable.order_by_kana.first 

		fetch_nurses_grouped_by_team

		first_day = DateTime.new(params[:y].to_i, params[:m].to_i, 1, 0,0)
		last_day_of_month = DateTime.new(params[:y].to_i, params[:m].to_i, -1, 23, 59)
		last_day = Date.today.end_of_day > last_day_of_month ? last_day_of_month : Date.today.end_of_day

		@provided_services_till_today = ProvidedService.joins(:nurse).where(planning_id: @planning.id, cancelled: false, archived_at: nil, service_date: first_day..last_day)

		#shintai vs seikatsu
		@provided_services_shintai = @provided_services_till_today.where('title LIKE ? ', '%身%').sum(:total_wage)
		@provided_services_seikatsu = @provided_services_till_today.where('title LIKE ?', '%生%').sum(:total_wage)

    	#appointments : since beginning of month
		today = Date.today 
        appointments = Appointment.valid.edit_not_requested.where(planning_id: @planning.id, master: false, starts_at: first_day..last_day).includes(:patient, :nurse)

	    #daily summary
    	@daily_appointments = appointments.where(starts_at: last_day.beginning_of_day..last_day)
    	@female_patients_ids = @corporation.patients.where(gender: true).ids
    	@male_patients_ids = @corporation.patients.where(gender: false).ids
		
    	#weekly summary, from monday to today
    	@weekly_appointments = appointments.where(starts_at: (last_day - (last_day.strftime('%u').to_i - 1).days).beginning_of_day..last_day)

		#monthly summary, until end of today
		@monthly_appointments = appointments

    	#daily provided_services to be verified
    	@daily_provided_services = ProvidedService.where(planning_id:  @planning.id, temporary: false, cancelled: false, archived_at: nil, service_date: last_day.beginning_of_day..last_day).includes(:patient, :nurse).order(service_date: :asc).group_by {|provided_service| provided_service.nurse_id}
	end

	def archive
		if @planning.update(archived: true)
			redirect_to authenticated_root_path, notice: 'スケジュールが削除されました。'
		end
	end

	def master
		authorize @planning, :is_employee?

		@full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    	@part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana

		@last_patient = @patients.last
    	@last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last
		@patients_firstless = @patients - [@patients.first]

		@admin = current_user.has_admin_access?.to_s
	end

	def settings 
		fresh_when etag: @corporation, last_modified: @corporation.updated_at
	end

	def monthly_general_report
		@planning = Planning.find(params[:id])
		@provided_services = @planning.provided_services.where(temporary: false, archived_at: nil, cancelled: false, provided: true, countable: false).includes(:nurse, :appointment)
		@service_types = @provided_services.order(:title).map{|p| p.title }.uniq
		@nurses = @corporation.nurses.displayable
		@service_counts_grouped_by_nurse = {}
		@nurses.each do |nurse|
			nurse_services = @provided_services.where(nurse_id: nurse.id)
			sub_hash = {}
			@service_types.each do |type|
				sub_hash[type] = nurse_services.where(title: type).count
			end
			@service_counts_grouped_by_nurse[nurse.name] = sub_hash
		end

		puts @service_counts_grouped_by_nurse
		
		respond_to do |format|
			format.xlsx { response.headers['Content-Disposition'] = 'attachment; filename="給与詳細.xlsx"'}
		end
	end


	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_nurses
		@nurses = @corporation.nurses.order_by_kana
	end

	def set_patients
		@patients = @corporation.patients.active.order_by_kana
	end

	def set_main_nurse
		@main_nurse = current_user.nurse ||= @corporation.nurses.displayable.order_by_kana.first
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end

	
	def fetch_nurses_grouped_by_team
		@nurses = @corporation.nurses.displayable.order_by_kana
		if @corporation.teams.any?
			@team_name_by_id = @corporation.teams.pluck(:id, :team_name).to_h
			puts @team_name_by_id
			@grouped_nurses = @nurses.group_by {|nurse| @team_name_by_id[nurse.team_id] }
		else
			nurses_grouped_by_full_timer = @nurses.group_by {|nurse| nurse.full_timer}
			full_timers = nurses_grouped_by_full_timer[true] ||= []
			part_timers = nurses_grouped_by_full_timer[false] ||= []
			@grouped_nurses = {'正社員' => full_timers, '非正社員' => part_timers }
		end
	end

end
