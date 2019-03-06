class WishedSlotsController < ApplicationController
	before_action :set_recurring_unavailability, only: [:show, :edit, :update, :destroy]
	before_action :set_planning
	before_action :set_corporation

	# GET /wished_slots
	# GET /wished_slots.json
	def index
	end

	# GET /wished_slots/1
	# GET /wished_slots/1.json
	def show
	end

	# GET /wished_slots/new
	def new
	end

	# GET /wished_slots/1/edit
	def edit
	end

	# POST /wished_slots
	# POST /wished_slots.json
	def create
	end

	# PATCH/PUT /wished_slots/1
	# PATCH/PUT /wished_slots/1.json
	def update
	end

	# DELETE /wished_slots/1
	# DELETE /wished_slots/1.json
	def destroy
	end

	private
	  # Use callbacks to share common setup or constraints between actions.
	  def set_wished_slot
	    @wished_slot = WishedSlot.find(params[:id])
	  end

  	def set_corporation
  	  @corporation = Corporation.cached_find(current_user.corporation_id)
  	end

	  def set_planning
	    @planning = Planning.find(params[:planning_id])
	  end

	  # Never trust parameters from the scary internet, only allow the white list through.
	  def wished_slot_params
	    params.require(:wished_slot).permit(:title, :anchor, :description, :starts_at, :ends_at, :frequency, :nurse_id, :planning_id, :end_day)
	  end
end
