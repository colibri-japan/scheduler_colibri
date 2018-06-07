class UnavailabilitiesController < ApplicationController
	before_action :set_unavailability, only: [:show, :edit, :update, :destroy]
	before_action :set_planning

	# GET /unavailabilities
	# GET /unavailabilities.json
	def index
	  if params[:nurse_id].present?
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
	  @nurses = Nurse.all
	  @patients = Patient.all
	end

	# GET /unavailabilities/1/edit
	def edit
	  @nurses = Nurse.all
	  @patients = Patient.all
	end

	# POST /unavailabilities
	# POST /unavailabilities.json
	def create
	  @unavailability = @planning.unavailabilities.create(unavailability_params)

	  respond_to do |format|
	    if @unavailability.save
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

	  def set_planning
	    @planning = Planning.find(params[:planning_id])
	  end

	  # Never trust parameters from the scary internet, only allow the white list through.
	  def unavailability_params
	    params.require(:unavailability).permit(:title, :description, :start, :end, :nurse_id, :planning_id)
	  end
end
