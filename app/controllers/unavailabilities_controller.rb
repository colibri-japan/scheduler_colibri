class UnavailabilitiesController < ApplicationController
	before_action :set_unavailability, only: [:show, :edit, :update, :destroy]
	before_action :set_planning
	before_action :set_corporation

	# GET /unavailabilities
	# GET /unavailabilities.json
	def index
	  if params[:nurse_id].present?
	  	@nurse = Nurse.find(params[:nurse_id])
	    @unavailabilities = @planning.unavailabilities.where(nurse_id: params[:nurse_id])
	  elsif params[:patient_id].present?
	  	@unavailabilities = @planning.unavailabilities.where(patient_id: params[:patient_id])
	  else
	   @unavailabilities = @planning.unavailabilities.all
	 end
	end

	# GET /unavailabilities/1
	# GET /unavailabilities/1.json
	def show
	end

	# GET /unavailabilities/new
	def new
	  @unavailability = Unavailability.new
	  @nurses = @corporation.nurses.displayable.order_by_kana
	  @patients = @corporation.patients.active.all
	end

	# GET /unavailabilities/1/edit
	def edit
	  @nurses= @corporation.nurses.all
	  @patients = @corporation.patients.where(active: true).all
	end

	# POST /unavailabilities
	# POST /unavailabilities.json
	def create
	  @unavailability = @planning.unavailabilities.new(unavailability_params)

	  respond_to do |format|
	    if @unavailability.save
	      @activity = @unavailability.create_activity :create, owner: current_user, planning_id: @planning.id, patient_id: @unavailability.patient_id
	      format.html { redirect_to @unavailability, notice: 'unavailability was successfully created.' }
	      format.js
	      format.json { render :show, status: :created, location: @unavailability }
	    else
	      format.html { render :new }
	      format.js
	      format.json { render json: @unavailability.errors, status: :unprocessable_entity }
	    end
	  end
	end

	# PATCH/PUT /unavailabilities/1
	# PATCH/PUT /unavailabilities/1.json
	def update
	  respond_to do |format|
	    if @unavailability.update(unavailability_params)
	      @activity = @unavailability.create_activity :update, owner: current_user, planning_id: @planning.id, patient_id: @unavailability.patient_id

	      format.html { redirect_to @unavailability, notice: 'unavailability was successfully updated.' }
	      format.js
	      format.json { render :show, status: :ok, location: @unavailability }
	    else
	      format.html { render :edit }
	      format.js
	      format.json { render json: @unavailability.errors, status: :unprocessable_entity }
	    end
	  end
	end

	# DELETE /unavailabilities/1
	# DELETE /unavailabilities/1.json
	def destroy
	  @activity = @unavailability.create_activity :destroy, owner: current_user, planning_id: @planning.id, patient_id: @unavailability.patient_id

	  @unavailability.destroy
	  respond_to do |format|
	    format.html { redirect_to unavailabilities_url, notice: 'unavailability was successfully destroyed.' }
	    format.json { head :no_content }
	    format.js
	  end
	end

	private
	  # Use callbacks to share common setup or constraints between actions.
	  def set_unavailability
	    @unavailability = Unavailability.find(params[:id])
	  end

	  def set_corporation
	    @corporation = Corporation.find(current_user.corporation_id)
	  end

	  def set_planning
	    @planning = Planning.find(params[:planning_id])
	  end

	  # Never trust parameters from the scary internet, only allow the white list through.
	  def unavailability_params
	    params.require(:unavailability).permit(:title, :description, :starts_at, :ends_at, :nurse_id, :patient_id, :planning_id)
	  end
end
