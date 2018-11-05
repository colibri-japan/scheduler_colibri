class PlanningsController < ApplicationController

	before_action :set_corporation
	before_action :set_planning, only: [:show, :destroy, :master, :archive, :master_to_schedule, :duplicate_from, :duplicate, :settings, :payable]
	before_action :set_nurses, only: [:show]
	before_action :set_patients, only: [:show, :master]

	def index
		@plannings = @corporation.plannings.where(archived: false)
	end

	def show
		authorize @planning, :is_employee?
		authorize @planning, :is_not_archived?

		set_valid_range
		@last_patient = @patients.last
		@last_nurse = @nurses.last
		@activities = PublicActivity::Activity.where(planning_id: @planning.id).includes(:owner, {trackable: :nurse}, {trackable: :patient}).order(created_at: :desc).limit(6)
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

	def master_to_schedule
		authorize @planning, :is_employee?
		authorize current_user, :is_admin?

		CopyPlanningFromMasterWorker.perform_async(@planning.id)

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

		@full_timers = @corporation.nurses.displayable.full_timers
		@part_timers = @corporation.nurses.displayable.part_timers

		#data needed to show mashup of this month's salary
		#what has been accomplished service wise, and counts/hours provided for each nurse
	end

	def archive
		if @planning.update(archived: true)
			redirect_to root_path, notice: 'スケジュールが削除されました。'
		end
	end

	def master
		authorize @planning, :is_employee?

		@full_timers = @corporation.nurses.where(full_timer: true, displayable: true).order_by_kana
    	@part_timers = @corporation.nurses.where(full_timer: false, displayable: true).order_by_kana

		@last_patient = @patients.last
    	@last_nurse = @full_timers.present? ? @full_timers.last : @part_timers.last
		@patients_firstless = @patients - [@patients.first]

		set_valid_range
		@admin = current_user.admin.to_s
	end

	def settings 
		@services = @corporation.services.without_nurse_id.order_by_title
		@last_nurse = @corporation.nurses.where(displayable: true).last
	end


	private

	def set_corporation
		@corporation = Corporation.find(current_user.corporation_id)
	end

	def set_planning
		@planning = Planning.find(params[:id])
	end

	def set_valid_range
		@start_valid = Date.new(@planning.business_year, @planning.business_month, 1).strftime("%Y-%m-%d")
	end

	def set_nurses
		@nurses = @corporation.nurses.order_by_kana
	end

	def set_patients
		@patients = @corporation.patients.active.order_by_kana
	end

	def planning_params
		params.require(:planning).permit(:business_month, :business_year, :title)
	end



end
